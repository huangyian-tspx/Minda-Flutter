class AppConfigs {
  // OpenRouter API Configuration
  static const String openRouterBaseUrl = "https://openrouter.ai/api/v1";

  // === API KEYS CONFIGURATION ===
  // FREE API KEYS (for testing/development)
  static const String _freeApiKey1 =
      "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";
  static const String _freeApiKey2 =
      "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";

  // PAID API KEY (for production - currently commented out)
  static const String _paidApiKey =
      "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";

  // Current active API key (using free key for testing)
  static const String openRouterApiKey =
      _paidApiKey; // Switch to _freeApiKey2 or _paidApiKey when needed

  // Model configuration - using lighter model for free tier
  static const String openRouterModel =
      "anthropic/claude-3.5-sonnet"; // May need to switch to cheaper model for free tier

  // Alternative free tier models (uncomment if needed)
  // static const String openRouterModel = "meta-llama/llama-3.2-3b-instruct:free";
  // static const String openRouterModel = "microsoft/phi-3-mini-128k-instruct:free";

  // Legacy API configs (updated to use free keys)
  static const String baseUrl = "https://openrouter.ai/api/v1";
  static const String apiKey = openRouterApiKey; // Use the same key

  // Notion Configuration (unchanged)
  static const String dbIDNotion = "20e6726c-3fe6-80c8-9fbf-db756961cd1e";
  static const String apiKeyNotion =
      "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";
  static const bool isApiKeyRequired = true;

  // Timeout configs (increased for free tier which might be slower)
  static const Duration connectTimeout = Duration(
    seconds: 45,
  ); // Increased from 30
  static const Duration receiveTimeout = Duration(
    seconds: 90,
  ); // Increased from 60

  // OpenRouter specific configs
  static const String appName = "Mind AI App";
  static const String appUrl = "https://mind-ai-app.com";

  // === CACHING CONFIGURATION ===
  static const String cacheBoxName = "prompt_cache";
  static const Duration cacheExpiry = Duration(hours: 24); // Cache for 24 hours
  static const int maxCacheSize = 100; // Maximum number of cached responses
}
