import 'package:flutter/material.dart';
import '../bloc/orders_bloc.dart';
import '../../../core/theme/app_colors.dart';

class OrderFilterTabs extends StatelessWidget {
  final OrderFilter currentFilter;
  final Function(OrderFilter) onFilterChanged;

  const OrderFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterTab(
            'All',
            OrderFilter.all,
            currentFilter == OrderFilter.all,
          ),
          const SizedBox(width: 12),
          _buildFilterTab(
            'In progress',
            OrderFilter.inProgress,
            currentFilter == OrderFilter.inProgress,
          ),
          const SizedBox(width: 12),
          _buildFilterTab(
            'Delivered',
            OrderFilter.delivered,
            currentFilter == OrderFilter.delivered,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, OrderFilter filter, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.body,
            ),
          ),
        ),
      ),
    );
  }
}
