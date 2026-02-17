import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

class PinLoginScreen extends StatefulWidget {
  final String phoneNumber;
  const PinLoginScreen({super.key, required this.phoneNumber});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Enter PIN'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: AppSizes.p24),
              const Text(
                'Enter Security PIN',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back! Enter PIN for ${widget.phoneNumber}',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p32),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: InputDecoration(
                  counterText: '',
                  border: const OutlineInputBorder(),
                  errorText: _error ? 'Incorrect PIN. Try again.' : null,
                ),
                onChanged: (_) => setState(() => _error = false),
              ),
              const SizedBox(height: AppSizes.p24),
              PrimaryButton(
                text: 'Login',
                isLoading: authProvider.isLoading,
                onPressed: _handlePinLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePinLogin() async {
    try {
      await context.read<AuthProvider>().loginWithPhoneAndPin(
            widget.phoneNumber,
            _pinController.text,
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() => _error = true);
    }
  }
}
