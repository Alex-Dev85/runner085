class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Runner085';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String plansCollection = 'training_plans';
  static const String progressCollection = 'user_progress';
  static const String sessionsCollection = 'training_sessions';

  // SharedPreferences keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Training defaults
  static const int defaultSessionsPerWeek = 3;
  static const int maxSessionsPerWeek = 7;
}
