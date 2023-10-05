import 'package:blog_explorer/splash_screen.dart';
import 'package:flutter/material.dart';

import 'BlogDetailScreen.dart';
import 'BlogListScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Define a custom MaterialColor with black as the primary color
    MaterialColor customBlack = MaterialColor(0xFF000000, {
      50: Color(0xFFE0E0E0),
      100: Color(0xFFB3B3B3),
      200: Color(0xFF808080),
      300: Color(0xFF4D4D4D),
      400: Color(0xFF262626),
      500: Color(0xFF000000),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    });

    return MaterialApp(
      title: 'Blog Explorer',
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: customBlack, // Set your custom black MaterialColor
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/blogList': (context) => BlogListScreen(),
        '/blogDetails': (context) => BlogDetailScreen(),
        // '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}
