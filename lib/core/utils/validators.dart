class Validators {
  const Validators._();

  static String? required(String? value, [String label = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? latitude(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a valid latitude';
    if (parsed < -90 || parsed > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  static String? longitude(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a valid longitude';
    if (parsed < -180 || parsed > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  static String? positiveNumber(String? value, [String label = 'Value']) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a valid $label';
    if (parsed <= 0) return '$label must be greater than zero';
    return null;
  }
}
