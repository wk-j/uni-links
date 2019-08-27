import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final Uri uri;

  SecondPage(this.uri);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Uni Links")),
        body: Container(
            child: Center(
                child: Text(
          uri.toString(),
          style: TextStyle(fontSize: 22),
        ))));
  }
}
