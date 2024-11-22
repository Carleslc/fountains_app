import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exceptions/auth.dart';
import '../providers/user_provider.dart';
import '../router/app_screens.dart';
import '../router/navigation.dart';
import '../styles/app_styles.dart';
import '../utils/message.dart';
import '../utils/spacing.dart';
import '../widgets/form_validation.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/localization.dart';
import '../widgets/logo.dart';

/// Login user screen
class LoginScreen extends StatefulWidget {
  final String? email; // prefill from another screen (e.g. register)

  const LoginScreen({super.key, this.email});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with FormValidation, Localization {
  late UserProvider _userProvider;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text.trim();
  String get password => _passwordController.text.trim();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _emailController.text = widget.email ?? '';
    addValidation(_emailController, _validateEmail, email.isNotEmpty);
    addValidation(_passwordController, _validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return l.emailRequired;
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return l.passwordRequired;
    }
    if (password.length < 6) {
      return l.minLength(6);
    }
    return null;
  }

  /// Login user and handle errors
  Future<void> _login() async {
    if (!validateSubmit()) return;
    setState(() => _isLoading = true);
    try {
      await _userProvider.login(
        email: email,
        password: password,
      );
      // Navigate back on success
      Navigation.backFromAuth(l);
    } on AuthException catch (e, stackTrace) {
      if (e.report) {
        ShowMessage.error(
          e.localizedMessage(l),
          log: e.message,
          errorObject: e,
          errorContext: _emailController.text,
          stackTrace: stackTrace,
          report: e.report,
        );
      } else {
        ShowMessage.warning(
          e.localizedMessage(l),
          log: e.message,
          context: _emailController.text,
        );
      }
    } catch (e, stackTrace) {
      // Other errors
      ShowMessage.error(
        l.authenticationFailed,
        log: 'Error logging in user',
        errorObject: e,
        stackTrace: stackTrace,
        report: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Register?
  Widget _askRegister() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l.askRegister),
        ElevatedButton(
          onPressed: () => Navigation.navigateToAuth(
            AppScreens.register,
            l,
            email: _emailController.text,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(128, 42),
            elevation: 2,
          ),
          child: Text(l.registerAction, style: AppStyles.text.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.orientationOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.login),
        bottom: _isLoading ? const LoadingIndicator() : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Fix height to center content with scroll view
                // Adjust with padding and viewInsets when keyboard is shown
                minHeight:
                    max(0, constraints.maxHeight - viewInsets.bottom - 64),
              ),
              child: Center(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (orientation == Orientation.landscape) _askRegister(),
                      if (orientation == Orientation.portrait &&
                          !isKeyboardShown)
                        const Logo(size: 128),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child:
                            Text(l.loginAction, style: AppStyles.text.header),
                      ),
                      Text(l.loginUsageComment),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 512),
                        child: Column(
                          children: [
                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l.email,
                              ),
                              validator: validator(_emailController),
                              onTapOutside: (_) {
                                unfocus();
                                validateField(_emailController);
                              },
                              onEditingComplete: () {
                                validateField(_emailController);
                                FocusScope.of(context).nextFocus();
                              },
                              onChanged: (_) {
                                validateForm();
                                setState(() {});
                              },
                            ),
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l.password,
                                errorMaxLines: 2,
                              ),
                              validator: validator(_passwordController),
                              onTapOutside: (_) {
                                unfocus();
                                validateField(_passwordController);
                              },
                              onEditingComplete: () {
                                validateField(_passwordController);
                                _login();
                              },
                              onChanged: (_) {
                                validateForm();
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            // Login button
                            FilledButton(
                              onPressed: isValid && !_isLoading ? _login : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(160, 44),
                                elevation: 1,
                              ),
                              child: Text(l.loginButton),
                            ),
                          ].withSpacing(8),
                        ),
                      ),
                      if (orientation == Orientation.portrait) ...[
                        const SizedBox(height: 64),
                        _askRegister(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
