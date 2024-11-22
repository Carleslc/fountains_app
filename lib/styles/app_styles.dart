import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'color_styles.dart';
part 'text_styles.dart';

/// Custom styles for this app
abstract final class AppStyles {
  /// Color styles
  static ColorStyles get color => _color;
  static late ColorStyles _color;

  /// Text styles
  static TextStyles get text => _text;
  static late TextStyles _text;

  // Button styles
  static late ButtonStyle? primaryButton;
  static late ButtonStyle? primaryContainerButton;

  /// Theme of this app
  static late ThemeData theme;

  /// Initialize app theme
  static ThemeData getTheme(BuildContext context) {
    final ThemeData defaultTheme = Theme.of(context);

    // Initialize color styles from context
    _color = ColorStyles._(defaultTheme.colorScheme);

    // Initialize text styles from context
    _text = TextStyles._(defaultTheme.textTheme);

    // Initialize theme with custom color and text themes
    theme = ThemeData.from(
      useMaterial3: true,
      colorScheme: color.scheme,
      textTheme: text.theme,
    ).copyWith(
      // Icons theme
      iconTheme: const IconThemeData(
        fill: 1, // filled
        size: 24,
        opticalSize: 32,
        weight: 400,
      ),
      //
      // Widgets themes
      //
      appBarTheme: AppBarTheme(
        backgroundColor:
            color.scheme.inversePrimary, // Alt: colorScheme.primary
        foregroundColor:
            color.scheme.onPrimaryContainer, // Alt: colorScheme.onPrimary
        titleTextStyle: text.appBarTitle,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          disabledBackgroundColor: color.gray,
          disabledForegroundColor: color.scheme.onInverseSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor:
            color.scheme.primary, // Alt: colorScheme.primaryContainer
        foregroundColor: color.scheme.onPrimary, // Alt: colorScheme.primary
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        sizeConstraints: BoxConstraints.tight(const Size.fromRadius(32)),
        iconSize: 32,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text.bold,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: color.scheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: text.small,
        errorMaxLines: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: color.scheme.inverseSurface,
        actionTextColor: color.scheme.inversePrimary,
        contentTextStyle: TextStyle(color: color.scheme.onInverseSurface),
        behavior: SnackBarBehavior.fixed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        preferBelow: true,
        margin: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: color.scheme.inverseSurface,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: color.scheme.primary,
        linearTrackColor: color.lightGray,
        circularTrackColor: color.lightGray,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: text.header,
      ),
      listTileTheme: ListTileThemeData(
        selectedColor: defaultTheme.colorScheme.primary,
      ),
      dividerTheme: DividerThemeData(color: color.scheme.outlineVariant),
    );

    primaryButton = ElevatedButton.styleFrom(
      backgroundColor: color.scheme.primary,
      foregroundColor: color.scheme.onPrimary,
    );

    primaryContainerButton = ElevatedButton.styleFrom(
      backgroundColor: color.scheme.primaryContainer,
      foregroundColor: color.scheme.onPrimaryContainer,
    );

    return theme;
  }
}
