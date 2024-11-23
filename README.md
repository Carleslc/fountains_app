# Fountains Finder

🇪🇸 **Buscador de fuentes**

<!-- toc -->

- [Images](#images)
- [Install](#install)
- [App structure](#app-structure)
- [Development](#development)
  * [Visual Studio Code](#visual-studio-code)
  * [Build](#build)
    + [i18n / l10n](#i18n--l10n)
    + [Firebase](#firebase)
    + [Android](#android)
    + [iOS](#ios)
    + [Web](#web)
  * [Release](#release)
- [Resources](#resources)
  * [Flutter](#flutter)
  * [Design](#design)
  * [Maps](#maps)
  * [Release](#release-1)
  * [Other](#other)
- [Libraries](#libraries)
  * [Design](#design-1)
  * [Localization](#localization)
  * [Logging](#logging)
  * [Network](#network)
  * [State management](#state-management)
  * [Permissions](#permissions)
  * [Maps and geolocation](#maps-and-geolocation)
  * [Firebase](#firebase-1)
    + [Authentication](#authentication)
    + [Firestore Database](#firestore-database)
    + [Cloud Storage](#cloud-storage)
    + [Analytics](#analytics)
    + [Crashlytics](#crashlytics)
  * [Release](#release-2)
  * [Other](#other-1)

<!-- tocstop -->

This app helps users find public drinking water sources,
supporting efforts towards sustainable development and the protection of this vital resource.

<a href="https://idx.google.com/import?url=https%3A%2F%2Fgithub.com%2FCarleslc%2Ffountains_app%2F" target="_blank">
  <picture>
    <source
      media="(prefers-color-scheme: dark)"
      srcset="https://cdn.idx.dev/btn/open_dark_32.svg">
    <source
      media="(prefers-color-scheme: light)"
      srcset="https://cdn.idx.dev/btn/open_light_32.svg">
    <img
      height="32"
      alt="Open in IDX"
      src="https://cdn.idx.dev/btn/open_purple_32.svg">
  </picture>
</a>

## Images

![5](<./images/5.png>)

Display fountains markers near your location, with clustering.

![6](<./images/6.png>)

In cities.

![7](<./images/7.png>)

And forests.

![11](<./images/11.png>)

There is a zoom limit to not overload your device memory and data usage while keeping a good performance.

![12](<./images/12.png>)

Different kind of water sources, different types of data information.

![14](<./images/14.png>)

Some fountains of turistic interest have an image and maybe also a website.

![16](<./images/16.png>)

You can edit fountains information directly in OpenStreetMap: https://www.openstreetmap.org/

Your changes will be reflected in the app after at most 24 hours.

![17](<./images/17.png>)

Also works without location permission.

![18](<./images/18.png>)

Accessibility data. Open in Google Maps button.

![19-en](<./images/19-en.png>)

🇺🇸🇬🇧 App information.

![19-es](<./images/19-es.png>)

🇪🇸 Información de la aplicación.

![20](<./images/20.png>)

Attribution.

![21](<./images/21.png>)

Log in.

![22](<./images/22.png>)

Sign up.

![25](<./images/25.png>)

Translated to English, Spanish and Catalan.

![26](<./images/26.png>)

Image, distance and accessibility information.

![27](<./images/27.png>)

Fail-safe error handling for unstable networks and connection issues.

![28](<./images/28.png>)

Map with rotation and button at top-right to reset rotation to north.

## Install

1. [Install Flutter SDK](https://docs.flutter.dev/get-started/install).

2. Clone the repository:

```sh
git clone https://github.com/Carleslc/fountains_app.git
# GitHub CLI: gh repo clone Carleslc/fountains_app

cd fountains_app
```

3. Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run # -h
```

## App structure

```
lib
├── exceptions
├── l10n
├── models
├── providers
├── router
├── screens
├── services
├── styles
├── utils
├── widgets
├── firebase_options.dart
└── main.dart
```

Flutter app code is at `lib/`.

The starting point is at `main.dart`.

`exceptions`: exceptions of the application domain.

`l10n`: localized messages in English, Spanish and Catalan.

`models`: the models of the application domain, both serializable _data models_ and other utility ones.

`providers`: data providers to manage the state of the data obtained through the different services.

`router`: the screens are defined with routes for navigation between screens of the application, which can be accessed with a global context from the _Navigation_ class.

`screens`: the different screens of the application, starting with the _SplashScreen_. It is important to know, however, that a significant part of the UI code is in other classes that do not correspond exactly to a screen, such as the `widgets/fountain_details.dart` dialog, the `widgets/fountain_marker.dart` marker and the map classes located in the `widgets/map` folder.

`services`: services that use different libraries to obtain the location of the user's device, manage connection changes, manage the user session and obtain the water sources of the _backend_ API.

`styles`: where the main styles of the application are defined, with themes for different widgets in `AppStyles` and centralization of colors and text styles.

`utils`: other utility classes and extensions that do not correspond to a widget. The most relevant ones are `logger.dart` which is responsible for centralizing logging and error management and `message.dart` which is responsible for showing messages.

`widgets`: the rest of the widgets are mostly utility in order to simplify the code.

## Development

### Visual Studio Code

[Install Flutter extension](https://docs.flutter.dev/tools/vs-code)

Run the app at `lib/main.dart` (`Run | Debug`).

Open Flutter DevTools with `Cmd+Shift+P` → `Flutter: Open DevTools`

### Build

#### i18n / l10n

Generate [localization]((https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization))
files using `l10n.yaml` configuration and `lib/l10n` `.arb` files:

```sh
flutter gen-l10n
```

These files are also generated on flutter build and run.

If some translations are missing they are reported in `l10n_missing_translations.json`.

#### [Firebase](https://console.firebase.google.com/)

[Configure Firebase](https://firebase.google.com/docs/flutter/setup?hl=es-419&platform=android) for this project:

```sh
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase project
flutterfire configure
```

This will generate different [firebase configuration files](https://firebase.google.com/docs/projects/learn-more#config-files-objects) to setup the firebase project:

```
firebase.json
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

#### Android

Build the app in debug or release mode:

```sh
flutter build apk --debug
flutter build apk --release
```

Build app bundle:

```sh
flutter build appbundle --debug
flutter build appbundle --release
```

Install the app in your device:

```sh
# Check connected devices
adb devices

# Default connected device
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Specific device (serial device-ID, e.g. emulator-5554)
adb -s device-ID install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s device-ID install -r build/app/outputs/flutter-apk/app-release.apk

# Uninstall app from the device
adb uninstall me.carleslc.fountains
adb -s device-ID uninstall me.carleslc.fountains
```

#### iOS

Build the app in debug or release mode:

```sh
flutter build ios --debug
flutter build ios --release
```

#### Web

```sh
flutter build web --debug
flutter build web --release
```

### [Release](https://docs.flutter.dev/deployment/android#reference-the-keystore-from-the-app)

Generate release key store:

```sh
keytool -genkey -v -keystore android/app/release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fountains_app
```

Configure environment variables with the key and password you provided in the key store:

```sh
cp android/key.template.properties android/key.properties

vim android/key.properties
```

Build the release app:

```sh
flutter build apk --release
```

### [App fingerprint](https://developers.google.com/android/guides/client-auth)

SHA1

```sh
# Debug fingerprint
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
# default password: android

# Release fingerprint
keytool -list -v -alias fountains_app -keystore android/app/release-key.jks
# use password from android/key.properties
```

## Resources

### Flutter

- [Flutter Docs](https://docs.flutter.dev/)
- [Flutter API](https://api.flutter.dev/)
- [Material Widgets](https://docs.flutter.dev/ui/widgets/material)
- [Dart Style Guide](https://dart.dev/effective-dart)
- [Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [JSON Serialization](https://docs.flutter.dev/data-and-backend/serialization/json)

### Design

- [Colors Palette](https://coolors.co/03256c-2541b2-1768ac-06bee1-ffffff)
- [Font: Quicksand](https://fonts.google.com/specimen/Quicksand)
- [Icons: Material Symbols](https://fonts.google.com/icons?icon.set=Material+Symbols)
- [Images: Freepik](https://www.freepik.es/search?format=families&iconType=standard&last_filter=iconType&last_value=standard&shape=lineal-color&type=icon)
- [Mockups: sketchize](https://www.sketchize.com/)

### Maps

- [Geolocation and Maps packages](https://fluttergems.dev/geolocation-maps/)
- [google_maps_flutter Guide](https://medium.com/@patrick.lange.dev/flutter-displaying-openstreetmap-data-on-google-maps-f52de62d5afc)

### Release

- [Release Documentation](https://docs.flutter.dev/deployment) ([android](https://docs.flutter.dev/deployment/android), [ios](https://docs.flutter.dev/deployment/ios))
- [App Icon](https://docs.flutter.dev/ui/assets/assets-and-images#updating-the-app-icon) ([android](https://docs.flutter.dev/deployment/android#add-a-launcher-icon))
- [Splash Screen](https://docs.flutter.dev/ui/assets/assets-and-images#updating-the-launch-screen) ([android](https://docs.flutter.dev/platform-integration/android/splash-screen), [ios](https://docs.flutter.dev/platform-integration/ios/splash-screen))
- [Icon Kitchen](https://icon.kitchen/) / [Android: Image Asset Studio](https://developer.android.com/studio/write/create-app-icons)
- [Bundle _google_fonts_ for release](https://pub.dev/packages/google_fonts#bundling-fonts-when-releasing)
- [Setup Android app name localizations](https://developer.android.com/guide/topics/resources/app-languages)
- [Setup iOS localizations for App Store](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#localizing-for-ios-updating-the-ios-app-bundle)

### Other

- [Android API Levels](https://apilevels.com/)
- [JSON Data Models: Quicktype](https://app.quicktype.io/)

## Libraries

### Design
- [google_fonts](https://pub.dev/packages/google_fonts)
- [material_symbols_icons](https://pub.dev/packages/material_symbols_icons)

### Localization
- [intl](https://pub.dev/packages/intl)

### Logging
- [logger](https://pub.dev/packages/logger)

### Network
- [http](https://pub.dev/packages/http)
- [url_launcher](https://pub.dev/packages/url_launcher)
- [connectivity](https://pub.dev/packages/connectivity)
- [internet_connection_checker_plus](https://pub.dev/packages/internet_connection_checker_plus)

### State management
- [provider](https://pub.dev/packages/provider)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

### Permissions
- [permission_handler](https://pub.dev/packages/permission_handler)

### Maps and geolocation
- [latlong2](https://pub.dev/packages/latlong2)
- [geolocator](https://pub.dev/packages/geolocator)
- [geocoding](https://pub.dev/packages/geocoding)
- [flutter_map](https://fluttergems.dev/packages/flutter_map/)
- [flutter_map_location_marker](https://pub.dev/packages/flutter_map_location_marker)
- [flutter_map_marker_cluster](https://pub.dev/packages/flutter_map_marker_cluster)

### Firebase
- [firebase_core](https://pub.dev/packages/firebase_core)

#### Authentication
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [google_sign_in](https://pub.dev/packages/google_sign_in)

#### Firestore Database
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)

#### Cloud Storage
- [firebase_storage](https://pub.dev/packages/firebase_storage)

#### Analytics
- [firebase_analytics](https://pub.dev/packages/firebase_analytics)

#### Crashlytics
- [firebase_crashlytics](https://pub.dev/packages/firebase_crashlytics)

### Release
`--dev`
- [package_rename](https://pub.dev/packages/package_rename)
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

### Other
- [introduction_screen](https://pub.dev/packages/introduction_screen)
- [package_info_plus](https://pub.dev/packages/package_info_plus)
- [skeletonizer](https://pub.dev/packages/skeletonizer)
