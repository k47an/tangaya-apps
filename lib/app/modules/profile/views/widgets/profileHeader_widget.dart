import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/user_model.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildAppBar(), _buildHeaderContent()]);
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Primary.darkColor,
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Profil Saya",
        style: semiBold.copyWith(color: Colors.white, fontSize: 18),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        TextButton.icon(
          onPressed: onEditPressed,
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.white.withOpacity(0.9),
            size: 18,
          ),
          label: Text(
            "Edit",
            style: regular.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Primary.darkColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child:
          user == null
              ? const SizedBox(
                height: 76,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                ),
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage:
                        user?.photoUrl != null && user!.photoUrl.isNotEmpty
                            ? NetworkImage(user!.photoUrl)
                            : const AssetImage(
                                  "assets/images/default_profile.png",
                                )
                                as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'Nama Pengguna',
                          style: bold.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (user?.role != null && user!.role.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              user!.role == 'user'
                                  ? 'Pengunjung'
                                  : (user!.role.capitalizeFirst ?? user!.role),
                              style: medium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
