import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../styles/app_styles.dart';
import 'icon_text.dart';
import 'localization.dart';

class LocationUsageDialog extends StatefulWidget {
  const LocationUsageDialog({super.key});

  @override
  State<LocationUsageDialog> createState() => _LocationUsageDialogState();
}

class _LocationUsageDialogState extends State<LocationUsageDialog>
    with Localization {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: IconText(
        icon: Icon(
          Symbols.my_location,
          color: AppStyles.color.titleTextColor,
        ),
        text: Text(l.locationPermissions),
        alignment: WrapAlignment.start,
      ),
      content: Text(
        l.locationPermissionsUsage,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
          },
          child: Text(l.continueButton.toUpperCase()),
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(
        // Outside padding
        horizontal: 32,
        vertical: 24,
      ),
    );
  }
}
