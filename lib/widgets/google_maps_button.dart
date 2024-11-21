import 'package:flutter/material.dart';

import '../utils/url.dart';

/// Open a location in Google Maps
class GoogleMapsButton extends StatelessWidget {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? label;
  final IconData icon;
  final bool tooltip;
  final bool tonal;
  final ButtonStyle? style;
  final String Function()? onErrorMessage;

  GoogleMapsButton({
    super.key,
    this.address,
    this.latitude,
    this.longitude,
    this.label,
    this.icon = Icons.map,
    this.tooltip = false,
    this.tonal = false,
    this.style,
    this.onErrorMessage,
  });

  /// Search by address or coordinates
  String get mapsQuery {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (latitude != null && longitude != null) {
      return '$latitude,$longitude';
    }
    return '';
  }

  /// Google Maps URL with search query
  String get mapsUrl => 'https://maps.google.com/maps?q=$mapsQuery';

  /// Open the location in Google Maps
  void _launchMap() {
    openUrl(
      mapsUrl,
      onErrorMessage: () {
        final String errorMessage =
            onErrorMessage?.call() ?? 'Could not open Google Maps';
        return '$errorMessage\n$mapsUrl';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mapsQuery.isEmpty) {
      return const SizedBox.shrink();
    }
    Widget child;
    Icon icon = Icon(this.icon);

    if (this.label == null) {
      if (tonal) {
        child = IconButton.filledTonal(
          icon: icon,
          style: style,
          onPressed: _launchMap,
        );
      } else {
        child = IconButton.filled(
          icon: icon,
          style: style,
          onPressed: _launchMap,
        );
      }
    } else {
      Text label = Text(this.label!);

      if (tonal) {
        child = FilledButton.tonalIcon(
          icon: icon,
          label: label,
          style: style,
          onPressed: _launchMap,
        );
      } else {
        child = ElevatedButton.icon(
          icon: icon,
          label: label,
          style: style,
          onPressed: _launchMap,
        );
      }
    }

    if (!tooltip) return child;

    // Coordinates or address
    String tooltipMessage = latitude != null || longitude != null
        ? "${latitude ?? '?'}, ${longitude ?? '?'}"
        : address ?? '';

    return Tooltip(
      message: tooltipMessage,
      showDuration: const Duration(seconds: 3),
      child: child,
    );
  }
}
