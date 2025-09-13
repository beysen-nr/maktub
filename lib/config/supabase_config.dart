import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://zmnbmhkgdhijswyggghx.supabase.co';
  static const String supabaseAnonKey = '';

  static final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseAnonKey);
}

