import 'package:flutter/material.dart';

class DropdownFormField extends StatelessWidget {
  final String labelText; // 필드 라벨
  final String? value; // 현재 선택된 값
  final List<String> items; // 드롭다운 아이템 리스트
  final void Function(String?)? onChanged; // 값 변경 콜백
  final String? hintText; // 힌트 텍스트

  const DropdownFormField({
    Key? key,
    required this.labelText,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dropdownColor: Colors.white, // 기본 배경색
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
