import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'data/services/local_storage_service.dart';
import 'data/network/app_interceptor.dart';
import 'data/network/rest_client.dart';
import 'core/config/app_configs.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // SharedPreferences
  sl.registerSingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());
  await sl.isReady<SharedPreferences>();
  
  // LocalStorageService
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService(sl<SharedPreferences>()));
  
  // Dio (Network client)
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfigs.baseUrl,
      connectTimeout: AppConfigs.connectTimeout,
      receiveTimeout: AppConfigs.receiveTimeout,
    ));
    dio.interceptors.add(AppInterceptor());
    return dio;
  });

  // RestClient (API client)
  sl.registerLazySingleton<RestClient>(() => RestClient(sl<Dio>()));
} 