import 'package:flutter/material.dart';
import 'package:tangaya_apps/constant/constant.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final String? onChanged;
  final dynamic validator;
  final dynamic title;

  const InputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.title,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText?.isNotEmpty == true ? errorText : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        contentPadding: ScaleHelper.paddingSymmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }
}
