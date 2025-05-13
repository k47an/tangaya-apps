import 'package:flutter/material.dart';

import '../../constant/constant.dart';

class MainButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final bool isEnabled;

  const MainButton({required this.label, this.onTap, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: ScaleHelper.paddingSymmetric(vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isEnabled ? Primary.mainColor : Neutral.white1,
        ),
        child: Text(
          label,
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
            color: isEnabled ? Neutral.white1 : Neutral.dark3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
