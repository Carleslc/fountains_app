import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../exceptions/http.dart';
import '../providers/internet_provider.dart';
import '../utils/message.dart';
import 'localization.dart';

/// Show the Internet connection status with an icon and SnackBar messages
class ConnectionStatus extends StatefulWidget {
  final VoidCallback? onConnectionLost;
  final VoidCallback? onConnectionResumed;

  const ConnectionStatus({
    super.key,
    this.onConnectionLost,
    this.onConnectionResumed,
  });

  /// Internet status icon given the connection status and connectivity mode
  static IconData icon(InternetProvider internetProvider) {
    if (internetProvider.isOnline) {
      if (internetProvider.isWifi) {
        return Icons.wifi;
      } else if (internetProvider.isMobile) {
        return Icons.signal_cellular_alt;
      }
      return Icons.signal_wifi_statusbar_null;
    } else if (internetProvider.isOffline) {
      if (internetProvider.isWifi) {
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      } else if (internetProvider.isMobile) {
        return Icons.signal_cellular_connected_no_internet_4_bar;
      }
      return Icons.wifi_off;
    }
    return Icons.signal_wifi_bad;
  }

  @override
  State<ConnectionStatus> createState() => ConnectionStatusState();
}

class ConnectionStatusState extends State<ConnectionStatus> with Localization {
  late final InternetProvider _internetProvider;

  /// Message when internet is not available
  SnackBarController? _connectionStatusMessage;

  /// Flag to control when the offline status message has been shown
  bool _hasShownOfflineMessage = false;

  @override
  void initState() {
    super.initState();
    _internetProvider = context.read<InternetProvider>();
    _internetProvider.addListener(checkConnectionStatus);
  }

  @override
  void dispose() {
    _connectionStatusMessage?.close();
    _internetProvider.removeListener(checkConnectionStatus);
    super.dispose();
  }

  /// Check the Internet status message
  void checkConnectionStatus() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_internetProvider.isOffline) {
        _connectionStatusMessage?.close();
        _connectionStatusMessage = ShowMessage.warning(
          _internetProvider.wasOnline && !_hasShownOfflineMessage
              ? l.connectionLost
              : l.noConnectionCheck,
          icon: ConnectionStatus.icon(_internetProvider),
          log: NoInternetException().message,
          sticky: _internetProvider.wasOffline,
          seconds: 10,
        );
        _hasShownOfflineMessage = true;
        widget.onConnectionLost?.call();
      } else if (_internetProvider.isOnline &&
          _internetProvider.wasOffline &&
          _hasShownOfflineMessage) {
        _connectionStatusMessage?.close();
        _connectionStatusMessage = ShowMessage.show(
          l.connectionResumed,
          icon: ConnectionStatus.icon(_internetProvider),
        );
        _hasShownOfflineMessage = false;
        widget.onConnectionResumed?.call();
      }
      _connectionStatusMessage?.onClosed(() {
        _connectionStatusMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InternetProvider>(
      builder: (context, internetProvider, child) {
        if (internetProvider.isOffline) {
          return Tooltip(
            message: l.noConnection,
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(ConnectionStatus.icon(internetProvider)),
          );
        }
        return const SizedBox.shrink(); // online
      },
    );
  }
}
