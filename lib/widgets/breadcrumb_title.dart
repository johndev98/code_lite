import 'package:flutter/cupertino.dart';

class BreadcrumbTitle extends StatefulWidget {
  final String breadcrumb;

  const BreadcrumbTitle({super.key, required this.breadcrumb});

  @override
  State<BreadcrumbTitle> createState() => _BreadcrumbTitleState();
}

class _BreadcrumbTitleState extends State<BreadcrumbTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(BreadcrumbTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breadcrumb != widget.breadcrumb) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<String> parts = widget.breadcrumb.split(' -> ');
        String display = widget.breadcrumb;
        bool isTruncated = false;

        if (_hasOverflow(display, constraints.maxWidth)) {
          isTruncated = true;
          while (parts.length > 1) {
            parts.removeAt(0);
            display = parts.join(' -> ');
            if (!_hasOverflow(display, constraints.maxWidth)) break;
          }
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.activeBlue.withValues(alpha: 0.08),
                  CupertinoColors.systemPurple.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTruncated) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      size: 12,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 12,
                    color: CupertinoColors.secondaryLabel.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(child: _buildBreadcrumbItems(parts, isTruncated)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbItems(List<String> parts, bool isTruncated) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: parts.asMap().entries.map((entry) {
        final index = entry.key;
        final part = entry.value;
        final isLast = index == parts.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLast
                    ? CupertinoColors.activeBlue.withValues(alpha: 0.15)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: isLast
                    ? Border.all(
                        color: CupertinoColors.activeBlue.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLast)
                    const Icon(
                      CupertinoIcons.bookmark_fill,
                      size: 10,
                      color: CupertinoColors.activeBlue,
                    ),
                  if (isLast) const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      part,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                        color: isLast
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.label,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_right,
                size: 10,
                color: CupertinoColors.secondaryLabel.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
            ],
          ],
        );
      }).toList(),
    );
  }

  bool _hasOverflow(String text, double maxWidth) {
    const style = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    // Thêm padding và spacing cho các phần tử
    final estimatedWidth = tp.width + (text.split(' -> ').length * 40) + 100;
    return estimatedWidth > maxWidth;
  }
}
