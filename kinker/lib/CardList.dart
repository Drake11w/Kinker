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
 /* List<Widget> _getMatchCard() { 
    List<MatchCard> cards = new List(); 
    cards.add(MatchCard()); 
    cards.add(MatchCard()); 
    cards.add(MatchCard()); 
    List<Widget> cardList = new List(); 
   for (int x = 0; x < 3; x++) { 
     cardList.add(Positioned( 
       top: cards[x].margin, 
       child: Draggable( 
          onDragEnd: (drag){ 
            _removeCard(x); 
          }, 
       childWhenDragging: Container(), 
       feedback: Card( 
         elevation: 12, 
         //color: Color.fromARGB(255, cards[x].redColor, cards[x].greenColor, cards[x].blueColor), 
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
         child: Container( 
            width: 240, 
            height: 300, 
            ), 
          ), 
       child: Card( 
         elevation: 12, 
         //color: Color.fromARGB(255, cards[x].redColor, cards[x].greenColor, cards[x].blueColor), 
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
         child: Container( 
           width: 240, 
           height: 300, 
          ), 
         ), 
       ), 
     )
   ); 

  List<Widget> getcardList(){
    return cardList;
  }

  } 
  return cardList; 
} 
 */