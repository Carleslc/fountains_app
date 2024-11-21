import 'dart:async';

import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';
import '../localization.dart';
import 'map_controller.dart';

/// Compass button to reset the map rotation
class CompassButton extends StatefulWidget {
  final AbstractMapController _mapController;
  final bool enabled;

  const CompassButton({
    super.key,
    required AbstractMapController mapController,
    this.enabled = true,
  }) : _mapController = mapController;

  @override
  State<CompassButton> createState() => _CompassButtonState();
}

class _CompassButtonState extends State<CompassButton> with Localization {
  /// Show N symbol in compass button
  bool _showCompassNorth = false;
  Timer? _compassNorthTimer;

  @override
  void dispose() {
    _compassNorthTimer?.cancel();
    super.dispose();
  }

  /// Reset map rotation to north
  void _onCompassButton() {
    if (!mounted) return;

    _compassNorthTimer?.cancel();

    setState(() {
      _showCompassNorth = true;
      widget._mapController.rotate(0); // north
    });

    // Show N symbol for 2 seconds, then hide the compass button
    _compassNorthTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _showCompassNorth = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    final double currentRotation = widget._mapController.currentRotation;

    return Visibility(
      visible: _showCompassNorth || currentRotation != 0,
      child: Tooltip(
        margin: const EdgeInsets.symmetric(vertical: 4),
        message: l.northRotation,
        child: Transform.rotate(
          angle: currentRotation,
          child: FloatingActionButton.small(
            heroTag: 'compass',
            elevation: 4,
            foregroundColor:
                AppStyles.color.primary, // Alt: AppStyles.color.red
            backgroundColor: AppStyles.color.scheme.surfaceBright,
            onPressed: currentRotation != 0 ? _onCompassButton : null,
            child: currentRotation == 0
                // North icon (N symbol)
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -4,
                        child: Icon(
                          Icons.arrow_drop_up,
                          size: 32,
                          color: AppStyles.color.red,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        child: Text(
                          'N',
                          style: AppStyles.text.bold.copyWith(
                            fontSize: 16,
                            color: AppStyles.color.textColor,
                          ),
                        ),
                      ),
                    ],
                  )
                // Compass icon
                : Image.asset('assets/icons/compass.png'),
            // Icon(
            //   Symbols.arrow_upward_alt, // Alt: north, compass_calibration
            //   weight: 700,
            // ),
          ),
        ),
      ),
    );
  }
}
