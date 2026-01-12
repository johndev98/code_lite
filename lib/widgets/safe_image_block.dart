import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class SafeImageBlock extends StatefulWidget {
  final String url;
  final String? caption;
  
  const SafeImageBlock({super.key, required this.url, this.caption});
  
  @override
  State<SafeImageBlock> createState() => _SafeImageBlockState();
}

class _SafeImageBlockState extends State<SafeImageBlock> {
  bool _hasError = false;
  
  @override
  Widget build(BuildContext context) {
    if (_hasError || widget.url.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                height: 200,
                color: CupertinoColors.systemGrey6,
                child: const Center(child: CupertinoActivityIndicator()),
              ),
              errorWidget: (_, _, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _hasError = true);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
          if (widget.caption != null && !_hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.caption!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
