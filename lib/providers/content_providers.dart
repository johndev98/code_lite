import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import '../utils/content_loader.dart';
import 'connectivity_provider.dart';

/// Provider để load danh sách courses với tự động retry khi có kết nối
final coursesProvider = FutureProvider.autoDispose<List<ContentItem>>((ref) async {
  // Lắng nghe thay đổi connectivity và tự động refresh khi có kết nối lại
  ref.listen(connectivityProvider, (_, next) {
    next.whenData((isConnected) {
      // Hễ có kết nối mạng (isConnected == true) thì refresh provider
      if (isConnected) {
        ref.invalidateSelf();
      }
    });
  });

  return ContentLoader.loadCollection('content/courses/index.json');
});

/// Provider để load collection theo path với tự động retry khi có kết nối
final collectionProvider = FutureProvider.autoDispose.family<List<ContentItem>, String>(
  (ref, path) async {
    // Lắng nghe thay đổi connectivity và tự động refresh khi có kết nối lại
    ref.listen(connectivityProvider, (_, next) {
      next.whenData((isConnected) {
        if (isConnected) {
          ref.invalidateSelf();
        }
      });
    });

    return ContentLoader.loadCollection(path);
  },
);
