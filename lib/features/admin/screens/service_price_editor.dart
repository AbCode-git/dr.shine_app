import 'package:flutter/material.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class ServicePriceEditor extends StatefulWidget {
  const ServicePriceEditor({super.key});

  @override
  State<ServicePriceEditor> createState() => _ServicePriceEditorState();
}

class _ServicePriceEditorState extends State<ServicePriceEditor> {
  late List<ServiceModel> _services;
  final Map<String, bool> _activeStatus = {};

  @override
  void initState() {
    super.initState();
    _services = List.from(defaultServices);
  }

  void _editService(int index) {
    final service = _services[index];
    final nameController = TextEditingController(text: service.name);
    final priceController =
        TextEditingController(text: service.price.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              setState(() {
                _services[index] = ServiceModel(
                  id: service.id,
                  name: nameController.text,
                  description: service.description,
                  price: double.tryParse(priceController.text) ?? service.price,
                );
                // Update the global list for the session (mock)
                defaultServices[index] = _services[index];
              });
              Navigator.pop(context);
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
            onPressed: () {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                return;
              }

              setState(() {
                final newService = ServiceModel(
                  id: 'service_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  description: 'Custom service added by management',
                  price: double.tryParse(priceController.text) ?? 0,
                );
                _services.add(newService);
                defaultServices.add(newService);
              });
              Navigator.pop(context);
            },
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Pricing')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_business),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = _services[index];
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
                    onPressed: () => _editService(index),
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
