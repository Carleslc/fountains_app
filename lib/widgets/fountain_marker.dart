import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../models/fountain.dart';
import '../models/fountain_enums.dart';
import '../styles/app_styles.dart';
import 'fountain_details.dart';

/// Fountain map marker with a custom icon
class FountainMarker extends StatelessWidget {
  final Fountain fountain;

  const FountainMarker(this.fountain, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: markerIcon(fountain),
      onPressed: () {
        // Navigate to fountain details
        showFountainDetails(context, fountain, dialog: true);
      },
    );
  }

  /// Build the icon from fountain details
  static Icon markerIcon(Fountain fountain) {
    IconData icon;
    Color color;
    double? weight;

    // Type
    FountainType type = fountain.type;

    switch (type) {
      case FountainType.tapWater:
        icon = Symbols.water_drop;
      case FountainType.natural:
        icon = Symbols.water;
        weight = 800;
      case FountainType.wateringPlace:
        icon = Symbols.water_full; // Alt: local_drink, water_voc, humidity_high
      case FountainType.waterPoint:
        icon =
            Symbols.fire_hydrant; // Alt: water_pump, water_bottle_large, valve;
      case FountainType.unknown:
        icon = Symbols.humidity_high;
    }

    // Safe water
    color = safeWaterColor(fountain.safeWater);

    // Fee
    if (fountain.fee == true) {
      color = AppStyles.color.yellow;
    }

    // Access
    final FountainAccess access = fountain.access;

    if (access != FountainAccess.unknown) {
      if (access == FountainAccess.customers) {
        switch (type) {
          case FountainType.natural:
            icon = Symbols.waves;
          case FountainType.tapWater:
            icon = Symbols.total_dissolved_solids;
          case FountainType.waterPoint:
            icon = Symbols.water_pump;
          case FountainType.wateringPlace:
            icon = Symbols.local_drink;
          case FountainType.unknown:
        }
      } else if (access == FountainAccess.no ||
          access == FountainAccess.private ||
          access == FountainAccess.permit) {
        icon = Symbols.water_lock;
      }
    }

    // Operational status
    if (fountain.operationalStatus == false) {
      if (type == FountainType.tapWater) {
        icon = Symbols.format_color_reset; // Alt: invert_colors_off
      } else if (type == FountainType.wateringPlace) {
        icon = Symbols.water_loss;
      }
      color = AppStyles.color.darkGray;
    }

    return Icon(icon, color: color, weight: weight, fill: 1);
  }

  /// Color of the marker icon relative to the water quality
  static Color safeWaterColor(FountainSafeWater safeWater) =>
      switch (safeWater) {
        FountainSafeWater.yes => Colors.blue,
        FountainSafeWater.probably => Colors.teal,
        FountainSafeWater.no => AppStyles.color.red,
        FountainSafeWater.unknown || _ => Colors.blueGrey
      };
}
