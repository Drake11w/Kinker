import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'CardList.dart';
import 'signIn.dart';

CardList blah = new CardList();


class Kinker extends StatefulWidget {
  final FirebaseUser user;

  const Kinker({Key key, this.user}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return new _KinkerState();
  }

}

class _KinkerState extends State<Kinker> {

  _KinkerState();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Builder(
          builder: (context) => new Scaffold(
          appBar:  new AppBar(
            title: new Text('Kinker'),
            backgroundColor: Colors.deepPurple,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => Messages()),
                  );
                }
              ),
              FloatingActionButton(
                heroTag: "profile",
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image(
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    image: new AssetImage("assets/images/blah.jpg"),
                  ),
                ),
              )
          ]
          ),
          body:new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
             // blah,
                new Container(
                color: Colors.black,
                child: new Center(
                  child: new Row(
                    children: <Widget>[
                      Spacer(),
                      new FloatingActionButton(
                        heroTag:"dislike",
                        child: Icon(Icons.clear),
                        backgroundColor: Colors.red,
                        onPressed: (){

                        },
                      ),
                      Spacer(),
                      new FloatingActionButton(
                        heroTag:"like",
                        child: Icon(Icons.favorite),
                        backgroundColor: Colors.deepPurple,
                        onPressed: (){

                        },
                      ),
                      Spacer(),
                      
                    ],
                ),)
              ) 
            ]),
         backgroundColor: Colors.black,
            )
        )
    );
  }
}

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Messages'),
        ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
      )
  );
  }
}

openMessages() {
  print('HI!');
}

openProfile() {
  print('Profile');
}