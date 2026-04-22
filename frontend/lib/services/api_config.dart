class ApiConfig {
  // STRICT LOCAL CONFIGURATION
  // Enforced by Connection Failure Audit
  static const String baseUrl = 'http://192.168.7.98:8000'; 
  
  static const Duration timeout = Duration(seconds: 15);
}
