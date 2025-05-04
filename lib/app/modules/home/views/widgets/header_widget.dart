import 'package:flutter/material.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:get/get.dart';

class HeaderWidget extends StatelessWidget {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String photoURL;

  HeaderWidget({
    super.key,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan Get.find() untuk mengambil instance yang sudah ada dari AuthController
    var auth = Get.find<AuthController>();

    // Gunakan data dari arguments atau fallback ke default jika null
    final String userDisplayName =
        displayName.isNotEmpty ? displayName : 'No Name';
    final String userEmail = email.isNotEmpty ? email : 'No Email';
    final String userPhoneNumber =
        phoneNumber.isNotEmpty ? phoneNumber : 'No Phone Number';
    final String userPhotoURL = photoURL.isNotEmpty ? photoURL : '';
    debugPrint(
      'User Info: $userDisplayName, $userEmail, $userPhoneNumber, $userPhotoURL',
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Primary.darkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: ScaleHelper(context).scaleWidthForDevice(50),
                height: ScaleHelper(context).scaleHeightForDevice(50),
                decoration: BoxDecoration(
                  border: Border.all(color: Neutral.dark4, width: 1),
                  image: DecorationImage(
                    image:
                        (userPhotoURL.isNotEmpty)
                            ? NetworkImage(
                              userPhotoURL,
                            ) // Memastikan gambar diambil dari URL
                            : AssetImage('assets/dummy/profile.JPG')
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50),
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
              Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    color: Primary.subtleColor,
                    iconSize: ScaleHelper(context).scaleWidthForDevice(20),
                    onPressed: () {
                      // Aksi untuk membuka halaman notifikasi
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.message_rounded),
                    color: Primary.subtleColor,
                    iconSize: ScaleHelper(context).scaleWidthForDevice(20),
                    onPressed: () {
                      // Aksi untuk membuka halaman chat
                      Get.toNamed(Routes.CHAT);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      (userDisplayName.isNotEmpty && userPhotoURL.isNotEmpty)
                          ? Icons.logout_sharp
                          : Icons.login,
                    ),
                    color: Primary.subtleColor,
                    iconSize: ScaleHelper(context).scaleWidthForDevice(20),
                    onPressed: () {
                      if (userDisplayName.isNotEmpty &&
                          userPhotoURL.isNotEmpty) {
                        auth.signOut(); // Panggil fungsi logout
                      } else {
                        Get.toNamed(
                          Routes.SIGNIN,
                        ); // Arahkan ke halaman login jika belum login
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
