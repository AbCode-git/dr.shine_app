import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/features/admin/providers/service_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class ServicePriceEditor extends StatefulWidget {
  const ServicePriceEditor({super.key});

  @override
  State<ServicePriceEditor> createState() => _ServicePriceEditorState();
}

class _ServicePriceEditorState extends State<ServicePriceEditor> {
  final Map<String, bool> _activeStatus = {};

  @override
  void initState() {
    super.initState();
  }

  void _editService(int index, ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final priceController =
        TextEditingController(text: service.price.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit ${service.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (ETB)'),
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
              final serviceProvider = context.read<ServiceProvider>();
              final updatedService = ServiceModel(
                id: service.id,
                name: nameController.text,
                description: service.description,
                price: double.tryParse(priceController.text) ?? service.price,
              );
              await serviceProvider.updateService(updatedService);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addService() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add New Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (ETB)'),
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
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                return;
              }

              final serviceProvider = context.read<ServiceProvider>();
              final newService = ServiceModel(
                id: 'service_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                description: 'Custom service added by management',
                price: double.tryParse(priceController.text) ?? 0,
              );
              await serviceProvider.addService(newService);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final services = serviceProvider.services;

    return Scaffold(
      appBar: AppBar(title: const Text('Service Pricing')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_business),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = services[index];
          final isActive = _activeStatus[service.id] ?? true;

          return Card(
            child: ListTile(
              title: Text(
                service.name,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
                  decoration: isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text('${service.price.toInt()} ETB'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: isActive,
                    onChanged: (val) {
                      setState(() {
                        _activeStatus[service.id] = val;
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.edit, size: 20, color: Colors.white38),
                    onPressed: () => _editService(index, service),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
