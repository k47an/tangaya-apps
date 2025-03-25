import 'package:flutter/material.dart';
import 'package:tangaya_apps/constant/constant.dart';
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
                    image: AssetImage('assets/dummy/profile.JPG'),
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
                    'Katan',
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
                      // Navigate to search page
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.message_rounded),
                    color: Primary.subtleColor,
                    iconSize: ScaleHelper(context).scaleWidthForDevice(20),
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
