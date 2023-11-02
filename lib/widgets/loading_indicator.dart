
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    int numberOfBars = 4;

    _controllers = List.generate(numberOfBars, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
      );
    });

    _animations = List.generate(numberOfBars, (index) {
      return Tween<double>(begin: 8.0, end: 30.0).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOut,
      ));
    });

    for (int i = 0; i < numberOfBars; i++) {
      Future.delayed(Duration(milliseconds: 100 * (i+1)), () {
        _controllers[i].forward().then((_) {
          _controllers[i].reverse().whenComplete(() => _controllers[i].repeat(reverse: true));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(_animations.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: _buildBar(_animations[index]),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBar(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Container(
        width: 8.0,
        height: animation.value,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
