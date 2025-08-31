import 'package:flutter/material.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';

class CategoriesSlider extends StatelessWidget {
  final List<String> categories;
  final Function(String)? onCategorySelected;
  final int? selectedIndex;

  const CategoriesSlider({
    super.key, 
    required this.categories,
    this.onCategorySelected,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex != null ? index == selectedIndex : index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            child: ElevatedButton(
              onPressed: () {
                if (onCategorySelected != null) {
                  onCategorySelected!(categories[index]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Color(0xFFF9FAFB),
                foregroundColor: isSelected
                    ? AppColors.primary
                    : AppColors.heading,
                elevation: isSelected ? 0 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Color(0xFFEAECF0), // dynamic border color
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(categories[index]),
            ),
          );
        },
      ),
    );
  }
}
