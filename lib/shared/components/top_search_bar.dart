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
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF2F4F7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Icon(Feather.search, color: AppColors.body),
                      const SizedBox(width: 12),
                      Text(
                        hintText,
                        style: TextStyle(
                          color: AppColors.body,
                          fontSize: 16,
                        ),
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
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.body),
                prefixIcon: Icon(Feather.search, color: AppColors.body),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Character count indicator when typing (if less than 3 chars)
                    if (controller?.text.isNotEmpty == true && controller!.text.length < 3)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: controller!.text.length == 2
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.body.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${controller!.text.length}/3',
                          style: TextStyle(
                            color: controller!.text.length == 2
                                ? AppColors.primary
                                : AppColors.body,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // Clear button when there's text
                    if (controller?.text.isNotEmpty == true)
                      IconButton(
                        onPressed: onClear,
                        icon: Icon(Feather.x, color: AppColors.body),
                        iconSize: 20,
                      ),
                    // Search button
                    if (onSearch != null)
                      IconButton(
                        onPressed: () {
                          if (controller?.text.trim().isNotEmpty == true) {
                            onSearch!();
                          }
                        },
                        icon: Icon(Feather.search, color: AppColors.primary),
                      ),
                  ],
                ),
                filled: true,
                fillColor: Color(0XFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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
