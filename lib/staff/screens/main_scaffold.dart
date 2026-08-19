import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../contexts/auth_provider.dart';
import '../../core/auth_provider.dart';
import '../../core/constants.dart' hide AppColors;
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'orders_screen.dart';
import 'tables_screen.dart';
import 'billing_screen.dart';
import '../../utils/session_manager.dart';
import 'profile_screen.dart';
import 'package:go_router/go_router.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / New Orders / Create Order / Menu Management / Orders
/// screens exactly (#8B1D1D primary / #F4C430 gold accent), so the app shell
/// (sidebar on wide screens, bottom nav on mobile) now reads as part of the
/// same cohesive, professional brand instead of the previous neutral
/// slate/white chrome. Used ONLY for this screen's visual layer — nothing
/// here touches AppColors, AppShadows, or any role/auth logic. Role-based
/// accent colors (accentColor / accentLightColor / isBilling) are still
/// computed and passed through exactly as before; this palette only
/// restyles the structural chrome around them.
///
/// UI-ENHANCEMENT PASS: this revision adds richer depth (layered shadows,
/// soft glows, subtle gradients), a clearer active-state language (side
/// accent bar + top indicator dot + scale/bounce), and a slightly more
/// "premium" presentation for the Billing role (gold-flecked ring +
/// finance-style badge) — purely presentational, no logic/state/color
/// source changes.
///
/// NOTE: this is a private class redeclared identically to the one in
/// order_details_screen.dart / new_orders_screen.dart / menu_screen.dart /
/// orders_screen.dart (private classes can't be shared across files without
/// a new shared import, which would go beyond a pure UI-only change here).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color gold = Color(0xFFF4C430);
  static const Color goldLight = Color(0xFFF7D66B);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on every other staff screen.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Small resting shadow for icon chips — gives inactive icon badges a
  /// gentle lift so they stay clearly visible against the cream chrome.
  static List<BoxShadow> get chipShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  /// Elevated shadow that floats "up" — used for the bottom navigation bar
  /// so it reads as a raised, premium dock rather than a flat strip.
  static List<BoxShadow> get floatUpShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.14),
          blurRadius: 28,
          offset: const Offset(0, -10),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ];

  /// Soft ambient gold glow, used behind brand/avatar chips.
  static List<BoxShadow> goldGlow({double alpha = 0.35}) => [
        BoxShadow(
          color: gold.withValues(alpha: alpha),
          blurRadius: 14,
          spreadRadius: 0.5,
        ),
      ];

  /// Wider, softer glow used behind an *active* accent-tinted badge — gives
  /// the currently-selected item a gentle "lit up" halo instead of a flat
  /// tinted circle, making the active state unmistakable at a glance.
  static List<BoxShadow> accentGlow(Color color, {double alpha = 0.32}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.14),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
}

class MainScaffold extends StatefulWidget {
  final int initialTab;
  const MainScaffold({super.key, this.initialTab = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with WidgetsBindingObserver {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _currentIndex = widget.initialTab;

    _checkSessionOnStartup();
  }

  Future<void> _checkSessionOnStartup() async {
    final isValid = await SessionManager.isSessionValid();

    print('Startup Session Valid: $isValid');

    if (!isValid) {
      print('===== STARTUP SESSION INVALID =====');

      await SessionManager.logout();

      if (!mounted) return;

      await context.read<StaffAuthProvider>().logout();

      if (!mounted) return;

      context.go('/login');

      return;
    }

    await SessionManager.updateLastActiveTime();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App resumed
    print("Lifecycle: $state");
    if (state == AppLifecycleState.inactive) {
      await SessionManager.updateLastActiveTime();
    }
    if (state == AppLifecycleState.resumed) {
      bool isValid = await SessionManager.isSessionValid();
      print("Session Valid: $isValid");

      if (!isValid && mounted) {
        print("===== LOGGING OUT =====");

        await SessionManager.logout();

        if (!mounted) return;
        await context.read<StaffAuthProvider>().logout();

        if (mounted) {
          context.go('/login');
        }
      } else {
        await SessionManager.updateLastActiveTime();
      }
    }

    // App paused
    if (state == AppLifecycleState.paused) {
      await SessionManager.updateLastActiveTime();
    }
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _currentIndex = widget.initialTab;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffAuth = context.watch<StaffAuthProvider>();
    final coreAuth = context.watch<AuthProvider>();

    final role = staffAuth.role;
    final user = staffAuth.user;

    // Fix flicker: Use coreAuth role if staffAuth role is not yet loaded
    final isBilling = role == StaffRole.billingStaff ||
        coreAuth.role == UserRole.billingStaff;

    // Role-based accent color
    // NOTE: per request, Billing no longer uses AppColors.billingAccent
    // (green) — both roles now share the same Serving accent color so the
    // whole app shell reads as one consistent Dark Maroon × Gold theme.
    // `isBilling` itself is untouched and still drives which nav items,
    // labels, and icons are shown — only the accent *color* is unified.
    const accentColor = AppColors.servingAccent;
    const accentLightColor = AppColors.servingAccentLight;

    final servingItems = [
      const _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        screen: DashboardScreen(),
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'Orders',
        screen: OrdersScreen(
          onGoHome: () => setState(() => _currentIndex = 0),
        ),
      ),
      _NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Tables',
        screen: TablesScreen(
          onGoHome: () => setState(() => _currentIndex = 0),
        ),
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        screen: ProfileScreen(),
      ),
    ];

    final billingItems = [
      const _NavItem(
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: 'Billing',
        screen: BillingScreen(),
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        screen: ProfileScreen(),
      ),
    ];

    final navItems = isBilling ? billingItems : servingItems;
    final safeIndex = _currentIndex < navItems.length ? _currentIndex : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        if (isWide) {
          return Scaffold(
            backgroundColor: _Palette.canvas,
            body: Row(
              children: [
                _Sidebar(
                  navItems: navItems,
                  currentIndex: safeIndex,
                  onTap: (idx) => setState(() => _currentIndex = idx),
                  roleName: isBilling ? 'Billing Staff' : 'Serving Staff',
                  isBilling: isBilling,
                  accentColor: accentColor,
                  initials: (user?.name.isNotEmpty == true)
                      ? user!.name.substring(0, 1).toUpperCase()
                      : 'S',
                ),
                Expanded(child: navItems[safeIndex].screen),
              ],
            ),
          );
        }

        // ── Mobile Bottom Navigation ──────────────────────────────────────
        return Scaffold(
          backgroundColor: _Palette.canvas,
          body: navItems[safeIndex].screen,
          bottomNavigationBar: _RoleAwareBottomNav(
            navItems: navItems,
            currentIndex: safeIndex,
            accentColor: accentColor,
            accentLightColor: accentLightColor,
            isBilling: isBilling,
            onTap: (idx) => setState(() => _currentIndex = idx),
          ),
        );
      },
    );
  }
}

// ─── Role-Aware Bottom Navigation Bar ─────────────────────────────────────
// Chrome (background, corners, shadow, resting label/icon color) uses the
// Dark Maroon × Soft Cream × Gold Glow theme so it matches every other
// staff screen. Icons sit inside an always-visible circular badge — a soft
// white/cream chip at rest, a bold role-tinted gradient disc with an
// ambient halo when active — plus a small top indicator dot and a subtle
// "lift" scale so the active tab is unmistakable. Billing gets a slightly
// richer gold-ring treatment to feel like a dedicated finance/payments
// dock. The role-based active-state tinting (accentColor / accentLightColor
// / isBilling) is untouched — same variables, same conditionals as before —
// this is a pure presentational wrapper around it.
class _RoleAwareBottomNav extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final Color accentColor;
  final Color accentLightColor;
  final bool isBilling;
  final ValueChanged<int> onTap;

  const _RoleAwareBottomNav({
    required this.navItems,
    required this.currentIndex,
    required this.accentColor,
    required this.accentLightColor,
    required this.isBilling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _Palette.canvasDeep.withValues(alpha: 0.5)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        // Thin gold cap line across the top of the dock, echoing the
        // lemon-chiffon border used on every screen header. Slightly
        // richer / more visible than before for a more "premium" dock.
        border: Border(
          top: BorderSide(
            color: _Palette.lemonChiffon.withValues(alpha: 0.65),
            width: 2.5,
          ),
        ),
        boxShadow: _Palette.floatUpShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: navItems.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = currentIndex == idx;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Top indicator dot — a tiny gold-rimmed accent
                        // dot that fades/pops in above the active badge,
                        // giving a second, unmistakable "you are here"
                        // signal beyond just the badge color change. ────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(bottom: 4),
                          width: isActive ? 18 : 0,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isBilling ? _Palette.gold : accentColor)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: (isBilling
                                              ? _Palette.gold
                                              : accentColor)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        // ── Always-visible circular icon badge — a soft
                        // white/cream chip at rest so the glyph stays
                        // crisp against the bar, and a bold role-tinted
                        // gradient disc with a gold-flecked ambient halo
                        // when active. Billing gets an extra-thick gold
                        // ring so payments feel distinctly "premium". ──
                        AnimatedScale(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          scale: isActive ? 1.0 : 0.94,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width: isActive ? 50 : 44,
                            height: isActive ? 50 : 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isActive
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accentColor,
                                        accentColor.withValues(alpha: 0.78),
                                      ],
                                    )
                                  : null,
                              color: isActive ? null : Colors.white,
                              border: Border.all(
                                color: isActive
                                    ? _Palette.gold.withValues(
                                        alpha: isBilling ? 0.85 : 0.7,
                                      )
                                    : _Palette.milanoRedDeep.withValues(
                                        alpha: 0.12,
                                      ),
                                width: isActive ? (isBilling ? 2.0 : 1.6) : 1.2,
                              ),
                              boxShadow: isActive
                                  ? _Palette.accentGlow(accentColor)
                                  : _Palette.chipShadow,
                            ),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? Colors.white
                                  : _Palette.milanoRedDeep.withValues(
                                      alpha: 0.68,
                                    ),
                              size: isActive ? 26 : 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: AppTheme.sans(
                            size: 10.5,
                            weight:
                                isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive ? accentColor : _Palette.textDark,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar for wide screens ──────────────────────────────────────────────
// Restyled entirely to the Dark Maroon × Soft Cream × Gold Glow theme —
// brand mark, active-item styling, avatar, and dividers now match the
// other staff screens. Every nav icon sits inside its own rounded chip — a
// soft cream badge at rest, a crisp white-on-maroon badge when active — and
// the active row now also carries a bold left accent bar plus a stronger
// glow so the current section is obvious even from a quick glance. The
// role badge gains a matching icon (wallet for Billing, room-service bell
// for Serving) and a slightly richer "premium" ring for Billing so the
// finance/payments context reads as distinct and polished. The role badge
// still uses the accentColor / isBilling values exactly as before
// (role-differentiated by design), just with a richer chip presentation.
class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String roleName;
  final String initials;
  final bool isBilling;
  final Color accentColor;

  const _Sidebar({
    required this.navItems,
    required this.currentIndex,
    required this.onTap,
    required this.roleName,
    required this.initials,
    required this.isBilling,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _Palette.canvasDeep.withValues(alpha: 0.45)],
        ),
        border: Border(
          right: BorderSide(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Brand header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                // Brand icon chip — thin gold border + soft gold glow,
                // matching the icon chip used on every other staff
                // screen's header.
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _Palette.gold.withValues(alpha: 0.8),
                      width: 1.3,
                    ),
                    boxShadow: _Palette.goldGlow(alpha: 0.32),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: _Palette.lemonChiffon,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'PUREDINE',
                  style: AppTheme.serif(
                    size: 22,
                    weight: FontWeight.w700,
                    color: _Palette.milanoRedDeep,
                  ).copyWith(letterSpacing: -0.5),
                ),
              ],
            ),
          ),

          // Role badge — now carries a small role icon (wallet for Billing,
          // room-service bell for Serving) plus a richer "premium" ring
          // treatment for Billing so payments/finance reads distinctly.
          Container(
            margin: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.12),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accentColor.withValues(alpha: isBilling ? 0.35 : 0.22),
                width: isBilling ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                if (isBilling)
                  BoxShadow(
                    color: _Palette.gold.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBilling
                        ? Icons.account_balance_wallet_rounded
                        : Icons.room_service_rounded,
                    size: 14,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  isBilling ? 'BILLING STAFF' : 'SERVING STAFF',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              children: navItems.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                final isActive = currentIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onTap(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _Palette.milanoRedLight,
                                    _Palette.milanoRedDeep,
                                  ],
                                )
                              : null,
                          color: isActive ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isActive
                              ? Border.all(
                                  color: _Palette.gold.withValues(alpha: 0.5),
                                )
                              : Border.all(color: Colors.transparent),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _Palette.milanoRedDeep.withValues(
                                      alpha: 0.30,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: _Palette.gold.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // ── Left accent bar — a thin gold bar that
                            // appears only on the active row, giving a
                            // clear "you are here" marker beyond just
                            // the fill color, echoing app-shell patterns
                            // used in professional dashboards. ─────────
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 3,
                              height: isActive ? 22 : 0,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _Palette.gold,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            // ── Icon badge — always shown as a rounded
                            // chip so the glyph is clearly visible even
                            // at rest, not just a bare icon on a flat
                            // row. ────────────────────────────────────
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : _Palette.canvasDeep.withValues(
                                        alpha: 0.75,
                                      ),
                                border: Border.all(
                                  color: isActive
                                      ? _Palette.gold.withValues(alpha: 0.45)
                                      : _Palette.milanoRedDeep.withValues(
                                          alpha: 0.10,
                                        ),
                                  width: 1.2,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : _Palette.chipShadow,
                              ),
                              child: Icon(
                                isActive ? item.activeIcon : item.icon,
                                color: isActive
                                    ? Colors.white
                                    : _Palette.milanoRedDeep.withValues(
                                        alpha: 0.72,
                                      ),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppTheme.sans(
                                  size: 15,
                                  weight: isActive
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : _Palette.textDark,
                                ),
                              ),
                            ),
                            if (isActive)
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom user info
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
              ),
              boxShadow: _Palette.softShadow,
            ),
            child: Row(
              children: [
                // Initials avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _Palette.gold.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: _Palette.goldGlow(alpha: 0.32),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTheme.sans(
                        size: 16,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleName,
                        style: AppTheme.sans(
                          size: 13,
                          weight: FontWeight.w700,
                          color: _Palette.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4ADE80,
                                  ).withValues(alpha: 0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Online',
                            style: AppTheme.sans(
                              size: 11,
                              color: _Palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}
