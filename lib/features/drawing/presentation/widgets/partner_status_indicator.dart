import 'package:flutter/material.dart';
import 'package:hooklove/core/theme/app_colors.dart';

class PartnerStatusIndicator extends StatelessWidget {
  final bool isDrawing;
  final String? partnerName;

  const PartnerStatusIndicator({
    super.key,
    required this.isDrawing,
    this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDrawing) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pulsingDot(),
          const SizedBox(width: 8),
          Text(
            '${partnerName ?? 'Tu pareja'} está dibujando...',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulsingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
