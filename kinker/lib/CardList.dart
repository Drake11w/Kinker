import 'package:flutter/cupertino.dart';
import 'MatchCard.dart';

class CardList extends StatefulWidget {

  @override
  _CardListState createState() => _CardListState();

}

class _CardListState extends State<CardList> {

  List<Widget> cardList = new List();

  _CardListState(){
    push(MatchCard("D", 21,["assets/images/blah.jpg"]));
    //push(MatchCard("D", 21,["assets/images/blah.jpg"]));
    //push(MatchCard("D", 21,["assets/images/blah.jpg"]));
    //push(MatchCard("D", 21,["assets/images/blah.jpg"]));
    //push(MatchCard("D", 21,["assets/images/blah.jpg"]));
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: cardList,
    );
  }

  List<Widget> getCardList(){
    return cardList;
  }

  void push(MatchCard card){
    cardList.add(card);
  }

  void pop(index){
    cardList.removeAt((cardList.length-1));
  }


}
 