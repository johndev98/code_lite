import 'package:flutter/cupertino.dart';

void showExplanation(BuildContext context, String title, String content) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 17, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showUpdateDialog(
  BuildContext context,
  String title, {
  bool shouldPopScreen = false,
}) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: const Text("Nội dung đang được cập nhật!"),
      actions: [
        CupertinoDialogAction(
          child: const Text("Đóng"),
          onPressed: () {
            Navigator.pop(ctx);
            if (shouldPopScreen) Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
