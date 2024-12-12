import 'package:flutter/material.dart';

class CircleFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final double size; // 버튼 크기 추가

  const CircleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip = '',
    this.backgroundColor = Colors.blue, // 기본 배경색
    this.iconColor = Colors.white, // 기본 아이콘 색
    this.size = 56.0, // 기본 사이즈 (FloatingActionButton 기본 크기와 동일)
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: backgroundColor, // 버튼 배경색
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: size * 0.5, // 아이콘 크기는 버튼 크기에 비례
              ),
            ),
          ),
        ),
      ),
    );
  }
}
