import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../exceptions/http.dart';
import '../exceptions/location.dart';
import '../models/fetch_context.dart';
import '../models/fountains.dart';
import '../providers/fountains_provider.dart';
import '../providers/internet_provider.dart';
import '../providers/location_provider.dart';
import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../services/fountains_service.dart';
import '../services/location_service.dart';
import '../styles/app_styles.dart';
import '../utils/location.dart';
import '../utils/logger.dart';
import '../utils/message.dart';
import '../widgets/connection_status.dart';
import '../widgets/localization.dart';
import '../widgets/location_usage_dialog.dart';
import '../widgets/map/compass_button.dart';
import '../widgets/map/location_button.dart';
import '../widgets/map/map_controller.dart';
import '../widgets/map/openstreetmap.dart';
import '../widgets/map/openstreetmap_controller.dart';
import '../widgets/skeleton_container.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with Localization, WidgetsBindingObserver {
  static const Location _defaultLocation = Location(40, 0);

  late FountainsProvider _fountainsProvider;
  final FountainsService _fountainsService = FountainsService();

  late LocationProvider _locationProvider;
  LocationService get _locationService => _locationProvider.locationService;

  late InternetProvider _internetProvider;

  /// Map controller
  late AbstractMapController _mapController;

  /// Load map after permissions requested
  bool _initialized = false;
  bool _mapLoaded = false;
  bool _isRequestingPermissions = false;
  bool _isLoadingLocation = false;

  /// Map initial location
  Location? _initialLocation;

  /// Center map on location updates
  bool _autoCenter = true;

  /// Fetch fountains with some delay after moving the map
  Timer? _fetchDebounce;

  /// Fetch when screen size changes
  Size? _currentScreenSize;

  /// Latest fetch bounding box context
  FetchContext? _lastFetchContext;

  /// Some requests may happen simultaneously for different bounding boxes
  final Map<FetchContext, Timer> _fetchingContexts = {};

  /// Whether the user opened app settings to enable permissions
  bool _openedSettings = false;

  /// Message to open the location app settings
  SnackBarController? _locationSettingsMessage;

  /// Message if the bounding box for the current zoom level is too big to fetch data
  SnackBarController? _zoomMessage;

  /// Message while fetching the current location
  SnackBarController? _loadingLocationMessage;
  Timer? _loadingLocationMessageTimer;

  /// Message while fetching fountains
  SnackBarController? _loadingFountainsMessage;

  /// Key to the connection status to show connection status messages in this screen
  final GlobalKey<ConnectionStatusState> _connectionStatusKey =
      GlobalKey<ConnectionStatusState>();

  @override
  void initState() {
    super.initState();
    _mapController = OpenStreetMapController()
      ..onMapMoveStart = _onMapMoveStart
      ..onMapMoveUpdate = _onMapMoveUpdate
      ..onMapMoveEnd = _onMapMoveEnd;
    _fountainsProvider = context.read<FountainsProvider>();
    _internetProvider = context.read<InternetProvider>();
    _locationProvider = context.read<LocationProvider>();
    _locationProvider.addListener(_onNewPosition);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    _onScreenSizeChanged();
    _checkLocationPermissions();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _fetchDebounce?.cancel();
    _internetProvider.stopInternetStatusUpdates();
    _locationProvider.removeListener(_onNewPosition);
    _locationProvider.stopLocationUpdates();
    _locationProvider.stopLocationServiceStatusUpdates();
    _loadingLocationMessageTimer?.cancel();
    _loadingLocationMessage?.close();
    _loadingFountainsMessage?.close();
    _locationSettingsMessage?.close();
    _zoomMessage?.close();
    _fetchingContexts.values.forEach((f) => f.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_openedSettings && state == AppLifecycleState.resumed) {
      // Back from settings
      _openedSettings = false;
      _updateCurrentLocation(override: true);
    }
  }

  /// Called when a new position is notified by [LocationProvider]
  void _onNewPosition() {
    if (_autoCenter) {
      final Position? newPosition = _locationProvider.userPosition;

      if (newPosition != null) {
        _centerMap(newPosition.toLocation());
      }
    }
  }

  /// Center map to [location]
  void _centerMap(final Location location) {
    if (!_mapLoaded || !mounted) return;

    final zoom = _mapController.currentZoom < _mapController.minZoomFetch
        ? _mapController.defaultZoom
        : _mapController.currentZoom;

    setState(() {
      _mapController.center(location, zoom: zoom);
    });

    // Fetch fountains inside this [location] bounding box
    _fetchFountains();
  }

  /// Map move started
  void _onMapMoveStart(final bool byController) {
    // Cancel fetching fountains for a previous move
    _fetchDebounce?.cancel();

    // Avoid auto center if the user is moving the map
    if (_autoCenter && !byController) {
      _autoCenter = false;
    }
  }

  /// Map move ended
  void _onMapMoveEnd(final bool byController) {
    _updateMapStatus();

    // Schedule fetching fountains when map move ends and is idle
    _fetchDebounce = Timer(const Duration(milliseconds: 750), _fetchFountains);
  }

  /// Map is moving
  void _onMapMoveUpdate(final bool byController) {
    _updateMapStatus();
  }

  /// Map moved
  void _updateMapStatus() {
    setState(() {
      bool zoomLimit = _mapController.currentZoom < _mapController.minZoomFetch;

      if (zoomLimit && _zoomMessage == null && _internetProvider.isOnline) {
        // Show message if zoom level is too wide to fetch fountains
        _zoomMessage = ShowMessage.sticky(l.zoomMessage, height: 30);
        _zoomMessage?.onClosed(() {
          _zoomMessage = null;
        });
      } else if (!zoomLimit && _zoomMessage != null) {
        // Hide zoom message if the zoom level is no longer wide
        _zoomMessage?.close();
      }
    });
  }

  /// Fetch fountains when screen size changes
  void _onScreenSizeChanged() {
    final Size? lastScreenSize = _currentScreenSize;
    final Size screenSize = MediaQuery.sizeOf(context);

    if (lastScreenSize != screenSize) {
      debug('Screen $screenSize');

      _currentScreenSize = screenSize;

      if (lastScreenSize != null) {
        // Schedule fetching fountains when screen size changes and is idle
        _fetchDebounce?.cancel();
        _fetchDebounce = Timer(const Duration(seconds: 1), _fetchFountains);
      }
    }
  }

  /// Check for location permissions, if not granted then show a usage dialog
  void _checkLocationPermissions() {
    // Delay until build is finished
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_isRequestingPermissions) return;

      _checkConnectionStatus();

      bool permissionsGranted = await _locationService.hasPermissions();

      if (permissionsGranted) {
        // Retrieve current location
        await _updateCurrentLocation();
      } else {
        _isRequestingPermissions = true;

        // Show location usage dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) => const LocationUsageDialog(),
        );

        // Request permissions and retrieve current location
        await _updateCurrentLocation();
      }
    });
  }

  /// Request location permissions if needed
  Future<void> _ensurePermissions() async {
    bool hasPermissions =
        await _locationProvider.locationService.hasPermissions();
    if (!hasPermissions) {
      _isRequestingPermissions = true;
      await _locationProvider.ensurePermissions();
      _isRequestingPermissions = false;
    }
  }

  /// Retrieve current location
  Future<void> _updateCurrentLocation({bool override = false}) async {
    if (_isLoadingLocation && !override) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Listen to location service status changes
      if (!_locationProvider.isListeningLocationServiceStatus) {
        await _startLocationServiceStatusUpdates();
      }

      // Request permissions if needed to retrieve current location
      await _ensurePermissions();

      // Show loading message if it takes some time
      _loadingLocationMessageTimer?.cancel();
      _loadingLocationMessageTimer = Timer(const Duration(seconds: 2), () {
        _loadingLocationMessage = ShowMessage.sticky(
          l.updatingLocation,
          loading: true,
        );
        _loadingLocationMessage?.onClosed(() {
          _loadingLocationMessage = null;
        });
      });

      // Set current location and listen to future location updates
      if (!_locationProvider.isListeningLocationUpdates &&
          _locationProvider.isLocationServiceEnabled) {
        await _startLocationUpdates();
      } else {
        // debug('Update current location');
        await _locationProvider.updateCurrentPosition();
      }
    } on LocationServicesDisabledException catch (e) {
      _onLocationServicesDisabled(e);
    } on LocationPermissionDeniedException catch (e) {
      _onLocationPermissionDenied(e);
    } catch (e, stackTrace) {
      // Other errors
      ShowMessage.error(
        l.locationError,
        log: 'Error getting the location',
        errorObject: e,
        stackTrace: stackTrace,
      );
    } finally {
      // Finish loading
      _loadingLocationMessageTimer?.cancel();
      _loadingLocationMessage?.close();
      setState(() {
        _isRequestingPermissions = false;
        _isLoadingLocation = false;
        _initialized = true;
      });
    }
  }

  /// Start listening to location updates
  Future<void> _startLocationUpdates() async {
    bool isUpdatedLocation = false;

    if (_initialLocation == null) {
      // Fast location (last known position)
      await _locationProvider.updateInitialPosition();
      _initialLocation = _locationProvider.userPosition?.toLocation();

      if (_initialLocation != null) {
        debug('Set initial location (last known position)');
      } else {
        // Wait for current location
        await _locationProvider.updateCurrentPosition();
        _initialLocation = _locationProvider.userPosition!.toLocation();
        isUpdatedLocation = true;
        debug('Set initial location (current position)');
      }
    }

    debug('Start location updates');
    await _locationProvider.startLocationUpdates(
      onError: (e, stackTrace) {
        switch (e) {
          case LocationServicesDisabledException():
            // Already handled with the location service status listener
            break;
          case LocationPermissionDeniedException():
            _onLocationPermissionDenied(e);
          default:
            error('Error while listening to location updates', e, stackTrace);
        }
      },
    );

    if (!_initialized) {
      // Load map
      setState(() {
        _initialized = true;
      });
    }

    // Update current location
    if (!isUpdatedLocation) {
      debug('Update current location');
      await _locationProvider.updateCurrentPosition();
    }
  }

  /// Listen to location service status changes
  Future<void> _startLocationServiceStatusUpdates() async {
    await _locationProvider.startLocationServiceStatusUpdates(
      onLocationServiceEnabled: () async {
        info('Location services enabled');
        _locationSettingsMessage?.close();
        await _updateCurrentLocation(override: true);
      },
      onLocationServiceDisabled: () async {
        await _locationProvider.stopLocationUpdates();
        _onLocationServicesDisabled(LocationServicesDisabledException());
      },
    );
  }

  void _onLocationServicesDisabled(LocationServicesDisabledException e) {
    if (_locationSettingsMessage == null) {
      warning(e.message);

      _locationSettingsMessage = ShowMessage.show(
        l.locationServicesDisabled,
        seconds: 10,
        actionLabel: l.enable,
        onAction: () async {
          debug('Open location settings');
          _openedSettings = await _locationService.openLocationSettings();
        },
      );
      _locationSettingsMessage?.onClosed(
        () => setState(() {
          _locationSettingsMessage = null;
        }),
      );
    }
  }

  void _onLocationPermissionDenied(LocationPermissionDeniedException e) {
    warning(e.message);

    _locationSettingsMessage = ShowMessage.show(
      l.locationPermissionsDenied,
      seconds: 10,
      actionLabel: l.allow,
      onAction: () async {
        debug('Open app settings');
        _openedSettings = await _locationService.openAppSettings();
      },
    );
    _locationSettingsMessage?.onClosed(
      () => setState(() {
        _locationSettingsMessage = null;
      }),
    );
  }

  /// Fetch fountains from API for the current bounding box
  Future<void> _fetchFountains() async {
    if (!mounted || !_mapLoaded) return;

    // avoid fetching without connection
    if (_internetProvider.isOffline) {
      _checkConnectionStatus();
      return;
    }

    // avoid large requests
    if (_mapController.currentZoom < _mapController.minZoomFetch) {
      return;
    }

    final FetchContext fetchContext = FetchContext(
      screenSize: _currentScreenSize!,
      zoom: _mapController.currentZoom,
      location: _mapController.currentPosition,
      boundingBox: _mapController.bounds,
    );

    // avoid repeated updates
    if ((_lastFetchContext != null &&
            fetchContext.isSimilarTo(_lastFetchContext!)) ||
        _fetchingContexts.keys.any(
            (fetchingContext) => fetchContext.isSimilarTo(fetchingContext))) {
      return;
    }

    final stopwatch = Stopwatch()..start();

    // Show loading message if fetching takes some time
    final fetchTimer = Timer(const Duration(seconds: 1), () {
      if (_loadingFountainsMessage == null) {
        _loadingFountainsMessage = ShowMessage.sticky(
          l.fetchingFountains,
          loading: true,
        );
        _loadingFountainsMessage?.onClosed(() {
          _loadingFountainsMessage = null;
        });
      }
    });

    // Register concurrent requests
    _fetchingContexts[fetchContext] = fetchTimer;

    try {
      await _internetProvider.ensureInternetConnection();

      debug(
        'Fetching fountains at (${fetchContext.location.latitude}, ${fetchContext.location.longitude}) '
        'with zoom ${fetchContext.zoom}',
      );

      // Fetch fountains from API
      final Fountains fountains = await _fountainsService
          .fountainsWithinBoundingBox(context: fetchContext);

      _lastFetchContext = fetchContext;

      // Provide fetched fountains
      _fountainsProvider.setFountains(fountains);

      debug('${stopwatch.elapsedMilliseconds} ms: $fountains');
    } on NoInternetException catch (e) {
      ShowMessage.warning(
        l.noConnectionCheck,
        log: 'Could not fetch fountains (no internet)',
        errorObject: e,
        icon: ConnectionStatus.icon(_internetProvider),
      );
    } on HttpResponseError catch (e) {
      ShowMessage.error(
        l.fountainsNetworkError,
        log: 'Could not fetch fountains (network error)',
        errorObject: e,
      );
    } catch (e, stackTrace) {
      // Other errors
      ShowMessage.error(
        l.fountainsError,
        log: 'Error fetching fountains',
        errorObject: e,
        stackTrace: stackTrace,
      );
    } finally {
      stopwatch.stop();

      fetchTimer.cancel();
      _fetchingContexts.remove(fetchContext);

      if (_fetchingContexts.isEmpty) {
        // all fetching finished
        _loadingFountainsMessage?.close();
      }
    }
  }

  /// Compass button at top-right corner to reset the rotation to north
  Widget _compassButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: CompassButton(
        enabled: _mapLoaded,
        mapController: _mapController,
      ),
    );
  }

  /// Check the Internet status message
  void _checkConnectionStatus() {
    _connectionStatusKey.currentState?.checkConnectionStatus();
  }

  Widget _connectionStatus() {
    return ConnectionStatus(
      key: _connectionStatusKey,
      onConnectionResumed: _updateCurrentLocation,
    );
  }

  Widget _about() {
    return IconButton(
      tooltip: l.about,
      icon: const Icon(Icons.info),
      onPressed: () {
        Navigation.navigateTo(
          AppScreens.about,
          errorMessage: l.navigationError,
        );
      },
    );
  }

  /// Center current user position
  void _onCenterLocationButton() {
    _autoCenter = true;
    final Position? userPosition = _locationProvider.userPosition;
    final hasPosition = userPosition != null;
    if (hasPosition) {
      _centerMap(userPosition.toLocation());
    }
    _updateCurrentLocation();
  }

  /// Location button to center the map to the current user position
  Widget? _centerLocationButton() {
    if (!_mapLoaded) return null;

    return LocationButton(
      tooltip: l.centerLocation,
      enabled: _locationSettingsMessage == null,
      currentMapPosition: _mapController.currentPosition,
      onPressed: _onCenterLocationButton,
    );
  }

  /// Map widget
  Widget _map() {
    if (!_initialized) {
      // Show skeleton background while initializing
      return LayoutBuilder(
        builder: (context, constraints) {
          return SkeletonContainer(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: AppStyles.color.scheme.inversePrimary,
            backgroundColor: AppStyles.color.scheme.surface,
          );
        },
      );
    }
    if (!_mapLoaded) {
      // Wait for the map to load in the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Map initialized and mounted
        setState(() {
          _mapLoaded = true;
        });
        _fetchFountains();
      });
    }
    // Map instance
    return OpenStreetMap(
      controller: _mapController as OpenStreetMapController,
      initialPosition: _initialLocation ?? _defaultLocation,
      initialZoom: _initialLocation == null ? 3 : _mapController.defaultZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          // Internet status icon
          _connectionStatus(),
          // About screen icon
          _about(),
        ],
      ),
      body: Stack(
        children: [
          // Map instance
          _map(),
          // Compass button
          _compassButton(),
        ],
      ),
      // Center location button
      floatingActionButton: _centerLocationButton(),
    );
  }
}
