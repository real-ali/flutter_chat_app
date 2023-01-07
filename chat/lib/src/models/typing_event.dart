enum Typing { start, stop }

extension TypingEnumparsing on Typing {
  String value() {
    return toString().split('.').last;
  }

  static Typing formString(String status) {
    return Typing.values.firstWhere((element) => element.value() == status);
  }
}

class TypingEvent {
  String get getId => _id;
  final String from;
  final String to;
  final Typing event;
  String _id;

  TypingEvent({
    this.from,
    this.to,
    this.event,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'event': event.value(),
      };

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final user = TypingEvent(
      from: json['from'],
      to: json['to'],
      event: TypingEnumparsing.formString(json['event']),
    );
    user._id = json['id'];
    json.removeWhere((key, value) => value == null);

    return user;
  }
}
