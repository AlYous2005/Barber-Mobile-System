class AppUser {
  const AppUser({
    required this.username,
    required this.displayName,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.birthDate,
    this.avatarUrl,
    this.barberId,
  });

  final String username;
  final String displayName;
  final String role;

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? avatarUrl;

  /// يكون له قيمة فقط إذا المستخدم حلاق.
  final String? barberId;

  bool get isCustomer => role == 'customer';
  bool get isBarber => role == 'barber';

  AppUser copyWith({
    String? username,
    String? displayName,
    String? role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? birthDate,
    String? avatarUrl,
    String? barberId,
  }) {
    return AppUser(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      barberId: barberId ?? this.barberId,
    );
  }
}
