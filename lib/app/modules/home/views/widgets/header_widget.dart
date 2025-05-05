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
      automaticallyImplyLeading: false, // Menghilangkan tombol back
      backgroundColor: Primary.darkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      // Menetapkan tinggi AppBar
      toolbarHeight: ScaleHelper(
        context,
      ).scaleHeightForDevice(80), // Atur tinggi AppBar di sini
      title: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: Row(
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
                width: ScaleHelper(context).scaleWidthForDevice(50),
                height: ScaleHelper(context).scaleHeightForDevice(50),
                decoration: BoxDecoration(
                  border: Border.all(color: Neutral.white1, width: 1),
                  image: DecorationImage(
                    image: profileImage,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            SizedBox(width: ScaleHelper(context).scaleWidthForDevice(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: extraBold.copyWith(
                    color: Primary.subtleColor,
                    fontSize: ScaleHelper(context).scaleTextForDevice(14),
                  ),
                ),
                Text(
                  userDisplayName,
                  style: regular.copyWith(
                    color: Primary.subtleColor,
                    fontSize: ScaleHelper(context).scaleTextForDevice(14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          color: Primary.subtleColor,
          iconSize: ScaleHelper(context).scaleWidthForDevice(20),
          onPressed: () {
            // TODO: Aksi notifikasi
          },
        ),
        IconButton(
          icon: const Icon(Icons.message_rounded),
          color: Primary.subtleColor,
          iconSize: ScaleHelper(context).scaleWidthForDevice(20),
          onPressed: () {
            Get.toNamed(Routes.CHAT);
          },
        ),
        IconButton(
          icon: Icon(isLoggedIn ? Icons.logout_sharp : Icons.login),
          color: Primary.subtleColor,
          iconSize: ScaleHelper(context).scaleWidthForDevice(20),
          onPressed: () async {
            if (isLoggedIn) {
              await auth.signOut(); // Pastikan signOut selesai
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
