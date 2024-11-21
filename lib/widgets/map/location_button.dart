import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../utils/location.dart';

class LocationButton extends StatelessWidget {
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;
  final Location currentMapPosition;

  const LocationButton({
    super.key,
    this.enabled = true,
    required this.tooltip,
    required this.onPressed,
    required this.currentMapPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (
        BuildContext context,
        LocationProvider locationProvider,
        Widget? child,
      ) {
        return Visibility(
          visible: enabled &&
              currentMapPosition != locationProvider.userPosition?.toLocation(),
          child: Tooltip(
            preferBelow: false,
            margin: const EdgeInsets.symmetric(vertical: 12),
            message: tooltip,
            child: FloatingActionButton(
              heroTag: 'my_location',
              onPressed: onPressed,
              child: const Icon(Icons.my_location),
            ),
          ),
        );
      },
    );
  }
}
