// import 'package:chat/chat.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:labalaba/data/datasources/datasource_contract.dart';
// import 'package:labalaba/models/chat.dart';
// import 'package:labalaba/models/local_message.dart';
// import 'package:labalaba/models/viewmodels/chat_view_model.dart';
// import 'package:mockito/mockito.dart';

// class MockDataSource extends Mock implements IDataSource {}

// void main() {
//   late ChatViewModel sut;
//   late MockDataSource mockDataSource;

//   setUp(() {
//     mockDataSource = MockDataSource();
//     sut = ChatViewModel(mockDataSource);
//   });

//   final message = Message.fromJson({
//     'from': '1111',
//     'to': '222',
//     'timeStamp': DateTime.now(),
//     'contents': 'hey',
//     'id': '4444'
//   });

//   test('initial chats return empty list', () async* {
//     when(mockDataSource.findAllChats())
//         .thenAnswer((realInvocation) async => []);
//     expect(await sut.getMessages('123'), isEmpty);
//   });

//   test('retutns list of message from local storage', () async* {
//     final chat = Chat('123');
//     final localMessage = LocalMessage(
//         chatId: chat.id, message: message, receipt: ReceiptStatus.delivered);
//     when(mockDataSource.findMessages(chat.id))
//         .thenAnswer((_) async => [localMessage]);
//     final messages = await sut.getMessages('123');
//     expect(messages, isNotEmpty);
//     expect(messages.first.chatId, '123');
//   });

//   test('create a new chat when sending first message', () async* {
//     when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
//     await sut.sentMessage(message);
//     verify(mockDataSource.addChat(any)).called(1);
//   });

//   test('add  new sent message to the chat ', () async* {
//     final chat = Chat('123');
//     final localMessage = LocalMessage(
//         chatId: chat.id, message: message, receipt: ReceiptStatus.sent);
//     when(mockDataSource.findMessages(chat.id))
//         .thenAnswer((_) async => [localMessage]);
//     await sut.getMessages(chat.id);
//     await sut.sentMessage(message);
//     verifyNever(mockDataSource.addChat(any));
//     verify(mockDataSource.addMessage(any)).called(1);
//   });

//   test('add  new received message to the chat ', () async* {
//     final chat = Chat('123');
//     final localMessage = LocalMessage(
//         chatId: chat.id, message: message, receipt: ReceiptStatus.delivered);
//     when(mockDataSource.findMessages(chat.id))
//         .thenAnswer((_) async => [localMessage]);
//     when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => chat);
//     await sut.getMessages(chat.id);
//     await sut.sentMessage(message);
//     verifyNever(mockDataSource.addChat(any));
//     verify(mockDataSource.addMessage(any)).called(1);
//   });

//   test('create  new chat when message received is not a part fo this chat ',
//       () async* {
//     final chat = Chat('123');
//     final localMessage = LocalMessage(
//         chatId: chat.id, message: message, receipt: ReceiptStatus.delivered);
//     when(mockDataSource.findMessages(chat.id))
//         .thenAnswer((_) async => [localMessage]);
//     when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => null);
//     await sut.getMessages(chat.id);
//     await sut.receivedMessage(message);
//     verify(mockDataSource.addChat(any)).called(1);
//     verify(mockDataSource.addMessage(any)).called(1);
//     expect(sut.otherMessage, 1);
//   });
// }
