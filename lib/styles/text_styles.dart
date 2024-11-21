part of 'app_styles.dart';

/// App text styles.
///
/// Example: `AppStyles.text.title`
final class TextStyles {
  /// App texts font
  static const font = GoogleFonts.quicksand;

  /// App texts font theme
  static const fontTheme = GoogleFonts.quicksandTextTheme;

  /// App texts font family
  static final fontFamily = font().fontFamily;

  /// Large size text
  final big = textStyle(fontSize: 20);

  /// Medium size text
  final medium = textStyle(fontSize: 18);

  /// Default size text
  final normal = textStyle(fontSize: 16);

  /// Small text
  final small = textStyle(fontSize: 14);

  /// Bold text with font variant
  final bold = textStyle(fontWeight: FontWeight.bold);

  /// Italic text with font variant
  final italic = textStyle(fontStyle: FontStyle.italic);

  /// Titles
  final title = textStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppStyles.color.titleTextColor,
    overflow: TextOverflow.ellipsis,
  );

  /// Headers / Dialog titles
  final header = textStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppStyles.color.titleTextColor,
    overflow: TextOverflow.clip,
  );

  /// AppBar Title
  final appBarTitle = textStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppStyles.color.scheme.onPrimaryContainer,
    overflow: TextOverflow.ellipsis,
  );

  /// Links
  final link = textStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppStyles.color.darkAccent,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.solid,
  );

  /// Text Theme
  ///
  // Spec: https://m3.material.io/styles/typography/type-scale-tokens
  late final TextTheme theme;

  /// Initialize text theme
  TextStyles._(TextTheme defaultTheme) {
    theme = fontTheme(
      defaultTheme.merge(TextTheme(
        bodyLarge: medium,
        bodyMedium: normal,
        bodySmall: small,
        // ...
      )),
    );
  }

  /// Create a TextStyle with the app font applied.\
  /// If `applyFontVariant` is true then applies the font variant if available,
  /// otherwise only the generic fontFamily is applied
  static TextStyle textStyle({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    TextOverflow? overflow,
    bool applyFontVariant = true,
  }) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
      decoration: decoration,
      decorationStyle: decorationStyle,
      overflow: overflow,
      color: color,
    );
    return applyFontVariant ? textStyle.withAppFont : textStyle;
  }
}

extension TextStyleExtensions on TextStyle {
  /// Apply app font with variant, if available\
  /// p.e. Quicksand_bold or Quicksand_700
  TextStyle get withAppFont => TextStyles.font(textStyle: this);

  /// Inherit default TextStyle properties
  TextStyle withDefaults(TextStyle? defaults) => defaults?.merge(this) ?? this;
}
