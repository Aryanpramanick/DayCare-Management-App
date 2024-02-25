import 'package:flutter/material.dart';

class DisplayError extends StatelessWidget {
  const DisplayError({Key? key, required this.error}) : super(key: key);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Something went wrong: $error'),
    );
  }
}
