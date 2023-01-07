import 'dart:async';

import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final Rethinkdb _r;

  ReceiptService(Connection connection, Rethinkdb r)
      : _connection = connection,
        _r = r;
  final _controller = StreamController<Receipt>.broadcast();

  @override
  dispose() {
    _controller.close();
  }

  @override
  Stream<Receipt> receipts(User user) async* {
    _startReceivingRecripts(user);
    yield* _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    var data = receipt.toJson();

    Map record = await _r.table('messages').insert(data).run(_connection);
    return record['inserted'] == 1;
  }

  StreamSubscription _changefeed;
  void _startReceivingRecripts(User activeUser) {
    _changefeed = _r
        .table('receipts')
        .filter({'recipient': activeUser.getId})
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
                final reseipt = receiptFromFeed(feedData);
                _removeDeliveredReceipt(reseipt);
                _controller.sink.add(reseipt);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Receipt receiptFromFeed(feedData) {
    var data = feedData['new_val'];

    return Receipt.fromJson(data);
  }

  void _removeDeliveredReceipt(Receipt reseipt) {
    _r
        .table('receipts')
        .get(reseipt.getId)
        .delete({'return_changes': false}).run(_connection);
  }
}
