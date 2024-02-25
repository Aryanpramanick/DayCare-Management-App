import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';

void main() {
  test('Test Child Class', () {
    Child child = new Child('Vinay', 5, false, 0);

    // Verify child.
    expect(child.name, 'Vinay');
    expect(child.id, 5);
    expect(child.sharePermissions, false);
    expect(child.present, false);
  });
}
