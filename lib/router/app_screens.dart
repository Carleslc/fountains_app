import 'package:flutter/material.dart';

import '../models/fountain.dart';
import '../screens/about_screen.dart';
import '../screens/fountain_screen.dart';
import '../screens/introduction_screen.dart';
import '../screens/login_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';

/// Routes for the screens of this app
abstract final class AppScreens {
  /// Map screens routes to their screen builder
  static final routes = _routesMap(
    [
      introduction,
      map,
      about,
      login,
      register,
      profile,
      fountain,
    ],
  );

  static final introduction = AppScreen(
    '/intro',
    (context) => const IntroductionScreen(),
  );

  static final map = AppScreen(
    '/map',
    (context) => const MapScreen(),
  );

  static final about = AppScreen(
    '/about',
    (context) => const AboutScreen(),
  );

  static final login = AppScreen(
    '/login',
    (context) {
      final String? email =
          ModalRoute.of(context)?.settings.arguments as String?;
      return LoginScreen(email: email?.trim());
    },
  );

  static final register = AppScreen(
    '/register',
    (context) {
      final String? email =
          ModalRoute.of(context)?.settings.arguments as String?;
      return RegisterScreen(email: email?.trim());
    },
  );

  static final profile = AppScreen(
    '/profile',
    (context) => const ProfileScreen(),
  );

  static final fountain = AppScreen(
    '/fountain',
    (context) {
      final Fountain fountain =
          ModalRoute.of(context)!.settings.arguments as Fountain;
      return FountainScreen(fountain: fountain);
    },
  );
}

/// A route of this app
abstract class AppRoute {
  String get route;

  @override
  String toString() => route;
}

/// A screen route of this app
final class AppScreen extends AppRoute {
  AppScreen(this.route, this.screenBuilder);

  /// Route of this screen
  final String route;

  /// Screen builder for this screen
  final Widget Function(BuildContext) screenBuilder;
}

/// Builds the routing table required at `MaterialApp` `routes` parameter.
Map<String, Widget Function(BuildContext)> _routesMap(
  List<AppScreen> routes,
) {
  final routesMap = <String, Widget Function(BuildContext)>{};

  routes.forEach((AppScreen screen) {
    routesMap[screen.route] = screen.screenBuilder;
  });

  return routesMap;
}
