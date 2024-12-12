import 'package:flutter/material.dart';

class RectangleButton extends StatelessWidget {
  final String text; // 버튼에 표시될 텍스트
  final VoidCallback? onPressed; // 버튼 클릭 시 실행할 함수
  final Color? color; // 버튼 배경색
  final Color? textColor; // 텍스트 색상
  final double fontSize; // 텍스트 크기
  final double borderRadius; // 버튼 테두리 둥근 정도
  final bool isLoading; // 로딩 상태
  final bool isDisabled; // 비활성화 상태

  const RectangleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.fontSize = 13.0,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey
              : (color ?? Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        onPressed: isDisabled || isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: textColor ?? Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
