import 'package:flutter/cupertino.dart';

/// Block điểm kiểm tra - đảm bảo người học hiểu trước khi tiếp tục
class CheckpointBlock extends StatefulWidget {
  final String question;
  final List options;
  final int correctAnswer;
  final String? explanation;

  const CheckpointBlock({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  @override
  State<CheckpointBlock> createState() => _CheckpointBlockState();
}

class _CheckpointBlockState extends State<CheckpointBlock> {
  int? _selectedAnswer;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final isCorrect = _selectedAnswer == widget.correctAnswer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemYellow.withValues(alpha: 0.15),
            CupertinoColors.systemOrange.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemOrange.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: CupertinoColors.systemOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Điểm kiểm tra",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Hãy trả lời câu hỏi này trước khi tiếp tục để đảm bảo bạn đã hiểu!",
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value.toString();
            final isSelected = _selectedAnswer == index;
            final isCorrectOption = index == widget.correctAnswer;

            return GestureDetector(
              onTap: () {
                if (!_showResult) {
                  setState(() {
                    _selectedAnswer = index;
                    _showResult = true;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _showResult && isCorrectOption
                      ? CupertinoColors.activeGreen.withValues(alpha: 0.1)
                      : isSelected && !isCorrectOption
                          ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                          : isSelected
                              ? CupertinoColors.systemBlue.withValues(alpha: 0.1)
                              : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showResult && isCorrectOption
                        ? CupertinoColors.activeGreen
                        : isSelected && !isCorrectOption
                            ? CupertinoColors.systemRed
                            : isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemGrey4,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _showResult && isCorrectOption
                            ? CupertinoColors.activeGreen
                            : isSelected && !isCorrectOption
                                ? CupertinoColors.systemRed
                                : isSelected
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.label,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_showResult && isSelected)
                      Icon(
                        isCorrectOption
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.xmark_circle_fill,
                        color: isCorrectOption
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemRed,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (_showResult) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? CupertinoColors.activeGreen.withValues(alpha: 0.1)
                    : CupertinoColors.systemRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemRed,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.xmark_circle_fill,
                    color: isCorrect
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.systemRed,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCorrect ? "Chính xác! 🎉" : "Chưa đúng 😔",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.systemRed,
                          ),
                        ),
                        if (widget.explanation != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.explanation!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.label,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
