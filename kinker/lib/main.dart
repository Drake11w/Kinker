import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'CardList.dart';
import 'signIn.dart';

bool signedIn;
CardList blah = new CardList();
Kinker app = new Kinker(blah);

 
void main() => runApp(signIn());


class Kinker extends StatefulWidget {
  final CardList blah;

  Kinker(this.blah);

  @override
  State<StatefulWidget> createState() {
    return new _KinkerState(this.blah);
  }

}

class _KinkerState extends State<Kinker> {
  CardList blah;
  _KinkerState(this.blah);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
          appBar: new AppBar(
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
                        child: Icon(Icons.clear),
                        backgroundColor: Colors.red,
                        onPressed: (){

                        },
                      ),
                      Spacer(),
                      new FloatingActionButton(
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