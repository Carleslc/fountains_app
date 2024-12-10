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

/// Register user screen
class RegisterScreen extends StatefulWidget {
  final String? email; // prefill from another screen (e.g. login)

  const RegisterScreen({super.key, this.email});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with FormValidation, Localization {
  late UserProvider _userProvider;

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text.trim();
  String get name => _nameController.text.trim();
  String get password => _passwordController.text.trim();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _emailController.text = widget.email ?? '';
    addValidation(_emailController, _validateEmail, email.isNotEmpty);
    addValidation(_passwordController, _validatePassword);
    addValidation(_nameController, _validateName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return l.emailRequired;
    }
    return null;
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return l.nameRequired;
    }
    if (name.length < 4) {
      return l.minLength(4);
    }
    if (name.length > 40) {
      return l.maxLength(40);
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

  /// Register user and handle errors
  Future<void> _register() async {
    if (!validateSubmit()) return;
    setState(() => _isLoading = true);
    try {
      await _userProvider.register(
        email: email,
        password: password,
        name: name,
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
        log: 'Error registering user',
        errorObject: e,
        stackTrace: stackTrace,
        report: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Login?
  Widget _askLogin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(l.askLogin),
        ElevatedButton(
          onPressed: () => Navigation.navigateToAuth(
            AppScreens.login,
            l,
            email: _emailController.text,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(128, 42),
            elevation: 2,
          ),
          child: Text(l.loginAction, style: AppStyles.text.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.orientationOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.register),
        bottom: _isLoading ? const LoadingIndicator() : null,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            // Fix height to center content with scroll view
            // Adjust with padding and viewInsets when keyboard is shown
            constraints: BoxConstraints(
              minHeight: max(0, constraints.maxHeight - viewInsets.bottom - 64),
            ),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (orientation == Orientation.landscape) _askLogin(),
                    if (orientation == Orientation.portrait && !isKeyboardShown)
                      const Logo(size: 128),
                    const SizedBox(height: 28),
                    Text(l.registerAction, style: AppStyles.text.header),
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
                          // User name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l.name,
                            ),
                            validator: validator(_nameController),
                            onTapOutside: (_) {
                              unfocus();
                              validateField(_nameController);
                            },
                            onEditingComplete: () {
                              validateField(_nameController);
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
                            ),
                            validator: validator(_passwordController),
                            onTapOutside: (_) {
                              unfocus();
                              validateField(_passwordController);
                            },
                            onEditingComplete: () {
                              validateField(_passwordController);
                              _register();
                            },
                            onChanged: (_) {
                              validateForm();
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          // Register button
                          FilledButton(
                            onPressed:
                                isValid && !_isLoading ? _register : null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(160, 44),
                              elevation: 1,
                            ),
                            child: Text(l.registerButton),
                          ),
                        ].withSpacing(8),
                      ),
                    ),
                    if (orientation == Orientation.portrait) ...[
                      const SizedBox(height: 48),
                      _askLogin(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
