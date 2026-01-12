import 'package:flutter/cupertino.dart';

class CupertinoDivider extends StatelessWidget {
  const CupertinoDivider({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: CupertinoColors.systemGrey5,
    );
  }
}
