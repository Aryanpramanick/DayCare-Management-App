import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/parent_class.dart';

void main() {
  test('Test Parent Class', () {
    Parent parent = new Parent(
        uuid: 1,
        firstname: 'Vinay',
        parentId: 5,
        lastname: 'Parab',
        time_stamp: '2023',
        last_message: 'hello');

    // Verify parent.
    expect(parent.uuid, 1);
    expect(parent.firstname, 'Vinay');
    expect(parent.parentId, 5);
    expect(parent.lastname, 'Parab');
    expect(parent.time_stamp, '2023');
    expect(parent.last_message, 'hello');
  });
}
