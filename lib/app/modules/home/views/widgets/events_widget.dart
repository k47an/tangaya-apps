import 'package:flutter/material.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EventsWidget extends StatelessWidget {
  const EventsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
      itemCount: 6, // Hanya contoh
      itemBuilder: (context, index) {
        return const ArticleCard(
          image: "assets/dummy/camp.jpg",
          title: "Camping Adventure",
        );
      },
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String image;
  final String title;

  const ArticleCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: ScaleHelper(context).scaleHeightForDevice(150),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            height: ScaleHelper(context).scaleHeightForDevice(150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                stops: const [0.1, 0.9],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              title,
              style: semiBold.copyWith(
                color: Colors.white,
                fontSize: ScaleHelper(context).scaleTextForDevice(14),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
