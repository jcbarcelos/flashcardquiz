import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flutter/foundation.dart'; // Verifica a plataforma
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Para uso em desktop
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use `sqflite_common_ffi` para desktop
    if (kIsWeb) {
      throw UnsupportedError("Web não é suportado para SQLite");
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Inicializa o FFI
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi; // Usa FFI para Desktop
      final dbPath = await databaseFactory.getDatabasesPath();
      return await databaseFactory.openDatabase(
        join(dbPath, 'flashcards.db'),
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE flashcards(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                question TEXT NOT NULL,
                options TEXT,
                correctIndex INTEGER
              )
            ''');
            // Insere dados iniciais, se necessário
            //  await insertInitialFlashcards(db);
          },
        ),
      );
    } else {
      // Usa o sqflite para Android/iOS
      final dbPath = await getDatabasesPath();
      return await openDatabase(
        join(dbPath, 'flashcards.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE flashcards(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              question TEXT NOT NULL,
              options TEXT,
              correctIndex INTEGER
            )
          ''');
          // Insere dados iniciais, se necessário
          //  await insertInitialFlashcards(db);
        },
      );
    }
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Mude o número da versão conforme necessário
      await db.execute('ALTER TABLE flashcards ADD COLUMN options TEXT');
    }
  }

  Future<void> insertInitialFlashcards(Database db) async {
    // Insira flashcards iniciais no banco de dados
    await db.insert('flashcards', {
      'question': 'What is Flutter?',
      'optionss': 'A UI toolkit by Google.'
    });
    await db.insert('flashcards', {
      'question': 'What is Dart?',
      'options': 'A programming language for Flutter.'
    });
  }

  Future<int> insertFlashcard(FlashCard flashcard) async {
    final db = await database;
    return await db.insert(
      'flashcards',
      flashcard.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FlashCard>> getFlashcards() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('flashcards');
      return List.generate(maps.length, (i) {
        return FlashCard.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateFlashcard(FlashCard flashcard) async {
    final db = await database;
    return await db.update('flashcards', flashcard.toMap(),
        where: 'id = ?', whereArgs: [flashcard.id]);
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<FlashCard?> getRandomFlashcard() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flashcards');
    if (maps.isEmpty) return null;

    // Seleciona uma pergunta aleatória da lista
    final randomIndex = Random().nextInt(maps.length);
    return FlashCard.fromMap(maps[randomIndex]);
  }

  // Função para fazer backup do banco de dados
  Future<String> backupDatabase() async {
    final dbPath = await getDatabasesPath();
    final databasePath = join(dbPath, 'flashcards.db');

    // Seleciona o diretório de destino para o backup
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final backupPath = join(selectedDirectory, 'flashcards_backup.db');
      try {
        final dbFile = File(databasePath);
        await dbFile.copy(backupPath);
        return 'Backup criado com sucesso em $backupPath';
      } catch (e) {
        throw Exception('Erro ao fazer backup do banco de dados: $e');
      }
    } else {
      return 'Operação de backup cancelada';
    }
  }

  // Função para restaurar o banco de dados a partir do backup selecionado
  Future<String> restoreDatabase() async {
    final dbPath = await getDatabasesPath();
    final databasePath = join(dbPath, 'flashcards.db');

    // Seleciona o arquivo de backup para restaurar
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null) {
      final backupFile = File(result.files.single.path!);
      try {
        await backupFile.copy(databasePath);
        _database = await _initDatabase(); // Re-inicializa o banco de dados
        return 'Banco de dados restaurado com sucesso';
      } catch (e) {
        throw Exception('Erro ao restaurar banco de dados: $e');
      }
    } else {
      return 'Operação de restauração cancelada';
    }
  }
}
