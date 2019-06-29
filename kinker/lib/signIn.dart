import 'package:flutter/material.dart';
import 'auth.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class signIn extends StatefulWidget {
  signIn({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  _signInState createState() => new _signInState();
}
enum FormType{
  login,
  register
}

class _signInState extends State<signIn> {

  String _email;
  String _password;
  FormType _formType = FormType.login;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Builder(
        builder: (context) => new Scaffold(
          appBar: new AppBar(
            title: Text('Sign In'),
            backgroundColor: Colors.deepPurple,
          ),
          body: new Form(
            key: _formKey,
            child: new Column(
              children: buildInputs() + buildSubmitButtons()
            ),
          ),
          //backgroundColor: Colors.black
        )
      )
    );
  }

  List<Widget> buildInputs(){
    return[
     new TextFormField(
      validator: (input){
        if(input.isEmpty){
          return 'Please type an email';
        }
      },
      onSaved: (input) => _email = input,
      decoration: InputDecoration(
        labelText: 'Email'
      ),
    ),
    new TextFormField(
      validator: (input){
        if(input.length < 6){
          return 'Please type a password';
        }
      },
      onSaved: (input) => _password = input,
      decoration: InputDecoration(
        labelText: 'Password'
      ),
      obscureText: true,
    ),
    ];
  }

  List<Widget> buildSubmitButtons(){
    if (_formType == FormType.login){
      return[
      new RaisedButton(
        child: Text('Sign In'),
        onPressed: validateAndSubmit,
      ),
      new FlatButton(
        child: new Text('Create an account'),
        onPressed: moveToRegister,
      )
      ];
    }
    else{
      return[
        new RaisedButton(
          child: Text('Create an account'),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
          child: new Text('Have an account? Login'),
          onPressed: moveToLogin,
        )
      ];
    }
  }

  bool validateAndSave() {
    final formState = _formKey.currentState;

    if(formState.validate()){
      formState.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async{
    if (validateAndSave()){
      try {
        if (_formType == FormType.login){
          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print ('logged in user:' + userId);
        }
        else{
          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
          print ('created in user:' + userId);
        }
        widget.onSignedIn();
      } catch (e) {
        print(e.message());
      }
    }
  }

  void moveToRegister(){
    _formKey.currentState.reset();
    setState(() {
    _formType = FormType.register;
    });
  }
  
  void moveToLogin(){
    _formKey.currentState.reset();
    setState(() {
     _formType = FormType.login; 
    });
  }

}