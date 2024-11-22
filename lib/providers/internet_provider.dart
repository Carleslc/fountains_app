import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../exceptions/http.dart';
import '../services/internet_service.dart';
import '../utils/logger.dart';

/// Provider of device Internet connection status
class InternetProvider extends ChangeNotifier {
  final InternetService internetService = InternetService();

  /// Current connection status
  InternetStatus? _internetStatus;

  /// Previous connection status
  InternetStatus? _previousStatus;

  /// Connection status listeners
  StreamSubscription<InternetStatus>? _internetStatusListener;
  AppLifecycleListener? _appLifecycleListener;

  /// Returns if the device is connected to the internet.
  ///
  /// If it is unknown, both [isOnline] and [isOffline] return false.
  ///
  /// See: [startInternetStatusUpdates]\
  /// See: [ensureInternetConnection]
  bool get isOnline => _internetStatus == InternetStatus.connected;

  /// Returns if the device is not connected to the internet.
  ///
  /// If it is unknown, both [isOnline] and [isOffline] return false.
  ///
  /// See: [startInternetStatusUpdates]\
  /// See: [ensureInternetConnection]
  bool get isOffline => _internetStatus == InternetStatus.disconnected;

  /// Returns if the previous connection status was online.
  ///
  /// If it was unknown, both [wasOnline] and [wasOffline] return false.
  bool get wasOnline => _previousStatus == InternetStatus.connected;

  /// Returns if the previous connection status was offline.
  ///
  /// If it was unknown, both [wasOnline] and [wasOffline] return false.
  bool get wasOffline => _previousStatus == InternetStatus.disconnected;

  /// Change the internet status and notify listeners
  void _setInternetStatus(final InternetStatus status) {
    if (_internetStatus != status) {
      _previousStatus = _internetStatus;
      _internetStatus = status;
      notifyListeners();
    }
  }

  /// Current connectivity mode
  ConnectivityResult? get connectivityMode => _connectivityMode;
  ConnectivityResult? _connectivityMode;

  /// Connectivity mode listener
  StreamSubscription<ConnectivityResult>? _connectivityModeListener;

  /// Returns if the device is connected to a wifi network.
  bool get isWifi => _connectivityMode == ConnectivityResult.wifi;

  /// Returns if the device is connected to a mobile network.
  bool get isMobile => _connectivityMode == ConnectivityResult.mobile;

  /// Change the connectivity mode and notify listeners
  void _setConnectivityMode(final ConnectivityResult connectivityMode) {
    _connectivityMode = connectivityMode;
    notifyListeners();
  }

  /// Ensure the device has internet connection,
  /// otherwise throws [NoInternetException].
  Future<void> ensureInternetConnection() async {
    if (!isListeningToInternetStatusUpdates) {
      await startInternetStatusUpdates();
    }
    if (isOffline) {
      throw NoInternetException();
    }
  }

  /// Returns if it is listening to internet connection status updates
  bool get isListeningToInternetStatusUpdates =>
      _internetStatusListener != null && _connectivityModeListener != null;

  /// Start listening to connection changes.
  ///
  /// Must be called to initialize the current internet status.
  ///
  /// See also: [stopInternetStatusUpdates]
  Future<void> startInternetStatusUpdates() async {
    // Connection status
    if (_internetStatusListener == null) {
      try {
        _setInternetStatus(await internetService.getConnectionStatus());
      } catch (e, stackTrace) {
        error(
          'Error checking the connection status',
          error: e,
          stackTrace: stackTrace,
          report: true,
        );
      }

      _internetStatusListener =
          internetService.internetStatusStream.listen(_setInternetStatus);
    }

    // Connectivity mode
    if (_connectivityModeListener == null) {
      try {
        _setConnectivityMode(await internetService.getConnectivityMode());
      } catch (e, stackTrace) {
        error(
          'Error checking the connectivity mode',
          error: e,
          stackTrace: stackTrace,
          report: true,
        );
      }

      _connectivityModeListener =
          internetService.connectivityModeStream.listen(_setConnectivityMode);
    }

    _appLifecycleListener?.dispose();

    _appLifecycleListener = AppLifecycleListener(
      onPause: () {
        _internetStatusListener?.pause();
        _connectivityModeListener?.pause();
      },
      onHide: () {
        _internetStatusListener?.pause();
        _connectivityModeListener?.pause();
      },
      onResume: () {
        _internetStatusListener?.resume();
        _connectivityModeListener?.resume();
      },
    );
  }

  /// Stop listening to connection changes
  Future<void> stopInternetStatusUpdates() async {
    _appLifecycleListener?.dispose();
    await _internetStatusListener?.cancel();
    _internetStatusListener = null;
    await _connectivityModeListener?.cancel();
    _connectivityModeListener = null;
  }

  @override
  void dispose() {
    stopInternetStatusUpdates();
    super.dispose();
  }
}
