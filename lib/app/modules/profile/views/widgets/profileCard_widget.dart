import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ProfileCardWidget extends GetView<ProfileController> {
  const ProfileCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.userModel;
    String displayPhone = (user?.phone.isEmpty ?? true) ? "-" : user!.phone;
    String displayAddress =
        (user?.address.isEmpty ?? true) ? "-" : user!.address;
    String displayGender = (user?.gender.isEmpty ?? true) ? "-" : user!.gender;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Neutral.white4,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10.0, top: 4.0),
            child: Text(
              "Informasi Pribadi",
              style: bold.copyWith(fontSize: 18, color: Neutral.dark1),
            ),
          ),
          const Divider(
            thickness: 0.5,
            height: 16,
            indent: 16,
            endIndent: 16,
            color: Neutral.dark4,
          ),
          _infoListTile(
            context,
            icon: Icons.email_outlined,
            label: "Email",
            value: user?.email ?? "-",
          ),
          _infoListTile(
            context,
            icon: Icons.person_outline_rounded,
            label: "Jenis Kelamin",
            value: displayGender,
          ),
          _infoListTile(
            context,
            icon: Icons.phone_iphone_rounded,
            label: "Nomor HP",
            value: displayPhone,
          ),
          _infoListTile(
            context,
            icon: Icons.location_on_outlined,
            label: "Alamat",
            value: displayAddress,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _infoListTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isMultiLine ? 8 : 4,
      ),
      leading: Icon(icon, color: Primary.mainColor, size: 24),
      title: Text(
        label,
        style: medium.copyWith(fontSize: 13, color: Neutral.dark3),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Text(
          value.isEmpty ? "-" : value,
          style: regular.copyWith(
            fontSize: 15,
            color: Neutral.dark1,
            height: isMultiLine ? 1.4 : 1.2,
          ),
        ),
      ),
      dense: !isMultiLine,
    );
  }
}
