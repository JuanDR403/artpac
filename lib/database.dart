import 'package:artpac/comment.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Post {
  final String username;
  final String description;
  final String imagePath;
  int likes; // Agrega este atributo
  List<Comment> comments; // Agrega este atributo

  Post({
    required this.username,
    required this.description,
    required this.imagePath,
    this.likes = 0,
    this.comments = const [],
  });
}

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('my_database.db');
    return _database!;
  }

  Future<String?> getCurrentUsername() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty && maps.first['username'] != null) {
      return maps.first['username'].toString();
    } else {
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createDB(
            db, version); // Llama a la función de creación de la tabla users
        await _createPostsTable(
            db, version); // Crea la tabla posts si no está creada
      },
    );
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT * FROM users WHERE username = ?', [username]);
    return result.isNotEmpty;
  }

  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'dates': DateTime.now().toString(),
        'username': username,
        'password': password,
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        dates TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  // Función para crear la tabla posts si no está creada
  Future<void> _createPostsTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY,
        userName TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCommentsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS comments(
      id INTEGER PRIMARY KEY,
      postId INTEGER,
      username TEXT,
      content TEXT
    )
  ''');
  }

  Future<int> insertComment(Comment comment) async {
    final db = await database;
    return await db.insert('comments', comment.toMap());
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
    );

    return List.generate(maps.length, (index) {
      return Comment(
        id: maps[index]['id'],
        username: maps[index]['username'],
        content: maps[index]['content'],
      );
    });
  }

  // Función para insertar una publicación en la tabla posts
  Future<void> insertPost(
      String username, String description, String imageUrl) async {
    final db = await database;

    await db.insert(
      'posts',
      {
        'userName': username,
        'description': description,
        'imageUrl': imageUrl,
      },
    );
  }
}
