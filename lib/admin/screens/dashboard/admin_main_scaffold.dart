import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_unified_app/admin/core/providers/notification_provider.dart';
import 'menu/menu_screen.dart';
import 'staff/staff_landing_screen.dart';
import 'tables/tables_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

/// Local nav colors — matches the app's maroon/gold brand identity used
/// throughout the admin dashboard header and cards. Purely cosmetic;
/// doesn't touch any shared theme/AppColors file.
class _NavPalette {
  static const Color maroon = Color(0xFF8B1D1D);
  static const Color gold = Color(0xFFF4C430);
  static const Color muted = Color(0xFF8A6F5E);
}

class _AdminNavItem {
  final IconData icon;
  final String label;
  const _AdminNavItem(this.icon, this.label);
}

/// Persistent bottom-nav shell for the admin console, mirroring the same
/// pattern already used by the staff module's MainScaffold. Wraps the five
/// admin screens (Dashboard, Menu, Staff, Tables, Orders) in an
/// IndexedStack so switching tabs preserves each screen's scroll position,
/// filters, and other state instead of rebuilding from scratch — the same
/// Instagram-style behavior the staff side already has.
class AdminMainScaffold extends StatefulWidget {
  final int initialTab;
  const AdminMainScaffold({super.key, this.initialTab = 0});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  late int _currentIndex;
// Must stay in the same order as the tabs/screens below. Menu is the
  // first/default tab — the old dashboard cards screen ("Home") has been
  // removed entirely and replaced with a Profile tab.
  static const List<String> _tabRoutes = [
    '/admin/menu',
    '/admin/staff',
    '/admin/tables',
    '/admin/orders',
    '/admin/profile',
  ];

  static const List<_AdminNavItem> _navItems = [
    _AdminNavItem(Icons.restaurant_rounded, 'Menu'),
    _AdminNavItem(Icons.people_outline_rounded, 'Staff'),
    _AdminNavItem(Icons.grid_view_rounded, 'Tables'),
    _AdminNavItem(Icons.receipt_long_rounded, 'Orders'),
    _AdminNavItem(Icons.account_circle_rounded, 'Profile'),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, _tabRoutes.length - 1);

    // Notification polling previously only started inside the old
    // dashboard ("Home") screen's initState. Since that screen is no
    // longer part of the bottom nav, nothing was starting it — moved
    // here instead, since this shell is always mounted regardless of
    // which tab (Menu/Staff/Tables/Orders/Profile) is active.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().startPolling();
    });
  }

  // Called by AdminDashboardScreen's cards instead of context.go(), so
  // tapping a card switches tabs in place rather than pushing a whole new
  // route on top of this shell.
  void _handleDashboardNavigate(String route) {
    final idx = _tabRoutes.indexOf(route);
    if (idx != -1) {
      setState(() => _currentIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const MenuScreen(),
      const StaffLandingScreen(),
      const TablesScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final isSelected = _currentIndex == i;
                final item = _navItems[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _NavPalette.maroon.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            size: 21,
                            color: isSelected
                                ? _NavPalette.maroon
                                : _NavPalette.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? _NavPalette.maroon
                                : _NavPalette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
