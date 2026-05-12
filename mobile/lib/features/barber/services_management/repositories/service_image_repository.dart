import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase_config.dart';

class ServiceImageRepository {
  const ServiceImageRepository();

  static const String bucketName = 'service-images';

  Future<String> uploadServiceImage({
    required String barberId,
    required XFile image,
  }) async {
    final Uint8List bytes = await image.readAsBytes();

    final String extension = _extensionFromFileName(image.name);
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_service_image.$extension';

    final String storagePath = '$barberId/$fileName';

    await SupabaseConfig.client.storage
        .from(bucketName)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeFromExtension(extension),
            upsert: false,
          ),
        );

    return SupabaseConfig.client.storage
        .from(bucketName)
        .getPublicUrl(storagePath);
  }

  Future<void> deleteServiceImageByPublicUrl(String? imageUrl) async {
    final String? storagePath = _storagePathFromPublicUrl(imageUrl);

    if (storagePath == null) {
      return;
    }

    await SupabaseConfig.client.storage.from(bucketName).remove([storagePath]);
  }

  String? _storagePathFromPublicUrl(String? imageUrl) {
    if (imageUrl == null) {
      return null;
    }

    final String cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(cleanUrl);
    if (uri == null) {
      return null;
    }

    final List<String> segments = uri.pathSegments;

    final int bucketIndex = segments.indexOf(bucketName);
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
      return null;
    }

    return segments.sublist(bucketIndex + 1).join('/');
  }

  String _extensionFromFileName(String fileName) {
    final String cleanName = fileName.trim().toLowerCase();

    if (cleanName.endsWith('.png')) {
      return 'png';
    }

    if (cleanName.endsWith('.webp')) {
      return 'webp';
    }

    if (cleanName.endsWith('.jpg') || cleanName.endsWith('.jpeg')) {
      return 'jpg';
    }

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
