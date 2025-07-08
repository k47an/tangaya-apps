import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/app/modules/profile/views/widgets/editProfile_widget.dart';
import 'package:tangaya_apps/app/modules/profile/views/widgets/profileCard_widget.dart';
import 'package:tangaya_apps/app/modules/profile/views/widgets/profileHeader_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Neutral.white1,
        body: Obx(() {
          if (!controller.dataLoaded.value && controller.userModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: Primary.mainColor),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadUserData(),
            color: Primary.mainColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeaderWidget(
                    user: controller.userModel,
                    onEditPressed: () {
                      controller.prepareForm();
                      Get.dialog(const EditProfileWidget());
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  sliver: SliverToBoxAdapter(child: const ProfileCardWidget()),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildLogoutButton(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
        label: Text(
          "Logout",
          style: semiBold.copyWith(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
      ),
    );
  }
}
