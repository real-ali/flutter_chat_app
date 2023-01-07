import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class UserService implements IUserService {
  final Rethinkdb r;
  final Connection _connection;

  UserService(this.r, this._connection);

  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    if (user.getId != null) data['id'] = user.getId;
    final result = await r.table('users').insert(
      data,
      {
        'conflict': 'update',
        'return_changes': true,
      },
    ).run(_connection);

    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnect(User user) async {
    await r.table('users').update({
      'id': user.getId,
      'username': user.username,
      'photoURL': user.photoURL,
      'active': false,
      'lastSeen': DateTime.now()
    }).run(_connection);
    _connection.close();
  }

  @override
  Future<List<User>> online() async {
    Cursor users =
        await r.table('users').filter(({'active': true})).run(_connection);
    final userList = await users.toList();
    return userList.map((item) => User.fromJson(item)).toList();
  }

  @override
  Future<User> fetch(String id) async {
    final user = await r.table('users').get(id).run(_connection);
    return User.fromJson(user);
  }
}
