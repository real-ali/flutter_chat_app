part of 'message_bloc.dart';

@immutable
abstract class MessageState extends Equatable {
  const MessageState();
  @override
  List<Object> get props => [];

  factory MessageState.initial() => MessageInitial();
  factory MessageState.sent(Message message) => MessageSentSuccess(message);
  factory MessageState.received(Message message) =>
      MessageReceivedSuccess(message);
}

class MessageInitial extends MessageState {}

class MessageSentSuccess extends MessageState {
  final Message message;
  const MessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MessageReceivedSuccess extends MessageState {
  final Message message;
  const MessageReceivedSuccess(this.message);

  @override
  List<Object> get props => [message];
}
