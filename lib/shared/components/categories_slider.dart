import 'package:flutter/material.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/core/utils/responsive.dart';

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
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex != null
              ? index == selectedIndex
              : index == 0;
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
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : Color(0xFFF9FAFB),
                foregroundColor: isSelected
                    ? AppColors.primary
                    : Color(0XFF667085),
                elevation: isSelected ? 0 : 1,
                minimumSize: const Size(0, 26),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                textStyle: TextStyle(
                  fontSize: fontSize + 6,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
