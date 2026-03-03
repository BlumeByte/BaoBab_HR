class AppConstants {
  static const appName = 'Baobab HR';
  static const defaultAvatar =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300';
  static const bambooInspiredBlue = 0xFF0A66C2;

  // Use --dart-define=SUPABASE_URL=..., --dart-define=SUPABASE_ANON_KEY=..., --dart-define=PAYSTACK_PUBLIC_KEY=...
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const paystackPublicKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY', defaultValue: '');
}
