import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider để quản lý index của bottom navigation bar
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);
