import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';

class TopSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final EdgeInsets? margin;
  final String hintText;
  final bool showBorder;
  final bool readOnly;

  const TopSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSearch,
    this.onClear,
    this.focusNode,
    this.margin,
    this.hintText = 'Search...',
    this.showBorder = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: readOnly
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF2F4F7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Icon(Feather.search, color: AppColors.body, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        hintText,
                        style: TextStyle(color: AppColors.body, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (onSearch != null && value.trim().isNotEmpty) {
                  onSearch!();
                }
              },
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.heading,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.body, fontSize: 14),
                prefixIcon: Icon(
                  Feather.search,
                  color: AppColors.body,
                  size: 18,
                ),
                filled: true,
                fillColor: Color(0XFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: showBorder
                      ? BorderSide(color: Colors.grey.shade300)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: showBorder
                      ? BorderSide(color: AppColors.primary)
                      : BorderSide.none,
                ),
              ),
            ),
    );
  }
}
