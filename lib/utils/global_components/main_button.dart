import 'package:flutter/material.dart';
import '../../constant/constant.dart';

class MainButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;

  const MainButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        isEnabled
            ? (backgroundColor ?? Primary.mainColor)
            : (disabledBackgroundColor ?? Neutral.white1);

    final Color fgColor =
        isEnabled
            ? (textColor ?? Neutral.white1)
            : (disabledTextColor ?? Neutral.dark3);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: ScaleHelper.paddingSymmetric(vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: bgColor,
        ),
        child: Text(
          label,
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
            color: fgColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
