import 'package:flutter/material.dart';
import 'package:tangaya_apps/constant/constant.dart';

enum SnackBarType { success, error, warning }

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData iconData;
    BoxBorder? border;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Primary.subtleColor;
        textColor = Primary.darkColor;
        iconColor = Primary.mainColor;
        iconData = Icons.check_circle;
        border = Border.all(color: Primary.mainColor, width: 1.5);
        break;
      case SnackBarType.error:
        backgroundColor = Error.mainColor;
        textColor = Neutral.white1;
        iconColor = Neutral.white1;
        iconData = Icons.highlight_off;
        border = null;
        break;
      case SnackBarType.warning:
        backgroundColor = Warning.mainColor;
        textColor = Neutral.dark1; // Gunakan teks gelap agar lebih terbaca
        iconColor = Neutral.dark1; // Ikon gelap juga
        iconData = Icons.warning_amber_rounded;
        border = null; // Tidak ada border
        break;
    }

    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.all(16), // Padding seragam
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border, // Terapkan border di sini
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(iconData, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: medium.copyWith(color: textColor, fontSize: 14),
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 4),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
