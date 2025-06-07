class AppConfigs {
  static const String baseUrl = "https://your-api-domain.com/api/v1";
  static const String apiKey = "your-api-key-here";
  static const bool isApiKeyRequired = true;
  
  // Timeout configs
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
} 