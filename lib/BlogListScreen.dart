import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'offline.dart';

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<Blog> blogs = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  bool isConnectedToInternet = true;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    databaseHelper.initializeDatabase();
    checkInternetConnection();
    if (isConnectedToInternet) {
      fetchBlogs();
    } else {
      fetchFavoriteBlogs();
      print("no internet");
    }
  }
  Future<void> initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'blog_database.db');

    var sqLiteDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS favorite_blogs(id INTEGER PRIMARY KEY, title TEXT, imageUrl TEXT)',
        );
      },
    );
  }


  Future<void> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isConnectedToInternet = true;
          print("CONNECTED");
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isConnectedToInternet = false;
        print("NOT CONNECTED");
      });
    }
  }

  Future<void> fetchBlogs() async {
    try {
      if (isConnectedToInternet) {
        final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
        final String adminSecret =
            '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

        final response = await http.get(Uri.parse(url), headers: {
          'x-hasura-admin-secret': adminSecret,
        });

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);

          if (data is List) {
            setState(() {
              blogs = data
                  .map((item) => Blog(
                title: item['title'],
                imageUrl: item['image_url'],
              ))
                  .toList();
            });
          } else if (data is Map) {
            final List<dynamic> blogList = data['blogs'];
            setState(() {
              blogs = blogList
                  .map((item) => Blog(
                title: item['title'],
                imageUrl: item['image_url'],
              ))
                  .toList();
            });
          } else {
            print('API response is not in the expected format.');
          }
        } else {
          print('Request failed with status code: ${response.statusCode}');
          print('Response data: ${response.body}');
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        blogs.forEach((blog) {
          blog.isFavorite = prefs.getBool(blog.title) ?? false;
        });
      } else {
        fetchFavoriteBlogs();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchFavoriteBlogs() async {
    final List<Blog> favorites = await databaseHelper.getFavoriteBlogs();
    setState(() {
      blogs = favorites;
    });
  }

  void updateFavoriteStatus(Blog blog) async {
    blog.isFavorite = !blog.isFavorite;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(blog.title, blog.isFavorite);

    if (blog.isFavorite) {
      await databaseHelper.insertFavoriteBlog(blog.title, blog.imageUrl);
    } else {
      await databaseHelper.deleteFavoriteBlog(blog.title);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blog Explorer',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Image.network(
          "https://play-lh.googleusercontent.com/l1cu4ndpgcfawgOzOVmWS1Z-N8iVIqlfTfU3UcoYxGp3Jbjv9at5gs3dLWMR-6eWfFoW",
          width: 40,
          height: 40,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OfflineScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F2F2F),
              Color(0xFF2F2F2F),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            return BlogListItem(
              blog: blogs[index],
              updateFavoriteStatus: updateFavoriteStatus,
            );
          },
        ),
      ),
    );
  }
}

class BlogListItem extends StatelessWidget {
  final Blog blog;
  final Function(Blog) updateFavoriteStatus;

  BlogListItem({required this.blog, required this.updateFavoriteStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00FFBB),
            Color(0xFF00FFBB),
            Color(0xFF00FFBB),
            Colors.transparent,
            Colors.transparent,
            Color(0xFF00FFBB),
            Color(0xFF00FFBB),
            Color(0xFF00FFBB),
          ],
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            blog.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          leading: Container(
            width: 80.0,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                blog.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              blog.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: blog.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              updateFavoriteStatus(blog);
            },
          ),
          onTap: () {
            Navigator.pushNamed(context, '/blogDetails', arguments: blog);
          },
        ),
      ),
    );
  }
}

class Blog {
  final String title;
  final String imageUrl;
  bool isFavorite;

  Blog({required this.title, required this.imageUrl, this.isFavorite = false});
}

class DatabaseHelper {
   late Database sqLiteDatabase;
   DatabaseHelper() {
     initializeDatabase();
   }

  Future<void> initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'blog_database.db');

    sqLiteDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS favorite_blogs(id INTEGER PRIMARY KEY, title TEXT, imageUrl TEXT)',
        );
      },
    );
  }

  Future<void> insertFavoriteBlog(String title, String imageUrl) async {
    await sqLiteDatabase.insert(
      'favorite_blogs',
      {
        'title': title,
        'imageUrl': imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavoriteBlog(String title) async {
    await sqLiteDatabase.delete(
      'favorite_blogs',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<List<Blog>> getFavoriteBlogs() async {
    final List<Map<String, dynamic>> favoriteBlogMaps =
    await sqLiteDatabase.query('favorite_blogs');
    final List<Blog> favorites = favoriteBlogMaps.map((favoriteBlogMap) {
      return Blog(
        title: favoriteBlogMap['title'],
        imageUrl: favoriteBlogMap['imageUrl'],
        isFavorite: true,
      );
    }).toList();

    return favorites;
  }
}
