import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final List<DetailRow> details;

  const DetailSection({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          ...details.map((detail) => _buildDetailRow(detail)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(DetailRow detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${detail.label}:',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.body,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.heading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow {
  final String label;
  final String value;

  DetailRow({
    required this.label,
    required this.value,
  });
}
