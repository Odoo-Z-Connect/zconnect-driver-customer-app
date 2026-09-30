import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import '../../../core/app_colors.dart';
import 'driver_home_screen.dart';
import 'driver_jobs_screen.dart';
import 'driver_profile_screen.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _index = 0;
  int _previousIndex = 0;

  static const List<Widget> _screens = [
    DriverHomeScreen(),
    DriverJobsScreen(),
    DriverJobsHistoryScreen(),
    DriverProfileScreen(),
  ];

  static const _items = [
    _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    _NavItem(
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded,
        label: 'Jobs'),
    _NavItem(
        icon: Icons.history_rounded,
        activeIcon: Icons.history_rounded,
        label: 'History'),
    _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    setState(() {
      _previousIndex = _index;
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: _index < _previousIndex,
        transitionBuilder: (child, animation, secondary) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondary,
          child: child,
        ),
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar:
          _BottomNav(currentIndex: _index, items: _items, onTap: _onTap),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(
      {required this.currentIndex, required this.items, required this.onTap});
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          key: ValueKey(selected),
                          color: selected
                              ? AppColors.primaryGreen
                              : AppColors.warmGrey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected
                                  ? AppColors.primaryGreen
                                  : AppColors.warmGrey)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
