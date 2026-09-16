import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_unified_app/admin/core/providers/notification_provider.dart';
import 'menu/menu_screen.dart';
import 'staff/staff_landing_screen.dart';
import 'tables/tables_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

/// Local nav colors — matches the app's "Dark Maroon × Soft Cream × Gold
/// Glow" brand identity (Theme 1) used throughout the admin dashboard
/// header and cards. Purely cosmetic; doesn't touch any shared
/// theme/AppColors file.
///
/// UI-ENHANCEMENT PASS: the bottom navigation bar has been restyled to
/// match the staff module's `_RoleAwareBottomNav` (MainScaffold) exactly —
/// a cream/gold docked bar with a top gold indicator dot + a circular
/// icon badge (gold-ringed, gradient-filled, glowing when active) instead
/// of the previous floating "pill" bar with a lifted gold circle. The
/// extra shadow helpers below (`softShadow`, `chipShadow`,
/// `floatUpShadow`, `goldGlow`, `accentGlow`) mirror `_Palette`'s in
/// main_scaffold.dart so the two bottom bars are visually identical in
/// construction, just reusing this file's own `_NavPalette` colors. All
/// pre-existing color constants are unchanged so nothing else that
/// already references `_NavPalette` is affected.
///
/// SIZE-REDUCTION PASS / SIZE-REDUCTION PASS 2 / CURSOR PASS: see the
/// notes directly above `_AdminBottomNav` below — purely dimensional
/// trims and a pointer-cursor affordance, no palette or logic changes.
///
/// COLOR-THEME PASS ("PUREDINE Maroon + Cream" — darker) — this pass:
/// swapped the underlying color values in `_NavPalette` for the
/// requested PUREDINE Maroon + Cream reference palette — Deep Wine
/// Maroon (#742A3C), Wine (#813244), Burgundy (#8A183F), Deep Brown/
/// Black (#2E0D16), Warm Off-White (#FBF8F5), Soft Cream (#F7F1ED),
/// Dusty Blush (#F3D9DC), Pale Rose (#EFD7DA), Warm Gold (#F3C564),
/// Soft Yellow (#FCE1AB), Fresh Green (#44AF70), and Muted Taupe
/// (#9B707A) — and deepened the surrounding chrome (rail/dock
/// backgrounds, shadows, a couple of flat fills turned into gradients)
/// so the admin shell reads as noticeably richer/darker instead of
/// washed out, matching the same PUREDINE identity now used on the
/// login screen. Every field name below (`maroon`, `maroonDark`,
/// `maroonDeep`, `maroonLight`, `gold`, `goldDeep`, `muted`, `cream`,
/// `creamDeep`, `chipBg`) is unchanged on purpose, since every widget in
/// this file already reads from these exact names — only the `Color`
/// values themselves (plus two small additive fields, noted below) were
/// updated:
///   • maroon → Deep Wine Maroon (#742A3C), the primary brand tone used
///     for the brand-header logo mark, the "Admin Panel" badge icon/
///     text, the active side-nav-row gradient, and the active bottom-
///     nav label.
///   • maroonDark → Burgundy (#8A183F), the palette's own "primary
///     accent", used as the deeper step in the brand-header logo
///     gradient and the selected side-nav-row gradient.
///   • maroonDeep → Deep Brown/Black (#2E0D16), used for the deepest
///     shadow tint (dock shadow, chip shadow) and as the deep step in
///     the active bottom-nav badge gradient, for a rich, grounded lift
///     instead of a plain grey/black shadow.
///   • maroonLight → Wine (#813244), the requested lighter header-
///     gradient tone, used as the light step in the active bottom-nav
///     badge gradient (Wine → Deep Brown/Black).
///   • gold / goldDeep → Warm Gold (#F3C564) stays the accent used for
///     the top indicator dot, active badge ring/glow, gold dock cap
///     border, and side-nav accent bar. `goldDeep` is a small,
///     purely-internal deeper-amber shade derived from Warm Gold (not a
///     separate hex from the requested table — same pattern as the
///     login screen's internal gradient "bridge" tone), used only to
///     give the "Admin Panel" badge a richer two-stop gold gradient
///     instead of a flat fill.
///   • muted → Muted Taupe (#9B707A), used for inactive bottom-nav
///     labels and the side-nav footer's secondary text.
///   • cream → Warm Off-White (#FBF8F5), the requested main background,
///     used for the Scaffold background, the side-nav rail, and (per
///     the "for cards" background spec) the admin footer summary card.
///   • creamDeep → Soft Cream (#F7F1ED), used as the deeper step in the
///     bottom-nav dock's gradient and the side-nav rail's gradient, so
///     both read as a richer cream instead of a near-white flat fill.
///   • chipBg → Dusty Blush (#F3D9DC), which is exactly the requested
///     "Icon BG" tone for cards — used for the unselected side-nav-row
///     icon chip.
///   • fieldBorder (new field, additive only) → Pale Rose (#EFD7DA), the
///     requested card border tone, used on the admin footer summary
///     card per the "for cards" border spec.
///   • success (new field, additive only) → Fresh Green (#44AF70), the
///     requested "Live/Success" tone, used for the footer card's
///     "Online" status dot in place of the generic `Colors.green` it
///     previously used.
/// Shadow alpha/blur values in `softShadow`, `chipShadow`,
/// `floatUpShadow`, `goldGlow`, and `accentGlow` were also deepened
/// slightly (same colors, a bit more opacity/spread) for a richer,
/// more premium lift. No tab order, routes, tap behavior, breakpoints,
/// sizing, animation durations/curves, or any other logic was touched
/// anywhere in this pass — presentation only.
class _NavPalette {
  static const Color maroon = Color(0xFF742A3C); // Deep Wine Maroon (Primary)
  static const Color maroonDark =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color maroonDeep =
      Color(0xFF2E0D16); // Deep Brown/Black (deepest shade)
  static const Color maroonLight =
      Color(0xFF813244); // Wine (lighter header gradient tone)
  static const Color gold = Color(0xFFF3C564); // Warm Gold (Accent)

  // Small, purely-internal deeper-amber shade derived from Warm Gold —
  // not a separate hex from the requested table, needed only to give
  // the "Admin Panel" badge a richer two-stop gold gradient instead of
  // a flat fill (same pattern as the login screen's internal gradient
  // "bridge" tone).
  static const Color goldDeep = Color(0xFFD9A94A);

  static const Color muted = Color(0xFF9B707A); // Muted Taupe
  static const Color cream =
      Color(0xFFFBF8F5); // Warm Off-White (main background)
  static const Color creamDeep =
      Color(0xFFF7F1ED); // Soft Cream (deeper cream / card tone)
  static const Color chipBg =
      Color(0xFFF3D9DC); // Dusty Blush (requested "Icon BG")

  // Additive field: the requested "for cards" border tone, used on the
  // admin footer summary card.
  static const Color fieldBorder = Color(0xFFEFD7DA); // Pale Rose

  // Additive field: the requested "Live/Success" tone, used for the
  // footer card's "Online" status dot (previously a generic
  // `Colors.green`).
  static const Color success = Color(0xFF44AF70); // Fresh Green

  /// Themed soft shadow for resting cards/panels — mirrors `_Palette`'s
  /// softShadow in main_scaffold.dart. Deepened slightly in the PUREDINE
  /// darker pass for a richer lift.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: maroonDeep.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Small resting shadow for icon chips — gives inactive icon badges a
  /// gentle lift so they stay clearly visible against the cream chrome.
  /// Deepened slightly in the PUREDINE darker pass.
  static List<BoxShadow> get chipShadow => [
        BoxShadow(
          color: maroonDeep.withValues(alpha: 0.09),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  /// Elevated shadow that floats "up" — used for the bottom navigation bar
  /// so it reads as a raised, premium dock rather than a flat strip.
  /// Deepened slightly in the PUREDINE darker pass.
  static List<BoxShadow> get floatUpShadow => [
        BoxShadow(
          color: maroonDeep.withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, -10),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ];

  /// Soft ambient gold glow, used behind brand/avatar chips. Deepened
  /// slightly in the PUREDINE darker pass.
  static List<BoxShadow> goldGlow({double alpha = 0.40}) => [
        BoxShadow(
          color: gold.withValues(alpha: alpha),
          blurRadius: 14,
          spreadRadius: 0.5,
        ),
      ];

  /// Wider, softer glow used behind an *active* accent-tinted badge — gives
  /// the currently-selected item a gentle "lit up" halo instead of a flat
  /// tinted circle, making the active state unmistakable at a glance.
  /// Deepened slightly in the PUREDINE darker pass.
  static List<BoxShadow> accentGlow(Color color, {double alpha = 0.38}) => [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.18),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
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
/// admin screens (Menu, Staff, Tables, Orders, Profile) in an IndexedStack
/// so switching tabs preserves each screen's scroll position, filters, and
/// other state instead of rebuilding from scratch — the same
/// Instagram-style behavior the staff side already has.
///
/// On wide (desktop/web) viewports, the same tab list is presented as a
/// persistent side navigation rail instead of a bottom bar. On narrow
/// (mobile) viewports the bottom bar now uses the exact same visual
/// language as the staff module's `_RoleAwareBottomNav` — see
/// [_AdminBottomNav] — styled to Theme 1 (Dark Maroon × Soft Cream × Gold
/// Glow), with a top gold indicator dot and a gold-ringed, glowing gradient
/// badge on the active tab. No tab order, routes, or tap behavior were
/// changed.
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

        // Mobile/tablet layout: bottom navigation bar restyled to match
        // the staff module's `_RoleAwareBottomNav` exactly (Theme 1 — Dark
        // Maroon × Soft Cream × Gold Glow): top gold indicator dot + a
        // circular icon badge that turns into a gold-ringed, glowing
        // gradient disc on the active tab. Same `_navItems` list and the
        // same `setState(() => _currentIndex = i)` tap behavior as
        // before — only the presentation changed.
        return Scaffold(
          backgroundColor: _NavPalette.cream,
          body: body,
          bottomNavigationBar: _AdminBottomNav(
            items: _navItems,
            currentIndex: _currentIndex,
            onSelect: (i) => setState(() => _currentIndex = i),
          ),
        );
      },
    );
  }
}

// ─── Admin Bottom Navigation Bar ──────────────────────────────────────────
// Mirrors the staff module's `_RoleAwareBottomNav` (main_scaffold.dart)
// exactly: a cream→gold-capped dock (gradient background, rounded top
// corners, thin gold top border, floatUpShadow) holding a row of tabs.
// Each tab shows a small top indicator dot above an always-visible
// circular icon badge — a soft white chip at rest, a maroon gradient disc
// with a gold ring + ambient glow when active — plus a bold gold label
// underneath. Behavior is unchanged: exactly the same [items] list, same
// [currentIndex], and tapping an item calls [onSelect] with its index.
//
// SIZE-REDUCTION PASS: purely dimensional trims to make the bar shorter
// overall and shrink the icon badges/icons/label/dot to match — no
// structure, palette, animation curves, or tap behavior were touched.
// Changed values: outer vertical padding 12→6, badge diameter 50/44→40/34,
// icon glyph size 26/22→20/17, top indicator dot 18×3.5→14×3, the gap
// under the badge 6→4, and the label font size 10.5→9.5.
//
// SIZE-REDUCTION PASS 2: further height reduction on top of the pass
// above, with icons/badges/dot/label shrunk proportionally to match the
// shorter bar — no structure, palette, animation curves, or tap behavior
// were touched. Changed values: outer vertical padding 6→3, badge
// diameter 40/34→34/28, icon glyph size 20/17→17/14, top indicator dot
// 14×3→12×2.5, the gap under the badge 4→3, inner column vertical padding
// 4→2, and the label font size 9.5→8.5.
//
// CURSOR PASS: each tab is now wrapped in a MouseRegion with
// SystemMouseCursors.click so hovering over any nav icon on web/desktop
// shows a hand/pointer cursor instead of the default arrow. Purely a
// pointer-affordance change — no layout, palette, animation, or tap
// behavior was touched.
//
// COLOR-THEME PASS ("PUREDINE Maroon + Cream" — darker): the dock's
// background gradient now blends Warm Off-White into a more visible Soft
// Cream (previously a near-white 0.5-alpha tint) so the bar reads as a
// deliberate cream surface instead of washed-out white — see the
// `_NavPalette` notes above for the full color mapping. No structure,
// sizing, animation, or tap behavior was touched.
class _AdminBottomNav extends StatelessWidget {
  final List<_AdminNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AdminBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _NavPalette.creamDeep.withValues(alpha: 0.7)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        // Thin gold cap line across the top of the dock, echoing the
        // lemon-chiffon border used on every staff screen header and on
        // the staff bottom nav.
        border: Border(
          top: BorderSide(
            color: _NavPalette.gold.withValues(alpha: 0.65),
            width: 2.5,
          ),
        ),
        boxShadow: _NavPalette.floatUpShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Row(
            children: items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = currentIndex == idx;

              return Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 2),
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
                            margin: const EdgeInsets.only(bottom: 2.5),
                            width: isActive ? 12 : 0,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _NavPalette.gold
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: _NavPalette.gold
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          // ── Always-visible circular icon badge — a soft
                          // white chip at rest so the glyph stays crisp
                          // against the bar, and a bold maroon gradient
                          // disc with a gold ring + ambient glow when
                          // active. ─────────────────────────────────────
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
                                          _NavPalette.maroonLight,
                                          _NavPalette.maroonDeep,
                                        ],
                                      )
                                    : null,
                                color: isActive ? null : Colors.white,
                                border: Border.all(
                                  color: isActive
                                      ? _NavPalette.gold.withValues(alpha: 0.85)
                                      : _NavPalette.maroonDeep.withValues(
                                          alpha: 0.12,
                                        ),
                                  width: isActive ? 1.8 : 1.2,
                                ),
                                boxShadow: isActive
                                    ? _NavPalette.accentGlow(
                                        _NavPalette.maroon,
                                      )
                                    : _NavPalette.chipShadow,
                              ),
                              child: Icon(
                                item.icon,
                                color: isActive
                                    ? Colors.white
                                    : _NavPalette.maroonDeep.withValues(
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
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight:
                                  isActive ? FontWeight.w800 : FontWeight.w600,
                              color: isActive
                                  ? _NavPalette.maroon
                                  : _NavPalette.muted,
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

/// Persistent side navigation rail shown only on desktop/web-width
/// viewports (see [_kDesktopBreakpoint]). Presents the same tab items as
/// the mobile bottom nav bar — same [items] list, same [currentIndex] /
/// [onSelect] contract — just laid out as a branded vertical panel
/// (logo header, "ADMIN PANEL" badge, pill-style nav rows, admin footer
/// card) instead of a bottom bar. Purely a presentational alternative;
/// no navigation logic is duplicated or diverges between layouts.
///
/// SIZE-REDUCTION / CURSOR PASSES: unchanged — only the mobile bottom nav
/// was touched by those. The nav rows below already show a hand/pointer
/// cursor on hover by default (InkWell's default `mouseCursor` resolves
/// to `SystemMouseCursors.click`), so no cursor change was needed here.
///
/// COLOR-THEME PASS ("PUREDINE Maroon + Cream" — darker): the rail's flat
/// cream fill is now a subtle top-to-bottom Warm Off-White → Soft Cream
/// gradient, the brand-mark tile and "Admin Panel" badge now use small
/// two-stop gradients instead of flat fills, and the footer summary card
/// now uses the requested "for cards" background/border (Warm Off-White
/// fill, Pale Rose border) with its "Online" dot recolored to the
/// requested Fresh Green — see the `_NavPalette` notes above for the full
/// mapping. No layout, sizing, or navigation logic was touched.
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_NavPalette.cream, _NavPalette.creamDeep],
        ),
      ),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_NavPalette.maroon, _NavPalette.maroonDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _NavPalette.goldGlow(alpha: 0.22),
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
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_NavPalette.gold, _NavPalette.goldDeep],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _NavPalette.goldGlow(alpha: 0.28),
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
          color: _NavPalette.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _NavPalette.fieldBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _NavPalette.maroonDeep.withValues(alpha: 0.08),
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
                        color: _NavPalette.success,
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
