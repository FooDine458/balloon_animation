import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedContainerWidget extends StatefulWidget {
  const AnimatedContainerWidget({super.key});

  @override
  State<AnimatedContainerWidget> createState() =>
      _AnimatedContainerWidgetState();
}

class _AnimatedContainerWidgetState
    extends State<AnimatedContainerWidget> {

  double _width = 120;
  double _height = 120;
  double _radius = 20;
  Color _color = Colors.blue;

  final Random _random = Random();

  void _animate() {
    setState(() {
      _width = (_random.nextInt(200) + 120).toDouble();
      _height = (_random.nextInt(200) + 120).toDouble();
      _radius = _random.nextInt(100).toDouble();
      _color = Color.fromRGBO(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _animate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutBack,
          height: _height,
          width: _width,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "Tap Me!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}