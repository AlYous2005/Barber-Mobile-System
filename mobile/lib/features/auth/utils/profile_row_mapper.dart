import '../auth.dart';

String readTextFromRow(Map<String, dynamic> row, String key) {
  return (row[key] ?? '').toString().trim();
}

AppUser mapProfileRowToAppUser({
  required String userId,
  required Map<String, dynamic> profileRow,
  String? barberId,
}) {
  final firstName = readTextFromRow(profileRow, ProfileColumnNames.firstName);
  final lastName = readTextFromRow(profileRow, ProfileColumnNames.lastName);
  final phoneNumber = readTextFromRow(
    profileRow,
    ProfileColumnNames.phoneNumber,
  );
  final role = readTextFromRow(profileRow, ProfileColumnNames.role);
  final avatarUrl = readTextFromRow(profileRow, ProfileColumnNames.avatarUrl);
  final areaId = readTextFromRow(profileRow, ProfileColumnNames.areaId);
  final birthDate = parseDateFromDatabase(
    profileRow[ProfileColumnNames.birthDate],
  );

  final displayName = '$firstName $lastName'.trim();

  return AppUser(
    username: userId,
    displayName: displayName,
    role: role,
    firstName: firstName.isNotEmpty ? firstName : null,
    lastName: lastName.isNotEmpty ? lastName : null,
    phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
    birthDate: birthDate,
    barberId: barberId,
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    areaId: areaId.isNotEmpty ? areaId : null,
  );
}
