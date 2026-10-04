// Checks typed on the sign-in and create-account forms.
// The server still decides whether the account is valid.

const int sierraLeoneCountryCode = 232;

String? validateEmailAddress(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) {
    return 'Enter your email address';
  }
  final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (!emailPattern.hasMatch(input)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter your phone number';
  }
  if (sierraLeoneNationalNumber(value) == null) {
    return 'Enter an 8-digit Sierra Leone number';
  }
  return null;
}

/// Eight-digit national number, or null when [value] is not a Sierra Leone mobile number.
String? sierraLeoneNationalNumber(String? value) {
  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (digits.isEmpty) {
    return null;
  }
  final national = _nationalDigits(digits);
  if (!RegExp(r'^\d{8}$').hasMatch(national)) {
    return null;
  }
  return national;
}

String formatSierraLeoneNumber(String nationalDigits) {
  return '+$sierraLeoneCountryCode ${nationalDigits.substring(0, 2)} ${nationalDigits.substring(2)}';
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter your password';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}

String _nationalDigits(String digits) {
  var national = digits;
  if (national.startsWith('$sierraLeoneCountryCode') && national.length > 3) {
    national = national.substring(3);
  }
  if (national.startsWith('0')) {
    national = national.substring(1);
  }
  return national;
}
