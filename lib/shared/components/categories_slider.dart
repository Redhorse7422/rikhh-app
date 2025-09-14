import 'package:flutter/material.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/core/utils/responsive.dart';
import 'package:rikhh_app/features/products/models/product_model.dart';
import 'package:rikhh_app/shared/components/optimized_image.dart';
import 'package:rikhh_app/core/services/image_optimization_service.dart';

class CategoriesSlider extends StatelessWidget {
  final List<ProductCategory> categories;
  final Function(ProductCategory)? onCategorySelected;
  final int? selectedIndex;

  const CategoriesSlider({
    super.key,
    required this.categories,
    this.onCategorySelected,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    return SizedBox(
      height: 90, // bigger height for image + text
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex != null
              ? index == selectedIndex
              : index == -1;
          return GestureDetector(
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(categories[index]);
              }
            },
            child: Container(
              width: 70, // fixed width per category
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFEAECF0),
                        width: 2,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: OptimizedImage(
                        imageUrl: categories[index].image ?? '',
                        fit: BoxFit.cover,
                        size: ImageSize.thumbnail,
                        width: 50,
                        height: 50,
                        errorWidget: Icon(Icons.category, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categories[index].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0XFF667085),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
