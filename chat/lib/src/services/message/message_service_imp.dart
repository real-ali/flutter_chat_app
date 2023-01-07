import 'dart:async';

import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_contract.dart';
import 'package:chat/src/services/message/message_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final Rethinkdb r;
  final IEncryption _encryption;
  final _controller = StreamController<Message>.broadcast();
  StreamSubscription _changefeed;

  MessageService(this._connection, this.r, {IEncryption iEncryption})
      : _encryption = iEncryption;

  @override
  dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  @override
  Stream<Message> message({User activeUser}) {
    _startReceivingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<Message> send(Message message) async {
    var data = message.toJson();
    if (_encryption != null) {
      data['contents'] = _encryption.encrypt(message.contents);
    }

    Map record = await r
        .table('messages')
        .insert(data, {'return_changes': true}).run(_connection);
    return Message.fromJson(record['changes'].first['new_val']);
  }

  void _startReceivingMessages(User activeUser) {
    _changefeed = r
        .table('messages')
        .filter({'to': activeUser.getId})
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
                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
                _removeDeliveredMessage(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    if (_encryption != null) {
      data['contents'] = _encryption.decrypt(data['contents']);
    }
    return Message.fromJson(data);
  }

  void _removeDeliveredMessage(Message message) {
    r
        .table('messages')
        .get(message.getId)
        .delete({'return_changes': false}).run(_connection);
  }
}
