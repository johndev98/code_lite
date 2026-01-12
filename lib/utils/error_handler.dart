import 'package:flutter/cupertino.dart';
import 'dialogs.dart';

class ErrorHandler {
  static void handleNetworkError(BuildContext context, String title) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showUpdateDialog(context, title),
    );
  }

  static void handleNetworkErrorWithPop(
    BuildContext context,
    String title,
  ) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showUpdateDialog(context, title, shouldPopScreen: true),
    );
  }
}
