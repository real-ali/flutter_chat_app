enum ReceiptStatus { sent, delivered, read }

extension Enumparsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus formString(String status) {
    return ReceiptStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  final String recipient;
  final String messageId;

  final ReceiptStatus status;
  final DateTime timeStamp;
  String get getId => _id;
  String _id;

  Receipt({
    this.recipient,
    this.messageId,
    this.status,
    this.timeStamp,
  });

  Map<String, dynamic> toJson() => {
        'recipient': recipient,
        'messageId': messageId,
        'status': status.value(),
        'timeStamp': timeStamp
      };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final user = Receipt(
      recipient: json['recipient'],
      messageId: json['messageId'],
      status: Enumparsing.formString(json['status']),
      timeStamp: json['timeStamp'],
    );
    user._id = json['id'];
    json.removeWhere((key, value) => value == null);

    return user;
  }
}
