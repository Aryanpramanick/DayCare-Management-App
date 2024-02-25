import 'dart:math';

class Message {
  String text;
  String date;
  int sender;
  int receiver;
  Message(
      {required this.text,
      required this.date,
      required this.sender,
      required this.receiver});
}

class MessageData {
  MessageData(
      {required this.sender,
      required this.sendername,
      required this.message,
      required this.receiver,
      required this.messageDate,
      required this.dateMessage,
      required this.profilePicture});
  final int sender;
  final int receiver;
  final String message;
  final DateTime messageDate;
  final String dateMessage;
  final String profilePicture;
  final String sendername;
}

// Generates random profile pictures for the messages
abstract class Helpers {
  static final random = Random();

  static String randomPictureName() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }
}
