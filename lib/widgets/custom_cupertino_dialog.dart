import 'package:flutter/cupertino.dart';

class CustomCupertinoDialog extends StatelessWidget {
  final String titleText;
  final String contentText;
  final String removeButtonText;
  final VoidCallback onRemovePressed;

  CustomCupertinoDialog({
    required this.titleText,
    required this.contentText,
    required this.removeButtonText,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(titleText),
      content: Text(contentText),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          onPressed: onRemovePressed,
          child: Text(removeButtonText),
        ),
      ],
    );
  }
}
