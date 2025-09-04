import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesSliderSkeleton extends StatelessWidget {
  const CategoriesSliderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6, // number of skeleton items
        itemBuilder: (context, index) {
          return Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 12, width: 50, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
