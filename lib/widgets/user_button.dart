import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../utils/logger.dart';
import '../utils/message.dart';
import 'localization.dart';

/// Button to navigate to user profile or login screen
class UserButton extends StatefulWidget {
  final Color? color;
  final double size;

  const UserButton({
    super.key,
    this.color,
    this.size = 28,
  });

  @override
  State<UserButton> createState() => _UserButtonState();
}

class _UserButtonState extends State<UserButton> with Localization {
  late UserProvider _userProvider;

  // Profile picture with error
  String? imageError;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _userProvider.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    _userProvider.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    final User? user = _userProvider.user;

    /// Logged in message
    if (user != null && !user.isAnonymous) {
      ShowMessage.show(l.loggedInAs(user.name), icon: Icons.person);
    } else if (user == null) {
      ShowMessage.show(l.loggedOut, icon: Icons.logout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return IconButton(
          tooltip: userProvider.isLoggedIn ? l.profile : l.login,
          onPressed: () {
            if (userProvider.isLoggedIn) {
              Navigation.navigateTo(AppScreens.profile, l, replace: false);
            } else {
              Navigation.navigateToAuth(AppScreens.login, l, replace: false);
            }
          },
          icon: _userIcon(userProvider.user),
        );
      },
    );
  }

  Widget _userIcon(final User? user) {
    if (user == null) {
      return Icon(
        Icons.person, // Alt: Icons.login
        size: widget.size,
        color: widget.color,
      );
    }
    if (user.picture == null || user.picture == imageError) {
      return Icon(
        Icons.account_circle,
        size: widget.size,
        color: widget.color,
      );
    }
    return CircleAvatar(
      backgroundColor: widget.color,
      foregroundImage: NetworkImage(user.picture!),
      radius: widget.size,
      onForegroundImageError: (e, stackTrace) {
        setState(() {
          imageError = user.picture;
        });
        errorWithContext(
          'Cannot load profile picture: ${user.picture}',
          errorObject: e,
          stackTrace: stackTrace,
          errorContext: () => user,
          report: true,
        );
      },
    );
  }
}
