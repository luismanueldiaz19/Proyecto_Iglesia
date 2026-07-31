class ApiConfig {
  ApiConfig._(); // Prevenir instanciación

  // Base URL de la API de Laravel
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Módulo de Contabilidad
  static const String accounts = '$baseUrl/accounts';
}
