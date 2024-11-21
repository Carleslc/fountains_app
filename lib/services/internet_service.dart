import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../exceptions/http.dart';

/// Service to check for internet connectivity status
class InternetService {
  /// Stream of connection status changes.
  ///
  /// Updates periodically testing network requests reachability.
  Stream<InternetStatus> get internetStatusStream => _internetStatusStream;
  final Stream<InternetStatus> _internetStatusStream;

  /// Stream of connectivity mode changes.
  Stream<ConnectivityResult> get connectivityModeStream =>
      _connectivityModeStream;
  final Stream<ConnectivityResult> _connectivityModeStream;

  // Singleton service
  factory InternetService() => _instance;
  static final _instance = InternetService._();

  InternetService._()
      : _internetStatusStream = InternetConnection().onStatusChange,
        _connectivityModeStream = Connectivity().onConnectivityChanged;

  /// Returns if the device is connected to the internet using [getConnectionStatus].
  Future<bool> get isOnline async {
    final internetStatus = await getConnectionStatus();
    return internetStatus == InternetStatus.connected;
  }

  /// Equivalent to ![isOnline]
  Future<bool> get isOffline async => !(await isOnline);

  /// Returns if the device is connected to a wifi network using [getConnectivityMode].
  Future<bool> get isWifi async =>
      (await getConnectivityMode()) == ConnectivityResult.wifi;

  /// Returns if the device is connected to a mobile network using [getConnectivityMode].
  Future<bool> get isMobile async =>
      (await getConnectivityMode()) == ConnectivityResult.mobile;

  /// Check the current connection status trying a network request.
  ///
  /// `connected`, `disconnected`
  Future<InternetStatus> getConnectionStatus() =>
      InternetConnection().internetStatus;

  /// Check the current connectivity mode (may be offline).
  ///
  /// `wifi`, `mobile`, `none`
  Future<ConnectivityResult> getConnectivityMode() =>
      Connectivity().checkConnectivity();

  /// Ensure the device currently has internet connection,
  /// otherwise throws [NoInternetException].
  Future<void> ensureInternetConnection() async {
    if (await isOffline) {
      throw NoInternetException();
    }
  }
}
