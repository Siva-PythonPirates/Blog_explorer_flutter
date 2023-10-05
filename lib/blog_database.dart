import 'package:sqflite/sqflite.dart';

import 'BlogListScreen.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), 'blogs.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE IF NOT EXISTS favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavoriteBlog(String title, String imageUrl) async {
    await _database.insert('favorites', {
      'title': title,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deleteFavoriteBlog(int id) async {
    await _database.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Blog>> getFavoriteBlogs() async {
    final List<Map<String, dynamic>> maps = await _database.query('favorites');
    return List.generate(maps.length, (i) {
      return Blog(
        // id: maps[i]['id'],
        title: maps[i]['title'],
        imageUrl: maps[i]['imageUrl'],
        isFavorite: true, // Set isFavorite to true for favorite blogs
      );
    });
  }
}