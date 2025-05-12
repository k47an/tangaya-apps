import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Neutral.white4,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Get.back(),
            ),
            iconTheme: const IconThemeData(color: Neutral.white1),
            centerTitle: true,
            backgroundColor: Primary.mainColor,
            title: Text(
              "Admin Dashboard",
              style: semiBold.copyWith(
                fontSize: ScaleHelper(context).scaleTextForDevice(20),
                color: Neutral.white1,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (auth.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(ScaleHelper(context).scaleWidthForDevice(14)),
          child: Container(
            decoration: BoxDecoration(
              color: Neutral.white3,
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            padding: EdgeInsets.all(
              ScaleHelper(context).scaleWidthForDevice(16),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: ScaleHelper(context).scaleWidthForDevice(60),
                      height: ScaleHelper(context).scaleWidthForDevice(60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image:
                              auth.userPhotoURL.startsWith('http')
                                  ? NetworkImage(auth.userPhotoURL)
                                  : AssetImage(auth.userPhotoURL)
                                      as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ScaleHelper(context).scaleWidthForDevice(16),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName,
                          style: bold.copyWith(
                            fontSize: ScaleHelper(
                              context,
                            ).scaleTextForDevice(20),
                            color: Neutral.dark1,
                          ),
                        ),
                        Text(
                          auth.userRole.value.capitalizeFirst ?? 'Pengunjung',
                          style: semiBold.copyWith(
                            fontSize: ScaleHelper(
                              context,
                            ).scaleTextForDevice(14),
                            color: Neutral.dark4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(24)),
                Row(
                  children: [
                    Text(
                      "Data Pribadi",
                      style: bold.copyWith(fontSize: 16, color: Neutral.dark1),
                    ),
                  ],
                ),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(8)),
                Divider(color: Primary.mainColor),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(8)),
                _dataPribadiTextField("Email", auth.user?.email ?? "-"),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(15)),
                _dataPribadiTextField(
                  "Jenis Kelamin",
                  auth.userGender.value.isEmpty ? "-" : auth.userGender.value,
                ),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(15)),
                _dataPribadiTextField(
                  "Nomor HP",
                  auth.userPhone.value.isEmpty ? "-" : auth.userPhone.value,
                ),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(15)),
                _alamatTextField(
                  "Alamat",
                  auth.userAddress.value.isEmpty ? "-" : auth.userAddress.value,
                ),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(8)),
                Divider(color: Primary.mainColor),
                _manageTextField("List Paket dan event", "lihat"),
                SizedBox(height: ScaleHelper(context).scaleHeightForDevice(8)),
                _orderTextField("List Order", "lihat"),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _dataPribadiTextField(String title, String data) {
    return Row(
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        Text(data, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
      ],
    );
  }

  Widget _alamatTextField(String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        Expanded(
          child: Text(
            data,
            style: bold.copyWith(fontSize: 12, color: Neutral.dark1),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _manageTextField(String title, String data) {
    return Row(
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.MANAGE_TOUR);
          },
          child: Text(
            data,
            style: bold.copyWith(
              fontSize: 12,
              color: Primary.mainColor,
              decoration: TextDecoration.underline,
              decorationColor: Primary.mainColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderTextField(String title, String data) {
    return Row(
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.ORDERVIEW);
            debugPrint("Order View");
          },
          child: Text(
            data,
            style: bold.copyWith(
              fontSize: 12,
              color: Primary.mainColor,
              decoration: TextDecoration.underline,
              decorationColor: Primary.mainColor,
            ),
          ),
        ),
      ],
    );
  }
}
