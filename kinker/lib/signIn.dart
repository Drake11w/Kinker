import 'package:flutter/material.dart';
import 'package:kinker/auth.dart';
import 'package:kinker/auth_provider.dart';
import 'package:flutter/services.dart';
import 'common_widgets/platform_alert_dialog.dart';


class signIn extends StatefulWidget {

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
          body: SingleChildScrollView(
          child: new Form(
            key: _formKey,
            child: new Column(
              children: buildInputs() + buildSubmitButtons()
            ),
          ),
        )
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
        final BaseAuth auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login){
          String userId = await auth.signInWithEmailAndPassword(_email, _password);
          print ('logged in user:' + userId);
        }
        else{
          String userId = await auth.createUserWithEmailAndPassword(_email, _password);
          print ('created in user:' + userId);
        }
      } on PlatformException catch (e) {
        _showErrorMessage(context, e.message);
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

void _showErrorMessage(BuildContext context, message){
  PlatformAlertDialog(
    title: "Login error",
    content: message,
    confirmText: "Okay",
  ).show(context);
}