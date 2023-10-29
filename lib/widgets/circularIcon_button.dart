import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final double iconSize;
  final double width;
  final double height;
  final double? borderWidth;
  final Color iconColor;

  final Color? borderColor;
  final Function()? onPressed;
  final bool isEnabled;

  const CircularIconButton({
    Key? key,
    required this.backgroundColor,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.isEnabled,
    this.onPressed,
    required this.iconColor,
    required this.icon, this.borderWidth, this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        
      ),
      child: Center(
        child: IconButton(
          icon: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          padding: EdgeInsets.zero,
          onPressed: isEnabled ? onPressed : null,
        ),
      ),
    );
  }
}
