class CustomerProfileResult {
  const CustomerProfileResult({
    required this.displayName,
    required this.countryCode,
    required this.phoneNumber,
    this.avatarUrl,
  });

  final String displayName;
  final String countryCode;
  final String phoneNumber;
  final String? avatarUrl;

  bool get hasProfileImage {
    return avatarUrl != null && avatarUrl!.trim().isNotEmpty;
  }
}
