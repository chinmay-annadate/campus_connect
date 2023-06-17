import 'package:flutter/material.dart';

// exit confirmation dialog
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exit Confirmation'),
      content: const Text('Are you sure you want to exit?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            // pops dialog
            Navigator.of(context)
                .pop(false); // Return false when "Cancel" is pressed
          },
        ),
        TextButton(
          child: const Text('Exit'),
          onPressed: () {
            // pops dialog
            Navigator.of(context).pop(true);
            // Return true when "Exit" is pressed
          },
        ),
      ],
    );
  }
}

// Implementation example in your widget:

Future<bool?> showExitConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const ExitConfirmationDialog();
    },
  );
}
