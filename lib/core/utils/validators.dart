class Validators {
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters long';
    }
    return null;
  }
}