import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dr_shine_app/features/auth/providers/auth_provider.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';
import 'package:dr_shine_app/features/booking/providers/booking_provider.dart';
import 'package:dr_shine_app/features/booking/models/booking_model.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_strings.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';
import 'package:dr_shine_app/core/utils/helpers.dart';
import 'package:dr_shine_app/shared/models/service_model.dart';
import 'package:dr_shine_app/shared/widgets/service_card.dart';
import 'package:dr_shine_app/features/booking/screens/create_booking_screen.dart';
import 'package:dr_shine_app/core/widgets/bubble_animation_widget.dart';
import 'package:dr_shine_app/app/app_routes.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isListening = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final statusProvider = context.watch<StatusProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final user = authProvider.currentUser;

    if (!_isListening && user != null) {
      _isListening = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bookingProvider.listenToUserBookings(user.id, (title, body) {
          AppHelpers.showSnackBar(context, '$title: $body');
        });
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Animation
          const BubbleAnimationWidget(),
          
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, authProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.p16),
                      _buildHeader(user?.displayName),
                      const SizedBox(height: AppSizes.p32),
                      _buildPromotionsCarousel(),
                      const SizedBox(height: AppSizes.p32),
                      _buildLiveTracker(context, bookingProvider, user?.id),
                      const SizedBox(height: AppSizes.p32),
                      _buildStatusBanner(statusProvider.currentStatus),
                      const SizedBox(height: AppSizes.p40),
                      _buildSectionTitle('Quick Navigation'),
                      const SizedBox(height: AppSizes.p20),
                      _buildActionGrid(context),
                      const SizedBox(height: AppSizes.p40),
                      _buildSectionHeader(
                        'Our Premium Services', 
                        'View All',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      _buildQuickServices(context),
                      const SizedBox(height: AppSizes.p40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthProvider auth) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColors.background.withValues(alpha: 0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Text(
        AppStrings.appName.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
          color: AppColors.primary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, size: 20, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String? name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${name ?? "Friend"}!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(BusyStatus status) {
    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (status) {
      case BusyStatus.busy:
        statusColor = AppColors.statusBusy;
        statusTitle = 'SHOP IS BUSY';
        statusIcon = Icons.access_time_filled;
        break;
      case BusyStatus.veryBusy:
        statusColor = AppColors.statusVeryBusy;
        statusTitle = 'HIGH DEMAND';
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = AppColors.statusNotBusy;
        statusTitle = 'READY TO WASH';
        statusIcon = Icons.check_circle_rounded;
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
      borderRadius: BorderRadius.circular(AppSizes.r24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSizes.r24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Come in for a fresh shine today',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Colors.white38,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildGlassActionCard(
          context,
          icon: Icons.directions_car_rounded,
          title: 'My Garage',
          desc: 'Manage vehicles',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/vehicle-list'),
        ),
        _buildGlassActionCard(
          context,
          icon: Icons.receipt_long_rounded,
          title: 'Activity',
          desc: 'View bookings',
          color: AppColors.accent,
          onTap: () => Navigator.pushNamed(context, '/booking-list'),
        ),
        _buildGlassActionCard(
          context,
          icon: Icons.emoji_events_rounded,
          title: 'Rewards',
          desc: 'Lucky points',
          color: Colors.greenAccent,
          onTap: () => Navigator.pushNamed(context, '/loyalty'),
        ),
        _buildGlassActionCard(
          context,
          icon: Icons.map_rounded,
          title: 'Support',
          desc: 'Find us',
          color: Colors.lightBlueAccent,
          onTap: () => Navigator.pushNamed(context, '/location'),
        ),
      ],
    );
  }

  Widget _buildGlassActionCard(BuildContext context,
      {required IconData icon, required String title, required String desc, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.r24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSizes.r24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionsCarousel() {
    // These paths are relative to the project root and will work in the bundled app
    final promos = [
      {
        'image': 'assets/images/promo_opening.png', // Temporary path for logic
        'title': '50% OFF OPENING WEEK',
        'subtitle': 'First time? Get half off your first wash!'
      },
      {
        'image': 'assets/images/promo_rewards.png',
        'title': 'LOYALTY REWARDS',
        'subtitle': 'Your 5th wash is on us!'
      },
    ];

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                if (promo['title']!.contains('LOYALTY')) {
                  Navigator.pushNamed(context, '/loyalty');
                } else {
                  Navigator.pushNamed(context, '/booking');
                }
              },
              borderRadius: BorderRadius.circular(AppSizes.r24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r24),
                child: Stack(
                  children: [
                    // Image Placeholder with Brand Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary.withValues(alpha: 0.5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                         child: Icon(Icons.star_rounded, color: Colors.white10, size: 80),
                      ),
                    ),
                    // Dark Overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0, 0.6],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveTracker(BuildContext context, BookingProvider provider, String? userId) {
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<BookingModel>>(
      stream: provider.getTodayBookings(), // In demo mode this returns mock data
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final activeBooking = bookings.cast<BookingModel?>().firstWhere(
              (b) => b?.status != 'completed' && b?.status != 'cancelled' && b?.userId == userId,
              orElse: () => null,
            );

        if (activeBooking == null) return const SizedBox.shrink();

        final steps = ['Queued', 'Washing', 'Polishing', 'Ready'];
        int currentStep = 0;
        if (activeBooking.status == 'accepted') currentStep = 1;
        if (activeBooking.status == 'washing') currentStep = 2; // Simulated status
        if (activeBooking.status == 'ready') currentStep = 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Active Wash Status'),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSizes.r24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (index) {
                      final isActive = index <= currentStep;
                      final isCurrent = index == currentStep;
                      return Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : Colors.white10,
                                shape: BoxShape.circle,
                                boxShadow: isCurrent
                                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10)]
                                    : null,
                              ),
                              child: Icon(
                                isActive ? Icons.check : Icons.circle,
                                size: 16,
                                color: isActive ? Colors.white : Colors.white24,
                              ),
                            ),
                            if (index < steps.length - 1)
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: index < currentStep ? AppColors.primary : Colors.white10,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (index) {
                      final isActive = index <= currentStep;
                      return Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.white : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickServices(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: defaultServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final service = defaultServices[index];
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.r24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ServiceCard(
              service: service,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateBookingScreen(initialService: service),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
