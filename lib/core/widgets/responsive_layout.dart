import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool useConstraint;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.useConstraint = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!useConstraint) return child;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSizes.desktopMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
