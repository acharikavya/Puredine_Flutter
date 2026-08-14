import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/core/constants.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// AdminDashboardScreen, MenuScreen, and OrdersScreen exactly, so this
/// screen reads as part of the same consistent brand instead of its own
/// one-off theme. Used ONLY for this screen's restyle. Nothing here touches
/// AppColors or any other file — pure UI enhancement, no logic changed
/// anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a large faint watermark emblem, and a fine glass highlight
/// line along the top edge) matching the Orders / Admin Dashboard screens'
/// Pass-2 treatment, and the full-screen backdrop gained an extra diagonal
/// sheen plus a secondary ambient glow for more depth. The role cards
/// picked up a slim gold top cap so they carry the same color-coded
/// identity language used on the Orders stat cards. No navigation, hover
/// state, sizing, or card-selection logic was touched anywhere in this
/// pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 3 (mobile bottom nav + desktop side rail + back
/// button removal):
///   1. A fixed, cream bottom navigation bar (`_AdminBottomNav`) was
///      added, showing "Menu / Staff / Tables / Order Bill" — mobile
///      widths only (`bottomNavigationBar` is `null` on desktop). "Staff"
///      renders as the active tab since that's this screen. This uses its
///      own `isNavMobile` (< 800) breakpoint, kept separate from the
///      screen's existing `isMobile` (< 600) used for the role-card
///      sizing math below, so none of that sizing logic is touched.
///   2. A branded vertical side-navigation rail (`_DesktopSideNav`) was
///      added — desktop widths only — sitting to the left of the
///      existing centered role-card content, which is now factored into
///      `_buildRoleCardsBody` so both the mobile and desktop layouts
///      reuse the exact same widget subtree. The rail carries a small
///      brand mark, an "ADMIN PANEL" pill, the same four destinations as
///      the bottom nav (with "Staff" shown active), and a small profile
///      chip at the bottom. Tapping a tile uses the same
///      `context.go(route)` pattern already used throughout this file.
///   3. The top-left "‹" back chevron control (previously
///      `_BackChevronButton`) has been removed from the header. The
///      header's `Row` keeps its `Spacer()` so the date label continues
///      to sit flush right exactly as before.
/// No navigation-target routes, hover state, card-sizing math, or other
/// business logic was touched anywhere in this pass — presentation and
/// navigation-chrome only.
///
/// UI-ENHANCEMENT PASS 4 (desktop side nav now matches the Admin Orders
/// screen exactly):
///   The desktop side rail (`_DesktopSideNav`) is now a fixed, full-height
///   panel flush against the left edge of the screen — identical in
///   structure and styling to the Admin Orders screen's `_AdminSideNav`
///   (same 260px width, same "PUREDINE" logo header, "ADMIN PANEL" pill,
///   nav tiles with a gold-accented active pill, and a profile card
///   pinned to the bottom via a `Spacer`). Previously it was a floating,
///   rounded card inset with padding beside the header; now — exactly
///   like the Orders screen — it sits as a `Row` sibling alongside the
///   header + scrollable role-card content, spanning the full height of
///   the body. No navigation-target routes, hover state, card-sizing
///   math, or other business logic was touched in this pass —
///   presentation and layout structure only.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF2E0808); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFC62828);

  // UI-ENHANCEMENT PASS 2: promoted from a flat 3-stop wash to a richer
  // 4-stop diagonal gradient with explicit stops — matches the Orders
  // screen header's "faceted" surface language exactly.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRed, milanoRedDeep, milanoRedDarkest],
    stops: [0.0, 0.38, 0.72, 1.0],
  );

  /// Themed soft shadow for resting cards/panels — matches MenuScreen's and
  /// OrdersScreen's softShadow exactly, so every surface across the admin
  /// app shares the same warm, branded tint.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Themed elevated/hover shadow — matches MenuScreen's glowShadow, used
  /// on card hover for a richer, more premium lift effect.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
}

class StaffLandingScreen extends StatelessWidget {
  const StaffLandingScreen({super.key});

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _todayLabel() {
    final now = DateTime.now();
    return '${_monthNames[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    // UI-ENHANCEMENT PASS 3: separate breakpoint used only to decide
    // whether the admin nav chrome (bottom bar vs. side rail) shows —
    // matches the 800px breakpoint used on MenuScreen / OrdersScreen /
    // TablesScreen. Kept independent from `isMobile` (600px) above, which
    // continues to drive the existing role-card sizing math untouched.
    final bool isNavMobile = size.width < 800;

    // ── Card sizing ──────────────────────────────────────────────────────
    // Cards are now narrow, tall rectangles (instead of near-squares) and,
    // on mobile, their width is derived from the actual available screen
    // width so both cards always sit side-by-side without ever forcing the
    // horizontal scroll fallback on typical phone screens. Purely a sizing
    // change — card content, hover behaviour, and navigation are untouched.
    final double horizontalPadding = isMobile ? 16 : 40;
    final double cardSpacing = isMobile ? 16 : 40;
    final double mobileCardWidth =
        ((size.width - (horizontalPadding * 2) - cardSpacing) / 2)
            .clamp(130.0, 172.0);
    final double cardWidth = isMobile ? mobileCardWidth : 240;
    final double cardHeight =
        isMobile ? (cardWidth * 2.2).clamp(300.0, 360.0) : 380;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // UI-ENHANCEMENT PASS 3: fixed cream bottom navigation bar with
      // "Menu / Staff / Tables / Order Bill" — mobile widths only. On
      // desktop this is `null`; the `_DesktopSideNav` rail (added below,
      // as a full-height `Row` sibling — see PASS 4) covers the same
      // destinations there instead, matching the Admin Orders screen.
      bottomNavigationBar:
          isNavMobile ? const _AdminBottomNav(currentIndex: 1) : null,
      // UI-ENHANCEMENT PASS 4: on desktop, the side nav is now a
      // full-height `Row` sibling placed directly in the `Scaffold.body`
      // — identical in structure to how OrdersScreen wires up its
      // `_AdminSideNav` — instead of being nested inside the content
      // Column below the header. The ambient background, header, and
      // scrollable role-card content (built by `_buildScreenBody`)
      // occupy the remaining `Expanded` space to its right.
      body: isNavMobile
          ? _buildScreenBody(
              isMobile: isMobile,
              horizontalPadding: horizontalPadding,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              cardSpacing: cardSpacing,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DesktopSideNav(currentIndex: 1),
                Expanded(
                  child: _buildScreenBody(
                    isMobile: isMobile,
                    horizontalPadding: horizontalPadding,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    cardSpacing: cardSpacing,
                  ),
                ),
              ],
            ),
    );
  }

  /// The ambient background dressing + fixed header + scrollable
  /// "choose a role" content that makes up the main screen area —
  /// unchanged in content from before this pass, just factored out into
  /// its own method (as OrdersScreen already does with `_buildScreenBody`)
  /// so it can sit to the right of the full-height `_DesktopSideNav` on
  /// desktop, or fill the whole screen on mobile. No navigation-target
  /// routes, hover state, card-sizing math, or other business logic was
  /// touched — presentation/layout only.
  Widget _buildScreenBody({
    required bool isMobile,
    required double horizontalPadding,
    required double cardWidth,
    required double cardHeight,
    required double cardSpacing,
  }) {
    return Stack(
      children: [
        // ── Ambient background dressing ─────────────────────────────────
        // Purely decorative — layered gold/maroon glows plus a faint
        // textured photograph, matching MenuScreen's/OrdersScreen's
        // "foggy" backdrop so the whole admin experience feels like one
        // cohesive, premium brand.
        Positioned.fill(
          child: Container(
            color: _Palette.canvas,
            child: Stack(
              children: [
                Positioned(
                  top: -70,
                  right: -60,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -90,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.milanoRed.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 260,
                  right: -110,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffonDeep.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // UI-ENHANCEMENT PASS 2: extra low, wide glow further down
                // the page — gives the role-card area a second soft focal
                // point instead of all the ambient light sitting only
                // near the header. Matches the Orders / Admin Dashboard
                // screens' Pass-2 backdrop.
                Positioned(
                  top: 560,
                  left: -100,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.milanoRedLight.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.04,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),

        // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping across the
        // whole body — a subtle extra layer of depth so the cream backdrop
        // doesn't read as flat behind the header, echoing the glass-
        // highlight language used in the header itself. Purely cosmetic,
        // sits above the ambient blobs and below all real content.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.26),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),
        ),

        Column(
          children: [
            _buildCustomHeader(isMobile),
            Expanded(
              child: _buildRoleCardsBody(
                isMobile: isMobile,
                horizontalPadding: horizontalPadding,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                cardSpacing: cardSpacing,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The scrollable "choose a role" body (section label + the two role
  /// cards) — factored out so both the mobile single-column layout and
  /// the desktop side-nav + content layout in `build()` share the exact
  /// same widget tree and behaviour. No content, ordering, sizing, or
  /// navigation logic changed from the original inline widget tree —
  /// purely extracted for reuse.
  Widget _buildRoleCardsBody({
    required bool isMobile,
    required double horizontalPadding,
    required double cardWidth,
    required double cardHeight,
    required double cardSpacing,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 32 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _Palette.milanoRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CHOOSE A ROLE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                        color: _Palette.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _Palette.milanoRedDeep.withValues(alpha: 0.14),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // ── Role cards ──────────────────────────────
                // Forced onto a single row instead of wrapping
                // to a second line. Card width/height are now
                // computed above so both narrow, rectangular
                // cards fit the mobile viewport without needing
                // to scroll; the horizontal scroll fallback
                // stays in place as a safety net for unusually
                // narrow screens. Card content, hover behaviour,
                // and navigation are completely unchanged.
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StaffTypeCard(
                          title: 'Billing Staff',
                          description:
                              'Manage cashier terminals and transaction logs.',
                          icon: Icons.receipt_long_rounded,
                          role: 'cashier',
                          index: 0,
                          isMobile: isMobile,
                          width: cardWidth,
                          height: cardHeight,
                        ),
                        SizedBox(width: cardSpacing),
                        _StaffTypeCard(
                          title: 'Serving Staff',
                          description:
                              'Manage floor staff and service assignments.',
                          icon: Icons.restaurant_rounded,
                          role: 'server',
                          index: 1,
                          isMobile: isMobile,
                          width: cardWidth,
                          height: cardHeight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Branded "floating navbar" header — mirrors the exact Pass-2 treatment
  /// used on the Orders / AdminDashboardScreen / MenuScreen headers: a
  /// richer four-stop diagonal gradient, rounded bottom corners, decorative
  /// diagonal ribbon accents, a soft radial glow behind the title block, a
  /// large faint watermark emblem, a fine glass highlight line along the
  /// very top edge, and a fine dotted texture strip.
  ///
  /// UI-ENHANCEMENT PASS 3: the back control has been removed entirely
  /// (see the top-of-file doc comment). Purely visual otherwise.
  Widget _buildCustomHeader(bool isMobile) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _Palette.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.35),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Subtle decorative diagonal ribbon accents (purely cosmetic,
              // matches the dashboard/menu/orders headers for a consistent
              // brand feel).
              Positioned(
                top: -60,
                right: -40,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 260,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -60,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Container(
                    width: 230,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Soft radial glow behind the title block, adding depth
              // without affecting any layout or logic.
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 260,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Large faint watermark emblem — a unique signature touch
              // this header didn't previously have, sitting low-opacity and
              // large behind the copy, never competing with the title.
              // Matches the Orders / Admin Dashboard hero's Pass-2
              // watermark treatment.
              Positioned(
                right: isMobile ? -22 : -12,
                bottom: isMobile ? -20 : -16,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.badge_rounded,
                      size: isMobile ? 120 : 170,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Fine dotted texture accent, matching the app's refined
              // decorative language used across the other admin headers.
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _Palette.lemonChiffon.withValues(
                            alpha: i == 2 ? 0.9 : 0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Fine glass highlight line along the very top edge, giving
              // the full-width panel a polished, "premium glass" finish —
              // matches the Orders / Admin Dashboard headers' top edge
              // treatment.
              Positioned(
                top: 0,
                left: 24,
                right: 24,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 40,
                  isMobile ? 16 : 24,
                  isMobile ? 20 : 40,
                  isMobile ? 20 : 28,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // UI-ENHANCEMENT PASS 3: the top-left back
                          // chevron control has been removed. The Spacer
                          // below is kept so the date label (desktop
                          // only) still lands flush right, exactly as
                          // before.
                          const Spacer(),
                          if (!isMobile)
                            Text(
                              _todayLabel(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Staff Management',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: isMobile ? 26 : 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _TitleDivider(),
                      const SizedBox(height: 10),
                      Text(
                        'Select a role to manage credentials and access.',
                        style: GoogleFonts.inter(
                          color: _Palette.lemonChiffon,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the same accent used on the dashboard, menu,
/// and orders screens so the title treatment matches exactly across the
/// admin app.
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _Palette.lemonChiffon.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// UI-ENHANCEMENT PASS 4 — Desktop-only branded side navigation rail,
/// restyled to match the Admin Orders screen's `_AdminSideNav` exactly.
///
/// A fixed, full-height (`Scaffold.body`-height) vertical sidebar shown
/// ONLY on desktop widths: a brand mark + name at the top, an "ADMIN
/// PANEL" pill badge, four nav destinations (Menu / Staff / Tables /
/// Order Bill) with the active one rendered as a solid maroon-gradient
/// pill with a gold left accent bar and a trailing chevron, and a small
/// profile chip pinned to the bottom via a `Spacer`. It is placed as a
/// direct `Row` sibling in `Scaffold.body` (see `build()`), spanning the
/// full available height — identical in structure to how
/// `OrdersScreen`/`_AdminSideNav` is wired up, rather than being nested
/// as a floating rounded card beside the header.
///
/// This is entirely additive/restyled — it doesn't replace or resize any
/// existing content, and tapping a tile uses the exact same
/// `context.go(route)` pattern already used throughout this file (see
/// `_AdminBottomNavTile`). No navigation-target routes, hover state, or
/// other business logic is touched by this widget.
/// ─────────────────────────────────────────────────────────────────────────
class _DesktopSideNavItem {
  final IconData icon;
  final String label;
  final String route;
  const _DesktopSideNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _DesktopSideNav extends StatelessWidget {
  final int? currentIndex;
  const _DesktopSideNav({this.currentIndex});

  static const List<_DesktopSideNavItem> _items = [
    _DesktopSideNavItem(
      icon: Icons.restaurant_menu_rounded,
      label: 'Menu',
      route: '/admin/menu',
    ),
    _DesktopSideNavItem(
      icon: Icons.groups_rounded,
      label: 'Staff',
      route: '/admin/staff',
    ),
    _DesktopSideNavItem(
      icon: Icons.table_restaurant_rounded,
      label: 'Tables',
      route: '/admin/tables',
    ),
    _DesktopSideNavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Order Bill',
      route: '/admin/orders',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: _Palette.canvas,
        border: Border(
          right: BorderSide(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logo header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _Palette.milanoRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.6),
                        width: 1.4,
                      ),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PUREDINE',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: _Palette.milanoRedDeep,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 20),
            // ── "ADMIN PANEL" badge ──────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _Palette.lemonChiffon.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: _Palette.milanoRedDeep,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ADMIN PANEL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ── Nav items ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  for (int i = 0; i < _items.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DesktopSideNavTile(
                        item: _items[i],
                        isActive: currentIndex == i,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // ── Profile card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
                  ),
                  boxShadow: _Palette.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _Palette.milanoRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _Palette.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _Palette.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _Palette.textMuted,
                                  fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable row inside `_DesktopSideNav`. Inactive tiles are a plain
/// transparent row with a muted icon+label; the active tile becomes a
/// solid maroon gradient pill with a small gold accent bar on its left
/// edge and a trailing white chevron — identical to the Admin Orders
/// screen's `_AdminSideNavTile`. Navigation is a plain
/// `context.go(item.route)` call, disabled when already active.
class _DesktopSideNavTile extends StatelessWidget {
  final _DesktopSideNavItem item;
  final bool isActive;
  const _DesktopSideNavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? null : () => context.go(item.route),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      _Palette.milanoRed,
                      _Palette.milanoRedDeep,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _Palette.lemonChiffon,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.16)
                      : _Palette.milanoRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 17,
                  color: isActive ? Colors.white : _Palette.milanoRedDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: isActive ? Colors.white : _Palette.textDark,
                  ),
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// UI-ENHANCEMENT PASS 3 — Mobile-only bottom navigation bar.
///
/// A fixed, cream bottom navigation bar with four evenly-spaced tiles —
/// Menu / Staff / Tables / Order Bill — each showing an icon inside a
/// circular badge with a label underneath. The active tab's badge is
/// filled solid gold with a white icon and bold gold label; inactive
/// tabs show a plain white badge with a dark-maroon icon and muted dark
/// label. Shown only on mobile widths (see `Scaffold.bottomNavigationBar`
/// in `build()`); tapping a tile uses the same `context.go(route)`
/// pattern already used throughout this file.
/// ─────────────────────────────────────────────────────────────────────────
class _AdminBottomNavItem {
  final IconData icon;
  final String label;
  final String route;
  const _AdminBottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _AdminBottomNav extends StatelessWidget {
  final int? currentIndex;
  const _AdminBottomNav({this.currentIndex});

  static const List<_AdminBottomNavItem> _items = [
    _AdminBottomNavItem(
      icon: Icons.restaurant_menu_rounded,
      label: 'Menu',
      route: '/admin/menu',
    ),
    _AdminBottomNavItem(
      icon: Icons.groups_rounded,
      label: 'Staff',
      route: '/admin/staff',
    ),
    _AdminBottomNavItem(
      icon: Icons.table_restaurant_rounded,
      label: 'Tables',
      route: '/admin/tables',
    ),
    _AdminBottomNavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Order Bill',
      route: '/admin/orders',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.canvas,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: const Border(
          top: BorderSide(color: _Palette.lemonChiffon, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < _items.length; i++)
                _AdminBottomNavTile(
                  item: _items[i],
                  isActive: currentIndex == i,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable tile inside `_AdminBottomNav` — an icon in a circular
/// badge (solid gold + white icon when active, white + dark-maroon icon
/// when inactive) with a label underneath. Navigation is a plain
/// `context.go(item.route)` call; disabled entirely when the tile is
/// already the active tab so tapping an already-active tab is a
/// harmless no-op instead of an unnecessary re-navigation.
class _AdminBottomNavTile extends StatelessWidget {
  final _AdminBottomNavItem item;
  final bool isActive;
  const _AdminBottomNavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : () => context.go(item.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? _Palette.lemonChiffon : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? _Palette.lemonChiffonDeep.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: isActive ? 14 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isActive ? Colors.white : _Palette.milanoRedDeep,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? _Palette.lemonChiffonDeep : _Palette.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffTypeCard extends StatefulWidget {
  final String title, description, role;
  final IconData icon;
  final int index;
  final bool isMobile;
  final double width;
  final double height;

  const _StaffTypeCard({
    required this.title,
    required this.description,
    required this.role,
    required this.icon,
    required this.index,
    required this.isMobile,
    required this.width,
    required this.height,
  });

  @override
  State<_StaffTypeCard> createState() => _StaffTypeCardState();
}

class _StaffTypeCardState extends State<_StaffTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Slightly denser content metrics on mobile, where cards are narrow,
    // tall rectangles rather than near-squares — keeps the icon, title,
    // and description comfortably inside the smaller footprint without
    // touching any hover logic, navigation, or card behaviour.
    final double iconBoxSize = widget.isMobile ? 58 : 72;
    final double iconSize = widget.isMobile ? 26 : 32;
    final double titleFontSize = widget.isMobile ? 17 : 28;
    final double descriptionFontSize = widget.isMobile ? 12 : 14;
    final double contentPadding = widget.isMobile ? 16 : 32;
    // UI-ENHANCEMENT PASS 2: slim gold top-cap height, matching the Orders
    // screen's stat-card identity strip. Reserved from the card's own fixed
    // height so it never disturbs the existing content layout below it.
    final double topCapHeight = 3;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/admin/staff/${widget.role}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height, // Now a tall rectangle, not a square
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -6.0))
              : Matrix4.identity(),
          // NOTE: BoxDecoration only ever uses `gradient` here (never mixed
          // with a plain `color`) so both hover states interpolate cleanly.
          // Mixing color + gradient across the two states is what threw
          // "Cannot provide both a color and a gradient" during the
          // hover animation before this fix.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? [
                      _Palette.cardWhite,
                      _Palette.lemonChiffon.withValues(alpha: 0.25),
                    ]
                  : [_Palette.cardWhite, _Palette.cardWhite],
            ),
            borderRadius: BorderRadius.circular(widget.isMobile ? 22 : 28),
            border: Border.all(
              color: _isHovered
                  ? _Palette.milanoRed
                  : _Palette.milanoRedDeep.withValues(alpha: 0.15),
              width: _isHovered ? 1.4 : 1,
            ),
            boxShadow: _isHovered ? _Palette.glowShadow : _Palette.softShadow,
          ),
          // The card has a fixed width/height (passed in from the parent so
          // it can be computed responsively). Decorative corner accents now
          // live in a ClipRRect + Stack that is bounded by this exact
          // width/height, so they can bleed right up to the rounded edge
          // without any risk of overflowing outside the card.
          //
          // The main content (icon + spacing + title + description + the
          // hint row, which always reserves its height even at opacity 0)
          // could add up to slightly more than the fixed height depending on
          // text/font metrics — that mismatch is what produced the "BOTTOM
          // OVERFLOWED BY 17 PIXELS" banner previously.
          //
          // Wrapping the content in a LayoutBuilder + SingleChildScrollView
          // (non-scrollable in normal use) lets it report its own height
          // safely instead of forcing it into the parent's constraints, so
          // the same centered layout renders with zero overflow risk.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isMobile ? 22 : 28),
            child: Stack(
              children: [
                // ── Decorative corner glow (purely cosmetic) ─────────────
                Positioned(
                  top: -36,
                  right: -36,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(
                            alpha: _isHovered ? 0.45 : 0.18,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.milanoRedDeep.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // UI-ENHANCEMENT PASS 2: slim gold top cap spanning the full
                // width of the card — echoes the Orders screen's stat-card
                // color-coded identity strip. Purely decorative, sits above
                // the corner glows and below the step-index tag.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: topCapHeight,
                    color: _isHovered
                        ? _Palette.milanoRed.withValues(alpha: 0.85)
                        : _Palette.lemonChiffon.withValues(alpha: 0.75),
                  ),
                ),
                // ── Step index tag, flush to the top-left corner ─────────
                Positioned(
                  top: 0,
                  left: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isMobile ? 11 : 14,
                      vertical: widget.isMobile ? 5 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? _Palette.milanoRedDeep
                          : _Palette.lemonChiffon.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.isMobile ? 20 : 26),
                        bottomRight: Radius.circular(widget.isMobile ? 14 : 18),
                      ),
                    ),
                    child: Text(
                      '0${widget.index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: widget.isMobile ? 10 : 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color:
                            _isHovered ? Colors.white : _Palette.milanoRedDeep,
                      ),
                    ),
                  ),
                ),
                // ── Main content ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ── Icon Container ─────────────────────────
                              // Also gradient-only in both states (fixes the
                              // same color/gradient interpolation crash as
                              // above), now wrapped in a soft outer ring for
                              // a more premium "badge" look.
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding:
                                    EdgeInsets.all(widget.isMobile ? 5 : 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isHovered
                                        ? _Palette.milanoRed
                                            .withValues(alpha: 0.25)
                                        : _Palette.lemonChiffon
                                            .withValues(alpha: 0.5),
                                    width: 1.4,
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: iconBoxSize,
                                  height: iconBoxSize,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _isHovered
                                          ? [
                                              _Palette.milanoRedDeep,
                                              _Palette.milanoRed,
                                            ]
                                          : [
                                              _Palette.lemonChiffon
                                                  .withValues(alpha: 0.5),
                                              _Palette.lemonChiffon
                                                  .withValues(alpha: 0.5),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        widget.isMobile ? 16 : 20),
                                    boxShadow: _isHovered
                                        ? [
                                            BoxShadow(
                                              color: _Palette.milanoRed
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: _Palette.lemonChiffonDeep
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    color: _isHovered
                                        ? Colors.white
                                        : _Palette.milanoRedDeep,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                              SizedBox(height: widget.isMobile ? 16 : 28),
                              // ── Title ───────────────────────────────────
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  color: _Palette.milanoRedDeep,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: widget.isMobile ? 6 : 8),
                              const _TitleDivider(),
                              SizedBox(height: widget.isMobile ? 10 : 14),
                              // ── Description ─────────────────────────────
                              Text(
                                widget.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: _Palette.textMuted,
                                  fontSize: descriptionFontSize,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: widget.isMobile ? 12 : 18),
                              // ── Hint pill (appears on hover) ────────────
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: _isHovered ? 1 : 0,
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 250),
                                  offset: _isHovered
                                      ? Offset.zero
                                      : const Offset(0, 0.3),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widget.isMobile ? 12 : 16,
                                      vertical: widget.isMobile ? 6 : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _Palette.milanoRed
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Manage',
                                          style: GoogleFonts.inter(
                                            color: _Palette.milanoRed,
                                            fontSize: widget.isMobile ? 12 : 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: _Palette.milanoRed,
                                          size: widget.isMobile ? 14 : 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (widget.index * 200).ms).scale(
              begin: const Offset(0.95, 0.95),
              curve: Curves.easeOutCirc,
            ),
      ),
    );
  }
}
