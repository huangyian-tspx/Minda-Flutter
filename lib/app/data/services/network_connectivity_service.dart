import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  // Trạng thái kết nối có thể được lắng nghe từ mọi nơi
  final RxBool isConnected = true.obs;

  NetworkConnectivityService() {
    _initialize();
  }

  void _initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      isConnected.value = false;
    } else {
      isConnected.value = true;
    }
  }
  
  // Hàm để người dùng gọi khi bấm nút "Thử lại"
  Future<bool> retryConnectionCheck() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return isConnected.value;
  }

  void dispose() {
    _subscription.cancel();
  }
} 