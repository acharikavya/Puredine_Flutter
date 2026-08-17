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
  static const Color maroonDark = Color(0xFF6E1616);
  static const Color gold = Color(0xFFF4C430);
  static const Color muted = Color(0xFF8A6F5E);
  static const Color cream = Color(0xFFFDF3E6);
  static const Color chipBg = Color(0xFFF3E1CE);
}

class _AdminNavItem {
  final IconData icon;
  final String label;
  const _AdminNavItem(this.icon, this.label);
}

/// Breakpoint above which the admin shell switches from a bottom nav bar
/// (mobile/tablet) to a persistent side navigation rail (desktop/web).
/// Purely a layout decision — no navigation logic changes based on this.
const double _kDesktopBreakpoint = 900;

/// Persistent bottom-nav shell for the admin console, mirroring the same
/// pattern already used by the staff module's MainScaffold. Wraps the five
/// admin screens (Dashboard, Menu, Staff, Tables, Orders) in an
/// IndexedStack so switching tabs preserves each screen's scroll position,
/// filters, and other state instead of rebuilding from scratch — the same
/// Instagram-style behavior the staff side already has.
///
/// On wide (desktop/web) viewports, the same tab list is presented as a
/// persistent side navigation rail instead of a bottom bar. On narrow
/// (mobile) viewports the layout is unchanged from before.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;

        final body = IndexedStack(
          index: _currentIndex,
          children: screens,
        );

        if (isDesktop) {
          // Desktop/web layout: persistent side navigation rail + content.
          return Scaffold(
            body: Row(
              children: [
                _AdminSideNavRail(
                  items: _navItems,
                  currentIndex: _currentIndex,
                  onSelect: (i) => setState(() => _currentIndex = i),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        // Mobile/tablet layout: unchanged bottom navigation bar.
        return Scaffold(
          body: body,
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
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
      },
    );
  }
}

/// Persistent side navigation rail shown only on desktop/web-width
/// viewports (see [_kDesktopBreakpoint]). Presents the same tab items as
/// the mobile bottom nav bar — same [items] list, same [currentIndex] /
/// [onSelect] contract — just laid out as a branded vertical panel
/// (logo header, "ADMIN PANEL" badge, pill-style nav rows, admin footer
/// card) instead of a bottom bar. Purely a presentational alternative;
/// no navigation logic is duplicated or diverges between layouts.
class _AdminSideNavRail extends StatelessWidget {
  final List<_AdminNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AdminSideNavRail({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: _NavPalette.cream,
      child: SafeArea(
        left: false,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildBrandHeader(),
            const SizedBox(height: 18),
            _buildAdminPanelBadge(),
            const SizedBox(height: 22),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final isSelected = currentIndex == i;
                  final item = items[i];
                  return _NavRow(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => onSelect(i),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildAdminFooterCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Fork/knife brand mark + "PUREDINE" wordmark at the top of the rail.
  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _NavPalette.maroon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'PUREDINE',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _NavPalette.maroon,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gold pill badge reading "ADMIN PANEL", centered under the brand header.
  Widget _buildAdminPanelBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _NavPalette.gold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 14,
              color: _NavPalette.maroonDark,
            ),
            const SizedBox(width: 6),
            Text(
              'ADMIN PANEL',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: _NavPalette.maroonDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static "Admin / Online" footer card at the bottom of the rail. Purely
  /// decorative chrome matching the brand panel — the real Profile screen
  /// is still reached via its entry in the nav list above.
  Widget _buildAdminFooterCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _NavPalette.maroon,
              child: Text(
                'A',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _NavPalette.maroonDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _NavPalette.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row in the desktop side nav. Selected state renders as a
/// maroon pill with a left accent bar, a circular icon chip, bold white
/// label, and a trailing chevron — unselected rows are plain icon + label
/// in muted tones.
class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [_NavPalette.maroonDark, _NavPalette.maroon],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Left accent bar, only visible when selected.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _NavPalette.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.16)
                      : _NavPalette.chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : _NavPalette.maroon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : _NavPalette.maroonDark,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
