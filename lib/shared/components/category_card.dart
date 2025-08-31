import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.image,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image Container
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Container(
                color: AppColors.divider,
                child: Center(
                  child: Icon(Feather.image, color: AppColors.body, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Product Name
          Text(
            name,
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
