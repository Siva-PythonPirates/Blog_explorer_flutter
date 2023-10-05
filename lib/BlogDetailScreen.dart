import 'package:flutter/material.dart';

import 'BlogListScreen.dart';

class BlogDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Blog blog = ModalRoute.of(context)?.settings.arguments as Blog;

    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(blog.imageUrl),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                blog.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
