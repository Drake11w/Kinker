import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kinker/auth_provider.dart';
import 'package:kinker/rootPage.dart';
import 'auth.dart';
import 'package:kinker/auth.dart';
import 'package:flutter/services.dart';


void main(){
  runApp(new MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return AuthProvider(
      auth: Auth(),
      child: new MaterialApp(
          title: 'Kinker',
          theme: new ThemeData(
            primarySwatch: Colors.deepPurple
          ),
          home: new RootPage()
    )
    );
  }
}