import 'dart:async';

import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final IMessageService _messageService;
  StreamSubscription _subscription;
  MessageBloc(this._messageService) : super(MessageState.initial()) {
    @override
    Stream<MessageState> mapEventToState(MessageEvent event) async* {
      if (event is Subscribed) {
        await _subscription.cancel();
        _subscription =
            _messageService.message(activeUser: event.user).listen((message) {
          add(_MessageReceived(message));
        });
      }

      if (event is _MessageReceived) {
        yield MessageState.received(event.message);
      }

      if (event is MessageSent) {
        final message = await _messageService.send(event.message);
        yield MessageState.sent(message);
      }
    }

    on<MessageEvent>((event, emit) => mapEventToState(event));

    @override
    Future<void> close() {
      _subscription?.cancel();
      _messageService.dispose();
      return super.close();
    }
  }
}
