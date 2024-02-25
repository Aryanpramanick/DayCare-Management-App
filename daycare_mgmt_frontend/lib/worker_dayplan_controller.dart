// Convert 12 hour time to 24 hour time for startTime

twentyfourhourS(_startTime) {
  if (_startTime.split(":")[1].split(" ")[1] == "PM" &&
      int.parse(_startTime.split(":")[0]) < 12) {
    int h = int.parse(_startTime.split(":")[0]) + 12;
    int m = int.parse(_startTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  } else if (_startTime.split(":")[1].split(" ")[1] == "PM" &&
      int.parse(_startTime.split(":")[0]) == 12) {
    int h = int.parse(_startTime.split(":")[0]);
    int m = int.parse(_startTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  } else {
    int h = int.parse(_startTime.split(":")[0]);
    int m = int.parse(_startTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  }
}

// Convert 12 hour time to 24 hour time for endTime
twentyfourhourE(_endTime) {
  if (_endTime.split(":")[1].split(" ")[1] == "PM" &&
      int.parse(_endTime.split(":")[0]) < 12) {
    int h = int.parse(_endTime.split(":")[0]) + 12;
    int m = int.parse(_endTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  } else if (_endTime.split(":")[1].split(" ")[1] == "PM" &&
      int.parse(_endTime.split(":")[0]) == 12) {
    int h = int.parse(_endTime.split(":")[0]);
    int m = int.parse(_endTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  } else {
    int h = int.parse(_endTime.split(":")[0]);
    int m = int.parse(_endTime.split(":")[1].split(" ")[0]);
    return "$h:$m";
  }
}
