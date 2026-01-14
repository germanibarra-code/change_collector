import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
}

/// Initialize Supabase
///
/// Call this function in main() before runApp()
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
}

/// Global Supabase client instance
///
/// Use this to access Supabase throughout your app:
/// - Authentication: supabase.auth
/// - Database: supabase.from('table_name')
/// - Storage: supabase.storage
final supabase = Supabase.instance.client;
