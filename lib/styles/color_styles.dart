part of 'app_styles.dart';

/// App Colors.
///
/// Example: `AppStyles.color.primary`
final class ColorStyles {
  //
  // Colors Palette
  // https://coolors.co/03256c-2541b2-1768ac-06bee1-ffffff
  //

  /// Primary color from palette
  final Color primary = const Color(0xFF1768AC); // Alt: Colors.blue

  /// Secondary color from palette
  final Color secondary = const Color(0xFF2541B2);

  /// Tertiary color from palette
  final Color tertiary = const Color(0xFF06BEE1); // Alt: Colors.lightBlue

  /// Dark accent color from palette
  final Color darkAccent = const Color(0xFF03256C);

  //
  // Other colors
  //

  /// Color of the user position marker
  final Color markerColor = Colors.deepPurple;

  /// Texts default color
  ///
  /// ColorScheme: onSurface
  late final Color textColor;

  /// Titles color
  late final Color titleTextColor; // darkAccent, Alt: Colors.black87

  /// e.g. TextField borders, ProgressIndicator, disabled buttons color...
  ///
  /// ColorScheme: outline
  final Color gray = Colors.grey;

  /// e.g. Divider
  ///
  /// ColorScheme: outlineVariant
  final Color lightGray = Colors.grey.shade300;

  /// Dark gray
  final Color darkGray = Colors.grey.shade600;

  /// Red color
  final Color red = Colors.red.shade800;

  /// Green color
  final Color green = Colors.green.shade800;

  /// Yellow color
  final Color yellow = Colors.yellow.shade600;

  /// White color
  final Color white = Colors.white;

  /// Background color
  ///
  /// ColorScheme: surface
  late final Color background;

  /// Color Scheme
  ///
  /// Spec: https://m3.material.io/styles/color/roles
  late final ColorScheme scheme;

  /// Initialize color scheme
  ColorStyles._(ColorScheme defaultScheme) {
    // Generate the default colors theme from primary as seed color
    final ColorScheme generated = ColorScheme.fromSeed(seedColor: primary);

    // Background color
    background = generated.surface;

    // Set the color scheme with some colors overridden
    scheme = generated.copyWith(
      // e.g. AppBar, FloatingActionButton background
      primary: primary,
      // e.g. AppBar, FloatingActionButton foreground
      onPrimary: generated.onPrimary,
      // e.g. ElevatedButton background
      primaryContainer: generated.primaryContainer,
      // e.g. ElevatedButton foreground
      onPrimaryContainer: generated.onPrimaryContainer,
      // secondary
      secondary: secondary,
      // secondary foreground
      onSecondary: generated.onSecondary,
      // e.g Card filled background
      secondaryContainer: generated.secondaryContainer,
      // e.g Card filled foreground
      onSecondaryContainer: generated.onSecondaryContainer,
      // tertiary
      tertiary: tertiary,
      // tertiary foreground
      onTertiary: generated.onTertiary,
      // e.g. Scaffold background
      surface: background,
      // e.g. Text
      onSurface: generated.onSurface,
      // e.g. Text labels
      onSurfaceVariant: generated.onSurfaceVariant, // Alt: gray
      // e.g. Card background
      surfaceContainer: generated.surfaceContainer,
      // e.g. Card overlay
      surfaceTint: generated.surfaceTint,
      // e.g. SnackBar background
      inverseSurface: generated.inverseSurface,
      // e.g. SnackBar foreground
      onInverseSurface: generated.onInverseSurface,
      // e.g. SnackBar TextButton
      inversePrimary: generated.inversePrimary,
      // e.g. TextField border
      outline: gray,
      // e.g. Divider
      outlineVariant: lightGray,
      // Error background (e.g. Snackbar)
      error: generated.error,
      // Error foreground (e.g. Snackbar Text)
      onError: generated.onError,
    );

    // Text color
    textColor = scheme.onSurface;
    titleTextColor = darkAccent;
  }
}
