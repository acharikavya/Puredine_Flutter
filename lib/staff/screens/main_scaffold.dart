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
/// PUREDINE Maroon + Cream palette — matches the Order Details / New
/// Orders / Create Order / Menu Management / Orders / Tables / Profile
/// screens exactly, so the app shell (sidebar on wide screens, bottom nav
/// on mobile) now reads as part of the same cohesive, professional brand.
/// Used ONLY for this screen's visual layer — nothing here touches
/// AppColors, AppShadows, or any role/auth logic. Role-based accent colors
/// (accentColor / accentLightColor / isBilling) are still computed and
/// passed through exactly as before; this palette only restyles the
/// structural chrome around them.
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
///
/// BOTTOM-NAV COLOR-THEME SYNC PASS: `_RoleAwareBottomNav` below has been
/// restyled to match `admin_main_scaffold.dart`'s `_AdminBottomNav` exactly
/// — same badge sizes (40/34), same icon sizes (20/17), same top indicator
/// dot (14×3), same gap under the badge (4), same label size (9.5), same
/// outer/inner padding (vertical 6 / vertical 4), and the active badge now
/// always uses the fixed Theme-1 maroon gradient + solid gold ring/glow
/// (instead of the previous role-tinted accentColor treatment) so the two
/// bottom bars are visually identical in construction. No nav items,
/// routes, role logic (isBilling), or tap behavior were changed — only the
/// bottom bar's own color/sizing values.
///
/// BOTTOM-NAV SIZE-REDUCTION PASS 2: `_RoleAwareBottomNav` has since been
/// shrunk further to match `_AdminBottomNav`'s latest size-reduction pass —
/// same badge sizes (34/28), same icon sizes (17/14), same top indicator
/// dot (12×2.5), same gap under the badge (3), same label size (8.5), same
/// outer/inner padding (vertical 3 / vertical 2) — so both bottom bars stay
/// visually identical in construction. Purely dimensional; no structure,
/// palette, animation curves, nav items, or tap behavior were touched.
///
/// PUREDINE PALETTE PASS (this pass): `_Palette`'s color values were
/// swapped from the old Dark Maroon × Gold Glow set to the exact PUREDINE
/// Maroon + Cream values, matching every other staff screen. Every field
/// name, every shadow method signature, and every call site that consumes
/// `_Palette` is unchanged — only the hex values behind each name changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Primary / Topbar — Deep Wine Maroon
  static const Color milanoRed = Color(0xFF742A3C);
  // Primary accent / deep — Burgundy
  static const Color milanoRedDeep = Color(0xFF8A183F);
  // Topbar lighter gradient — Wine
  static const Color milanoRedLight = Color(0xFF813244);

  // Gold accent family — Warm Gold (accent) / a deeper gold used for
  // borders and hover/emphasis states, plus the Soft Yellow highlight.
  static const Color lemonChiffon = Color(0xFFF3C564); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A63E); // Deeper gold

  // Main background — Warm Off-White
  static const Color canvas = Color(0xFFFBF8F5);
  // Card background — Soft Cream
  static const Color canvasDeep = Color(0xFFF7F1ED);

  // Dark text — Deep Brown/Black
  static const Color textDark = Color(0xFF2E0D16);
  // Secondary text — Muted Taupe
  static const Color textMuted = Color(0xFF9B707A);

  static const Color gold = Color(0xFFF3C564);
  static const Color goldLight = Color(0xFFFCE1AB); // Soft Yellow highlight

  // Extra brand tints from the PUREDINE palette.
  static const Color dustyBlush = Color(0xFFF3D9DC); // Blush/Pink tint
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background

  // Live / Success — Fresh Green.
  static const Color success = Color(0xFF44AF70);

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
// Color theme now mirrors `admin_main_scaffold.dart`'s `_AdminBottomNav`
// exactly: cream→gold-capped dock (same gradient, corners, gold top
// border, floatUpShadow), an always-visible circular icon badge — a soft
// white chip at rest, a fixed Theme-1 maroon gradient disc with a solid
// gold ring + ambient glow when active (previously role-tinted via
// accentColor; now the same fixed maroon/gold treatment as the admin bar
// so both bottom bars are visually identical in construction. No nav
// items, [currentIndex] semantics, or tap behavior were changed — tapping
// an item still calls [onTap] with its index exactly as before.
//
// The `accentColor` / `accentLightColor` / `isBilling` parameters are still
// accepted and passed through unchanged from `MainScaffold.build()` (no
// call-site or role logic was touched) — they're simply no longer used to
// tint the badge/indicator color, since the goal of this pass is for the
// bar's color theme to match the admin bar's fixed palette exactly.
//
// SIZE-REDUCTION PASS 2: further height reduction on top of the sync pass
// above, with icons/badges/dot/label shrunk proportionally to match the
// shorter bar — mirrors `_AdminBottomNav`'s latest sizing exactly. No
// structure, palette, animation curves, nav items, or tap behavior were
// touched. Changed values: outer vertical padding 6→3, per-tab inner
// vertical padding 4→2, badge diameter 40/34→34/28, icon glyph size
// 20/17→17/14, top indicator dot 14×3→12×2.5, the gap under the badge
// 4→3, and the label font size 9.5→8.5.
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
        // Thin gold cap line across the top of the dock, matching the
        // admin bottom nav's gold cap exactly.
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Row(
            children: navItems.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = currentIndex == idx;

              return Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Top indicator dot — same fixed gold dot
                          // used by the admin bottom nav, giving a
                          // second, unmistakable "you are here" signal
                          // beyond just the badge color change. ────────
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(bottom: 2.5),
                            width: isActive ? 12 : 0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color:
                                  isActive ? _Palette.gold : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: _Palette.gold
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          // ── Always-visible circular icon badge — a
                          // soft white chip at rest so the glyph stays
                          // crisp against the bar, and a fixed Theme-1
                          // maroon gradient disc with a solid gold ring
                          // + ambient glow when active — same treatment
                          // and sizing as the admin bottom nav badge. ──
                          AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            scale: isActive ? 1.0 : 0.94,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: isActive ? 34 : 28,
                              height: isActive ? 34 : 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
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
                                color: isActive ? null : Colors.white,
                                border: Border.all(
                                  color: isActive
                                      ? _Palette.gold.withValues(alpha: 0.85)
                                      : _Palette.milanoRedDeep.withValues(
                                          alpha: 0.12,
                                        ),
                                  width: isActive ? 1.8 : 1.2,
                                ),
                                boxShadow: isActive
                                    ? _Palette.accentGlow(_Palette.milanoRed)
                                    : _Palette.chipShadow,
                              ),
                              child: Icon(
                                isActive ? item.activeIcon : item.icon,
                                color: isActive
                                    ? Colors.white
                                    : _Palette.milanoRedDeep.withValues(
                                        alpha: 0.68,
                                      ),
                                size: isActive ? 17 : 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Label
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: AppTheme.sans(
                              size: 8.5,
                              weight:
                                  isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive
                                  ? _Palette.milanoRed
                                  : _Palette.textMuted,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              color: _Palette.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _Palette.success.withValues(
                                    alpha: 0.6,
                                  ),
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
