import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/auth_provider.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / Orders / New Orders / Create Order / Menu
/// Management screens exactly (#8B1D1D primary / #F4C430 gold accent), so
/// this screen now reads as part of the same cohesive, professional brand
/// instead of its own one-off theme. Used ONLY for this screen's visual
/// layer. Nothing here touches AppColors, AppTheme, or any other file —
/// pure UI enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: the hero header was pushed further into its own
/// distinctive "command bar" identity (four-stop gradient, a large faint
/// watermark emblem, a glass highlight line along the top edge), the
/// full-screen backdrop gained an extra diagonal sheen + a second ambient
/// glow lower on the page, the section cards now sit on a very subtle
/// warm gradient instead of flat white, and the Quick Access links plus
/// the Sign Out control picked up a soft hover/press lift so the screen
/// feels like an interactive, considered surface rather than a static
/// settings page. No provider, controller, route, or logout logic was
/// touched anywhere in this pass — every onTap/onBack callback is wired
/// to the exact same function as before; only Container/Decoration/
/// TextStyle-level presentation changed.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// the other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
/// change here).
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
  static const Color danger = Color(0xFFB81104);
  static const Color dangerBg = Color(0xFFFBEAE7);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Order Details/Orders/Menu/Create Order so every
  /// card on this screen carries the same warm, branded elevation.
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
  /// interactive/elevated elements, matching the Dashboard's feature
  /// cards and the Tables floor-plan tiles.
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

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the Order Details / Orders / Create Order /
  /// Dashboard headers (deep maroon drop shadow + soft ambient gold
  /// bloom + fine black contact shadow).
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

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / Orders screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Order Details / Menu
          // Management screens' "foggy" backdrop so the whole admin/staff
          // experience feels like one cohesive brand. No logic touched —
          // visuals only.
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
          // flat behind the hero, echoing the glass-highlight language
          // used in the hero itself.
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
              // ── Profile Hero Header — same Dark Maroon gradient + gold
              // accents + dotted/ribbon decorative language used on the
              // Order Details / Menu Management navbar, so every staff
              // screen reads as one cohesive brand. The back control has
              // been removed from this header per request. ─────────────
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ── Personal Details Card ──
                      _SectionCard(
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
                          ),

                      const SizedBox(height: 18),

                      // ── Quick Access Card ──
                      _SectionCard(
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
                          ),

                      const SizedBox(height: 18),

                      // ── App Info + Logout ──
                      _SectionCard(
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
                                            color: _Palette.milanoRedDeep
                                                .withValues(alpha: 0.20),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            // Full-width logout button — now with a soft
                            // hover/press lift, same async onTap logic.
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
                          ),

                      const SizedBox(height: 8),
                    ],
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

/// Small decorative gradient divider — purely cosmetic, mirrors the same
/// accent used beneath section titles on the Order Details / Menu
/// Management screens.
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
// Same white, softly bordered, softly shadowed card language used by the
// Order Details / Menu Management screens' panels, plus the same thin
// gold accent bar used as a section marker and an optional leading icon
// chip, so every card on this screen reads as part of the same Theme 1
// brand. UI-ENHANCEMENT PASS 2: the flat white fill became a very subtle
// warm gradient (white → a whisper of canvas) and the icon chip picked
// up a soft colored glow, for a touch more depth without changing the
// card's footprint or its content. Purely presentational — wraps the
// exact same child content as before.
class _SectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _Palette.canvasDeep.withValues(alpha: 0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _Palette.milanoRed.withValues(alpha: 0.10),
                          _Palette.milanoRed.withValues(alpha: 0.04),
                        ],
                      ),
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

// ─── Profile Hero Header — same Dark Maroon gradient treatment, bigger
// rounded "floating navbar" corners, a richer 3-layer shadow stack,
// dotted texture accent, layered ribbon + gold glows used on the Order
// Details / Menu Management screens' header, plus the same thin-gold-
// border language as the brand icon chip elsewhere, so this screen and
// every other staff screen read as one cohesive, unique brand.
// UI-ENHANCEMENT PASS 2: the gradient is now a richer four-stop diagonal
// wash, a large faint watermark emblem sits low-opacity behind the
// avatar/name block, and a fine glass highlight line runs along the very
// top edge — matching the Dashboard/Orders/Tables headers' "command bar"
// identity. The back chevron control remains removed from the top of
// this header per the earlier request — the `onBack` callback is still
// accepted and passed in unchanged (so the call site in ProfileScreen
// didn't need to change), it's simply not rendered here. Purely a
// presentational change — no data changed. ─────────────────────────────
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
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the
          // Dashboard hero's "faceted" surface language.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              Color(0xFF320A0A),
            ],
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
          // Softly rounded bottom corners give the header a modern,
          // "floating navbar" feel that matches the Order Details / Menu
          // Management screens exactly, instead of a flat hard-edged band.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: Border(
            bottom: BorderSide(
              color: _Palette.lemonChiffon.withValues(alpha: 0.9),
              width: 4,
            ),
          ),
          boxShadow: _Palette.heroShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle decorative diagonal ribbon accents (purely cosmetic,
            // matches the Order Details / Menu Management header for a
            // consistent brand feel across the whole app).
            Positioned(
              top: -60,
              right: -40,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 240,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.16),
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
                  width: 220,
                  height: 70,
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
            // Soft gold radial glow behind the avatar, echoing the
            // Dashboard / Order Details hero treatment.
            Positioned(
              top: -50,
              left: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.lemonChiffon.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Extra ambient gold glow, lower-right — matches the fuller
            // "full-screen backdrop" glow used on the other headers.
            Positioned(
              bottom: -70,
              right: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.lemonChiffon.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Large faint watermark emblem — a unique signature touch,
            // sits low-opacity and large behind the copy, never competing
            // with the avatar or name.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -26 : -20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.badge_rounded,
                    size: isMobile ? 130 : 175,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used on the Order Details / Menu
            // Management header.
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
            // matches the Dashboard/Orders/Tables headers' top edge.
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

            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  20,
                  isMobile ? 16 : 24,
                  26,
                ),
                child: Row(
                  children: [
                    // Initials Avatar with gold ring
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
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
                                size: 26,
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
                              color: const Color(0xFF4ADE80),
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
                              size: isMobile ? 20 : 22,
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
                                        color: Color(0xFF4ADE80),
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
          ],
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.15, duration: 450.ms);
  }
}

// ─── Profile Row — restyled to sit on the warm canvas background with
// the same soft rounded icon chips used across the Order Details / Menu
// Management / New Orders / Create Order screens. Same label/value
// content, same icon color inputs. ───────────────────────────────────
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

// ─── Quick Link — same warm rounded icon chip + arrow language as the
// rest of the screen, now with a soft hover/press lift (a faint tinted
// background + a slightly bolder arrow chip) in addition to the existing
// ripple, so each link clearly reads as tappable on both touch and
// pointer devices. Same label/onTap/accentColor content as before. ────
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

// ─── Sign Out Button — same soft "danger" gradient chip, same icon +
// label, and the exact same async onTap callback as before, now wrapped
// in a small stateful shell so it gets a subtle hover/press lift (a
// touch more shadow + a faint scale) matching the interactive feel of
// the rest of the redesigned screen.
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
