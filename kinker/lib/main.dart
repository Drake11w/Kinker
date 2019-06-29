import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kinker/rootPage.dart';
import 'auth.dart';
import 'package:kinker/auth.dart';


void main(){
  runApp(new MyApp());
}


class MyApp extends StatelessWidget {
  BaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Kinker',
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home: new RootPage(auth: new Auth(),)
    );
  }
}