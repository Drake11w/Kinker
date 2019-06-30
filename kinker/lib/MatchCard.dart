import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'CardList.dart';

class MatchCard extends StatefulWidget {
  final String name;
  final int age;
  final List<String> pics;

  MatchCard(this.name, this.age, this.pics);

  @override
  _MatchCardState createState() => _MatchCardState(name, age, pics);

}

class _MatchCardState extends State<MatchCard> {
  final String name;
  final int age;
  final List<String> pics;
  CardList blah;

  _MatchCardState(this.name, this.age, this.pics);

  @override
  Widget build(BuildContext context) {
    return new Draggable(
      
      maxSimultaneousDrags: 1,
      onDragEnd: (drag){ 
        //blah = Kinker.getBlah();
      },
       //childWhenDragging: Container(), 
       feedback: Card( 
         elevation: 12, 
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
          child: new ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(pics.first),
          )
         ),
        child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: new ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(pics.first)
                )
              )
    );
  }
}

