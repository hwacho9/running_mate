import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? hintText; // 힌트 텍스트
  final List<TextInputFormatter>? inputFormatters; // 입력 제한

  const InputFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.inputFormatters,
  }) : super(key: key);

  @override
  _InputFormFieldState createState() => _InputFormFieldState();
}

class _InputFormFieldState extends State<InputFormField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText, // 힌트 텍스트 추가
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
      ),
      obscureText: widget.isPassword ? _isObscure : false,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters, // 입력 제한 추가
    );
  }
}
