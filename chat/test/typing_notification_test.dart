import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  TypingNotification sut;

  setUp(() async {
    connection = await r.connect(host: '172.17.0.2');
    await createDb(r, connection);
    sut = TypingNotification(connection, r, null);
  });

  // tearDown(() async {
  //   sut.dispose();
  //   await cleanDb(r, connection);
  // });
  final user = User.fromJson({
    'id': '1234',
    'username': 'reza',
    'photoURL': 'photoURL',
    'active': true,
    'lastSeen': DateTime.now(),
  });
  final user2 = User.fromJson({
    'id': '1111',
    'username': 'ali',
    'photoURL': 'photoURL',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent typing notification Successfully', () async {
    TypingEvent typingEvent = TypingEvent(
      from: user2.getId,
      to: user.getId,
      event: Typing.start,
    );
    final res = await sut.send(event: typingEvent);
    expect(res, true);
  });

  test('successfully subscribe and reveive typing events', () async* {
    sut.subscribe(user2, [user.getId]).listen(expectAsync1((event) {
      expect(event.from, user.getId);
    }, count: 2));
    TypingEvent typing = TypingEvent(
      from: user2.getId,
      to: user.getId,
      event: Typing.start,
    );
    TypingEvent stopTyping = TypingEvent(
      from: user2.getId,
      to: user.getId,
      event: Typing.stop,
    );

    await sut.send(event: typing);
    await sut.send(event: stopTyping);
  });
}
