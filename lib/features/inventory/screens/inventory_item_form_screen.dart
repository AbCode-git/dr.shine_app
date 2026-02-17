import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/inventory/providers/inventory_provider.dart';
import 'package:dr_shine_app/features/inventory/models/inventory_item_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';
import 'package:uuid/uuid.dart';

class InventoryItemFormScreen extends StatefulWidget {
  final InventoryItem? item;
  const InventoryItemFormScreen({super.key, this.item});

  @override
  State<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState extends State<InventoryItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _currentStockController;
  late TextEditingController _minStockController;
  late TextEditingController _reorderController;
  late TextEditingController _unitController;
  late TextEditingController _costController;
  late TextEditingController _viscosityController;
  late InventoryCategory _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _currentStockController =
        TextEditingController(text: widget.item?.currentStock.toString());
    _minStockController = TextEditingController(
        text: widget.item?.minStockLevel.toString() ?? '10.0');
    _reorderController = TextEditingController(
        text: widget.item?.reorderLevel.toString() ?? '20.0');
    _unitController =
        TextEditingController(text: widget.item?.unit ?? 'liters');
    _costController =
        TextEditingController(text: widget.item?.costPerUnit.toString());
    _viscosityController =
        TextEditingController(text: widget.item?.viscosityGrade);
    _category = widget.item?.category ?? InventoryCategory.carWash;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.item == null ? 'Add Item' : 'Edit ${widget.item!.name}'),
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown(),
                const SizedBox(height: AppSizes.p20),
                _buildTextField(_nameController, 'Item Name', Icons.inventory),
                const SizedBox(height: AppSizes.p20),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_currentStockController,
                            'Current Stock', Icons.numbers,
                            isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_unitController,
                            'Unit (e.g. Liters)', Icons.straighten)),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_minStockController, 'Min Stock',
                            Icons.warning_amber,
                            isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _reorderController, 'Reorder Point', Icons.reorder,
                            isNumber: true)),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),
                _buildTextField(
                    _costController, 'Cost Per Unit (ETB)', Icons.payments,
                    isNumber: true),
                if (_category == InventoryCategory.oilChange) ...[
                  const SizedBox(height: AppSizes.p20),
                  _buildTextField(_viscosityController,
                      'Viscosity Grade (e.g. 5W-30)', Icons.oil_barrel),
                ],
                const SizedBox(height: AppSizes.p40),
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.primary,
                  ),
                  child:
                      Text(widget.item == null ? 'CREATE ITEM' : 'UPDATE ITEM'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<InventoryCategory>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12)),
      ),
      items: InventoryCategory.values.map((cat) {
        return DropdownMenuItem(
            value: cat, child: Text(cat.name.toUpperCase()));
      }).toList(),
      onChanged: (val) => setState(() => _category = val!),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final inventoryProvider = context.read<InventoryProvider>();

      final itemData = InventoryItem(
        id: widget.item?.id ?? const Uuid().v4(),
        name: _nameController.text,
        category: _category,
        currentStock: double.tryParse(_currentStockController.text) ?? 0,
        minStockLevel: double.tryParse(_minStockController.text) ?? 10.0,
        reorderLevel: double.tryParse(_reorderController.text) ?? 20.0,
        unit: _unitController.text,
        costPerUnit: double.tryParse(_costController.text) ?? 0,
        viscosityGrade: _category == InventoryCategory.oilChange
            ? _viscosityController.text
            : null,
      );

      if (widget.item == null) {
        await inventoryProvider.addItem(itemData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Inventory item created successfully')));
        }
      } else {
        await inventoryProvider.updateItem(itemData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inventory updated successfully')));
        }
      }
      if (mounted) Navigator.pop(context);
    }
  }
}
