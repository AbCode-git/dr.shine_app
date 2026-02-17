import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/user_provider.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class DutyRosterScreen extends StatefulWidget {
  const DutyRosterScreen({super.key});

  @override
  State<DutyRosterScreen> createState() => _DutyRosterScreenState();
}

class _DutyRosterScreenState extends State<DutyRosterScreen> {
  final Map<String, bool> _onDutyStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final staff = userProvider.staff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duty Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userProvider.fetchUsers(),
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : staff.isEmpty
              ? const Center(child: Text('No staff found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: staff.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = staff[index];
                    final isOnDuty = _onDutyStatus[member.id] ?? true;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOnDuty
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.white10,
                          child: Icon(
                            Icons.person,
                            color:
                                isOnDuty ? AppColors.success : Colors.white38,
                          ),
                        ),
                        title: Text(member.displayName ?? 'Staff member'),
                        subtitle: Text(
                          isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                          style: TextStyle(
                            color:
                                isOnDuty ? AppColors.success : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        trailing: Switch(
                          value: isOnDuty,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            setState(() {
                              _onDutyStatus[member.id] = val;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
