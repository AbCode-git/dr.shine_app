import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppColors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            effectiveBackgroundColor,
            effectiveBackgroundColor.withValues(
                alpha:
                    0.8), // Assuming withValues is a custom extension that behaves like withOpacity
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: [
          if (onPressed != null && !isLoading)
            BoxShadow(
              color: effectiveBackgroundColor.withValues(
                  alpha:
                      0.3), // Assuming withValues is a custom extension that behaves like withOpacity
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: isLoading
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Or some other disabled color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                elevation: 0, // No shadow when disabled
                side: BorderSide(
                    color: AppColors.primary.withValues(
                        alpha:
                            0.5)), // Assuming withValues is a custom extension that behaves like withOpacity
              )
            : ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.transparent, // Transparent to show gradient
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                elevation: 2,
                side: isLoading
                    ? BorderSide(
                        color: effectiveBackgroundColor.withValues(alpha: 0.1))
                    : null,
                shadowColor: AppColors.primary.withValues(
                    alpha:
                        0.3), // Assuming withValues is a custom extension that behaves like withOpacity
              ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
