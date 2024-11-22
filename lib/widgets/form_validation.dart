import 'package:flutter/material.dart';

/// Utility mixin to handle forms with validation
mixin FormValidation<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Enable / Disable validation for each field
  final Map<ValueNotifier, bool> validate = {};

  /// Validation functions returning a message if there is a validation error
  final Map<ValueNotifier, String? Function(bool validate, dynamic value)>
      _validations = {};

  late EdgeInsets viewInsets;

  /// Check if the keyboard is opened
  bool get isKeyboardShown => viewInsets.bottom > 0;

  @override
  void didChangeDependencies() {
    viewInsets = MediaQuery.viewInsetsOf(context);
    super.didChangeDependencies();
  }

  /// Unfocus text field only if keyboard is hidden
  void unfocus() {
    if (!isKeyboardShown) {
      FocusScope.of(context).unfocus();
    }
  }

  /// Add validation for a field
  void addValidation<F extends Object?, V>(
    ValueNotifier<F> field,
    String? Function(V value) validation, [
    bool enabled = false,
  ]) {
    validate[field] = enabled;
    _validations[field] =
        (validate, value) => validate ? validation(value) : null;
  }

  /// Get validator for a field using its validation function and validate state
  String? Function(V) validator<F extends Object?, V>(ValueNotifier<F> field) =>
      (value) => _validations[field]?.call(
            validate[field] == true,
            value is String ? value.trim() : value,
          );

  /// Enable field validation and validate form with current enabled fields
  void validateField(final ValueNotifier field) {
    validate[field] = true;
    validateForm();
  }

  /// Check if the form is currently valid according to
  /// the field validators and their validate state
  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Check if the form is valid to allow submit button,
  /// if all field validations are successful
  bool get isValid => _validations.entries
      .every((entry) => entry.value(true, entry.key.value.text) == null);

  /// Validate form before submit, enabling all validators
  bool validateSubmit() {
    _validations.keys.forEach((field) {
      validate[field] = true;
    });
    return validateForm();
  }
}
