import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_strings.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/core/widgets/bubble_animation_widget.dart';
import 'package:dr_shine_app/features/auth/widgets/shining_car_logo.dart';
import 'otp_verification_screen.dart';

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
        children: [
          // Background Animation
          const BubbleAnimationWidget(),
          
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.p32),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppSizes.r24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: ShiningCarLogo(size: 140),
                        ),
                        const SizedBox(height: AppSizes.p24),
                        const Text(
                          'DR. SHINE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'PREMIUM CAR WASH',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.p40),
                        const Text(
                          AppStrings.loginSubtitle,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.p32),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: '+251 9... or +251 7...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.r12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p24),
                        PrimaryButton(
                          text: AppStrings.sendOtp.toUpperCase(),
                          isLoading: authProvider.isLoading,
                          onPressed: () async {
                            final phone = _phoneController.text.trim();
                            if (phone.isNotEmpty) {
                              // Check for mock users (demo mode)
                              if (phone.endsWith('00') || phone.endsWith('44') || phone.endsWith('55')) {
                                 Navigator.pushNamed(context, '/pin-login', arguments: phone);
                                 return;
                              }
                              
                              // Only attempt Firebase auth if initialized
                              if (isFirebaseInitialized) {
                                await authProvider.verifyPhone(phone);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtpVerificationScreen(phoneNumber: phone),
                                    ),
                                  );
                                }
                              } else {
                                // Show error if not a mock user and Firebase not available
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Demo mode: Use quick access buttons below'),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        // Quick Access Buttons (always visible for demo)
                        const SizedBox(height: AppSizes.p40),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white10)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('QUICK ACCESS', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
                            ),
                            Expanded(child: Divider(color: Colors.white10)),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickLoginButton(context, 'Customer', '+251 9...55'),
                            _buildQuickLoginButton(context, 'Staff', '+251 9...44'),
                            _buildQuickLoginButton(context, 'Manager', '+251 9...00'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginButton(BuildContext context, String label, String phoneSuffix) {
    return InkWell(
      onTap: () {
        final fullPhone = phoneSuffix.replaceAll('...', '112233');
        _phoneController.text = fullPhone;
        if (phoneSuffix.contains('00') || phoneSuffix.contains('44') || phoneSuffix.contains('55')) {
           Navigator.pushNamed(context, '/pin-login', arguments: fullPhone);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Icon(
              label == 'Manager' ? Icons.admin_panel_settings : label == 'Staff' ? Icons.engineering : Icons.person,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(), 
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
