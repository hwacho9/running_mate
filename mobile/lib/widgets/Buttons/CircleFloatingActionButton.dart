import 'package:flutter/material.dart';

class CircleFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;

  const CircleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip = '',
    this.backgroundColor = Colors.blue, // 기본 배경색
    this.iconColor = Colors.white, // 기본 아이콘 색
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
