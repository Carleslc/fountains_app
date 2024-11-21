import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Adds `l` attribute to access localized texts (l10n)
mixin Localization<T extends StatefulWidget> on State<T> {
  /// App localized texts (l10n)
  AppLocalizations get l => _l10n;
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Set `l` to use the `AppLocalizations` of `context`
    _l10n = l10n(context);
  }
}

/// Shortcut for `AppLocalizations.of(context)!`
AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context)!;
