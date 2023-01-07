// import 'package:chat/chat.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:labalaba/states_management/message_bloc.dart';
// import 'package:mockito/mockito.dart';

// class FakeMessageService extends Mock implements IMessageService {}

// void main() {
//   late MessageBloc sut;
//   late IMessageService messageService;
//   late User user;
//   setUp(() {
//     messageService = FakeMessageService();

//     user = User(
//         username: 'test',
//         photoURL: 'photoURL',
//         active: true,
//         lastSeen: DateTime.now());
//     sut = MessageBloc(messageService);
//   });
//   tearDown(() => sut.close());

//   test('should emit inital only without subscription', () {
//     expect(sut.state, MessageInitial());
//   });

//   test("Should emit mesage sent state when message is sent", () async* {
//     final message = Message(
//       from: '111',
//       to: '222',
//       timeStamp: DateTime.now(),
//       contents: 'this is content',
//     );

//     when(messageService.send(message)).thenAnswer((_) async => null);
//     sut.add(MessageEvent.onMessageSent(message));
//     expectLater(sut.stream, emits(MessageState.sent(message)));
//   });
//   test("Should emit mesage received from Service ", () async* {
//     final message = Message(
//       from: '111',
//       to: '222',
//       timeStamp: DateTime.now(),
//       contents: 'this is content',
//     );

//     when(messageService.message(activeUser: anyNamed('activeUser')))
//         .thenAnswer((_) => Stream.fromIterable([message]));
//     sut.add(MessageEvent.onSubscribe(user));
//     expectLater(sut.stream, emitsInOrder([MessageReceivedSuccess(message)]));
//   });
// }
