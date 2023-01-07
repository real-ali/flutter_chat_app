// import 'package:chat/chat.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:labalaba/data/datasources/sqflit_dataource.dart';
// import 'package:labalaba/models/chat.dart';
// import 'package:labalaba/models/local_message.dart';
// import 'package:mockito/mockito.dart';
// import 'package:sqflite/sqlite_api.dart';

// class MockSqfLiteDatabase extends Mock implements Database {}

// class MockBatch extends Mock implements Batch {}

// void main() {
//   late SqfLitDataSource sut;
//   late MockSqfLiteDatabase database;
//   late MockBatch batch;
//   setUp(() {
//     database = MockSqfLiteDatabase();
//     batch = MockBatch();
//     sut = SqfLitDataSource(database);
//   });
//   final message = Message.fromJson({
//     'from': '1111',
//     'to': '222',
//     'timeStamp': DateTime.now(),
//     'contents': 'hey',
//     'id': '4444'
//   });

//   test('should perform insert of chat is the databse', () async* {
//     final chat = Chat('1234');
//     when(database.insert('chats', chat.toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace))
//         .thenAnswer((_) async => 1);

//     await sut.addChat(chat);

//     verify(database.insert('chats', chat.toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace))
//         .called(1);
//   });
//   test('should perform insert of message to the databse', () async* {
//     final localMessage = LocalMessage(
//         chatId: '1234', message: message, receipt: ReceiptStatus.sent);
//     when(database.insert('messages', localMessage.toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace))
//         .thenAnswer((_) async => 1);

//     await sut.addMessage(localMessage);

//     verify(database.insert('message', localMessage.toMap(),
//             conflictAlgorithm: ConflictAlgorithm.replace))
//         .called(1);
//   });

//   test('should perform a databse query and return message', () async* {
//     final messageMap = [
//       {
//         'chat_id': '1111',
//         'id': '4444',
//         'from': '1111',
//         'to': '2222',
//         'contents': 'hey',
//         'receipt': 'sent',
//         'timeStamp': DateTime.parse("2021-04-01"),
//       },
//     ];

//     when(
//       database.query(
//         'messages',
//         where: anyNamed('where'),
//         whereArgs: anyNamed('whereArgs'),
//       ),
//     ).thenAnswer((_) async => messageMap);

//     var message = await sut.findMessages('1111');

//     expect(message.length, 1);
//     expect(message.first.chatId, '1111');
//     verify(
//       database.query(
//         'messages',
//         where: anyNamed('where'),
//         whereArgs: anyNamed('whereArgs'),
//       ),
//     ).called(1);
//   });

//   test('should perform database update on messages', () async* {
//     final localMessage = LocalMessage(
//         chatId: '1234', message: message, receipt: ReceiptStatus.sent);
//     when(
//       database.update(
//         'messages',
//         localMessage.toMap(),
//         where: anyNamed('where'),
//         whereArgs: anyNamed('whereArgs'),
//       ),
//     ).thenAnswer(
//       (_) async => 1,
//     );
//     await sut.updateMessage(localMessage);

//     verify(database.update('messages', localMessage.toMap(),
//             where: anyNamed('where'),
//             whereArgs: anyNamed('whereArgs'),
//             conflictAlgorithm: ConflictAlgorithm.replace))
//         .called(1);
//   });

//   test('should perform database batch delete of messages', () async* {
//     const chatId = '1111';
//     when(
//       database.batch(),
//     ).thenReturn(batch);
//     await sut.deleteChat(chatId);

//     verifyInOrder([
//       database.batch(),
//       batch.delete('messages', where: anyNamed('where'), whereArgs: [chatId]),
//       batch.delete('chats', where: anyNamed('where'), whereArgs: [chatId]),
//       batch.commit(noResult: true)
//     ]);
//   });
// }
