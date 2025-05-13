import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class HeaderWidget extends StatelessWidget {
  final String displayName;
  final String photoURL;

  const HeaderWidget({
    super.key,
    required this.displayName,
    required this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isLoggedIn = auth.currentUser.value != null;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Neutral.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      toolbarHeight: ScaleHelper.scaleHeightForDevice(80),
      title: _buildUserInfo(auth),
      actions: [_buildNotificationButton(isLoggedIn)],
    );
  }

  Widget _buildUserInfo(AuthController auth) {
    final String userDisplayName =
        displayName.isNotEmpty ? displayName : 'Tamu';

    final ImageProvider<Object> profileImage =
        photoURL.isNotEmpty && photoURL.startsWith('http')
            ? NetworkImage(photoURL)
            : AssetImage(photoURL) as ImageProvider;

    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateProfile(auth),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Neutral.white1,
            backgroundImage: profileImage,
            child:
                photoURL.isEmpty
                    ? Icon(Icons.person, color: Primary.darkColor)
                    : null,
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
    );
  }

  Widget _buildNotificationButton(bool isLoggedIn) {
    return Container(
      margin: ScaleHelper.paddingOnly(right: 16),
      decoration: BoxDecoration(
        color: Neutral.white1,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications),
        color: Neutral.dark1,
        iconSize: ScaleHelper.scaleWidthForDevice(28),
        onPressed: () => _handleNotification(isLoggedIn),
      ),
    );
  }

  void _navigateProfile(AuthController auth) {
    final role = auth.userRole.value;
    if (role == 'admin') {
      Get.toNamed(Routes.ADMIN);
    } else if (role == 'user') {
      Get.toNamed(Routes.PROFILE);
    } else {
      Get.toNamed(Routes.SIGNIN);
    }
  }

  void _handleNotification(bool isLoggedIn) {
    Get.toNamed(isLoggedIn ? Routes.NOTIFICATION : Routes.SIGNIN);
  }
}
