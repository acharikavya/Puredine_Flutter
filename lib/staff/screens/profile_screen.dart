import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/auth_provider.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "PUREDINE — Maroon × Cream × Gold" palette — matches the brand's
/// Maroon + Cream palette (#742A3C primary / #F3C564 gold accent), so this
/// screen reads as part of the same cohesive, professional PUREDINE brand.
/// Used ONLY for this screen's visual layer. Nothing here touches
/// AppColors, AppTheme, or any other file — pure UI recolor, no logic
/// changed anywhere in this file.
///
/// Color mapping (per PUREDINE Maroon + Cream Palette spec):
///  - milanoRed        -> #742A3C  (Primary / Topbar Deep Wine Maroon)
///  - milanoRedLight    -> #813244  (Topbar lighter gradient Wine)
///  - milanoRedDeep     -> derived deep wine tone (kept within the maroon
///                          family) used only for shadow/gradient depth —
///                          not a distinct swatch in the given palette.
///  - lemonChiffon      -> #F3C564  (Gold accent — Warm Gold)
///  - lemonChiffonDeep   -> derived deeper gold, used only for hover/glow
///                          shadow depth.
///  - canvas            -> #FBF8F5  (Main background — Warm Off-White)
///  - canvasDeep         -> #F7F1ED  (Card background — Soft Cream)
///  - cardBorder         -> #EFD7DA  (Border — Pale Rose)
///  - iconChipBg          -> #F3D9DC  (Icon BG — Dusty Blush)
///  - textDark           -> #2E0D16  (Dark text — Deep Brown/Black)
///  - textMuted           -> #9B707A  (Secondary text — Muted Taupe)
///  - gold / goldLight    -> #F3C564 / #FCE1AB (Gold accent / highlight)
///  - successGreen        -> #44AF70  (Live / Success — Fresh Green)
///  - danger / dangerBg   -> kept as a distinct alert red (not part of the
///                          brand palette) so the Sign Out control still
///                          reads clearly as a destructive action.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// the other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
/// change here).
///
/// UI-ENHANCEMENT PASS (flat bottom edge to match Tables/
/// Create Order headers): `_ProfileHeroHeader`'s bottom edge is now a
/// straight, flat line instead of the previous rounded bottom corners.
/// The rounded `BorderRadius` on the header `Container`'s decoration was
/// removed (so the banner is now a plain rectangle) and a thin warm-gold
/// hairline border was added along the bottom edge, mirroring the same
/// flat-bottom topbar treatment used on the Tables / Create Order
/// screens' headers. Everything else in the header — the maroon-to-wine
/// gradient, the shadow stack, the avatar, name, role/status badges, and
/// any layout/logic/callback — is completely unchanged, as is every
/// other part of this file (`_SectionCard`, `_ProfileRow`, `_QuickLink`,
/// `_SignOutButton`, and all provider/navigation/logout logic in
/// `ProfileScreen`). Presentation only.
///
/// UI-ENHANCEMENT PASS (this pass — full three-tier responsive layout):
/// responsive-layout-only — no provider, controller, route, callback, or
/// keyword anywhere in this file was touched, and no field/callback was
/// renamed.
///   1. RESPONSIVE BREAKPOINTS: the screen now measures the available
///      width via a `_DeviceType` breakpoint (mobile < 700, tablet
///      700–1100, desktop ≥ 1100) — matching the same breakpoint already
///      used on the Orders / Tables screens, so every staff screen
///      switches layouts at identical widths — instead of the previous
///      single `isMobile` split at 800px used only inside the header.
///   2. CONTENT WIDTH: on tablet and desktop the scrollable card column
///      is now capped to a comfortable reading width (860px tablet /
///      1080px desktop) and centered, instead of stretching every card
///      edge-to-edge across a wide tablet or laptop viewport. The hero
///      header's inner content is centered to the same width so the
///      avatar/name line up with the cards below it on larger screens.
///      Mobile keeps the original full-width layout untouched.
///   3. DESKTOP TWO-COLUMN LAYOUT: on desktop only, "Personal Details"
///      now sits in a wider left column alongside a right column holding
///      "Quick Access" and the App Info/Sign Out card stacked beneath it
///      — a denser, more professional dashboard-style layout that makes
///      better use of the extra horizontal space. Mobile and tablet keep
///      the original single stacked column, in the original order,
///      unchanged. Every card's own content, spacing between its
///      internal rows, and all callbacks/logic inside each card are
///      completely unchanged — only which column each whole card sits in
///      changed on desktop.
///   4. TYPE SCALE & SPACING: the hero header's padding, avatar size, and
///      name type scale, plus each `_SectionCard`'s own padding, now have
///      a dedicated tablet value between the existing mobile and desktop
///      sizing, instead of jumping straight from phone sizing to laptop
///      sizing.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4B1B27); // Derived deepest wine
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (topbar gradient)
  static const Color burgundy = Color(0xFF8A183F); // Primary accent — Burgundy
  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (accent)
  static const Color lemonChiffonDeep =
      Color(0xFFC29E50); // Derived deeper gold
  static const Color canvas = Color(0xFFFBF8F5); // Warm Off-White background
  static const Color canvasDeep = Color(0xFFF7F1ED); // Soft Cream (card bg)
  static const Color cardBorder = Color(0xFFEFD7DA); // Pale Rose (card border)
  static const Color iconChipBg = Color(0xFFF3D9DC); // Dusty Blush (icon bg)
  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color gold = Color(0xFFF3C564); // Warm Gold
  static const Color goldLight =
      Color(0xFFFCE1AB); // Soft Yellow (gold highlight)
  static const Color successGreen = Color(0xFF44AF70); // Fresh Green
  static const Color paleMint = Color(0xFFEAF6EF); // Pale Mint background
  static const Color danger = Color(0xFFB81104);
  static const Color dangerBg = Color(0xFFFBEAE7);

  /// Themed soft shadow for resting cards/panels.
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

  /// Elevated/hover glow — a slightly stronger, warmer shadow used for
  /// interactive/elevated elements.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: lemonChiffonDeep.withValues(alpha: 0.24),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.14),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Richer navbar/header shadow stack — deep maroon drop shadow + soft
  /// ambient gold bloom + fine black contact shadow.
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.40),
          blurRadius: 34,
          offset: const Offset(0, 15),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.12),
          blurRadius: 40,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}

/// Simple responsive breakpoint helper — layout-only, does not touch any
/// provider/navigation/logout logic anywhere in this file. Matches the
/// same breakpoint values already used on the Orders / Tables screens so
/// every staff screen switches layouts at exactly the same widths.
enum _DeviceType { mobile, tablet, desktop }

_DeviceType _deviceTypeForWidth(double width) {
  if (width < 700) return _DeviceType.mobile;
  if (width < 1100) return _DeviceType.tablet;
  return _DeviceType.desktop;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<StaffAuthProvider>();
    final user = auth.user;
    final role = auth.role;
    final isBilling = role == StaffRole.billingStaff;

    final roleLabel = isBilling ? 'Billing Staff' : 'Serving Staff';
    final accentColor =
        isBilling ? AppColors.billingAccent : AppColors.servingAccent;

    final name = user?.name ?? 'Staff Member';
    final initials = name
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    // Three-tier breakpoint (mobile / tablet / desktop) shared by the
    // hero header and the scrollable card layout below, so both read the
    // same device width and switch together.
    final deviceType = _deviceTypeForWidth(MediaQuery.of(context).size.width);
    final isTablet = deviceType == _DeviceType.tablet;
    final isDesktop = deviceType == _DeviceType.desktop;

    // Tablet/desktop content is capped to a comfortable reading width and
    // centered, like the rest of the staff app's screens, instead of
    // stretching every card edge-to-edge on a wide tablet or laptop
    // viewport. Mobile keeps the original full-width behavior.
    final double maxContentWidth =
        isDesktop ? 1080 : (isTablet ? 860 : double.infinity);
    final double outerPadding = isDesktop ? 28 : (isTablet ? 24 : 20);

    // ── The three cards, built once so they can be arranged either as a
    // single stacked column (mobile/tablet, original order) or split
    // across two columns (desktop only) below — same widgets, same
    // content, same animations, just placed differently.
    final Widget personalDetailsCard = _SectionCard(
      title: 'Personal Details',
      icon: Icons.badge_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? 'N/A',
            iconColor: AppColors.info,
            iconBg: AppColors.infoLight,
          ),
          const SizedBox(height: 14),
          _ProfileRow(
            icon: Icons.work_rounded,
            label: 'Role',
            value: roleLabel,
            iconColor: accentColor,
            iconBg: isBilling
                ? AppColors.billingAccentLight
                : AppColors.servingAccentLight,
          ),
          const SizedBox(height: 14),
          _ProfileRow(
            icon: Icons.restaurant_rounded,
            label: 'Restaurant',
            value: user?.restaurantName ?? 'PUREDINE',
            iconColor: _Palette.milanoRedDeep,
            iconBg: _Palette.milanoRed.withValues(
              alpha: 0.08,
            ),
          ),
          if (user?.phone != null) ...[
            const SizedBox(height: 14),
            _ProfileRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: user!.phone!,
              iconColor: AppColors.success,
              iconBg: AppColors.successLight,
            ),
          ],
          const SizedBox(height: 14),
          _ProfileRow(
            icon: Icons.calendar_today_rounded,
            label: 'Joined On',
            value: _formatDate(user?.createdAt),
            iconColor: _Palette.textMuted,
            iconBg: _Palette.canvasDeep,
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(
          begin: 0.06,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );

    final Widget quickAccessCard = _SectionCard(
      title: 'Quick Access',
      icon: Icons.bolt_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isBilling) ...[
            _QuickLink(
              icon: Icons.receipt_long_rounded,
              label: 'View Active Orders',
              accentColor: _Palette.milanoRedDeep,
              onTap: () => context.push('/staff/orders'),
            ),
            Divider(
              height: 20,
              color: _Palette.milanoRedDeep.withValues(
                alpha: 0.08,
              ),
            ),
            _QuickLink(
              icon: Icons.table_restaurant_rounded,
              label: 'Floor Plan',
              accentColor: AppColors.billingAccent,
              onTap: () => context.push('/staff/tables'),
            ),
          ] else ...[
            _QuickLink(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Billing & Payments',
              accentColor: AppColors.billingAccent,
              onTap: () => context.push('/staff/billing'),
            ),
          ],
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 80.ms).slideY(
          begin: 0.06,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );

    final Widget appInfoCard = _SectionCard(
      title: null,
      icon: null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          _Palette.milanoRedLight,
                          _Palette.milanoRedDeep,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: _Palette.gold.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRedDeep.withValues(alpha: 0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RestaurantOS',
                        style: AppTheme.serif(
                          size: 15,
                          weight: FontWeight.w800,
                          color: _Palette.textDark,
                        ),
                      ),
                      Text(
                        'Staff App v1.0.0',
                        style: AppTheme.sans(
                          size: 12,
                          color: _Palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                child: Text(
                  isBilling ? 'BILLING' : 'SERVING',
                  style: AppTheme.sans(
                    size: 10,
                    weight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Full-width logout button — soft hover/press
          // lift, same async onTap logic.
          _SignOutButton(
            onTap: () async {
              final navigator = GoRouter.of(context);
              final rootAuth = context.read<AuthProvider>();
              await auth.logout();
              await rootAuth.logout();
              navigator.go('/login');
            },
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: 160.ms).slideY(
          begin: 0.06,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );

    // On desktop only: "Personal Details" sits in a wider left column,
    // "Quick Access" and the App Info/Sign Out card stack in a narrower
    // right column beside it — a denser, more professional dashboard
    // layout that makes use of the extra horizontal space. Mobile and
    // tablet keep the original single stacked column, in the original
    // order.
    final Widget cardsLayout = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: personalDetailsCard,
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    quickAccessCard,
                    const SizedBox(height: 18),
                    appInfoCard,
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              personalDetailsCard,
              const SizedBox(height: 18),
              quickAccessCard,
              const SizedBox(height: 18),
              appInfoCard,
            ],
          );

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / Orders screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash. No logic touched — visuals only.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _Palette.canvasDeep.withValues(alpha: 0.5),
                    _Palette.canvas,
                    _Palette.canvas,
                  ],
                  stops: const [0.0, 0.2, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffon.withValues(alpha: 0.20),
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
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRed.withValues(alpha: 0.07),
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
                  // Extra low, wide glow further down the page — gives the
                  // scroll area a second soft focal point instead of all
                  // the ambient light sitting only near the hero header.
                  Positioned(
                    top: 620,
                    left: -70,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRedLight.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Faint diagonal sheen sweeping across the whole page — a subtle
          // extra layer of depth so the cream backdrop doesn't read as
          // flat behind the hero.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.30),
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
              // ── Profile Hero Header — PUREDINE Deep Wine Maroon gradient
              // + Gold accents, so every staff screen reads as one
              // cohesive brand. The back control has been removed from
              // this header per request. ────────────────────────────────
              _ProfileHeroHeader(
                name: name,
                initials: initials,
                roleLabel: roleLabel,
                accentColor: accentColor,
                isBilling: isBilling,
                onBack: () {
                  if (context.canPop()) context.pop();
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(outerPadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        children: [
                          cardsLayout,
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    return '${now.day} ${_month(now.month)} ${now.year}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

/// Small decorative gradient divider — purely cosmetic.
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _Palette.gold.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────────
// Background now follows the PUREDINE card spec directly: a soft gradient
// from the warm off-white canvas into the Soft Cream card tone, a solid
// Pale Rose (#EFD7DA) border, and a Dusty Blush (#F3D9DC) icon chip — same
// card footprint and content as before, colors only.
//
// UI-ENHANCEMENT PASS: padding now has a dedicated tablet value (between
// the existing mobile and desktop sizing) instead of a single fixed value
// for every width. Same content, same structure.
class _SectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final deviceType = _deviceTypeForWidth(MediaQuery.of(context).size.width);
    final isMobile = deviceType == _DeviceType.mobile;
    final isTablet = deviceType == _DeviceType.tablet;
    final double cardPadding = isMobile ? 20 : (isTablet ? 24 : 26);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _Palette.canvasDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _Palette.cardBorder,
        ),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _Palette.iconChipBg,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: _Palette.milanoRedDeep.withValues(
                          alpha: 0.10,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 17,
                      color: _Palette.milanoRedDeep,
                    ),
                  ),
                  const SizedBox(width: 11),
                ] else
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_Palette.gold, _Palette.goldLight],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (icon == null) const SizedBox(width: 10),
                Text(
                  title!,
                  style: AppTheme.serif(
                    size: 18,
                    weight: FontWeight.w800,
                    color: _Palette.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 45),
              child: _TitleDivider(),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

// ─── Profile Hero Header ────────────────────────────────────────────────
// Recolored to the PUREDINE topbar spec: a clean two-stop diagonal
// gradient from Deep Wine Maroon (#742A3C) into Wine (#813244), the
// avatar, name, and badges — no structural change and no logic/callback
// signatures touched (onBack is still accepted, still not rendered,
// exactly as before).
//
// UI-ENHANCEMENT PASS: the bottom edge is now a straight,
// flat line instead of the previous rounded bottom corners — matching the
// flat-bottom topbar treatment used on the Tables / Create Order screens'
// headers. The rounded `BorderRadius` was removed from this Container's
// decoration and a thin warm-gold hairline border was added along the
// bottom edge, mirroring those screens' own bottom-edge accent. The
// gradient, shadow stack, avatar, name, and badges are all unchanged.
//
// UI-ENHANCEMENT PASS (this pass — three-tier responsive): the single
// `isMobile` split at 800px is now a three-tier `_DeviceType` breakpoint
// (mobile/tablet/desktop), matching the rest of the staff app, so the
// header's padding, avatar size, and name type scale each get a
// dedicated tablet value instead of jumping straight from phone sizing to
// desktop sizing. The header's inner content is also centered to the
// same max content width used by the scrollable cards below it, so the
// avatar/name line up with the cards on tablet/desktop. Structure, text,
// callbacks and data are unchanged.
class _ProfileHeroHeader extends StatelessWidget {
  final String name;
  final String initials;
  final String roleLabel;
  final Color accentColor;
  final bool isBilling;
  final VoidCallback onBack;

  const _ProfileHeroHeader({
    required this.name,
    required this.initials,
    required this.roleLabel,
    required this.accentColor,
    required this.isBilling,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = _deviceTypeForWidth(MediaQuery.of(context).size.width);
    final isMobile = deviceType == _DeviceType.mobile;
    final isTablet = deviceType == _DeviceType.tablet;
    final isDesktop = deviceType == _DeviceType.desktop;

    final double horizontalPadding = isMobile ? 16 : (isTablet ? 20 : 24);
    final double topPadding = isMobile ? 20 : (isTablet ? 22 : 24);
    final double bottomPadding = isMobile ? 26 : (isTablet ? 28 : 30);
    final double avatarSize = isMobile ? 72 : (isTablet ? 78 : 84);
    final double avatarFontSize = isMobile ? 26 : (isTablet ? 28 : 30);
    final double nameSize = isMobile ? 20 : (isTablet ? 21 : 22);
    final double maxContentWidth =
        isDesktop ? 1080 : (isTablet ? 860 : double.infinity);

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRed,
              _Palette.milanoRedLight,
            ],
          ),
          // Straight, flat bottom edge — no rounded corners — matching
          // the Tables / Create Order headers' shape, plus the same thin
          // warm-gold hairline those screens use along that bottom edge.
          border: Border(
            bottom: BorderSide(
              color: _Palette.gold.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          boxShadow: _Palette.heroShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Row(
                      children: [
                        // Initials Avatar with gold ring
                        Stack(
                          children: [
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    _Palette.milanoRed,
                                    _Palette.milanoRedDeep,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _Palette.gold.withValues(
                                    alpha: 0.85,
                                  ),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _Palette.gold.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: AppTheme.serif(
                                    size: avatarFontSize,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Online status dot
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _Palette.successGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _Palette.milanoRedDeep,
                                    width: 2,
                                  ),
                                ),
                              )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scale(
                                    begin: const Offset(0.85, 0.85),
                                    end: const Offset(1.1, 1.1),
                                    duration: 1500.ms,
                                    curve: Curves.easeInOut,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTheme.serif(
                                  size: nameSize,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const _TitleDivider(),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _Palette.lemonChiffon.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _Palette.gold.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      roleLabel.toUpperCase(),
                                      style: AppTheme.sans(
                                        size: 10,
                                        weight: FontWeight.w800,
                                        color: _Palette.lemonChiffon,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: _Palette.successGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ACTIVE NOW',
                                          style: AppTheme.sans(
                                            size: 10,
                                            weight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fade(duration: 400.ms)
                        .slideX(begin: -0.05, curve: Curves.easeOutQuad),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.15, duration: 450.ms);
  }
}

// ─── Profile Row ─────────────────────────────────────────────────────────
class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _Palette.gold.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTheme.sans(
                  size: 10,
                  weight: FontWeight.w700,
                  color: _Palette.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.sans(
                  size: 14,
                  weight: FontWeight.w700,
                  color: _Palette.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Quick Link ─────────────────────────────────────────────────────────
class _QuickLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_QuickLink> createState() => _QuickLinkState();
}

class _QuickLinkState extends State<_QuickLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: widget.accentColor.withValues(alpha: 0.08),
        highlightColor: widget.accentColor.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: 180.ms,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: _isHovered
                        ? widget.accentColor.withValues(alpha: 0.4)
                        : _Palette.gold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTheme.sans(
                    size: 14,
                    weight: FontWeight.w700,
                    color: _Palette.textDark,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: 180.ms,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.accentColor.withValues(alpha: 0.14)
                      : _Palette.canvasDeep,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _isHovered
                      ? widget.accentColor
                      : _Palette.textMuted.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sign Out Button ────────────────────────────────────────────────────
class _SignOutButton extends StatefulWidget {
  final Future<void> Function() onTap;

  const _SignOutButton({required this.onTap});

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isElevated = _isHovered || _isPressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : (_isHovered ? 1.01 : 1.0),
          duration: 150.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: 180.ms,
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _Palette.dangerBg,
                  _Palette.dangerBg.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _Palette.danger.withValues(
                  alpha: isElevated ? 0.45 : 0.25,
                ),
                width: isElevated ? 1.4 : 1,
              ),
              boxShadow: isElevated
                  ? [
                      BoxShadow(
                        color: _Palette.danger.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: _Palette.danger,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: AppTheme.sans(
                    size: 14,
                    weight: FontWeight.w700,
                    color: _Palette.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
