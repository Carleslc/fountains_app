import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../models/distance.dart';
import '../models/fountain.dart';
import '../models/fountain_enums.dart';
import '../providers/location_provider.dart';
import '../router/navigation.dart';
import '../styles/app_styles.dart';
import '../utils/locale.dart';
import '../utils/location.dart';
import '../utils/logger.dart';
import '../utils/spacing.dart';
import '../utils/url.dart';
import 'fountain_marker.dart';
import 'google_maps_button.dart';
import 'icon_text.dart';
import 'image_skeleton.dart';
import 'localization.dart';

Future<void> showFountainDetails(
  BuildContext context,
  Fountain fountain, {
  bool dialog = true,
}) {
  debug(fountain);

  if (dialog) {
    return showDialog(
      context: context,
      builder: (context) => FountainDetailsDialog(fountain: fountain),
    );
  }
  return Navigation.navigateToFountain(
    fountain,
    l10n(context),
  );
}

class FountainDetailsDialog extends StatefulWidget {
  final Fountain fountain;

  const FountainDetailsDialog({super.key, required this.fountain});

  @override
  State<FountainDetailsDialog> createState() => _FountainDetailsDialogState();
}

class _FountainDetailsDialogState extends State<FountainDetailsDialog>
    with Localization {
  Fountain get fountain => widget.fountain;

  double get _minWidth {
    if (fountain.safeWater == FountainSafeWater.unknown ||
        fountain.safeWater == FountainSafeWater.probably ||
        fountain.access == FountainAccess.customers ||
        fountain.access == FountainAccess.permit) {
      // Avoid wrap overflow if possible (it may wrap nonetheless)
      return 300;
    }
    return 256;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      alignment: Alignment.center,
      icon: Center(child: _type(fountain, l)),
      title: _title(fountain.name),
      content: ConstrainedBox(
        constraints: BoxConstraints(minWidth: _minWidth),
        child: SingleChildScrollView(
          child: FountainDetails(
            fountain: fountain,
            dialog: true,
          ),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(
        // Outside padding
        horizontal: 24,
        vertical: 16,
      ),
      iconPadding:
          const EdgeInsets.only(bottom: 16, top: 24, left: 16, right: 16),
      titlePadding: const EdgeInsets.only(left: 16, right: 16),
      contentPadding: EdgeInsets.only(
        top: fountain.name != null ? 16 : 12,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      actionsPadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // Close dialog
        IconButton(
          tooltip: l.backToMap,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symbols.arrow_back),
        ),
        // Go to Maps
        _mapsButton(fountain, context),
      ],
    );
  }
}

class FountainDetails extends StatefulWidget {
  final Fountain fountain;
  final bool dialog;

  const FountainDetails({
    super.key,
    required this.fountain,
    this.dialog = false,
  });

  @override
  State<FountainDetails> createState() => _FountainDetailsState();
}

class _FountainDetailsState extends State<FountainDetails> with Localization {
  Fountain get fountain => widget.fountain;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        if (fountain.picture != null)
          _image(
            fountain,
            MediaQuery.sizeOf(context),
            MediaQuery.orientationOf(context),
          ),

        // Description
        if (fountain.description != null && !fountain.description!.isEmpty)
          SelectableText(
            fountain.description!,
            textAlign: TextAlign.justify,
          ),

        // Operational Status
        if (fountain.operationalStatus == false)
          _operationalStatusNotWorking(fountain, l),

        // Water Potability
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Legal Water
            if (fountain.legalWater != FountainLegalWater.unknown)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _legalWater(fountain.legalWater, l),
              ),

            // Safe Water
            _safeWater(fountain.safeWater, l),
          ],
        ),

        // Access restrictions
        if (fountain.access != FountainAccess.unknown)
          _access(fountain.access, l),

        // Fee
        if (fountain.fee == true)
          IconText(
            icon: Icon(Symbols.paid, color: AppStyles.color.yellow),
            text: Text(l.fountainFee, style: AppStyles.text.bold),
          ),

        // Accessibility
        if (fountain.accessWheelchair != null ||
            fountain.accessPets != null ||
            fountain.accessBottles != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 16,
                  children: [
                    // Wheelchair
                    if (fountain.accessWheelchair != null)
                      _accessibleIcon(
                        fountain.accessWheelchair!,
                        l.accessibleWheelchair,
                        Symbols.accessible,
                        l.notAccessibleWheelchair,
                        Symbols.not_accessible,
                      ),

                    // Pets
                    if (fountain.accessPets != null)
                      _accessibleIcon(
                        fountain.accessPets!,
                        l.accessiblePets,
                        Symbols.pets,
                        l.notAccessiblePets,
                      ),

                    // Bottles
                    if (fountain.accessBottles != null)
                      _accessibleIcon(
                        fountain.accessBottles!,
                        l.accessibleBottles,
                        Symbols.water_bottle,
                        l.notAccessibleBottles,
                      ),
                  ],
                )
              ],
            ),
          ),

        if (!widget.dialog)
          // Go to Maps
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _mapsButton(fountain, context),
          ),

        // More information
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Website
            if (fountain.website != null) _website(fountain, l),

            // Provider link
            if (fountain.providerName != null && fountain.providerUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ElevatedButton.icon(
                  onPressed: () {
                    openUrl(
                      fountain.providerUrl!,
                      onErrorMessage: () => l.urlError(fountain.providerUrl!),
                      onErrorContext: () => fountain,
                    );
                  },
                  icon: const Icon(Symbols.link),
                  label: Text(fountain.providerName!),
                ),
              ),
          ],
        ),
      ].withSpacing(12),
    );
  }
}

Widget? _title(String? name) {
  if (name != null) {
    return SelectableText(
      name,
      textAlign: TextAlign.center,
      style: AppStyles.text.title,
      magnifierConfiguration: TextMagnifierConfiguration.disabled,
    );
  }
  return null;
}

Widget _type(Fountain fountain, AppLocalizations l) {
  final String label = switch (fountain.type) {
    FountainType.tapWater => fountain.isPublic
        ? l.fountainTypeTapWaterPublic
        : l.fountainTypeTapWaterPrivate,
    FountainType.natural => l.fountainTypeNatural,
    FountainType.waterPoint => l.fountainTypeWaterPoint,
    FountainType.wateringPlace => l.fountainTypeWateringPlace,
    FountainType.unknown => l.fountainTypeUnknown,
  };
  return IconText(
    icon: FountainMarker.markerIcon(fountain),
    text: Text(label),
  );
}

Widget _image(
  Fountain fountain,
  Size screenSize,
  Orientation screenOrientation,
) {
  String? imageUrl = fountain.picture;

  if (imageUrl == null) return const SizedBox.shrink();

  debug('Image: $imageUrl');

  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: ConstrainedBox(
      constraints: screenOrientation == Orientation.portrait
          ? BoxConstraints(
              maxHeight: max(0.5 * screenSize.height, 300),
              maxWidth: max(0.75 * screenSize.width, 256),
            )
          : BoxConstraints(
              maxHeight: max(0.75 * screenSize.height, 256),
              maxWidth: max(0.5 * screenSize.width, 300),
            ),
      child: ImageSkeleton(
        imageUrl: imageUrl,
        filterQuality: FilterQuality.low,
        onErrorContext: () => fountain,
      ),
    ),
  );
}

Widget _website(Fountain fountain, AppLocalizations l) {
  String? url = fountain.website;

  if (url == null) return const SizedBox.shrink();

  final websiteTag = url.contains('wikipedia.org') ? 'Wikipedia' : l.moreInfo;

  return Tooltip(
    message: url,
    child: ElevatedButton.icon(
      onPressed: () {
        openUrl(
          url,
          onErrorMessage: () => l.urlError(url),
          onErrorContext: () => fountain,
        );
      },
      // Alternative: captive_portal, quick_reference
      icon: const Icon(Symbols.info),
      label: Text(websiteTag),
    ),
  );
}

Widget _safeWater(FountainSafeWater safeWater, AppLocalizations l) {
  final String safeWaterText;
  final IconData safeWaterIcon;
  TextStyle? safeWaterStyle;

  switch (safeWater) {
    case FountainSafeWater.yes:
      safeWaterText = l.safeWaterYes;
      safeWaterIcon = Symbols.humidity_high;
      safeWaterStyle = AppStyles.text.bold;
    case FountainSafeWater.probably:
      safeWaterText = l.safeWaterProbably;
      safeWaterIcon = Symbols.humidity_high;
      safeWaterStyle = AppStyles.text.bold;
    case FountainSafeWater.no:
      safeWaterText = l.safeWaterNo.toUpperCase();
      safeWaterIcon = Symbols.dangerous;
      safeWaterStyle = AppStyles.text.bold.copyWith(color: AppStyles.color.red);
    case FountainSafeWater.unknown:
      safeWaterText = l.unknown;
      safeWaterIcon =
          Symbols.psychology_alt; // Alt: question_mark, humidity_low
  }

  return IconText(
    icon: Icon(
      safeWaterIcon,
      color: FountainMarker.safeWaterColor(safeWater),
    ),
    text: Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: '${l.safeWater}: ',
        children: <TextSpan>[
          TextSpan(text: safeWaterText, style: safeWaterStyle),
        ],
      ),
    ),
  );
}

Widget _legalWater(FountainLegalWater legalWater, AppLocalizations l) {
  final String legalWaterText;
  final IconData legalWaterIcon;
  final Color legalWaterIconColor;

  switch (legalWater) {
    case FountainLegalWater.treated:
      legalWaterText = l.legalWaterTreated;
      legalWaterIcon = Symbols.check_circle;
      legalWaterIconColor = Colors.green;
    case FountainLegalWater.untreated:
      legalWaterText = l.legalWaterUntreated;
      legalWaterIcon = Symbols.warning;
      legalWaterIconColor = Colors.orange;
    case FountainLegalWater.unknown:
      legalWaterText = l.unknown;
      legalWaterIcon = Symbols.unpublished;
      legalWaterIconColor = Colors.blueGrey;
  }

  return IconText(
    icon: Icon(legalWaterIcon, color: legalWaterIconColor),
    text: Text(
      legalWaterText,
      style: AppStyles.text.italic,
      textAlign: TextAlign.center,
    ),
  );
}

Widget _access(FountainAccess access, AppLocalizations l) {
  final String accessText;
  final IconData accessIcon;
  TextStyle? accessStyle;

  switch (access) {
    case FountainAccess.yes:
      accessText = l.fountainAccessPublic;
      accessIcon = Symbols.directions_walk; // Alt: public
    case FountainAccess.permissive:
      accessText = l.fountainAccessPermissive;
      accessIcon = Symbols.follow_the_signs; // Alt: lock_open
    case FountainAccess.customers:
      accessText = l.fountainAccessCustomers;
      accessIcon = Symbols.group; // Alt: work
      accessStyle = AppStyles.text.bold;
    case FountainAccess.permit:
      accessText = l.fountainAccessPermit;
      accessIcon = Symbols.badge;
      accessStyle = AppStyles.text.bold;
    case FountainAccess.private:
      accessText = l.fountainAccessPrivate;
      accessIcon = Symbols.passkey; // Alt: water_lock
      accessStyle = AppStyles.text.bold;
    case FountainAccess.no:
      accessText = l.fountainAccessRestricted;
      accessIcon = Symbols.block;
      accessStyle = AppStyles.text.bold;
    case FountainAccess.unknown:
      accessText = l.unknown;
      accessIcon = Symbols.question_mark; // Alt: policy
  }

  return IconText(
    icon: Icon(accessIcon),
    text: Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: '${l.access}: ',
        children: <TextSpan>[
          TextSpan(text: accessText, style: accessStyle),
        ],
      ),
    ),
  );
}

Widget _accessibleIcon(
  bool isAccessible,
  String accessibleText,
  IconData icon,
  String noAccessibleText, [
  IconData? iconNo,
]) {
  IconData accessIcon;
  Color accessColor;
  String accessHintLabel;

  if (isAccessible) {
    accessIcon = icon;
    accessColor = AppStyles.color.green;
    accessHintLabel = accessibleText;
  } else {
    accessIcon = iconNo ?? icon;
    accessColor = AppStyles.color.red;
    accessHintLabel = noAccessibleText;
  }

  return Tooltip(
    message: isAccessible ? accessibleText : noAccessibleText,
    triggerMode: TooltipTriggerMode.tap,
    child: Icon(
      accessIcon,
      color: accessColor,
      semanticLabel: accessHintLabel,
      size: 32,
    ),
  );
}

Widget _operationalStatusNotWorking(Fountain fountain, AppLocalizations l) {
  final IconData statusIcon;
  final String statusText;

  if (fountain.type == FountainType.tapWater) {
    statusIcon = Symbols.construction;
    statusText = l.operationalStatusNotWorking;
  } else {
    statusIcon = Symbols.format_color_reset;
    statusText = l.operationalStatusNoWater;
  }

  return IconText(
    icon: Icon(statusIcon),
    text: Text(
      statusText,
      style: AppStyles.text.bold,
      textAlign: TextAlign.center,
    ),
  );
}

Widget _mapsButton(Fountain fountain, BuildContext context) {
  return Consumer<LocationProvider>(builder: (
    BuildContext context,
    LocationProvider locationProvider,
    Widget? child,
  ) {
    final Location? userLocation = locationProvider.userPosition?.toLocation();
    final double? meters = userLocation != null
        ? locationProvider.locationService.distance(
            userLocation,
            fountain.location,
            accuracy: DistanceCalculatorAccuracy.high,
          )
        : null;
    Distance? distance;
    if (meters != null) {
      distance = Distance.m(meters);
      if (meters >= 1000) {
        distance = distance.toKilometers();
      }
    }
    final l = l10n(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (distance != null && distance.distance > 0)
          Text(distance.format(locale: context.localeName)),
        Tooltip(
          message: l.openIn('Google Maps'),
          child: GoogleMapsButton(
            label: l.go,
            icon: Symbols.assistant_direction,
            latitude: fountain.latitude,
            longitude: fountain.longitude,
            style: AppStyles.primaryButton,
            onErrorMessage: () => l.cannotOpen('Google Maps'),
          ),
        ),
      ],
    );
  });
}
