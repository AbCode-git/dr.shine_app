import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/vehicle/providers/vehicle_provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';
import 'package:dr_shine_app/shared/widgets/service_card.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class CreateBookingScreen extends StatefulWidget {
  final ServiceModel? initialService;

  const CreateBookingScreen({super.key, this.initialService});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  VehicleModel? _selectedVehicle;
  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      context
          .read<VehicleProvider>()
          .fetchVehicles(authProvider.currentUser!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Wash')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Your Vehicle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            if (vehicleProvider.vehicles.isEmpty)
              _buildAddVehicleCta(context)
            else
              _buildVehicleSelector(vehicleProvider.vehicles),
            const SizedBox(height: AppSizes.p24),
            const Text('Select Service',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            _buildServiceSelector(),
            const SizedBox(height: AppSizes.p24),
            const Text('Select Day',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            _buildDateSelector(),
            const SizedBox(height: AppSizes.p32),
            PrimaryButton(
              text: 'Book Now',
              isLoading: bookingProvider.isLoading,
              onPressed: (_selectedVehicle != null && _selectedService != null)
                  ? () async {
                      final booking = BookingModel(
                        id: const Uuid().v4(),
                        userId: authProvider.currentUser!.id,
                        vehicleId: _selectedVehicle!.id,
                        serviceId: _selectedService!.id,
                        status: 'pending',
                        bookingDate: _selectedDate,
                        createdAt: DateTime.now(),
                        price: _selectedService!.price,
                      );

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      await bookingProvider.createBooking(booking);

                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Booking request submitted!')),
                        );
                        navigator.pop();
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddVehicleCta(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.registerVehicle),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, style: BorderStyle.none),
          borderRadius: BorderRadius.circular(AppSizes.r12),
          color: AppColors.surface,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary),
            SizedBox(width: 8),
            Text('No vehicles registered. Add one now.',
                style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(List<VehicleModel> vehicles) {
    return Wrap(
      spacing: 8,
      children: vehicles.map((v) {
        final isSelected = _selectedVehicle?.id == v.id;
        return ChoiceChip(
          label: Text('${v.nickname ?? v.type} (${v.plateNumber})'),
          selected: isSelected,
          onSelected: (selected) =>
              setState(() => _selectedVehicle = selected ? v : null),
        );
      }).toList(),
    );
  }

  Widget _buildServiceSelector() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: defaultServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p12),
        itemBuilder: (context, index) {
          final service = defaultServices[index];
          final isSelected = _selectedService?.id == service.id;

          return SizedBox(
            width: 200,
            child: ServiceCard(
              service: service,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedService = service),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return Row(
      children: [
        _dateChip('Today', DateTime.now()),
        const SizedBox(width: 8),
        _dateChip('Tomorrow', tomorrow),
      ],
    );
  }

  Widget _dateChip(String label, DateTime date) {
    final isSelected = date.day == _selectedDate.day;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedDate = date),
    );
  }
}
