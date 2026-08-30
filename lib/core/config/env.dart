class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mzezvswyticghhlsskff.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_QKcGTfAk1a3mC7ybqL88Jg_ZOlXLxXd',
  );

  /// The "Web application" OAuth client ID from Google Cloud Console —
  /// NOT the Android client ID. Supabase needs this one to verify the ID
  /// token Google Sign-In returns. See the setup steps for where to get
  /// this. Replace the placeholder below once you have it.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '1096116553943-82afio9ov0r29qbhg349lj5cvql4564q.apps.googleusercontent.com',
  );
}
