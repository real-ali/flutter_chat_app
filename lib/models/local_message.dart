import 'package:chat/chat.dart';

class LocalMessage {
  String chatId;
  String get getId => _id;
  String _id;
  Message message;

  ReceiptStatus receipt;

  LocalMessage({this.chatId, this.message, this.receipt});

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'id': message.getId,
        'sender': message.from,
        'receiver': message.to,
        'contents': message.contents,
        'receipt': receipt.value(),
        'received_at': message.timeStamp.toString(),
      };

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message(
      from: json['sender'],
      to: json['receiver'],
      contents: json['contents'],
      timeStamp: DateTime.parse(json['received_at']),
    );
    final localmessage = LocalMessage(
      chatId: json['chatId'],
      message: message,
      receipt: Enumparsing.formString(json['receipt']),
    );
    localmessage._id = json['id'];
    return localmessage;
  }
}
