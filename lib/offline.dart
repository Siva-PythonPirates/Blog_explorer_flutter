import 'package:flutter/material.dart';
import 'BlogListScreen.dart';
// import 'blog_database.dart';

class OfflineScreen extends StatefulWidget {
  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  List<Blog> offlineBlogs = []; // List to store offline blogs

  @override
  void initState() {
    super.initState();
    loadOfflineBlogs();
  }


  // Function to load data from the SQLite database
  Future<void> loadOfflineBlogs() async {
    // Create an instance of the DatabaseHelper
    DatabaseHelper databaseHelper = DatabaseHelper();
    // Fetch favorite blogs from the local SQLite database
    final List<Blog> favorites = await databaseHelper.getFavoriteBlogs();

    setState(() {
      offlineBlogs = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Blogs'),
      ),
      body: ListView.builder(
        itemCount: offlineBlogs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(offlineBlogs[index].title),
            subtitle: Image.network(offlineBlogs[index].imageUrl),
          );
        },
      ),
    );
  }
}
