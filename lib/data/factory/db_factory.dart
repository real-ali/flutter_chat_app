import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabseFactory {
  Future<Database> createDatabse() async {
    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, 'labalaba.db');

    var database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: populatedDb,
      onUpgrade: (db, oldVersion, newVersion) {
        if (newVersion > oldVersion) print("should be update");
      },
    );

    return database;
  }

  Future<void> populatedDb(Database db, int version) async {
    await _createChatTable(db);
    await _createMessangerTable(db);
  }

  _createChatTable(Database db) async {
    await db
        .execute(
          """CREATE TABLE chats(
            id TEXT PRIMARY KEY,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
        )""",
        )
        .then((_) => print('Created table chat ...'))
        .catchError((e) => print('error creating chat table $e'));
  }

  _createMessangerTable(Database db) async {
    await db
        .execute("""CREATE TABLE messages(
          chat_id TEXT NOT NULL,
          id TEXT PRIMARY KEY,
          sender TEXT NOT NULL,
          receiver TEXT NOT NULL,
          contents TEXT NOT NULL,
          receipt TEXT NOT NULL,
          received_at TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
        )
        """)
        .then((_) => print('Created table messages ...'))
        .catchError((e) => print('error creating messages table $e'));
  }
}
