import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dr_shine_app/features/vehicle/providers/vehicle_provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/vehicle/models/vehicle_model.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/primary_button.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _colorController = TextEditingController();
  String _vehicleType = 'Sedan';

  final List<String> _types = ['Compact', 'Sedan', 'SUV', 'Pickup', 'Van'];

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  hintText: 'e.g. 2AA12345',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _vehicleType = value!),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              PrimaryButton(
                text: 'Register',
                isLoading: vehicleProvider.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final vehicle = VehicleModel(
                      id: const Uuid().v4(),
                      ownerId: authProvider.currentUser!.id,
                      plateNumber: _plateController.text.trim(),
                      type: _vehicleType,
                      nickname: _nicknameController.text.trim(),
                      color: _colorController.text.trim(),
                    );
                    await vehicleProvider.registerVehicle(vehicle);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
