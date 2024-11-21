import 'package:flutter/material.dart';

import '../exceptions/error.dart';
import '../exceptions/navigation.dart';
import '../models/fountain.dart';
import 'app_screens.dart';

/// Navigation router to move between screens
abstract final class Navigation {
  /// Global navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// App screens with their routes
  static final routes = AppScreens.routes;

  /// Navigate to `screen`
  ///
  /// If `replace` is true then the screen replaces the previous route in the stack,
  /// otherwise the screen is added on top and will have a back button
  static Future<T?> navigateTo<T extends Object?>(
    final AppScreen screen, {
    bool replace = false,
    required String errorMessage,
  }) {
    return tryOrShowError(() {
      if (navigatorKey.currentState == null) {
        throw InvalidNavigationRouteStateException(screen);
      }
      if (replace) {
        return _navigatorState.pushReplacementNamed(screen.route);
      }
      return _navigatorState.pushNamed(screen.route);
    }, errorMessage: errorMessage);
  }

  /// Navigate to `AppScreens.fountain`
  static Future<T?> navigateToFountain<T extends Object?>(
    final Fountain fountain, {
    required String errorMessage,
  }) {
    return tryOrShowError(
      () => _navigatorState.pushNamed(
        AppScreens.fountain.route,
        arguments: fountain,
      ),
      errorMessage: errorMessage,
      onErrorLogMessage: (_) => 'Could not navigate to fountain details',
    );
  }

  /// Pop all screens of the router stack.
  ///
  /// The displayed screen is now the first route.
  static void popUntilFirst() {
    _navigatorState.popUntil((route) => route.isFirst);
  }

  /// Gets the current `NavigatorState`
  ///
  /// If `navigatorKey.currentState` is null then throws `InvalidNavigationStateException`
  static NavigatorState get _navigatorState {
    if (navigatorKey.currentState == null) {
      throw InvalidNavigationStateException();
    }
    return navigatorKey.currentState!;
  }
}
