class AppConfigs {
  // OpenRouter API Configuration
  static const String openRouterBaseUrl = "https://openrouter.ai/api/v1";
  static const String openRouterApiKey =
      "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"; // Thay bằng API key thật
  static const String openRouterModel =
      "anthropic/claude-3.5-sonnet"; // Model mặc định

  // Legacy API configs (giữ lại để backward compatibility)
  static const String baseUrl = "https://openrouter.ai/api/v1";
  static const String apiKey =
      "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";
  static const String dbIDNotion = "20e6726c-3fe6-80c8-9fbf-db756961cd1e";
  static const String apiKeyNotion =
      "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";
  static const bool isApiKeyRequired = true;

  // Timeout configs
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(
    seconds: 60,
  ); // Tăng timeout cho AI response

  // OpenRouter specific configs
  static const String appName = "Mind AI App";
  static const String appUrl = "https://mind-ai-app.com";
}
