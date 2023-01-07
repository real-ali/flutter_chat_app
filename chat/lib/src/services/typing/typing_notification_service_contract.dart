import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';

abstract class ITypingNotification {
  Future<bool> send({TypingEvent event});
  Stream<TypingEvent> subscribe(User user, List<String> usersId);
  void dispose();
}
