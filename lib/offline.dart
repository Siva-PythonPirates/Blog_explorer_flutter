import 'package:flutter/material.dart';
import 'BlogListScreen.dart';

class OfflineScreen extends StatefulWidget {
  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  List<Blog> offlineBlogs = [];

  @override
  void initState() {
    super.initState();
    loadOfflineBlogs();
  }

  Future<void> loadOfflineBlogs() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
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
