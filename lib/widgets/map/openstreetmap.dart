import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../../models/fountains.dart';
import '../../providers/fountains_provider.dart';
import '../../providers/internet_provider.dart';
import '../../providers/location_provider.dart';
import '../../styles/app_styles.dart';
import '../../utils/location.dart';
import '../../utils/platform.dart';
import '../fountain_marker.dart';
import 'openstreetmap_controller.dart';

class OpenStreetMap extends StatefulWidget {
  final OpenStreetMapController? controller;

  final Location initialPosition;
  final double initialZoom;

  const OpenStreetMap({
    super.key,
    this.controller,
    required this.initialPosition,
    this.initialZoom = 15,
  });

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  late InternetProvider _internetProvider;

  /// Map controller
  late OpenStreetMapController _mapController;

  /// Listener of map events
  StreamSubscription<MapEvent>? _mapListener;

  /// Key to refresh map tiles
  Key _tilesKey = UniqueKey();

  /// Fountains markers cache
  List<Marker> _fountainsMarkersCache = List.empty();

  /// Fountains of the current markers cache
  Fountains? _latestFountains;

  @override
  void initState() {
    super.initState();
    _setMapController();
    _startMapListener();
    _internetProvider = context.read<InternetProvider>();
    _internetProvider.addListener(_refreshTiles);
  }

  @override
  void didUpdateWidget(OpenStreetMap old) {
    if (old.controller != widget.controller) {
      _setMapController();
      _startMapListener();
    }
    super.didUpdateWidget(old);
  }

  @override
  void dispose() {
    _mapListener?.cancel();
    _internetProvider.removeListener(_refreshTiles);
    super.dispose();
  }

  /// Set the map controller instance
  void _setMapController() {
    _mapController = widget.controller != null
        ? widget.controller!
        : OpenStreetMapController();
  }

  /// Start listening to map events
  void _startMapListener() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _mapListener?.cancel();
      _mapListener = _mapController.controller.mapEventStream.listen((event) {
        bool byController = event.source == MapEventSource.mapController;
        if (event is MapEventMove) {
          _mapController.onMapMoveUpdate?.call(byController);
        } else if (event is MapEventMoveStart) {
          _mapController.onMapMoveStart?.call(byController);
        } else if (event is MapEventMoveEnd) {
          _mapController.onMapMoveEnd?.call(byController);
        }
      });
    });
  }

  /// OpenStreetMap tiles
  TileLayer _mapTiles() {
    return TileLayer(
      key: _tilesKey,
      minZoom: _mapController.minZoom,
      maxZoom: _mapController.maxZoom,
      tileSize: 256,
      evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: packageInfo.packageName,
    );
  }

  /// Refresh map tiles
  void _refreshTiles() {
    if (_internetProvider.isOnline && _internetProvider.wasOffline) {
      // Avoid caching errored tiles when the device had no connection
      _tilesKey = UniqueKey();
    }
  }

  /// Build fountains markers
  void _buildFountainsMarkers(FountainsProvider fountainsProvider) {
    _fountainsMarkersCache = List.unmodifiable(
      fountainsProvider.markers.map<Marker>((FountainMarker fountainMarker) {
        return Marker(
          width: 50,
          height: 50,
          point: fountainMarker.fountain.location,
          child: fountainMarker,
        );
      }),
    );
    _latestFountains = fountainsProvider.fountains;
  }

  /// Fountains OpenStreetMap markers
  Widget _fountainsMarkers() {
    return Consumer<FountainsProvider>(
      builder: (context, fountainsProvider, child) {
        // Update markers if there are new fountains
        if (_latestFountains != fountainsProvider.fountains) {
          _buildFountainsMarkers(fountainsProvider);
        }

        // Filter markers visible within the bounding box
        final visibleMarkers = _fountainsMarkersCache
            .where(
                (marker) => _mapController.visibleBounds.contains(marker.point))
            .toList();

        // Cluster markers for wide areas with many fountains
        return _fountainsMarkersCluster(visibleMarkers);
      },
    );
  }

  /// Cluster of fountains markers
  Widget _fountainsMarkersCluster(final List<Marker> markers) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        rotate: true,
        markers: markers,
        maxClusterRadius: _maxClusterRadius(),
        maxZoom: _mapController.maxZoom,
        alignment: Alignment.center,
        size: const Size.square(32),
        computeSize: (markers) => Size.square(
          markers.length < 1000 ? 32 : 48,
        ),
        disableClusteringAtZoom: 16,
        showPolygon: true, // show region on tap
        polygonOptions: PolygonOptions(
          color: AppStyles.color.scheme.secondary.withOpacity(0.2),
        ),
        builder: (context, markers) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                markers.length < 1000 ? 12 : 18,
              ),
              color: AppStyles.color.scheme.primary.withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                markers.length.toString(),
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppStyles.text.small.copyWith(
                  color: AppStyles.color.scheme.onPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Max cluster radius based on zoom level (display more markers on zoom in)
  int _maxClusterRadius() {
    final double currentZoom = _mapController.currentZoom;
    if (currentZoom > _mapController.defaultZoom + 0.5) {
      return 16;
    }
    if (currentZoom > _mapController.defaultZoom + 0.25) {
      return 32;
    }
    if (currentZoom >= _mapController.defaultZoom) {
      return 48;
    }
    return 64;
  }

  /// User location marker
  Widget _userLocationMarker() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.markerPositionStream == null) {
          return const SizedBox.shrink(); // no location
        }

        final (markerSize, iconSize, headingRadius) = _navigationIconSize();

        final markerColor = locationProvider.isCurrentLocation
            ? AppStyles.color.markerColor
            : AppStyles.color.gray;

        return CurrentLocationLayer(
          positionStream: locationProvider.markerPositionStream,
          alignDirectionOnUpdate:
              AlignOnUpdate.never, // AlignOnUpdate.always: Navigation mode
          style: LocationMarkerStyle(
            showHeadingSector: true,
            accuracyCircleColor: markerColor.withOpacity(0.1),
            headingSectorColor: markerColor,
            markerDirection: MarkerDirection.heading,
            marker: DefaultLocationMarker(
              color: markerColor,
              child: Icon(
                Icons.navigation,
                color: AppStyles.color.white,
                size: iconSize,
              ),
            ),
            markerSize: Size.square(markerSize),
            headingSectorRadius: headingRadius,
          ),
        );
      },
    );
  }

  /// Navigation icon size based on zoom level
  (double markerSize, double iconSize, double headingRadius)
      _navigationIconSize() {
    final double currentZoom = _mapController.currentZoom;
    double markerSizeMultiplier = currentZoom < 10 ? 2.5 : 2;
    double markerSize = clampDouble(currentZoom * markerSizeMultiplier, 16, 40);
    double headingRadius = clampDouble(25 * (currentZoom / 5), 30, 80);
    double iconSize = 0.6 * markerSize;
    return (markerSize, iconSize, headingRadius);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController.controller,
      options: MapOptions(
        initialCenter: widget.initialPosition,
        // Zoom
        initialZoom: widget.initialZoom,
        minZoom: _mapController.minZoom,
        maxZoom: _mapController.maxZoom,
        // Gestures
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all | InteractiveFlag.rotate,
          enableMultiFingerGestureRace: true,
          debugMultiFingerGestureWinner: false,
          pinchZoomThreshold: 0.33,
          pinchZoomWinGestures:
              MultiFingerGesture.pinchZoom | MultiFingerGesture.pinchMove,
          pinchMoveThreshold: 40,
          pinchMoveWinGestures:
              MultiFingerGesture.pinchMove | MultiFingerGesture.pinchZoom,
          rotationThreshold: 10,
          rotationWinGestures: MultiFingerGesture.all,
        ),
      ),
      children: [
        _mapTiles(),
        _userLocationMarker(),
        _fountainsMarkers(),
      ],
    );
  }
}
