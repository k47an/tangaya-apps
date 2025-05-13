import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class HeaderWidget extends StatelessWidget {
  final String displayName;
  final String photoURL;

  HeaderWidget({super.key, required this.displayName, required this.photoURL});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    final String userDisplayName =
        displayName.isNotEmpty ? displayName : 'Tamu';
    final ImageProvider<Object> profileImage =
        photoURL.isNotEmpty && photoURL.startsWith('http')
            ? NetworkImage(photoURL)
            : AssetImage(photoURL);

    final bool isLoggedIn = auth.currentUser.value != null;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Primary.mainColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        side: BorderSide(color: Primary.darkColor, width: 1),
      ),
      toolbarHeight: ScaleHelper.scaleHeightForDevice(80),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (auth.userRole.value == 'admin') {
                Get.toNamed(Routes.ADMIN);
              } else if (auth.userRole.value == 'user') {
                Get.toNamed(Routes.PROFILE);
              } else {
                Get.toNamed(Routes.SIGNIN);
              }
            },
            child: Container(
              width: ScaleHelper.scaleWidthForDevice(50),
              height: ScaleHelper.scaleHeightForDevice(50),
              decoration: BoxDecoration(
                border: Border.all(color: Primary.darkColor, width: 1),
                image: DecorationImage(image: profileImage, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          SizedBox(width: ScaleHelper.scaleWidthForDevice(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: extraBold.copyWith(
                  color: Primary.subtleColor,
                  fontSize: ScaleHelper.scaleTextForDevice(14),
                ),
              ),
              Text(
                userDisplayName,
                style: regular.copyWith(
                  color: Primary.subtleColor,
                  fontSize: ScaleHelper.scaleTextForDevice(14),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          color: Primary.subtleColor,
          iconSize: ScaleHelper.scaleWidthForDevice(20),
          onPressed: () {
            if (isLoggedIn) {
              Get.toNamed(Routes.NOTIFICATION);
            } else {
              Get.toNamed(Routes.SIGNIN);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.message_rounded),
          color: Primary.subtleColor,
          iconSize: ScaleHelper.scaleWidthForDevice(20),
          onPressed: () {
            Get.toNamed(Routes.CHAT);
          },
        ),
        IconButton(
          icon: Icon(isLoggedIn ? Icons.logout_sharp : Icons.login),
          color: Primary.subtleColor,
          iconSize: ScaleHelper.scaleWidthForDevice(20),
          onPressed: () async {
            if (isLoggedIn) {
              await auth.signOut();
              Get.offAllNamed(Routes.SIGNIN);
            } else {
              Get.toNamed(Routes.SIGNIN);
            }
          },
        ),
      ],
    );
  }
}
