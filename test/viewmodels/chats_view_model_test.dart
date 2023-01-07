// import 'package:chat/chat.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:labalaba/data/datasources/datasource_contract.dart';
// import 'package:labalaba/models/chat.dart';
// import 'package:labalaba/models/viewmodels/chats_view_model.dart';
// import 'package:mockito/mockito.dart';
// import 'package:rethink_db_ns/rethink_db_ns.dart';

// class MockDataSource extends Mock implements IDataSource {}

// void main() {
//   late ChatsViewModel sut;
//   late MockDataSource mockDataSource;
//   late IUserService userService;
//   late RethinkDb r;
//   late Connection connection;

//   setUp(() async {
//     r = RethinkDb();
//     connection = await r.connect(db: 'test', host: 'localhost');
//     userService = UserService(r, connection);
//     mockDataSource = MockDataSource();
//     sut = ChatsViewModel(mockDataSource, userService);
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
//     expect(await sut.getChats(), isEmpty);
//   });

//   test('retutns list of chats', () async* {
//     final chat = Chat('123');
//     when(mockDataSource.findAllChats())
//         .thenAnswer((realInvocation) async => [chat]);
//     final chats = await sut.getChats();
//     expect(chats, isNotEmpty);
//   });

//   test('create a new chat when reveiving message for the first time',
//       () async* {
//     when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
//     await sut.receivedMessage(message);
//     verify(mockDataSource.addChat(any)).called(1);
//   });

//   test('add  new message to existing chat ', () async* {
//     final chat = Chat('123');
//     when(mockDataSource.findChat(any)).thenAnswer((_) async => chat);
//     await sut.receivedMessage(message);
//     verifyNever(mockDataSource.addChat(any));
//     verify(mockDataSource.addMessage(any)).called(1);
//   });
// }
