import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/internet_provider.dart';
import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../styles/app_styles.dart';
import '../utils/locale.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';
import '../widgets/localization.dart';
import '../widgets/skeleton_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with Localization {
  @override
  void initState() {
    super.initState();

    // Async initializations
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await init();
      onLoaded();
    }, debugLabel: 'splash initAsync');
  }

  /// Asynchronous initializations required to load before the main screen is loaded
  Future<void> init() async {
    // Set default locale
    String localeName = getSystemLocaleName();
    Intl.defaultLocale = localeName;
    await initializeDateFormatting(localeName);
    info('Locale: $localeName');

    // Load package info
    await loadPackageInfo();

    // Check connection status
    await context.read<InternetProvider>().startInternetStatusUpdates();
  }

  /// After initializations
  void onLoaded() {
    /// Navigate to the introduction screen
    Navigation.navigateTo(
      AppScreens.introduction,
      replace: true,
      errorMessage: l.navigationError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double imageSize =
              min(512, min(constraints.maxWidth, constraints.maxHeight) / 2);

          return SkeletonContainer(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            colorOpacity: 0.5,
            color: AppStyles.color.scheme.inversePrimary,
            backgroundColor: AppStyles.color.scheme.surface,
            child: Image.asset(
              'assets/icons/logo.png',
              width: imageSize,
              height: imageSize,
            ),
          );
        },
      ),
    );
  }
}
