import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter_secure_notes/models/Note.dart';

class Database {
  static final Database instance = Database._constructor();
  Database._constructor();
  sqflite.Database? _db;
  Future<sqflite.Database> get database async {
    if(_db != null){
      return _db!;
    }
    await create();
    return _db!;
  }
  final String tableName = 'notes';
  final String idColumn = 'id';
  final String titleColumn = 'title';
  final String descriptionColumn = 'description';
  final String dateColumn = 'date';
  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "notes.db");
    _db = await sqflite.openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version){
          db.execute('''
          CREATE TABLE $tableName (
             $idColumn INTEGER PRIMARY KEY,
             $titleColumn TEXT NOT NULL,
             $descriptionColumn TEXT NOT NULL,
             $dateColumn INTEGER NOT NULL   
          )          
          ''');
        });
  }
  void addNote (String title, String description, int date) async {
    final db = await database;
    await db.insert(tableName, {
      titleColumn: title,
      descriptionColumn: description,
      dateColumn: date
    });
  }
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final data = await db.query(tableName);
    List<Note> notes = data.map(
            (item) => Note(
            id: item[idColumn] as int,
            title: item[titleColumn] as String,
            description: item[descriptionColumn] as String,
            date: item[dateColumn] as int
        )
    ).toList();
    return notes;
  }
  void deleteNote(Note note) async{
    final db = await database;
    await db.delete(tableName, where: '$idColumn = ?', whereArgs: [note.id]);
  }
  void deleteAllNotes() async {
    final db = await database;
    await db.delete(tableName);
  }
  void updateNote(Note note) async {
    final db = await database;
    var map = <String, Object>{
      titleColumn: note.title,
      descriptionColumn: note.description,
      dateColumn: note.date
    };
    map[idColumn] = note.id;
    await db.update(tableName, map,
        where: '$idColumn = ?', whereArgs: [note.id]);
  }
}