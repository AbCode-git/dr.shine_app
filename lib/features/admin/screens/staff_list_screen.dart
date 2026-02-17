import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/models/user_model.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:uuid/uuid.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';
import 'package:dr_shine_app/core/widgets/responsive_layout.dart';

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
    final pinController = TextEditingController();
    String selectedRole = staff?.role ?? 'staff';
    final isEditing = staff != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(isEditing ? 'Edit Team Member' : 'Add New Member'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'staff', child: Text('Standard Staff')),
                    DropdownMenuItem(value: 'washer', child: Text('Washer')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                if (!isEditing &&
                    (selectedRole == 'staff' || selectedRole == 'admin')) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'Initial Login PIN',
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: '6 digits recommended',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Staff will use this PIN to log in independently.',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ],
            ),
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

                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  return;
                }

                if (!isEditing &&
                    selectedRole == 'staff' &&
                    pinController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please set a PIN for staff')),
                  );
                  return;
                }

                try {
                  final authProvider = context.read<AuthProvider>();
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
                      role: selectedRole,
                      createdAt: DateTime.now(),
                      tenantId: authProvider.currentUser?.tenantId,
                    );

                    if (selectedRole == 'staff' || selectedRole == 'admin') {
                      await userProvider.createStaffAccount(
                        newUser,
                        pinController.text,
                        authRepository: locator.authRepository,
                      );
                    } else {
                      await userProvider.createWasherAccount(
                        newUser,
                        authRepository: locator.authRepository,
                      );
                    }
                  }

                  if (mounted) {
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentTenantId = authProvider.currentUser?.tenantId;

    final filteredUsers = userProvider.allUsers.where((u) {
      if (currentTenantId == null) return true;
      return u.tenantId == currentTenantId;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add),
      ),
      body: ResponsiveLayout(
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final bool isAdmin = user.role == 'admin';
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            (isAdmin ? AppColors.primary : Colors.blue)
                                .withValues(alpha: 0.1),
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: isAdmin ? AppColors.primary : Colors.blue,
                        ),
                      ),
                      title: Text(user.displayName ?? 'Unnamed User'),
                      subtitle: Text(user.phoneNumber),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Badge(
                            label: Text(user.role.toUpperCase()),
                            backgroundColor:
                                isAdmin ? AppColors.primary : Colors.blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.white38),
                            onPressed: () => _showStaffDialog(staff: user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
