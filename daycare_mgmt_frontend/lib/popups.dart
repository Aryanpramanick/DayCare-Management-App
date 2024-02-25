import 'package:flutter/material.dart';

enum popUpDialogType { Error, Success, Info, Warning }

void loadDialog(BuildContext context) {
  if (!context.mounted) return; // if the context is not mounted, return
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text("Loading..."),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  width: 20,
                ),
                Text("Please wait")
              ],
            ),
          ));
}

Future<int> popUpDialog(BuildContext context, popUpDialogType type,
    String title, String message) async {
  if (!context.mounted) return -1; // if the context is not mounted, return
  Map<popUpDialogType, IconData> icons = {
    popUpDialogType.Error: Icons.error,
    popUpDialogType.Success: Icons.check_circle,
    popUpDialogType.Info: Icons.info,
    popUpDialogType.Warning: Icons.warning
  };

  int dialog_input = 0;
  Map<popUpDialogType, List<Widget>> buttons = {
    popUpDialogType.Error: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"))
    ],
    popUpDialogType.Success: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"))
    ],
    popUpDialogType.Info: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"))
    ],
    popUpDialogType.Warning: [
      TextButton(
          onPressed: () {
            dialog_input = 1;
            Navigator.of(context).pop();
          },
          child: const Text("OK")),
      TextButton(
          onPressed: () {
            dialog_input = 0;
            Navigator.of(context).pop();
          },
          child: const Text("Cancel")),
    ]
  };

  await showDialog(
      builder: (context) => AlertDialog(
            key: Key('dialog'),
            title: Text(title),
            icon: Icon(icons[type]),
            content: Text(message),
            actions: buttons[type],
          ),
      context: context);

  return dialog_input;
}
