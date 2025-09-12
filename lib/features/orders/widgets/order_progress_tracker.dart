import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/theme/app_colors.dart';

enum OrderProgressStep {
  pending,
  shipped,
  delivered,
}

class OrderProgressTracker extends StatelessWidget {
  final String status;
  final String title;
  final String description;

  const OrderProgressTracker({
    super.key,
    required this.status,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep(status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.body,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressSteps(currentStep),
        ],
      ),
    );
  }

  OrderProgressStep _getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'seller_notified':
      case 'seller_accepted':
      case 'confirmed':
      case 'processing':
        return OrderProgressStep.pending;
      case 'shipped':
        return OrderProgressStep.shipped;
      case 'delivered':
        return OrderProgressStep.delivered;
      default:
        return OrderProgressStep.pending;
    }
  }

  Widget _buildProgressSteps(OrderProgressStep currentStep) {
    final steps = [
      _ProgressStepData(
        step: OrderProgressStep.pending,
        icon: Feather.shopping_bag,
        label: 'Pending',
      ),
      _ProgressStepData(
        step: OrderProgressStep.shipped,
        icon: Feather.truck,
        label: 'Shipped',
      ),
      _ProgressStepData(
        step: OrderProgressStep.delivered,
        icon: Feather.check_circle,
        label: 'Delivered',
      ),
    ];

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepData = entry.value;
        final isActive = stepData.step == currentStep;
        final isCompleted = _isStepCompleted(stepData.step, currentStep);

        return Expanded(
          child: Row(
            children: [
              // Step Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? AppColors.primary
                      : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stepData.icon,
                  size: 20,
                  color: isCompleted || isActive
                      ? AppColors.white
                      : AppColors.body,
                ),
              ),
              
              // Connector Line (except for last step)
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isStepCompleted(OrderProgressStep step, OrderProgressStep currentStep) {
    final stepOrder = [
      OrderProgressStep.pending,
      OrderProgressStep.shipped,
      OrderProgressStep.delivered,
    ];
    
    final stepIndex = stepOrder.indexOf(step);
    final currentIndex = stepOrder.indexOf(currentStep);
    
    return stepIndex < currentIndex;
  }
}

class _ProgressStepData {
  final OrderProgressStep step;
  final IconData icon;
  final String label;

  _ProgressStepData({
    required this.step,
    required this.icon,
    required this.label,
  });
}
