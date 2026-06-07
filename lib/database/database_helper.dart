import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatmorphism.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL DEFAULT 'New Chat',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        model TEXT,
        system_prompt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('user', 'assistant', 'system')),
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        metadata TEXT,
        FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
    await db.execute('CREATE INDEX idx_chats_updated ON chats(updated_at)');
  }

  Future<List<Chat>> getAllChats() async {
    final db = await database;
    final maps = await db.query('chats', orderBy: 'updated_at DESC');
    return maps.map((map) => Chat.fromMap(map)).toList();
  }

  Future<Chat?> getChat(String id) async {
    final db = await database;
    final maps = await db.query('chats', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Chat.fromMap(maps.first);
  }

  Future<void> insertChat(Chat chat) async {
    final db = await database;
    await db.insert('chats', chat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateChat(Chat chat) async {
    final db = await database;
    await db.update('chats', chat.toMap(),
        where: 'id = ?', whereArgs: [chat.id]);
  }

  Future<void> deleteChat(String id) async {
    final db = await database;
    await db.delete('messages', where: 'chat_id = ?', whereArgs: [id]);
    await db.delete('chats', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Message>> getMessages(String chatId) async {
    final db = await database;
    final maps = await db.query('messages',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'created_at ASC');
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> exportToJson() async {
    final db = await database;
    final chats = await db.query('chats');
    final messages = await db.query('messages');
    final export = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'chats': chats,
      'messages': messages,
    };
    return jsonEncode(export);
  }

  Future<void> importFromJson(String json) async {
    final db = await database;
    final data = jsonDecode(json) as Map<String, dynamic>;
    final chats = data['chats'] as List<dynamic>;
    final messages = data['messages'] as List<dynamic>;

    await db.transaction((txn) async {
      for (final chat in chats) {
        await txn.insert('chats', chat as Map<String, dynamic>);
      }
      for (final message in messages) {
        await txn.insert('messages', message as Map<String, dynamic>);
      }
    });
  }

  Future<String> getDatabaseFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'chatmorphism.db');
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('chats');
  }
}
