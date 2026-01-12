import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để theo dõi trạng thái kết nối mạng
final connectivityProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Kiểm tra trạng thái ban đầu
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult != ConnectivityResult.none;
  
  // Lắng nghe thay đổi kết nối
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
});

/// Provider đơn giản hóa để kiểm tra có kết nối hay không
final isConnectedProvider = Provider.autoDispose<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.when(
    data: (isConnected) => isConnected,
    loading: () => false, // Giả định không có kết nối khi đang kiểm tra
    error: (_, _) => false,
  );
});
