import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  /// Navigate to [screen] with [arguments]
  ///
  /// If [replace] is true then the screen replaces the previous route in the stack,
  /// otherwise the screen is added on top and will have a back button in AppBar.
  static Future<T?> navigateTo<T, A extends Object?>(
    final AppScreen screen,
    final AppLocalizations l, {
    final bool replace = false,
    final String? errorMessage,
    final A? arguments,
  }) {
    return tryOrShowError(
      () {
        if (navigatorKey.currentState == null) {
          throw InvalidNavigationRouteStateException(screen);
        }
        if (replace) {
          return _navigatorState.popAndPushNamed(
            screen.route,
            arguments: arguments,
          );
        }
        return _navigatorState.pushNamed(
          screen.route,
          arguments: arguments,
        );
      },
      errorMessage: errorMessage ?? l.navigationError,
      report: true,
    );
  }

  /// Navigate to login or register
  static Future<T?> navigateToAuth<T>(
    final AppScreen screen,
    final AppLocalizations l, {
    final String? email,
    final String? errorMessage,
    final bool replace = true,
  }) {
    assert(screen == AppScreens.login || screen == AppScreens.register);
    return navigateTo(
      screen,
      l,
      arguments: email,
      replace: replace,
      errorMessage: errorMessage,
    );
  }

  /// Navigate to `AppScreens.fountain`
  static Future<T?> navigateToFountain<T>(
    final Fountain fountain,
    final AppLocalizations l, {
    final String? errorMessage,
  }) {
    return tryOrShowError(
      () => _navigatorState.pushNamed(
        AppScreens.fountain.route,
        arguments: fountain,
      ),
      errorMessage: errorMessage ?? l.navigationError,
      onErrorLogMessage: (_) => 'Could not navigate to fountain details',
      report: true,
    );
  }

  /// Pop screens until the screen is not login or register
  static Future<void> backFromAuth(final AppLocalizations l) {
    return tryOrShowError(
      () async => _navigatorState.popUntil((route) {
        final screen = route.settings.name;
        return screen != AppScreens.login.route &&
            screen != AppScreens.register.route;
      }),
      errorMessage: l.navigationError,
      onErrorLogMessage: (_) =>
          'Could not navigate back from authentication screen',
      report: true,
    );
  }

  /// Navigate back to previous screen
  static Future<void> back(final AppLocalizations l) {
    return tryOrShowError(
      () async => _navigatorState.pop(),
      errorMessage: l.navigationError,
      onErrorLogMessage: (_) => 'Could not navigate back',
      report: true,
    );
  }

  /// Pop all screens of the router stack.
  ///
  /// The displayed screen is now the first route.
  static Future<void> popUntilFirst(final AppLocalizations l) {
    return tryOrShowError(
      () async => _navigatorState.popUntil((route) => route.isFirst),
      errorMessage: l.navigationError,
      onErrorLogMessage: (_) => 'Could not navigate back until first',
      report: true,
    );
  }

  /// Gets the current `NavigatorState`
  ///
  /// If `navigatorKey.currentState` is null then throws [InvalidNavigationStateException]
  static NavigatorState get _navigatorState {
    if (navigatorKey.currentState == null) {
      throw InvalidNavigationStateException();
    }
    return navigatorKey.currentState!;
  }
}
