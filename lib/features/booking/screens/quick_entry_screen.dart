import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/admin/providers/package_provider.dart';
import 'package:dr_shine_app/features/admin/models/package_model.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/admin/providers/service_provider.dart';
import 'package:dr_shine_app/features/customer/providers/customer_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';
import 'package:uuid/uuid.dart';

import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

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

  String? _selectedPackageId;
  bool _isPackageTab = false;

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

  final _plateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
      context.read<PackageProvider>().fetchPackages();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _plateController.dispose();
    _plateFocusNode.dispose();
    _modelController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitWash() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceId == null && _selectedPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service or package')),
      );
      return;
    }

    if (_selectedWasherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a washer')),
      );
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();
    final packageProvider = context.read<PackageProvider>();
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (bookingProvider.isLoading) return;

    // Determine price and description
    double price = 0;
    if (_selectedServiceId != null) {
      final service = serviceProvider.services.firstWhere(
          (s) => s.id == _selectedServiceId,
          orElse: () => ServiceModel(
              id: 'unknown', name: 'Unknown', price: 0, description: ''));
      price = service.price;
    } else if (_selectedPackageId != null) {
      final package = packageProvider.packages.firstWhere(
          (p) => p.id == _selectedPackageId,
          orElse: () => PackageModel(
              id: 'unknown',
              name: 'Unknown',
              price: 0,
              description: '',
              includedServiceIds: []));
      price = package.price;
    }

    final booking = BookingModel(
      id: const Uuid().v4(),
      tenantId: authProvider.currentUser?.tenantId,
      userId: 'walk_in', // Walk-in customer
      vehicleId: 'temp_vehicle',
      serviceId: _selectedServiceId,
      packageId: _selectedPackageId,
      status: 'washing',
      bookingDate: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      price: price,
      customerPhone: _phoneController.text.trim(),
      carBrand: _selectedBrand,
      carModel: _modelController.text.trim().isEmpty
          ? null
          : _modelController.text.trim(),
      plateNumber: _plateController.text.trim().toUpperCase(),
      washerStaffId: _selectedWasherId,
      washerStaffName: _selectedWasherName,
    );

    // Capture navigator and messenger before async gap
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await bookingProvider.createBooking(booking);
      debugPrint(
          'QuickEntryScreen: Booking created successfully. Attempting to pop.');

      if (mounted) {
        navigator.pop();
        debugPrint('QuickEntryScreen: Screen popped.');

        messenger.showSnackBar(
          SnackBar(
            content: Text('Wash started for ${booking.plateNumber}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showQuickWasherDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Washer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                return;
              }

              final userProvider = context.read<UserProvider>();
              final authProvider = context.read<AuthProvider>();
              final adminTenantId = authProvider.currentUser?.tenantId;

              final newUser = UserModel(
                id: const Uuid().v4(),
                tenantId: adminTenantId,
                phoneNumber: phoneController.text,
                displayName: nameController.text,
                role: 'washer',
                createdAt: DateTime.now().toUtc(),
              );

              try {
                await userProvider.createWasherAccount(
                  newUser,
                  authRepository: locator.authRepository,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Washer added!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final currentTenantId = authProvider.currentUser?.tenantId;
    final staffList = userProvider.workers.where((u) {
      if (currentTenantId == null) return true;
      return u.tenantId == currentTenantId;
    }).toList();

    final services = serviceProvider.services;

    debugPrint('QuickEntryScreen: Building with ${staffList.length} workers.');
    debugPrint(
        'QuickEntryScreen: Current Admin: ${authProvider.currentUser?.displayName}, Tenant: $currentTenantId');

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
      body: ResponsiveLayout(
        child: SingleChildScrollView(
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
                    // Plate Number with Autocomplete
                    RawAutocomplete<BookingModel>(
                      textEditingController: _plateController,
                      focusNode: _plateFocusNode,
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        // Capture context before async gap
                        final provider = context.read<CustomerProvider>();
                        return await provider
                            .searchCustomers(textEditingValue.text);
                      },
                      displayStringForOption: (BookingModel option) =>
                          option.plateNumber ?? '',
                      onSelected: (BookingModel selection) {
                        if (!mounted) return;

                        if (selection.carBrand != null) {
                          setState(() {
                            _selectedBrand = selection.carBrand;
                          });
                        }
                        if (selection.carModel != null) {
                          _modelController.text = selection.carModel!;
                        }
                        if (selection.customerPhone != null) {
                          _phoneController.text = selection.customerPhone!;
                        }

                        // Show "Welcome Back" message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Welcome back! Last visit: ${_formatDate(selection.bookingDate)}'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<BookingModel> onSelected,
                          Iterable<BookingModel> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.surface,
                            child: SizedBox(
                              height: 200.0,
                              width: MediaQuery.of(context).size.width -
                                  32, // Adjust width
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final BookingModel option =
                                      options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      option.plateNumber ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${option.carBrand ?? ''} ${option.carModel ?? ''} • Last: ${_formatDate(option.bookingDate)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                    trailing: const Icon(Icons.history,
                                        size: 16,
                                        color: AppColors.textSecondary),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Plate Number',
                            hintText: 'AA-12345',
                            prefixIcon: const Icon(Icons.pin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            suffixIcon:
                                context.watch<CustomerProvider>().isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : null,
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
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),

                    // Brand and Model Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useVerticalLayout = constraints.maxWidth < 400;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: useVerticalLayout
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2,
                              child: DropdownButtonFormField<String>(
                                value: _selectedBrand,
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
                            SizedBox(
                              width: useVerticalLayout
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2,
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
                        );
                      },
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
                    // Tabs
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPackageTab = false;
                                  _selectedPackageId = null;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isPackageTab
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: !_isPackageTab
                                      ? Border.all(color: AppColors.primary)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Single Services',
                                  style: TextStyle(
                                    fontWeight: !_isPackageTab
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !_isPackageTab
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPackageTab = true;
                                  _selectedServiceId = null;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isPackageTab
                                      ? Colors.amber.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: _isPackageTab
                                      ? Border.all(color: Colors.amber)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.stars,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Packages',
                                      style: TextStyle(
                                        fontWeight: _isPackageTab
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _isPackageTab
                                            ? Colors.amber
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!_isPackageTab) ...[
                      // Single Services List
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services.map((service) {
                          final isSelected = _selectedServiceId == service.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedServiceId = service.id;
                              });
                              // Upsell logic could go here
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
                                          ? Colors.white
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
                    ] else ...[
                      // Packages List
                      Consumer<PackageProvider>(
                        builder: (context, packageProvider, _) {
                          if (packageProvider.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (packageProvider.packages.isEmpty) {
                            return const Center(
                                child: Text('No packages available',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)));
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: packageProvider.packages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final package = packageProvider.packages[index];
                              final isSelected =
                                  _selectedPackageId == package.id;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedPackageId = package.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.amber.withValues(alpha: 0.1)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.stars,
                                            color: Colors.amber),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(package.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            Text(package.description,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors
                                                        .textSecondary)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              '${package.price.toStringAsFixed(0)} ETB',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                  color: Colors.amber)),
                                          if (package.description.contains(
                                              'Save')) // Rudimentary check, ideally calculate
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.success,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text('DEAL',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.p20),

                // Washer Assignment Card
                _buildSectionCard(
                  icon: Icons.person,
                  title: 'Assign Washer',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedWasherId,
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
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        (staff.displayName ??
                                                staff.phoneNumber)[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        staff.displayName ?? staff.phoneNumber),
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
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: _showQuickWasherDialog,
                          icon: const Icon(Icons.person_add_rounded),
                          tooltip: 'Add New Washer',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
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
                    onPressed: bookingProvider.isLoading ? null : _submitWash,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (bookingProvider.isLoading)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          const Icon(Icons.play_arrow, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'START WASH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p16),
              ],
            ),
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
