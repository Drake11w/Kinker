import 'package:flutter/material.dart';
import 'package:kinker/auth.dart';
import 'package:kinker/auth_provider.dart';
import 'package:kinker/common_widgets/platform_alert_dialog.dart';

class profile extends StatefulWidget {

  @override
  _profileState createState() => _profileState();

}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: (){
                Navigator.pop(context);
              },
              ),
            new FlatButton(
              textColor: Colors.white,
              child: new Text('Sign out'),
              onPressed: _signOut,
            )
          ],
          title: new Text('Profile'),
        ),
        body: new Center(
          child: new Text('Welcome'),
        ),
      ),
    );
  }

   void _signOut() async{
    try {
      bool confirmation = await _logOutDialog(context);
      if (confirmation == true){
        final BaseAuth auth = AuthProvider.of(context).auth;
        await auth.signOut();
      }
    } catch (e) {
      print(e);
    }
  }
Future<bool> _logOutDialog(BuildContext context) async{
  final didLogout = await PlatformAlertDialog(
    title: "Logout",
    content: "Are you sure that you want to logout?",
    cancelText: 'Cancel',
    confirmText: 'Logout',
  ).show(context);
  return didLogout;
  }
}

