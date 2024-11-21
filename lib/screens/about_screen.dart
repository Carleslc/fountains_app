import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../styles/app_styles.dart';
import '../utils/platform.dart';
import '../utils/spacing.dart';
import '../widgets/info_section.dart';
import '../widgets/localization.dart';
import '../widgets/text_link.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with Localization {
  /// Fountains data providers
  List<Provider> _providers = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    // TODO: Retrieve providers from backend
  }

  /// OpenStreetMap provider
  Provider get _openStreetMapProvider => _providers.firstWhere(
        (provider) => provider.name == 'OpenStreetMap',
        orElse: () => Provider(
          name: 'OpenStreetMap',
          url: 'https://www.openstreetmap.org/',
        ),
      );

  /// Other providers
  Iterable<Provider> get _otherProviders {
    final Provider openStreetMapProvider = _openStreetMapProvider;
    return _providers.where((provider) => provider != openStreetMapProvider);
  }

  /// Provider widget
  Widget _providerWidget(Provider provider) {
    return provider.url != null
        ? TextLink(text: provider.name, url: provider.url!)
        : Text(provider.name, style: AppStyles.text.bold);
  }

  /// App version
  String get _version => '${packageInfo.version}+${packageInfo.buildNumber}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.about),
      ),
      body: Scrollbar(
        thickness: 8,
        thumbVisibility: true,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              InfoSection(
                header: l.aboutDescriptionTitle,
                text: l.aboutDescription,
              ),
              // Terms and conditions
              InfoSection(
                header: l.aboutTermsTitle,
                text: l.aboutTerms,
              ),
              // Attributions
              InfoSection(
                header: l.aboutAttributionsTitle,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OpenStreetMap
                    InfoSection(
                      headerWidget: _providerWidget(_openStreetMapProvider),
                      padding: 4,
                      text: l.attributionOpenStreetMap,
                    ),
                    // Other providers
                    if (_otherProviders.isNotEmpty)
                      InfoSection(
                        headerWidget: Text(
                          '${l.attributionProviders}:',
                          style: AppStyles.text.medium
                              .merge(AppStyles.text.italic),
                        ),
                        padding: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _otherProviders
                              .map(_providerWidget)
                              .toList()
                              .withSpacing(8),
                        ),
                      ),
                    // Icons
                    InfoSection(
                      headerWidget: const TextLink(
                        text: 'Material Symbols',
                        url:
                            'https://fonts.google.com/icons?icon.set=Material+Symbols',
                      ),
                      padding: 4,
                      text: l.attributionIcons('Material Symbols'),
                    ),
                    // Freepik
                    InfoSection(
                      headerWidget: const TextLink(
                        text: 'Freepik',
                        url: 'https://www.freepik.com/icons',
                      ),
                      padding: 4,
                      text: l.attributionFreepik,
                    ),
                  ].withSpacing(12),
                ),
              ),
              // App version
              InfoSection(
                header: l.aboutVersionTitle,
                text: _version,
                textAlign: TextAlign.start,
              ),
            ].withSpacing(24),
          ),
        ),
      ),
    );
  }
}
