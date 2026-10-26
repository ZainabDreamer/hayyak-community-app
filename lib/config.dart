/// Base URL of your Firebase Realtime Database.
///
/// Pass it at run/build time instead of editing code:
///   flutter run --dart-define=DATABASE_URL=https://<your-project-id>-default-rtdb.firebaseio.com
const String kDatabaseUrl = String.fromEnvironment(
  'DATABASE_URL',
  defaultValue: 'https://YOUR-PROJECT-ID-default-rtdb.firebaseio.com',
);
