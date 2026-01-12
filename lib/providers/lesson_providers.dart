import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

/// Provider để cache từ điển - sử dụng keepAlive để giữ cache trong suốt app lifecycle
final dictionaryCacheProvider = StateNotifierProvider<DictionaryCacheNotifier, Map<String, Map<String, dynamic>>>(
  (ref) {
    final notifier = DictionaryCacheNotifier();
    // Giữ cache trong suốt app lifecycle
    ref.keepAlive();
    return notifier;
  },
);

class DictionaryCacheNotifier extends StateNotifier<Map<String, Map<String, dynamic>>> {
  DictionaryCacheNotifier() : super({});

  Future<void> loadDictionary(String dictKey, String languageId, {String? customPath}) async {
    // Nếu đã có trong cache thì không load lại
    if (state.containsKey(dictKey)) {
      return;
    }

    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String finalUrl;
      
      if (customPath != null) {
        finalUrl = '${AppConfig.baseUrl}/$customPath.json?t=$timestamp';
      } else {
        finalUrl =
            '${AppConfig.baseUrl}/content/dictionary/languages/$languageId.json?t=$timestamp';
      }

      final dictResponse = await http
          .get(Uri.parse(finalUrl))
          .timeout(AppConfig.networkTimeout);
      
      if (dictResponse.statusCode == 200) {
        final dictData = jsonDecode(dictResponse.body) as Map<String, dynamic>;
        state = {...state, dictKey: dictData};
      }
    } catch (e) {
      // Lỗi sẽ được xử lý ở UI layer
    }
  }
}

/// Provider để load lesson data - auto dispose khi không dùng
final lessonDataProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, LessonParams>(
  (ref, params) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final lessonUrl = '${AppConfig.baseUrl}/${params.path}?t=$timestamp';

    final lessonResponse = await http
        .get(Uri.parse(lessonUrl))
        .timeout(AppConfig.networkTimeout);
    
    if (lessonResponse.statusCode != 200) {
      throw Exception("Lỗi tải bài học: ${lessonResponse.statusCode}");
    }

    final lessonData = jsonDecode(lessonResponse.body) as Map<String, dynamic>;

    // Xác định từ điển
    String? customPath = lessonData['dictionary_path'] as String?;
    if (customPath != null && customPath.endsWith('.json')) {
      customPath = customPath.replaceAll('.json', '');
    }

    final dictKey = customPath ?? 'languages/${params.languageId}';

    // Load từ điển nếu chưa có (sử dụng cache provider)
    final cacheNotifier = ref.read(dictionaryCacheProvider.notifier);
    await cacheNotifier.loadDictionary(dictKey, params.languageId, customPath: customPath);

    // Giữ provider alive trong khi đang hiển thị lesson
    ref.keepAlive();

    return {
      'lesson': lessonData,
      'active_dict_path': dictKey,
    };
  },
);

/// Parameters cho lesson provider
class LessonParams {
  final String path;
  final String languageId;

  LessonParams({
    required this.path,
    required this.languageId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonParams &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          languageId == other.languageId;

  @override
  int get hashCode => path.hashCode ^ languageId.hashCode;
}
