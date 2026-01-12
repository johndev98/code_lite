import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_item.dart';
import '../utils/content_loader.dart';

/// Provider để load danh sách courses
final coursesProvider = FutureProvider.autoDispose<List<ContentItem>>((ref) async {
  return ContentLoader.loadCollection('content/courses/index.json');
});

/// Provider để load collection theo path
final collectionProvider = FutureProvider.autoDispose.family<List<ContentItem>, String>(
  (ref, path) async {
    return ContentLoader.loadCollection(path);
  },
);
