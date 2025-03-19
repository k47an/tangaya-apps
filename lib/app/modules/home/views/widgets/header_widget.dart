import 'package:flutter/material.dart';
import 'package:tangaya_apps/app/constant/constant.dart';
import 'package:get/get.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Primary.lightColor, width: 1),
                  image: DecorationImage(
                    image: AssetImage('assets/dummy/profile.JPG'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selamat Datang',
                    style: extraBold.copyWith(
                      color: Primary.subtleColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Katan',
                    style: regular.copyWith(
                      color: Primary.subtleColor,
                      fontSize: 14,
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
                    iconSize: 25,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.message_rounded),
                    color: Primary.subtleColor,
                    iconSize: 25,
                    onPressed: () {
                      // Navigate to
                      Get.toNamed('/chat');
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
