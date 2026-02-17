import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';
import 'package:dr_shine_app/core/widgets/bubble_animation_widget.dart';
import 'package:dr_shine_app/features/auth/widgets/shining_car_logo.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String _selectedRole = 'admin';
  String? _selectedTenantId;
  String? _errorMessage;

  List<Map<String, dynamic>> _tenants = [];
  bool _loadingTenants = true;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    try {
      // Fetch available branches (tenants) directly via Supabase
      // This works because we'll add a public SELECT policy on tenants
      final response = await Supabase.instance.client
          .from('tenants')
          .select('id, name')
          .order('name');
      setState(() {
        _tenants = List<Map<String, dynamic>>.from(response);
        _loadingTenants = false;
        if (_tenants.isNotEmpty) {
          _selectedTenantId = _tenants.first['id'];
        }
      });
    } catch (e) {
      print('RegisterScreen: Failed to load tenants: $e');
      setState(() => _loadingTenants = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
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
          const BubbleAnimationWidget(),
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
          SafeArea(
            child: ResponsiveLayout(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p24, vertical: 40),
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white70, size: 20),
                      ),
                    ),
                    const Center(
                      child: Hero(
                        tag: 'logo',
                        child: ShiningCarLogo(size: 100),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ADMIN REGISTRATION',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: AppColors.primary, blurRadius: 20),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register as a Branch Owner',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white38,
                          letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Registration Glass Card
                    _buildRegistrationCard(context, authProvider),

                    const SizedBox(height: 30),

                    // Already have account
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'LOGIN',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(
      BuildContext context, AuthProvider authProvider) {
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
              // Phone Number
              _buildInputField(
                controller: _phoneController,
                hint: 'Phone Number (e.g. +251911223300)',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Display Name
              _buildInputField(
                controller: _nameController,
                hint: 'Display Name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),

              // Branch Picker
              _buildBranchSelector(),
              const SizedBox(height: 16),

              // PIN
              _buildInputField(
                controller: _pinController,
                hint: '4-Digit PIN',
                icon: Icons.lock_rounded,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscure: true,
              ),
              const SizedBox(height: 16),

              // Confirm PIN
              _buildInputField(
                controller: _confirmPinController,
                hint: 'Confirm PIN',
                icon: Icons.lock_outline_rounded,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscure: true,
              ),
              const SizedBox(height: 8),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 8),

              // Submit Button
              PrimaryButton(
                text: 'CREATE ACCOUNT',
                isLoading: authProvider.isLoading,
                onPressed: () => _handleRegister(context, authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        counterText: '', // Hide character counter
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.store_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _loadingTenants
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white24),
                        ),
                        SizedBox(width: 12),
                        Text('Loading branches...',
                            style:
                                TextStyle(color: Colors.white24, fontSize: 14)),
                      ],
                    ),
                  )
                : _tenants.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No branches available',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 14)),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTenantId,
                          dropdownColor: AppColors.surface,
                          icon: const Icon(Icons.expand_more_rounded,
                              color: Colors.white38),
                          isExpanded: true,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          items: _tenants
                              .map((t) => DropdownMenuItem<String>(
                                    value: t['id'],
                                    child: Text(t['name'] ?? 'Unknown'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedTenantId = value);
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister(
      BuildContext context, AuthProvider authProvider) async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    // Validation
    if (phone.isEmpty || name.isEmpty || pin.isEmpty || confirmPin.isEmpty) {
      setState(() => _errorMessage = 'All fields are required');
      return;
    }
    if (_selectedTenantId == null && _tenants.isNotEmpty) {
      setState(() => _errorMessage = 'Please select a branch');
      return;
    }
    if (pin.length != 4) {
      setState(() => _errorMessage = 'PIN must be exactly 4 digits');
      return;
    }
    if (pin != confirmPin) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    setState(() => _errorMessage = null);

    try {
      await authProvider.register(phone, pin, name, _selectedRole,
          tenantId: _selectedTenantId);
      // On success, navigate to home (pop all routes)
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _errorMessage =
            'Registration failed. ${e.toString().contains('already registered') ? 'This phone is already registered.' : 'Please try again.'}');
      }
    }
  }
}
