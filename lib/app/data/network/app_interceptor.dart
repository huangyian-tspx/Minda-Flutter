import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/config/app_configs.dart';

class AppInterceptor extends QueuedInterceptorsWrapper {
  final logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 100),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i(
        "REQUEST[${options.method}] => PATH: ${options.path}\nHEADERS: ${options.headers}\nBODY: ${options.data}");
    
    // Thêm các header chung
    options.headers['Content-Type'] = 'application/json';

    // Thêm API Key nếu được config
    if (AppConfigs.isApiKeyRequired) {
      options.headers['Authorization'] = 'Bearer ${AppConfigs.apiKey}';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
        "RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\nDATA: ${response.data}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
        "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\nMESSAGE: ${err.message}");
    super.onError(err, handler);
  }
} 