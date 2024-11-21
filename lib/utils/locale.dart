import 'dart:io';

import 'package:flutter/material.dart';

/// Device locale name when the app started.
///
/// On Android the value will not change while the application is running,
/// even if the user adjusts their language settings.
String getSystemLocaleName() => Platform.localeName;

/// Current device locale
Locale getCurrentLocale(BuildContext context) =>
    Localizations.localeOf(context);

extension LocaleExtension on BuildContext {
  /// Current device locale.
  ///
  /// This value will change while the application is running
  /// if the user adjusts their language settings.
  Locale get locale => getCurrentLocale(this);

  /// Current device locale name.
  ///
  /// This value will change while the application is running
  /// if the user adjusts their language settings.
  String get localeName => locale.toLanguageTag();
}
