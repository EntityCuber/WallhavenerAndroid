import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallhavener/pages/home.dart';
import 'package:wallhavener/pages/wallview.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/wallview': (context) => WallView(),
      },
      theme: ThemeData(
          brightness: Brightness.dark, accentColor: Color(0xFF000000)),
      debugShowCheckedModeBanner: false,
    );
  }
}
