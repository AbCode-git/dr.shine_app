import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:uuid/uuid.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  void _showStaffDialog({UserModel? staff}) {
    final nameController = TextEditingController(text: staff?.displayName);
    final phoneController = TextEditingController(text: staff?.phoneNumber);
    final isEditing = staff != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isEditing ? 'Edit Staff member' : 'Add New Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                hintText: '+251...',
              ),
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
              final userProvider = context.read<UserProvider>();
              final navigator = Navigator.of(context);

              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                return;
              }

              if (isEditing) {
                await userProvider.updateUserDetails(
                  staff.id,
                  displayName: nameController.text,
                  phoneNumber: phoneController.text,
                );
              } else {
                final newUser = UserModel(
                  id: const Uuid().v4(),
                  phoneNumber: phoneController.text,
                  displayName: nameController.text,
                  role: 'admin',
                  createdAt: DateTime.now(),
                );
                await userProvider.createUser(newUser);
              }

              if (mounted) {
                navigator.pop();
              }
            },
            child: Text(isEditing ? 'Update' : 'Add Staff'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: userProvider.staff.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final staff = userProvider.staff[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(staff.displayName ?? 'Staff member'),
                    subtitle: Text(staff.phoneNumber),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Badge(
                          label: Text('ADMIN'),
                          backgroundColor: AppColors.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: Colors.white38),
                          onPressed: () => _showStaffDialog(staff: staff),
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
