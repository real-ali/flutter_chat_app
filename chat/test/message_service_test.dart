import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service.dart';
import 'package:chat/src/services/message/message_service_imp.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService sut;

  setUp(() async {
    final encryption = EncryptionService(
        Encrypter(AES(Key.fromLength(32), IV.fromLength(16))));
    connection = await r.connect(host: '172.17.0.2', port: 28015);
    await createDb(r, connection);
    sut = MessageService(connection, r, iEncryption: encryption);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1111',
    'username': 'ali',
    'photoURL': 'photoURL',
    'active': true,
    'lastSeen': DateTime.now(),
  });
  final user2 = User.fromJson({
    'id': '2222',
    'username': 'reza',
    'photoURL': 'photoURL',
    'active': true,
    'lastSeen': DateTime.now(),
  });
  test("Sent Message successfully", () async {
    Message message = Message(
      from: user1.getId,
      to: '3456',
      timeStamp: DateTime.now(),
      contents: 'this is a message',
    );
    final res = await sut.send(message);
    expect(res, true);
  });

  test("Succesfully subscribe and receive message", () async* {
    const content = 'this is contents';
    sut.message(activeUser: user2).listen(expectAsync1((message) {
          expect(message.to, user2.getId);
          expect(message.getId, isNotEmpty);
          expect(message.contents, content);
        }, count: 2));
    Message message = Message(
      from: user1.getId,
      to: user2.getId,
      timeStamp: DateTime.now(),
      contents: content,
    );
    Message secondMessage = Message(
      from: user1.getId,
      to: user2.getId,
      timeStamp: DateTime.now(),
      contents: "this is another message",
    );

    sut.send(message);
    sut.send(secondMessage);
  });
  test("Succesfully subscribe and receive new message", () {
    Message message = Message(
      from: user1.getId,
      to: user2.getId,
      timeStamp: DateTime.now(),
      contents: "this is a message",
    );
    Message secondMessage = Message(
      from: user1.getId,
      to: user2.getId,
      timeStamp: DateTime.now(),
      contents: "this is another message",
    );

    sut.send(message);
    sut.send(secondMessage).whenComplete(
          () => sut.message(activeUser: user2).listen(
                (expectAsync1((message) {
                  expect(message.to, user2.getId);
                }, count: 2)),
              ),
        );
  });
}
