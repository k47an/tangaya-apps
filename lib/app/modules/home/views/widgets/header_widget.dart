import 'package:flutter/material.dart';
import 'package:tangaya_apps/app/constant/constant.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Primary.mainColor,
        gradient: LinearGradient(
          colors: [Primary.mainColor, Primary.subtleColor, Neutral.white1],
          stops: [0.2, 0.9, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      height: 500,
      padding: EdgeInsets.only(top: 60, left: 20, right: 20),
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/dummy/profile.JPG'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: extraBold.copyWith(color: Neutral.dark1, fontSize: 16),
              ),
              Text(
                'Katan',
                style: regular.copyWith(color: Neutral.dark1, fontSize: 14),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.notifications),
            color: Neutral.dark1,
            iconSize: 25,
            onPressed: () {
              // Navigate to search page
            },
          ),
        ],
      ),
    );
  }
}
