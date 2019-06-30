import 'package:flutter/material.dart';
import 'package:kinker/homePage.dart';
import 'package:kinker/signIn.dart';
import 'package:kinker/auth.dart';
import 'package:kinker/auth_provider.dart';

class RootPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
        if (snapshot.connectionState == ConnectionState.active){
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn ? Kinker() : signIn();
        }
        return _buildWaitingScreen();
      }
    );
  }
}

Widget _buildWaitingScreen(){
  return new Scaffold(
    body: new Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator()
    ),
  );
}