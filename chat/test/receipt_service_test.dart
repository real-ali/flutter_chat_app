import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;
  setUp(() async {
    connection = await r.connect(host: '172.17.0.2');
    await createDb(r, connection);
    sut = ReceiptService(connection, r);
  });

  // tearDown(() async {
  //   sut.dispose();
  //   await cleanDb(r, connection);
  // });

  final user = User.fromJson({
    'id': '1111',
    'username': 'ali',
    'photoURL': 'photoURL',
    'active': true,
    'lastSeen': DateTime.now(),
  });
  test('sent receipt successfully', () async {
    Receipt receipt = Receipt(
      recipient: '4444',
      messageId: '1234',
      status: ReceiptStatus.delivered,
      timeStamp: DateTime.now(),
    );
    final res = await sut.send(receipt);
    expect(res, true);
  });
  test('successfully subscribe and reveive receipts', () async* {
    sut.receipts(user).listen(expectAsync1((receipt) {
          expect(receipt.recipient, user.getId);
        }, count: 2));
    Receipt receipt = Receipt(
      recipient: user.getId,
      messageId: '12345',
      status: ReceiptStatus.delivered,
      timeStamp: DateTime.now(),
    );
    Receipt anotherReceipt = Receipt(
      recipient: user.getId,
      messageId: '12345',
      status: ReceiptStatus.read,
      timeStamp: DateTime.now(),
    );

    await sut.send(receipt);
    await sut.send(anotherReceipt);
  });
}
