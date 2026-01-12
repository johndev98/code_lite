import 'package:flutter/cupertino.dart';

class BreadcrumbTitle extends StatelessWidget {
  final String breadcrumb;
  
  const BreadcrumbTitle({super.key, required this.breadcrumb});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const style = TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        );
        List<String> parts = breadcrumb.split(' -> ');
        String display = breadcrumb;
        if (_hasOverflow(display, style, constraints.maxWidth)) {
          while (parts.length > 1) {
            parts.removeAt(0);
            display = "... -> ${parts.join(' -> ')}";
            if (!_hasOverflow(display, style, constraints.maxWidth)) break;
          }
        }
        return Text(
          display,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  bool _hasOverflow(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    return tp.width > maxWidth;
  }
}
