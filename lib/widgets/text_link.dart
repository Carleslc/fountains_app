import 'package:flutter/material.dart';

import '../styles/app_styles.dart';
import '../utils/url.dart';
import 'localization.dart';

/// Text with a url to open in the browser
class TextLink extends StatefulWidget {
  final String text;
  final String url;

  const TextLink({super.key, required this.text, required this.url});

  @override
  State<TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> with Localization {
  /// Open the url in the browser
  void _open() {
    openUrl(
      widget.url,
      onErrorMessage: () => l.urlError(widget.url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _open,
      child: Text(
        widget.text,
        style: AppStyles.text.link,
      ),
      mouseCursor: WidgetStateMouseCursor.clickable,
    );
  }
}
