import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/constant/constant.dart';

class HeroImageWidget extends StatelessWidget {
  final String imageUrl;

  const HeroImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Image.network(
            imageUrl.isNotEmpty ? imageUrl : "https://via.placeholder.com/600x400?text=No+Image",
            key: ValueKey(imageUrl),
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(color: Primary.mainColor)),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: Colors.grey.shade300,
              child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.70),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ],
    );
  }
}