part of 'typing_bloc.dart';

abstract class TypingNotificationState extends Equatable {
  const TypingNotificationState();
  @override
  List<Object> get props => [];

  factory TypingNotificationState.initial() => TypingNotificationInitial();
  factory TypingNotificationState.sent() => TypingNotificationSentSuccess();
  factory TypingNotificationState.received(TypingEvent typingEvent) =>
      TypingNotificationReceivedSuccess(typingEvent);
}

class TypingNotificationInitial extends TypingNotificationState {}

class TypingNotificationSentSuccess extends TypingNotificationState {}

class TypingNotificationReceivedSuccess extends TypingNotificationState {
  final TypingEvent typingEvent;
  const TypingNotificationReceivedSuccess(this.typingEvent);

  @override
  List<Object> get props => [typingEvent];
}
