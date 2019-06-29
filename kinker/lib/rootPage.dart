import 'package:flutter/material.dart';
import 'package:kinker/homePage.dart';
import 'package:kinker/signIn.dart';
import 'auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;

  initState(){
    super.initState();
    widget.auth.currentUser().then((userId){
      setState((){
        _authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn(){
    setState(() {
     _authStatus = AuthStatus.signedIn; 
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_authStatus){
      case AuthStatus.notSignedIn:
        return new signIn(
          auth: widget.auth,
          onSignedIn: _signedIn,
          );
      case AuthStatus.signedIn:
        return new Kinker();
    }
  }
}