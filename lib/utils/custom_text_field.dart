import 'package:flutter/material.dart';

class CustomTextFieldStyle {
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    String? suffixText,
    Widget? suffix,
    Icon? icon,

    Widget? iconButton,
    double borderRadius = 16,
    Color focusedBorderColor = const Color.fromRGBO(40, 124, 145, 1),
    Color hintTextColor = const Color.fromRGBO(0, 0, 0, 0.4),
    double borderWidth = 2.5,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixText: suffixText,
      suffixIcon: iconButton,
      prefixIcon: icon,
      counterText: "",
      suffix: suffix,
      suffixStyle: TextStyle(fontSize: 12, color: hintTextColor),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        borderSide: BorderSide(width: borderWidth, color: focusedBorderColor),
      ),

      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      hintStyle: TextStyle(color: hintTextColor, fontSize: 13),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        borderSide: BorderSide(width: borderWidth, color: focusedBorderColor),
      ),

      border: OutlineInputBorder(
        borderSide: BorderSide(color: focusedBorderColor, width: borderWidth),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
    );
  }

  static TextStyle textStyle() {
    return const TextStyle(fontSize: 16, color: Colors.black);
  }
}

// password_text_field.dart
class PasswordTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;

  const PasswordTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      style: CustomTextFieldStyle.textStyle(),
      decoration: CustomTextFieldStyle.inputDecoration(
        labelText: widget.labelText,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
      ),
    );
  }
}
