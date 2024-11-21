import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Platform extensions
extension PlatformExtension on BuildContext {
  /// The device current platform.
  TargetPlatform get platform => getPlatform(this);

  bool get isAndroid => platform == TargetPlatform.android;
  bool get isIOS => platform == TargetPlatform.iOS;
}

bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
bool get isWeb => kIsWeb;

/// The platform the material widgets should adapt to target.
///
/// Defaults to the current platform.
///
/// This should be used in order to style UI elements according to platform
/// conventions.
TargetPlatform getPlatform(BuildContext context) => Theme.of(context).platform;

/// The package info with version, package name, build number, etc.
late PackageInfo packageInfo;

/// Load app package information
Future<void> loadPackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}
