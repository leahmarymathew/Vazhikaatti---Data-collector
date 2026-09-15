class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://vazhikaatti-data-collector.onrender.com',
  );
  static const requestTimeout = Duration(seconds: 20);
}
