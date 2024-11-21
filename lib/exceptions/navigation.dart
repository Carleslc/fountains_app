import '../router/app_screens.dart';
import 'error.dart';

///
/// Exceptions related to app navigation
///
abstract class NavigationException extends AppException {}

/// Cannot navigate to the requested route
class NavigationRouteException extends NavigationException {
  final AppRoute route;

  NavigationRouteException(this.route);

  @override
  String get message => 'Cannot navigate to $route';
}

/// Navigator state is invalid
class InvalidNavigationStateException implements NavigationException {
  static const String _message = 'NavigatorState is not attached';

  @override
  String get message => _message;
}

/// Cannot navigate to the requested route because Navigator state is invalid
class InvalidNavigationRouteStateException extends NavigationRouteException
    implements InvalidNavigationStateException {
  InvalidNavigationRouteStateException(super.route);

  @override
  String get message =>
      '${super.message}: ${InvalidNavigationStateException._message}';
}
