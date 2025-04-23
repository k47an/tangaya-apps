import 'package:flutter/material.dart';
import 'package:tangaya_apps/constant/constant.dart';

class InputField extends StatelessWidget {
  final String title;
  final void Function(String) onChanged;
  final bool obscureText;
  final Widget? icon;
  final Widget? errorIcon;
  final String? Function(String?)? validator;
  final String? errorText;

  const InputField({
    super.key,
    required this.title,
    required this.onChanged,
    this.obscureText = false,
    this.icon,
    this.errorIcon,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: obscureText,
      onChanged: onChanged,
      style: regular.copyWith(
        fontSize: ScaleHelper(context).scaleTextForDevice(14),
        color: Neutral.dark1,
      ),
      decoration: primary.copyWith(
        hintText: title,
        hintStyle: regular.copyWith(
          fontSize: ScaleHelper(context).scaleTextForDevice(14),
          color: Neutral.dark2,
        ),
        suffixIcon:
            icon != null
                ? Padding(
                  padding: EdgeInsets.all(
                    ScaleHelper(context).scaleWidthForDevice(10),
                  ),
                  child:
                      errorText != null && errorText!.isNotEmpty
                          ? errorIcon
                          : icon,
                )
                : null,
        errorText: errorText,
      ),
    );
  }
}
