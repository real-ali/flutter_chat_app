class Message {
  final String from;
  final String to;
  final DateTime timeStamp;
  final String contents;
  String _id;

  String get getId => _id;

  Message({
    this.from,
    this.to,
    this.timeStamp,
    this.contents,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'timeStamp': timeStamp,
        'contents': contents,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json['from'],
      to: json['to'],
      timeStamp: json['timeStamp'],
      contents: json['contents'],
    );
    message._id = json['id'];

    return message;
  }
}
