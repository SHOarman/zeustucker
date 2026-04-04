import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectIndex;

  const CustomBottomNav({super.key, required this.selectIndex});

  static const _items = [
    _NavItem(icon: 'assets/icon/home.svg', label: 'Home', route: '/home'),
    _NavItem(
      icon: 'assets/icon/Library.svg',
      label: 'Library',
      route: '/library',
    ),
    _NavItem(icon: 'assets/icon/Macros.svg', label: 'Macros', route: '/stats'),
    _NavItem(
      icon: 'assets/icon/Weekly.svg',
      label: 'Weekly',
      route: '/schedule',
    ),
    _NavItem(
      icon: 'assets/icon/profile.svg',
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        // The main bar background gradient (Dark to Grey)
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF3B3E43), Color(0xFF6E7175)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = selectIndex == index;

          return GestureDetector(
            onTap: () {
              if (!isSelected) Get.offAllNamed(item.route);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                // The active item is a solid Teal/Green color
                color: isSelected
                    ? const Color(0xFF00A781)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    item.icon,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    height: 24,
                    width: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
