class PendingPhoneSignUp {
  const PendingPhoneSignUp({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.role,
    required this.areaId,
  });

  final String phoneNumber;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String role;
  final String areaId;

  String get displayName {
    return '$firstName $lastName'.trim();
  }
}
