import 'package:flutter/cupertino.dart';

class QuizBlock extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const QuizBlock({super.key, required this.data});
  
  @override
  State<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<QuizBlock> {
  int? _selectedIndex;
  
  @override
  Widget build(BuildContext context) {
    final List options = widget.data['options'] ?? [];
    final int answer = widget.data['answer'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data['question'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (i) {
            final isCorrect = (i == answer);
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedIndex == i
                      ? (isCorrect
                            ? CupertinoColors.activeGreen.withValues(alpha: 0.2)
                            : CupertinoColors.systemRed.withValues(alpha: 0.2))
                      : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedIndex == i
                        ? (isCorrect
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemRed)
                        : CupertinoColors.systemGrey4,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "${String.fromCharCode(65 + i)}. ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(options[i].toString())),
                    if (_selectedIndex == i)
                      Icon(
                        isCorrect
                            ? CupertinoIcons.check_mark_circled
                            : CupertinoIcons.xmark_circle,
                        color: isCorrect
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemRed,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
