import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';
import 'package:dr_shine_app/features/admin/models/tenant_model.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final _tenantRepo = locator.tenantRepository;
  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() => _isLoading = true);
    try {
      final tenants = await _tenantRepo.getTenants();
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load branches')),
        );
      }
    }
  }

  Future<void> _showAddBranchDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title:
            const Text('Add New Branch', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Branch Name',
            hintText: 'e.g. Bole Branch',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _tenantRepo.createTenant(controller.text);
                if (context.mounted) Navigator.pop(context);
                _loadTenants();
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Branch Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTenants,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
              ? const _EmptyState()
              : _buildBranchList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBranchDialog,
        icon: const Icon(Icons.add),
        label: const Text('ADD BRANCH'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBranchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: _tenants.isEmpty ? 1 : _tenants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 8),
            child: Text(
              'ACTIVE LOCATIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
          );
        }
        final tenant = _tenants[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              child: const Icon(Icons.location_on_rounded,
                  color: AppColors.primary, size: 20),
            ),
            title: Text(
              tenant.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              'ID: ${tenant.id.substring(0, 8)}...',
              style: const TextStyle(color: Colors.white24, fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white10),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Branch?'),
                    content:
                        Text('Are you sure you want to remove ${tenant.name}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('CANCEL')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('DELETE',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _tenantRepo.deleteTenant(tenant.id);
                  _loadTenants();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'No branches registered yet',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
