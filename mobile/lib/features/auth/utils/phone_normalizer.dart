String normalizePhoneForAuth(String phoneNumber) {
  final trimmed = phoneNumber.trim();

  if (trimmed.startsWith('+')) {
    return trimmed.replaceAll(RegExp(r'\s+'), '');
  }

  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

  if (digitsOnly.startsWith('970')) {
    return '+$digitsOnly';
  }

  if (digitsOnly.startsWith('972')) {
    return '+$digitsOnly';
  }

  if (digitsOnly.startsWith('0')) {
    return '+970${digitsOnly.substring(1)}';
  }

  return '+970$digitsOnly';
}
