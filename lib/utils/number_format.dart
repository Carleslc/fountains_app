import 'package:intl/intl.dart' show NumberFormat;

extension NumberFormatter on num {
  /// Default number format with optional decimal digits.
  ///
  /// `#,##0.###` e.g. 1.234,567 (es) 1,234.567 (en)
  static final defaultPattern = NumberFormat.decimalPattern();

  /// Format this number with the following [NumberFormat]
  ///
  /// If [pattern] is provided: [pattern]\
  /// If [locale] is provided: `NumberFormat.decimalPattern(locale)`\
  /// Otherwise: [defaultPattern]
  String format({String? locale, NumberFormat? pattern}) {
    if (pattern == null && locale != null) {
      pattern = NumberFormat.decimalPattern(locale);
    }
    pattern ??= NumberFormatter.defaultPattern;
    return pattern.format(this);
  }
}
