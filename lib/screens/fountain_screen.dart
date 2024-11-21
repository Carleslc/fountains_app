import 'package:flutter/material.dart';

import '../models/fountain.dart';
import '../widgets/fountain_details.dart';
import '../widgets/fountain_marker.dart';
import '../widgets/icon_text.dart';
import '../widgets/localization.dart';

class FountainScreen extends StatefulWidget {
  final Fountain fountain;

  const FountainScreen({super.key, required this.fountain});

  @override
  State<FountainScreen> createState() => _FountainScreenState();
}

class _FountainScreenState extends State<FountainScreen> with Localization {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: IconText(
          icon: FountainMarker.markerIcon(widget.fountain),
          text: Text(widget.fountain.name ?? l.fountain),
          alignment: WrapAlignment.start,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FountainDetails(fountain: widget.fountain),
        ),
      ),
    );
  }
}
