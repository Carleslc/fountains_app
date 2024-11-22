import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../styles/app_styles.dart';
import '../widgets/icon_text.dart';
import 'logger.dart';

/// Global Messenger to show messages with `SnackBar`
abstract class ShowMessage {
  /// Global Messenger key
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Queue of snackbars to show (first is the snackbar currently shown)
  static Queue<SnackBarController> _snackbars = Queue();

  /// Close current displayed SnackBar, if any
  static void hideCurrentSnackBar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    // snackbar is removed from _snackbars using
    // the onClosed listener added in show method
  }

  /// Close all queued snackbars, if any
  static void clearSnackBars() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    _snackbars.clear();
  }

  /// Gets the current shown snackbar, if any
  static SnackBarController? getCurrentMessage() => _snackbars.firstOrNull;

  /// Show an error [message] with a `SnackBar`.
  ///
  /// Logs the [log] or [message] with [errorContext], [errorObject] and [stackTrace].
  static SnackBarController? error(
    String message, {
    String? log,
    Object? errorObject,
    StackTrace? stackTrace,
    Object? errorContext,
    bool report = false,
    IconData? icon,
    int seconds = 10,
    bool sticky = false,
  }) {
    errorWithContext(
      log ?? message,
      errorObject: errorObject,
      errorContext: errorContext,
      stackTrace: stackTrace,
      report: report,
    );
    return show(
      message,
      icon: icon,
      backgroundColor: AppStyles.color.scheme.error,
      foregroundColor: AppStyles.color.scheme.onError,
      seconds: sticky ? _stickySeconds : seconds,
      sticky: sticky,
    );
  }

  /// Show a warning [message] with a `SnackBar`.
  ///
  /// Logs the [log] or [message] with [context], [errorObject] and [stackTrace].
  static SnackBarController? warning(
    String message, {
    String? log,
    Object? errorObject,
    StackTrace? stackTrace,
    Object? context,
    IconData? icon,
    int seconds = 5,
    bool sticky = false,
  }) {
    warningWithContext(
      log ?? message,
      errorObject: errorObject,
      context: context,
      stackTrace: stackTrace,
    );
    return show(
      message,
      icon: icon,
      backgroundColor: AppStyles.color.scheme.surfaceBright,
      foregroundColor: AppStyles.color.scheme.error,
      seconds: sticky ? _stickySeconds : seconds,
      sticky: sticky,
    );
  }

  /// Show a [message] with a `SnackBar`, with an optional action
  static SnackBarController? show(
    String message, {
    int? seconds,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
    IconData? icon,
    Color? iconColor,
    bool replace = true,
    bool sticky = false,
    bool loading = false,
  }) {
    if (replace) {
      clearSnackBars(); // Close any existing SnackBars
    }

    bool hasAction = actionLabel != null && onAction != null;

    seconds ??= hasAction ? 10 : 4;

    Text text = Text(
      message,
      style: TextStyle(color: foregroundColor),
      softWrap: true,
    );

    Widget child = text;

    if (icon != null) {
      child = IconText(
        icon: Icon(
          icon,
          color: iconColor ??
              foregroundColor ??
              AppStyles.color.scheme.onInverseSurface,
        ),
        text: text,
        space: 16,
        alignment: WrapAlignment.start,
      );
    }

    final snackbar = SnackBar(
      content: Container(
        height: height,
        child: Align(
          alignment: Alignment.centerLeft,
          child: loading && !hasAction
              // (loading: true) text with loading progresss indicator
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: child,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: LinearProgressIndicator(
                          color: AppStyles.color.scheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                )
              :
              // (loading: false)
              child,
        ),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: seconds),
      action: hasAction
          ? SnackBarAction(
              label: actionLabel.toUpperCase(),
              onPressed: onAction,
            )
          : null,
      dismissDirection: sticky ? DismissDirection.none : null,
      hitTestBehavior:
          sticky ? HitTestBehavior.translucent : HitTestBehavior.opaque,
    );

    // Display SnackBar
    final controller =
        scaffoldMessengerKey.currentState?.showSnackBar(snackbar);

    SnackBarController? snackbarController;

    if (controller != null) {
      snackbarController = SnackBarController(controller);

      _snackbars.addLast(snackbarController);

      snackbarController.onClosed(() {
        _snackbars.removeWhere(
            (SnackBarController snackbar) => snackbar == snackbarController);
      });

      if (!sticky && hasAction) {
        // Hide SnackBar automatically (if hasAction then already hides automatically)
        final hideTimer =
            Timer(Duration(seconds: seconds), snackbarController.close);

        snackbarController.onClosed(hideTimer.cancel);
      }
    }

    return snackbarController;
  }

  /// Show a sticky message with a `SnackBar`, with an optional action
  static SnackBarController? sticky(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
    bool replace = true,
    bool loading = false,
  }) =>
      show(
        message,
        sticky: true,
        replace: replace,
        loading: loading,
        actionLabel: actionLabel,
        onAction: onAction,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        height: height,
        seconds: _stickySeconds,
      );

  static const int _stickySeconds = 100000000;
}

/// `SnackBar` handler with actions to `close` or listen `onClosed`
class SnackBarController {
  final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;

  const SnackBarController(this.controller);

  /// Hide and close this snackbar
  void close() {
    // Must be the first shown snackbar in the queue to close
    if (this == ShowMessage.getCurrentMessage()) {
      controller.close();
    }
  }

  /// Execute [callback] when this snackbar closes for whatever reason.\
  /// Returns a future with the reason.
  Future<SnackBarClosedReason> onClosed(
    FutureOr<void> Function() callback,
  ) {
    return controller.closed.whenComplete(callback);
  }

  /// Execute [callback] when this snackbar closes successfully with a [reason]
  Future<R> onClosedReason<R>(
    FutureOr<R> Function(SnackBarClosedReason reason) callback,
  ) {
    return controller.closed.then(
      (SnackBarClosedReason reason) => callback(reason),
    );
  }
}
