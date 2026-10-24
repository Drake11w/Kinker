import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinker/models/user_profile.dart';
import 'package:kinker/widgets/swipe_deck.dart';

void main() {
  const profiles = [
    UserProfile(uid: 'a', name: 'Alex', age: 30),
    UserProfile(uid: 'b', name: 'Blair', age: 28),
  ];

  Future<List<(String, bool)>> pumpDeck(WidgetTester tester,
      {SwipeDeckController? controller}) async {
    final swipes = <(String, bool)>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: SwipeDeck(
            profiles: profiles,
            controller: controller,
            onSwipe: (p, liked) => swipes.add((p.uid, liked)),
          ),
        ),
      ),
    ));
    return swipes;
  }

  testWidgets('dragging right past the threshold likes the top card',
      (tester) async {
    final swipes = await pumpDeck(tester);
    await tester.drag(find.text('Alex, 30'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(swipes, [('a', true)]);
  });

  testWidgets('dragging left past the threshold passes', (tester) async {
    final swipes = await pumpDeck(tester);
    await tester.drag(find.text('Alex, 30'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(swipes, [('a', false)]);
  });

  testWidgets('a short drag snaps back without swiping', (tester) async {
    final swipes = await pumpDeck(tester);
    await tester.timedDrag(find.text('Alex, 30'), const Offset(40, 0),
        const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(swipes, isEmpty);
  });

  testWidgets('controller buttons swipe the top card', (tester) async {
    final controller = SwipeDeckController();
    final swipes = await pumpDeck(tester, controller: controller);
    controller.dislike();
    await tester.pumpAndSettle();
    expect(swipes, [('a', false)]);
  });
}
