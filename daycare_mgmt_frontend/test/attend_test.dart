import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/attend_class.dart';

void main() {
  test('Attend class constuctor', () {
    DateTime now = DateTime.now();
    Attend attend = new Attend(1, 6, 5, now, false);

    // Verify attend.\
    expect(attend.id, 1);
    expect(attend.childID, 6);
    expect(attend.workerID, 5);
    expect(attend.time, now);
    expect(attend.present, false);
  });
}
