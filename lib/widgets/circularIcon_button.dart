import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final double iconSize;
  final Function()? onPressed;

  const CircularIconButton({super.key, 
    required this.icon,
    required this.backgroundColor,
    this.iconSize = 20.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 37.0,
      height: 37.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor, 
      ),
      child: Center(
        child: IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
          padding: EdgeInsets.zero, 
          onPressed: onPressed,
        ),
      ),
    );
  }
}
