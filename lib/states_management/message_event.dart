part of 'message_bloc.dart';

@immutable
abstract class MessageEvent extends Equatable {
  const MessageEvent();
  @override
  List<Object> get props => [];

  factory MessageEvent.onSubscribe(User user) => Subscribed(user);
  factory MessageEvent.onMessageSent(Message message) => MessageSent(message);
}

class Subscribed extends MessageEvent {
  final User user;

  const Subscribed(this.user);
  @override
  List<Object> get props => [user];
}

class MessageSent extends MessageEvent {
  final Message message;

  const MessageSent(this.message);
  @override
  List<Object> get props => [message];
}

class _MessageReceived extends MessageEvent {
  final Message message;

  const _MessageReceived(this.message);
  @override
  List<Object> get props => [message];
}
