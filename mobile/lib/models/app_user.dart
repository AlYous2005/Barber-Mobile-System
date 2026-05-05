class AppUser {
  const AppUser({
    required this.username,
    required this.displayName,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.birthDate,
  });

  final String username;
  final String displayName;
  final String role;

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? birthDate;

  bool get isCustomer => role == 'customer';
  bool get isBarber => role == 'barber';
}
