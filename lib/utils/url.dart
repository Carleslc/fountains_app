import 'package:url_launcher/url_launcher.dart';

import '../exceptions/error.dart';
import 'logger.dart';
import 'message.dart';

/// Open [url] in the device browser or show an [onErrorMessage] if cannot open successfully
void openUrl(
  String url, {
  String Function()? onErrorMessage,
  Object Function()? onErrorContext,
}) {
  url = _https(url);

  debug('Open: $url');

  tryOrShowError(
    () async {
      bool success = await launchUrl(Uri.parse(url));

      if (!success) {
        final String logError = _onErrorLogMessage(url);
        final String showError = onErrorMessage?.call() ?? logError;

        ShowMessage.error(
          showError,
          log: logError,
          errorContext: onErrorContext?.call(),
        );
      }
    },
    onErrorMessage: onErrorMessage,
    onErrorContext: onErrorContext,
    onErrorLogMessage: (e) => _onErrorLogMessage(url),
  );
}

/// Ensure [url] has the protocol prefix (http, https)
String _https(String url) => url.startsWith('http') ? url : 'https://$url';

String _onErrorLogMessage(String url) => 'Could not open $url';
