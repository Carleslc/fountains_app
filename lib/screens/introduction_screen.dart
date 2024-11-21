import 'package:flutter/material.dart';

import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../widgets/localization.dart';

// TODO: Introduction Slides

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with Localization {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, _navigateToMap);
  }

  /// Navigate to Map Screen
  void _navigateToMap() {
    Navigation.navigateTo(
      AppScreens.map,
      replace: true,
      errorMessage: l.navigationError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
      ),
      body: const Center(
        child: SizedBox.shrink(),
      ),
    );
  }
}
