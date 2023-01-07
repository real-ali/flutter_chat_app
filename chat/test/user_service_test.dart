import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  UserService sut;

  setUp(() async {
    connection = await r.connect(host: '172.17.0.2', port: 28015);
    await createDb(r, connection);
    sut = UserService(r, connection);
  });

  // tearDown(() async {
  //   await cleanDb(r, connection);
  // });

  test('create a new User document in database', () async {
    final user = User(
      username: 'test',
      photoURL: 'uel',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await sut.connect(user);
    expect(userWithId.getId, isNotEmpty);
  });
}
