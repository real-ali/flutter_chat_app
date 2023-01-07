import 'dart:async';

import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification_service_contract.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class TypingNotification implements ITypingNotification {
  final Connection _connection;
  final Rethinkdb _r;
  final _controller = StreamController<TypingEvent>.broadcast();
  final IUserService _userService;

  TypingNotification(this._connection, this._r, this._userService);

  @override
  Stream<TypingEvent> subscribe(User user, List<String> usersId) {
    _startReceivingTypingEvents(user, usersId);
    return _controller.stream;
  }

  @override
  Future<bool> send({TypingEvent event}) async {
    final revieiver = await _userService.fetch(event.to);
    if (!revieiver.active) return false;

    final record = await _r.table('typing_events').insert(
      event.toJson(),
      {
        'conflict': 'update',
      },
    ).run(_connection);
    return record['inserted'] == 1;
  }

  StreamSubscription _changeFeed;
  _startReceivingTypingEvents(User user, List<String> usersId) {
    _changeFeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(user.getId)
              .and(_r.expr(usersId).contains(event('from')));
        })
        .changes(
          {'include_initial': true},
        )
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;
                final typing = _eventFromFeed(feedData);
                _controller.sink.add(typing);
                _removeEvent(typing);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  void _removeEvent(TypingEvent event) {
    _r
        .table('typing_events')
        .get(event.getId)
        .delete({'return_changes': false}).run(_connection);
  }

  @override
  void dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }
}
