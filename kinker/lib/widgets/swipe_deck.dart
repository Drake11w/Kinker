import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'match_card.dart';

typedef SwipeCallback = void Function(UserProfile profile, bool liked);

/// Lets buttons outside the deck trigger a swipe on the top card.
class SwipeDeckController {
  _SwipeDeckState? _state;

  void like() => _state?._flyOut(liked: true);
  void dislike() => _state?._flyOut(liked: false);
}

/// A stack of [MatchCard]s. Drag the top card right to like it, left to
/// pass. The parent owns [profiles] and should drop the swiped profile in
/// [onSwipe].
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.profiles,
    required this.onSwipe,
    this.controller,
  });

  final List<UserProfile> profiles;
  final SwipeCallback onSwipe;
  final SwipeDeckController? controller;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  static const _swipeThreshold = 0.3; // fraction of the deck width
  static const _flingVelocity = 800.0;

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..addListener(_onTick);
  Animation<Offset>? _tween;
  Offset _offset = Offset.zero;
  double _width = 1;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _animation.dispose();
    super.dispose();
  }

  void _onTick() => setState(() => _offset = _tween!.value);

  Future<void> _animateTo(Offset target) {
    _tween = Tween(begin: _offset, end: target).animate(
        CurvedAnimation(parent: _animation, curve: Curves.easeOut));
    return _animation.forward(from: 0);
  }

  Future<void> _flyOut({required bool liked}) async {
    if (widget.profiles.isEmpty || _animation.isAnimating) return;
    final top = widget.profiles.first;
    await _animateTo(Offset((liked ? 1 : -1) * _width * 1.5, _offset.dy));
    if (!mounted) return;
    setState(() => _offset = Offset.zero);
    widget.onSwipe(top, liked);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_animation.isAnimating) return;
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_animation.isAnimating) return;
    final vx = details.velocity.pixelsPerSecond.dx;
    if (_offset.dx.abs() > _width * _swipeThreshold ||
        vx.abs() > _flingVelocity) {
      final liked = (_offset.dx.abs() > 1 ? _offset.dx : vx) > 0;
      _flyOut(liked: liked);
    } else {
      _animateTo(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _width = constraints.maxWidth;
      final profiles = widget.profiles;
      if (profiles.isEmpty) return const SizedBox.shrink();

      final progress = (_offset.dx / (_width * _swipeThreshold)).clamp(-1.0, 1.0);
      final top = profiles.first;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (profiles.length > 1)
            Transform.scale(
              scale: 0.94 + 0.06 * progress.abs(),
              child: MatchCard(
                  key: ValueKey(profiles[1].uid), profile: profiles[1]),
            ),
          GestureDetector(
            key: ValueKey('drag-${top.uid}'),
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.translate(
              offset: _offset,
              child: Transform.rotate(
                angle: progress * math.pi / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MatchCard(key: ValueKey(top.uid), profile: top),
                    if (progress > 0)
                      _Stamp(
                          label: 'LIKE',
                          color: Colors.greenAccent,
                          opacity: progress,
                          alignment: Alignment.topLeft),
                    if (progress < 0)
                      _Stamp(
                          label: 'NOPE',
                          color: Colors.redAccent,
                          opacity: -progress,
                          alignment: Alignment.topRight),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.color,
    required this.opacity,
    required this.alignment,
  });

  final String label;
  final Color color;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
