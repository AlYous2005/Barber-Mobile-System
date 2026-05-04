class CustomerProfileResult {
  const CustomerProfileResult({
    required this.displayName,
    required this.countryCode,
    required this.phoneNumber,
    this.hasProfileImage = false,
  });

  final String displayName;
  final String countryCode;
  final String phoneNumber;
  final bool hasProfileImage;
}
