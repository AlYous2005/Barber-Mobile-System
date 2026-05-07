import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_config.dart';

class BarberSalonImageRepository {
  const BarberSalonImageRepository();

  static const String _bucketName = 'barber-images';

  Future<String?> getSalonImageUrl({required String barberId}) async {
    final row = await SupabaseConfig.client
        .from('barbers')
        .select('salon_image_url')
        .eq('id', barberId)
        .maybeSingle();

    return row?['salon_image_url']?.toString();
  }

  Future<String> uploadSalonImage({
    required String barberId,
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final imagePath = _buildSalonImagePath(barberId);

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
        .from('barbers')
        .update({'salon_image_url': freshPublicUrl})
        .eq('id', barberId);

    return freshPublicUrl;
  }

  Future<void> removeSalonImage({
    required String barberId,
    String? salonImageUrl,
  }) async {
    final imagePath = _buildSalonImagePath(barberId);

    await SupabaseConfig.client.storage.from(_bucketName).remove([imagePath]);

    await SupabaseConfig.client
        .from('barbers')
        .update({'salon_image_url': null})
        .eq('id', barberId);
  }

  String _buildSalonImagePath(String barberId) {
    return 'barbers/$barberId/salon-image.jpg';
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
