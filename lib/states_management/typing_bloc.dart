import 'dart:async';

import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'typing_event.dart';
part 'typing_state.dart';

class TypingNotificationBloc
    extends Bloc<TypingNotificationEvent, TypingNotificationState> {
  final ITypingNotification _typingNotification;
  StreamSubscription _subscription;
  TypingNotificationBloc(this._typingNotification)
      : super(TypingNotificationState.initial()) {
    @override
    Stream<TypingNotificationState> mapEventtoState(
        TypingNotificationEvent typingEvent) async* {
      if (typingEvent is Subscribed) {
        if (typingEvent.userWithChat == null) {
          add(NotSubscribed());
          return;
        }
        await _subscription.cancel();
        _subscription = _typingNotification
            .subscribe(typingEvent.user, typingEvent.userWithChat)
            .listen((typingNotify) {
          add(_TypingNotificationReceived(typingNotify));
        });
      }

      if (typingEvent is _TypingNotificationReceived) {
        yield TypingNotificationState.received(typingEvent.event);
      }

      if (typingEvent is TypingNotificationSent) {
        await _typingNotification.send(event: typingEvent.event);
        yield TypingNotificationState.sent();
      }

      if (TypingEvent is NotSubscribed) {
        yield TypingNotificationState.initial();
      }
    }

    @override
    Future<void> close() {
      _subscription?.cancel();
      _typingNotification.dispose();
      return super.close();
    }
  }
}
