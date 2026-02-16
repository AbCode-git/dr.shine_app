import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class QuickEntryScreen extends StatefulWidget {
  const QuickEntryScreen({super.key});

  @override
  State<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends State<QuickEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedBrand;
  String? _selectedServiceId;
  String? _selectedWasherId;
  String? _selectedWasherName;

  // Common Ethiopian car brands
  final List<String> _carBrands = [
    'Toyota',
    'Hyundai',
    'Nissan',
    'Mitsubishi',
    'Suzuki',
    'Honda',
    'Mazda',
    'Isuzu',
    'Volkswagen',
    'Mercedes-Benz',
    'BMW',
    'Land Rover',
    'Other',
  ];

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitWash() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    if (_selectedWasherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a washer')),
      );
      return;
    }

    final service =
        defaultServices.firstWhere((s) => s.id == _selectedServiceId);
    final bookingProvider = context.read<BookingProvider>();

    final booking = BookingModel(
      id: 'wash_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'walk_in', // Walk-in customer
      vehicleId: 'temp_vehicle',
      serviceId: _selectedServiceId!,
      status: 'washing',
      bookingDate: DateTime.now(),
      createdAt: DateTime.now(),
      price: service.price,
      customerPhone: _phoneController.text.trim(),
      carBrand: _selectedBrand,
      carModel: _modelController.text.trim().isEmpty
          ? null
          : _modelController.text.trim(),
      plateNumber: _plateController.text.trim().toUpperCase(),
      washerStaffId: _selectedWasherId,
      washerStaffName: _selectedWasherName,
    );

    try {
      await bookingProvider.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wash started for ${booking.plateNumber}'),
            backgroundColor: AppColors.success,
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _plateController.clear();
        _modelController.clear();
        _phoneController.clear();
        setState(() {
          _selectedBrand = null;
          _selectedServiceId = null;
          _selectedWasherId = null;
          _selectedWasherName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final staffList = userProvider.staff;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Quick Car Entry'),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.primary.withValues(alpha: 0.8)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Fill in car details to start a new wash',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // Car Details Card
              _buildSectionCard(
                icon: Icons.directions_car,
                title: 'Vehicle Information',
                children: [
                  // Plate Number
                  TextFormField(
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: 'Plate Number',
                      hintText: 'AA-12345',
                      prefixIcon: const Icon(Icons.pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Plate number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Brand and Model Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedBrand,
                          decoration: InputDecoration(
                            labelText: 'Brand',
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          items: _carBrands.map((brand) {
                            return DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBrand = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Brand is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _modelController,
                          decoration: InputDecoration(
                            labelText: 'Model',
                            hintText: 'Optional',
                            prefixIcon: const Icon(Icons.car_repair),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p20),

              // Customer Phone Card
              _buildSectionCard(
                icon: Icons.phone,
                title: 'Customer Contact',
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+251 9XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p20),

              // Service Selection Card
              _buildSectionCard(
                icon: Icons.local_car_wash,
                title: 'Select Service',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: defaultServices.map((service) {
                      final isSelected = _selectedServiceId == service.id;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedServiceId = service.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                service.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.price.toStringAsFixed(0)} ETB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p20),

              // Washer Assignment Card
              _buildSectionCard(
                icon: Icons.person,
                title: 'Assign Washer',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedWasherId,
                    decoration: InputDecoration(
                      labelText: 'Select Staff Member',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    items: staffList.map((staff) {
                      return DropdownMenuItem(
                        value: staff.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                (staff.displayName ?? staff.phoneNumber)[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(staff.displayName ?? staff.phoneNumber),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWasherId = value;
                        final staff =
                            staffList.firstWhere((s) => s.id == value);
                        _selectedWasherName =
                            staff.displayName ?? staff.phoneNumber;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please assign a washer';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p32),

              // Submit Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.success],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitWash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'START WASH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Custom formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
