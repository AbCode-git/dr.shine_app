import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';
import 'package:dr_shine_app/core/widgets/bubble_animation_widget.dart';
import 'package:dr_shine_app/features/auth/widgets/shining_car_logo.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Animation Layer
          const BubbleAnimationWidget(),

          // Gradient Overlay for Depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p24, vertical: 40),
              child: Column(
                children: [
                  const Center(
                    child: Hero(
                      tag: 'logo',
                      child: ShiningCarLogo(size: 160),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  const Text(
                    'DR. SHINE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: AppColors.primary, blurRadius: 20),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'PREMIUM CAR CARE SUITE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Login Glass Card
                  _buildLoginCard(context, authProvider),

                  const SizedBox(height: 50),

                  // Premium Role Hub (The "Wow" FTA)
                  _buildRoleHub(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthProvider authProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded,
                      color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'SECURE LOGIN',
                isLoading: authProvider.isLoading,
                onPressed: () => _handleLogin(context, authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleHub(BuildContext context) {
    return Column(
      children: [
        const Text(
          'QUICK ACCESS HUB',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white24,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoleTile(
                context,
                'Manager',
                Icons.admin_panel_settings_rounded,
                '+251 9...00',
                AppColors.primary),
            const SizedBox(width: 16),
            _buildRoleTile(context, 'Staff', Icons.bolt_rounded, '+251 9...44',
                Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleTile(BuildContext context, String label, IconData icon,
      String phone, Color color) {
    return InkWell(
      onTap: () => _quickLogin(context, phone),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, AuthProvider authProvider) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Direct navigation to PIN login (Skipping OTP per requirements)
    Navigator.pushNamed(context, AppRoutes.pinLogin, arguments: phone);
  }

  void _quickLogin(BuildContext context, String phoneSuffix) {
    final fullPhone = phoneSuffix.replaceAll('...', '112233');
    _phoneController.text = fullPhone;
    Navigator.pushNamed(context, AppRoutes.pinLogin, arguments: fullPhone);
  }
}
