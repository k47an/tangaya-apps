import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tangaya_apps/constant/constant.dart';

class AuthButton extends StatelessWidget {
  final String svgAssetPath;
  final String label;
  final Function()? onTap;

  const AuthButton({
    required this.svgAssetPath,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScaleHelper(context).scaleWidthForDevice(30),
          vertical: ScaleHelper(context).scaleHeightForDevice(10),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Neutral.dark5, width: 0.5),
          color: Neutral.white3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: ScaleHelper(context).scaleWidthForDevice(10),
              ),
              child: SvgPicture.asset(
                svgAssetPath,
                width: ScaleHelper(context).scaleWidthForDevice(20),
                height: ScaleHelper(context).scaleHeightForDevice(20),
              ),
            ),
            Text(
              label,
              style: semiBold.copyWith(
                fontSize: ScaleHelper(context).scaleTextForDevice(16),
                color: Neutral.dark3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
