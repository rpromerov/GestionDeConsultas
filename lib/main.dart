import 'package:flutter/material.dart';
import './Widgets/LoginWidget.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosemar',
      home: Login(),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
