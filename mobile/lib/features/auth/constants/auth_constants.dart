class AuthRoles {
  const AuthRoles._();

  static const customer = 'customer';
  static const barber = 'barber';
  static const admin = 'admin';
}

class AuthMetadataKeys {
  const AuthMetadataKeys._();

  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const phoneNumber = 'phone_number';
  static const role = 'role';
  static const birthDate = 'birth_date';
  static const areaId = 'area_id';
}

class ProfileColumnNames {
  const ProfileColumnNames._();

  static const id = 'id';
  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const phoneNumber = 'phone_number';
  static const role = 'role';
  static const birthDate = 'birth_date';
  static const avatarUrl = 'avatar_url';
  static const phoneVerified = 'phone_verified';
  static const phoneVerifiedAt = 'phone_verified_at';
  static const areaId = 'area_id';
}

class BarberColumnNames {
  const BarberColumnNames._();

  static const id = 'id';
  static const profileId = 'profile_id';
}
