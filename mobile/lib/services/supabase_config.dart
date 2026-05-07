import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasRequiredValues {
    return url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
  }

  static Future<void> initialize() async {
    if (!hasRequiredValues) {
      throw StateError(
        'Missing Supabase environment values. '
        'Run the app with --dart-define=SUPABASE_URL=... '
        'and --dart-define=SUPABASE_ANON_KEY=...',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey, debug: kDebugMode);
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}
