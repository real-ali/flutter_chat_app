import 'package:chat/chat.dart';
import 'package:labalaba/data/datasources/datasource_contract.dart';
import 'package:labalaba/models/chat.dart';
import 'package:labalaba/models/local_message.dart';
import 'package:sqflite/sqflite.dart';

class SqfLitDataSource implements IDataSource {
  final Database _db;

  SqfLitDataSource(this._db);
  @override
  Future<void> addChat(Chat chat) async {
    await _db.transaction((txn) async {
      await _db.insert('chats', chat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    });
  }

  @override
  Future<void> addMessage(LocalMessage message) async {
    if (message != null) {
      await _db.transaction((txn) async {
        await _db.insert(
          'messages',
          message.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() async {
    return _db.transaction((txn) async {
      final chatsWithLatestMessage =
          await txn.rawQuery(''' SELECT messages.* FROM
                (SELECT 
                   chatId, MAX(created_at) AS created_at
                GROUP BY chatId
                ) AS latest_messages
                INNER JOIN messages
                ON messages.chatId = latest_messages.chatId
                AND messages.created_at = latest_messages.created_at
                ORDER BY messages.created_at DESC''');
      if (chatsWithLatestMessage.isEmpty) return [];

      final chatsWithUnreadMessages =
          await txn.rawQuery('''SELECT chatId, count(*) as unread
      FROM messages
      WHERE receipt = ?
      GROUP BY chatId
    ''', ['deliverred']);
      return chatsWithLatestMessage.map<Chat>((row) {
        final int unread = chatsWithUnreadMessages.firstWhere(
            (element) => row['chatId'] == element['chatId'],
            orElse: () => {'unread': 0})['unread'];
        final chat = Chat.fromMap({"id": row['chatId']});
        chat.unread = unread;
        chat.mostRecent = LocalMessage.fromMap(row);
        return chat;
      }).toList();
    });
  }

  @override
  Future<Chat> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMaps =
          await txn.query('chats', where: 'id = ?', whereArgs: [chatId]);
      if (listOfChatMaps.isEmpty) return null;
      final unread = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM messages WHERE chatId = ? AND receipt = ?',
          [chatId, 'deliverred']));

      final mostRecentMessage = await txn.query('message',
          where: 'chatId = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1);
      final chat = Chat.fromMap(listOfChatMaps.first);
      chat.unread = unread;
      chat.mostRecent = LocalMessage.fromMap(mostRecentMessage.first);
      return chat;
    });
  }

  @override
  Future<List<LocalMessage>> findMessages(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMaps =
          await txn.query('messages', where: 'chatId = ?', whereArgs: [chatId]);

      return listOfChatMaps
          .map<LocalMessage>((e) => LocalMessage.fromMap(e))
          .toList();
    });
  }

  @override
  Future<void> updateMessage(LocalMessage message) async {
    await _db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.message.getId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateMessageReceipt(String messageID, ReceiptStatus status) {
    return _db.transaction((txn) async {
      await txn.update(
        'messages',
        {'receipt': status.value()},
        where: 'id = ?',
        whereArgs: [messageID],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
}
