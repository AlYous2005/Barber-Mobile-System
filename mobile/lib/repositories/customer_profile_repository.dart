import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_config.dart';

class CustomerProfileRepository {
  const CustomerProfileRepository();

  static const String _bucketName = 'barber-images';

  Future<Map<String, dynamic>?> getCustomerProfile({
    required String userId,
  }) async {
    return SupabaseConfig.client
        .from('profiles')
        .select('first_name, last_name, phone_number, avatar_url')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> updateCustomerProfile({
    required String userId,
    required String displayName,
    required String phoneNumber,
  }) async {
    final nameParts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await SupabaseConfig.client
        .from('profiles')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<String> uploadCustomerAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final extension = _extensionFromFileName(originalFileName);
    final storagePath = 'customers/$userId/avatar.$extension';

    await SupabaseConfig.client.storage
        .from(_bucketName)
        .uploadBinary(
          storagePath,
          imageBytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeFromExtension(extension),
          ),
        );

    final publicUrl = SupabaseConfig.client.storage
        .from(_bucketName)
        .getPublicUrl(storagePath);

    final versionedUrl =
        '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await SupabaseConfig.client
        .from('profiles')
        .update({
          'avatar_url': versionedUrl,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);

    return versionedUrl;
  }

  Future<void> removeCustomerAvatar({required String userId}) async {
    await SupabaseConfig.client
        .from('profiles')
        .update({
          'avatar_url': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId);
  }

  String _extensionFromFileName(String fileName) {
    final cleaned = fileName.trim().toLowerCase();

    if (cleaned.endsWith('.png')) return 'png';
    if (cleaned.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  String _contentTypeFromExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
