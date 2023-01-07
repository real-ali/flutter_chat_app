part of 'typing_bloc.dart';

abstract class TypingNotificationEvent extends Equatable {
  const TypingNotificationEvent();
  @override
  List<Object> get props => [];

  factory TypingNotificationEvent.onSubscribe(User user,
          {List<String> userWithChat}) =>
      Subscribed(user, userWithChat: userWithChat);
  factory TypingNotificationEvent.onTypingEventSent(TypingEvent event) =>
      TypingNotificationSent(event);
}

class Subscribed extends TypingNotificationEvent {
  final User user;
  final List<String> userWithChat;
  const Subscribed(this.user, {this.userWithChat});
  @override
  List<Object> get props => [user, userWithChat];
}

class NotSubscribed extends TypingNotificationEvent {}

class TypingNotificationSent extends TypingNotificationEvent {
  final TypingEvent event;

  const TypingNotificationSent(this.event);
  @override
  List<Object> get props => [event];
}

class _TypingNotificationReceived extends TypingNotificationEvent {
  final TypingEvent event;

  const _TypingNotificationReceived(this.event);
  @override
  List<Object> get props => [event];
}
