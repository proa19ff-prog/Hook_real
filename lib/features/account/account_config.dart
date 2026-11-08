/// Supabase project coordinates for the account & sync backend.
///
/// These two values are PUBLIC by design — they identify the project, they
/// do not authorize anything by themselves. Every table is protected by
/// row-level security (see supabase/schema.sql), so the anon key only
/// allows a signed-in user to touch their own row.
///
/// Paste the values from the Supabase dashboard → Project Settings → API.
abstract final class AccountConfig {
  /// `https://<project-ref>.supabase.co`
  static const String supabaseUrl = 'https://jmemvsxtragmklosehcp.supabase.co';

  /// The `anon` / `publishable` public key.
  static const String supabaseAnonKey = 'sb_publishable_n-j-N2PZMIXagkNzyauY8A_0tY3BIls';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
