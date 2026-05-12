import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase_config.dart';

class BarberAvatarRepository {
  const BarberAvatarRepository();

  static const String _bucketName = 'barber-images';

  Future<String?> getBarberAvatarUrl({required String userId}) async {
    final row = await SupabaseConfig.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();

    return row?['avatar_url']?.toString();
  }

  Future<String> uploadBarberAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final imagePath = _buildAvatarImagePath(userId);

    await SupabaseConfig.client.storage
        .from(_bucketName)
        .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: FileOptions(
            contentType: _resolveContentType(originalFileName),
            upsert: true,
          ),
        );

    final publicUrl = SupabaseConfig.client.storage
        .from(_bucketName)
        .getPublicUrl(imagePath);

    final freshPublicUrl =
        '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await SupabaseConfig.client
        .from('profiles')
        .update({'avatar_url': freshPublicUrl})
        .eq('id', userId);

    return freshPublicUrl;
  }

  Future<void> removeBarberAvatar({required String userId}) async {
    final imagePath = _buildAvatarImagePath(userId);

    await SupabaseConfig.client.storage.from(_bucketName).remove([imagePath]);

    await SupabaseConfig.client
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', userId);
  }

  String _buildAvatarImagePath(String userId) {
    return 'profiles/$userId/barber-avatar.jpg';
  }

  String _resolveContentType(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.png')) {
      return 'image/png';
    }

    if (lowerFileName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }
}
