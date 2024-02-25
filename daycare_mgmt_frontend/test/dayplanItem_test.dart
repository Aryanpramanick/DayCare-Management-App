import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/dayplanItem_class.dart';

void main() {
  test('Test dayplanItem Class', () {
    //Testing the dayplanItem class
    DayplanItem plan =
        new DayplanItem('Hiking', 'a', '2023-04-04', '03:24', '12:45', 5, 5);

    // Verify dayplanItem.
    expect(plan.title, 'Hiking');
    expect(plan.note, 'a');
    expect(plan.date, '2023-04-04');
    expect(plan.startTime, '03:24');
    expect(plan.endTime, '12:45');
    expect(plan.workerId, 5);
    expect(plan.tabColor, 5);
  });
}
