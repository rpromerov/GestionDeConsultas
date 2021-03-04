import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/NotificationScreen';
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
    );
  }
}
