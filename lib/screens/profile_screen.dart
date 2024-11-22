import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../styles/app_styles.dart';
import '../widgets/image_skeleton.dart';
import '../widgets/localization.dart';

/// Profile screen with user details
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with Localization {
  void _logout() async {
    final UserProvider userProvider = context.read<UserProvider>();

    if (userProvider.isLoggedIn) {
      await userProvider.logout();
    }

    // Redirect to login after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigation.navigateToAuth(AppScreens.login, l);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          _logout();
          return noLoggedIn();
        }

        // Logged in
        final User user = userProvider.user!;

        return Scaffold(
          appBar: AppBar(
            title: Text(l.profile),
            actions: [
              // Logout
              Tooltip(
                message: l.logout,
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                ),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile picture
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppStyles.color.scheme.surface,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: user.picture != null
                      ? ImageSkeleton(
                          imageUrl: user.picture!,
                          onErrorContext: () => user,
                          borderRadius: BorderRadius.circular(50),
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 200,
                          color: AppStyles.color.secondary,
                        ),
                ),
                const SizedBox(height: 16),
                // Name
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    user.name,
                    style: AppStyles.text.header.copyWith(
                      color: AppStyles.color.textColor,
                    ),
                  ),
                ),
                // Email
                if (user.email != null)
                  Text(
                    user.email!,
                    style: AppStyles.text.italic,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget noLoggedIn() {
    return Scaffold(
      appBar: AppBar(
        title: Text(l.logout),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 128),
              const SizedBox(height: 32),
              Text(
                l.logoutRedirect,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
