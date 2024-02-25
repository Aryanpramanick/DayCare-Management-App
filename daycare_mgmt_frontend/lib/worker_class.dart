class Worker {
  Worker({
    required this.uuid,
    required this.firstname,
    required this.parentId,
    required this.lastname,
    required this.time_stamp,
    required this.last_message,
  });
  final String firstname;
  final String lastname;
  final int parentId;
  final int uuid;
  String time_stamp;
  final String last_message;
}
