import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/fountains_provider.dart';
import 'providers/internet_provider.dart';
import 'providers/location_provider.dart';
import 'providers/user_provider.dart';
import 'router/navigation.dart';
import 'screens/map_screen.dart';
import 'screens/splash_screen.dart';
import 'styles/app_styles.dart';
import 'utils/message.dart';
import 'widgets/localization.dart';

void main() async {
  // Run app
  runApp(const FountainsApp());
}

class FountainsApp extends StatelessWidget {
  const FountainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Location provider
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        // Fountains provider
        ChangeNotifierProvider<FountainsProvider>(
          create: (_) => FountainsProvider(),
        ),
        // Internet connection provider
        ChangeNotifierProvider<InternetProvider>(
          create: (_) => InternetProvider(),
        ),
        // User provider
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        // Theme
        theme: AppStyles.getTheme(context),
        // Splash Screen
        home: const SplashScreen(),
        // Snackbar Messages
        scaffoldMessengerKey: ShowMessage.scaffoldMessengerKey,
        // Navigation routes
        routes: Navigation.routes,
        navigatorKey: Navigation.navigatorKey,
        navigatorObservers: [MapScreen.routeObserver],
        // Localization
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [
          // English
          const Locale.fromSubtags(languageCode: 'en'),
          // Spanish
          const Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
          // Catalan
          const Locale.fromSubtags(languageCode: 'ca'),
        ],
        // App Title (localized)
        onGenerateTitle: (context) => l10n(context).appTitle,
        // Debug banner
        debugShowCheckedModeBanner: false,
        // Debug performance overlay
        showPerformanceOverlay: false,
      ),
    );
  }
}
