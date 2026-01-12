import 'package:flutter/cupertino.dart';

/// Block bài tập thực hành - tương tác cho người học
class PracticeBlock extends StatefulWidget {
  final Map<String, dynamic> data;
  // {title, description, code_template, solution, hint}

  const PracticeBlock({super.key, required this.data});

  @override
  State<PracticeBlock> createState() => _PracticeBlockState();
}

class _PracticeBlockState extends State<PracticeBlock> {
  bool _showHint = false;
  bool _showSolution = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title']?.toString() ?? 'Bài tập thực hành';
    final description = widget.data['description']?.toString();
    final codeTemplate = widget.data['code_template']?.toString();
    final solution = widget.data['solution']?.toString();
    final hint = widget.data['hint']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemGreen.withValues(alpha: 0.1),
            CupertinoColors.activeGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.activeGreen.withValues(alpha: 0.4),
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
                  color: CupertinoColors.activeGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.pencil_circle_fill,
                  color: CupertinoColors.activeGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: CupertinoColors.label,
                ),
              ),
            ),
          ],
          if (codeTemplate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff282c34),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📝 Code mẫu (hãy hoàn thiện):",
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    codeTemplate,
                    style: const TextStyle(
                      fontFamily: 'MyCodeFont',
                      color: CupertinoColors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (hint != null)
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                    onPressed: () {
                      setState(() => _showHint = !_showHint);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showHint
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          size: 16,
                          color: CupertinoColors.systemOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _showHint ? 'Ẩn gợi ý' : 'Xem gợi ý',
                          style: const TextStyle(
                            color: CupertinoColors.systemOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (hint != null && solution != null) const SizedBox(width: 12),
              if (solution != null)
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                    onPressed: () {
                      setState(() => _showSolution = !_showSolution);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showSolution
                              ? CupertinoIcons.lock_fill
                              : CupertinoIcons.lock_open,
                          size: 16,
                          color: CupertinoColors.systemBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _showSolution ? 'Ẩn đáp án' : 'Xem đáp án',
                          style: const TextStyle(
                            color: CupertinoColors.systemBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_showHint && hint != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.lightbulb_fill,
                    color: CupertinoColors.systemOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.label,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_showSolution && solution != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff282c34),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: CupertinoColors.activeGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Đáp án:",
                        style: TextStyle(
                          color: CupertinoColors.activeGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    solution,
                    style: const TextStyle(
                      fontFamily: 'MyCodeFont',
                      color: CupertinoColors.white,
                      fontSize: 14,
                      height: 1.5,
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
