import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../models/content_item.dart';

class ContentLoader {
  static Future<List<ContentItem>> loadCollection(String path) async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/$path'))
        .timeout(AppConfig.networkTimeout);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load content: ${response.statusCode}');
    }
    
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final items = jsonMap['items'] as List;
    
    return items
        .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
