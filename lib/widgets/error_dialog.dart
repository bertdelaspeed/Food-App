import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;
  ErrorDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          // ignore: sort_child_properties_last
          child: const Center(
            child: Text('OK'),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue[400],
          ),
        )
      ],
    );
  }
}
