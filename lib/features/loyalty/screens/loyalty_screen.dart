import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final points = user?.loyaltyPoints ?? 0;
    
    // Simple logic: 5 points = 1 free wash

    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Rewards')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.p24),
            Container(
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.r16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Shine Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Loyalty Member',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_car_wash,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final isFilled = index < (points % 5);
                      return Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isFilled ? Colors.white : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isFilled ? Icons.check : Icons.star_border,
                              color: isFilled ? AppColors.primary : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p40),
            Text(
              '$points Total Points',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            const Text(
              'Get your 5th wash for FREE!\nSimply show this card at the counter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSizes.p40),
            if (points > 0 && points % 5 == 0)
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.card_giftcard, color: AppColors.success),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have a FREE wash available!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
