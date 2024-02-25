import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/message_class.dart';

void main() {
  test('Test Message Class', () {
    Message text =
        new Message(text: 'Hello', date: '2023-04', sender: 5, receiver: 0);

    // Verify text.
    expect(text.text, 'Hello');
    expect(text.date, '2023-04');
    expect(text.sender, 5);
    expect(text.receiver, 0);
  });
}
