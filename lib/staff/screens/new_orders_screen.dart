import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../../core/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../contexts/auth_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the Create Order / Menu
/// Management / Dashboard / Orders / Order Details screens exactly, so this
/// screen now reads as part of the same cohesive, professional brand.
/// Field names are kept identical to the previous palette so every usage
/// below the class still lines up — only the color VALUES changed. Nothing
/// here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 4 (previous pass): the "ACCEPT ORDER" button on each
/// `_OrderCard` was reading too light (gold → soft-yellow gradient). Its
/// gradient now runs from the deeper gold tone into the base gold tone
/// (instead of base gold into the light gold highlight), and its border/
/// shadow were deepened to match, so the button reads as a bolder, more
/// confident primary CTA. Everything else — including the rest of PASS 3's
/// header restyle — was untouched. No provider, controller, route, sort, or
/// status-transition logic was touched in that pass — only that one
/// button's presentation changed.
///
/// UI-ENHANCEMENT PASS 5 (previous pass): `_ScreenHeader`'s bottom edge is
/// now a straight, flat line instead of the previous rounded 32px corners —
/// matching the flat-bottom topbar treatment used on the Tables screen's
/// header. The rounded `BorderRadius` on the header `Container`/`ClipRRect`
/// was removed (so the banner is now a plain rectangle, using `ClipRect`
/// instead of `ClipRRect`) and a thin warm-gold hairline border was added
/// along the bottom edge, mirroring Tables' own bottom-edge accent.
/// Everything else inside the header — the gradient, the drop shadow, the
/// ambient gold glows, the back chip, the refresh chip, the title block,
/// the tagline, the date/live row, and the sort chip — is completely
/// unchanged, as is every other part of this file (stats row, `_OrderCard`,
/// and all provider/sorting logic in `_NewOrdersScreenState`). Presentation
/// only.
///
/// UI-ENHANCEMENT PASS 6 (this pass): RESPONSIVE LAYOUT PASS
/// (MOBILE / TABLET / LAPTOP) — no navigation, provider/sorting logic,
/// status-transition logic, callbacks, routes, copy, or any existing
/// field/keyword anywhere in this file was renamed, removed, or otherwise
/// touched. Previously `_ScreenHeader` only ever branched on a single
/// `isMobile` check (`width < 800`), so every tablet was silently forced
/// into either the cramped "mobile" numbers or the full "desktop" numbers
/// depending only on which side of 800px it happened to fall on, and the
/// scrollable body below the header had no tablet/laptop tier at all — its
/// padding was a single fixed value and its content had no max-width cap,
/// so cards could stretch unnaturally wide on a laptop/desktop screen.
/// This pass fixes both:
///   1. SHARED BREAKPOINTS: two new top-level constants,
///      `_kTabletBreakpointWidth` (`600`) and `_kLaptopBreakpointWidth`
///      (`1024`), are now used consistently by both `_ScreenHeader` and
///      the scrollable body, replacing the header's old standalone `800`
///      threshold. `isMobile` now means `width < 600` and a new `isTablet`
///      flag covers `600–1023`; `1024` and above is laptop/desktop — the
///      same three-tier split used elsewhere in the app.
///   2. THREE-TIER SIZING: every metric that used to be a two-way
///      `isMobile ? mobileValue : desktopValue` ternary in `_ScreenHeader`
///      (padding, title font size, tagline font size, and the vertical
///      gaps between the header's rows) is now a three-way
///      `isMobile ? mobileValue : (isTablet ? tabletValue : desktopValue)`
///      ternary, with the tablet number always sitting sensibly between
///      the existing mobile and desktop numbers.
///   3. BODY CONTENT — WIDTH CAP + TIERED PADDING: `_buildContent`'s
///      `SingleChildScrollView` padding is now three-tier
///      (mobile/tablet/laptop) instead of one fixed value, and its content
///      `Column` is wrapped in a `Center` + `ConstrainedBox` capping the
///      content at a sensible max width on tablet (`900`) and laptop
///      (`1100`) — so on a wide laptop monitor the stats row and every
///      order card read as a deliberate, centered, professional column
///      instead of stretching edge-to-edge across the whole screen.
///      Mobile is unaffected (`double.infinity`, i.e. the exact original
///      behaviour) since phone screens are always narrower than either
///      cap anyway.
///   4. CARD / STAT-BOX POLISH ON TABLET & LAPTOP: `_StatBox` and
///      `_OrderCard` both gained two new boolean inputs, `isMobile` and
///      `isTablet` (new parameters added alongside the existing ones —
///      nothing existing was renamed), used only to scale their own
///      internal padding, icon sizes, and font sizes up a notch on tablet
///      and laptop for a fuller, more professional feel on larger screens.
///      The exact original mobile numbers are fully preserved; every
///      order card keeps the exact same content, arrangement, status
///      logic, accept/view-details buttons, and `onTap` callbacks as
///      before — only sizing changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Primary / Topbar — Deep Wine Maroon
  static const Color milanoRed = Color(0xFF742A3C);
  // Primary accent / deep — Burgundy
  static const Color milanoRedDeep = Color(0xFF8A183F);
  // Topbar lighter gradient — Wine
  static const Color milanoRedLight = Color(0xFF813244);

  // Main background — Warm Off-White
  static const Color canvas = Color(0xFFFBF8F5);
  // Card background — Soft Cream
  static const Color canvasDeep = Color(0xFFF7F1ED);

  // Dark text — Deep Brown/Black
  static const Color textDark = Color(0xFF2E0D16);
  // Secondary text — Muted Taupe
  static const Color textMuted = Color(0xFF9B707A);

  // Gold accent family — Warm Gold (accent) / a deeper gold used for
  // borders and hover/emphasis states, plus the Soft Yellow highlight.
  static const Color gold = Color(0xFFF3C564);
  static const Color goldLight = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color lemonChiffon = Color(0xFFF3C564); // alias, same as gold
  static const Color lemonChiffonDeep = Color(0xFFD9A63E); // deeper gold

  // Extra brand tints from the PUREDINE palette.
  static const Color dustyBlush = Color(0xFFF3D9DC); // Blush/Pink tint
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background

  // Live / Success — Fresh Green, with a deeper shade for on-mint text/
  // icons and the pale mint tint as its soft background.
  static const Color success = Color(0xFF44AF70);
  static const Color successDeep = Color(0xFF2E7D4F);
  static const Color successBg = Color(0xFFEAF6EF);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Menu/Create Order/Dashboard/Orders/Order Details
  /// so every card on this page carries the same warm, branded elevation.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Header/hero drop shadow — matches the Create Order hero exactly.
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];

  /// Soft inner "glass" shadow — kept for any capsule-style surfaces
  /// elsewhere on this screen.
  static List<BoxShadow> get statCapsuleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ];
}

const List<String> _kMonthNames = [
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

String _todayLabel() {
  final now = DateTime.now();
  return '${_kMonthNames[now.month - 1]} ${now.day}, ${now.year}';
}

// PASS 6: shared responsive breakpoints used by both `_ScreenHeader` and
// the scrollable body content below it, so mobile / tablet / laptop all
// get their own properly proportioned layout instead of tablets being
// silently treated as either phones or laptops depending only on which
// side of a single cutoff they happened to fall on.
const double _kTabletBreakpointWidth = 600;
const double _kLaptopBreakpointWidth = 1024;

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  bool _showNewestFirst = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final auth = context.read<StaffAuthProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    if (auth.token != null) {
      await ordersProvider.fetchOrders(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final newOrders = List<Order>.from(provider.newOrders);

    // Sort by createdAt
    newOrders.sort(
      (a, b) => _showNewestFirst
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );

    final acceptedCount = provider.activeOrders.length;

    // PASS 6: shared mobile/tablet classification for the scrollable body
    // below the header (the header computes its own copy internally using
    // the same shared breakpoint constants).
    final bodyWidth = MediaQuery.of(context).size.width;
    final isMobileBody = bodyWidth < _kTabletBreakpointWidth;
    final isTabletBody = !isMobileBody && bodyWidth < _kLaptopBreakpointWidth;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Create Order / Dashboard / Orders /
      // Order Details screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Create Order / Menu
          // Management / Orders / Order Details screens' "foggy" backdrop
          // so the whole admin/staff experience feels like one cohesive
          // brand. No logic touched — visuals only.
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
                            _Palette.gold.withValues(alpha: 0.16),
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
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Extra low, wide glow further down the page — gives a
                  // long order list a second soft focal point instead of
                  // all the ambient light sitting only near the header.
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
          // flat behind the header. Matches the Create Order / Orders /
          // Order Details screens exactly.
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
              // ── Header — restyled to match the Create Order screen's
              // header design language exactly (two-stop maroon-to-wine
              // gradient, flat bottom edge with a gold hairline, back
              // chip, title block, plain-text tagline with a gold accent
              // rule, date/live row, gold hairline). Refresh and
              // sort-order controls preserved, restyled into the same
              // minimal glass-chip language. ─────
              _ScreenHeader(
                title: 'New Orders',
                subtitle: 'Incoming Kitchen Orders',
                dateLabel: _todayLabel(),
                newOrdersCount: newOrders.length,
                acceptedCount: acceptedCount,
                onBack: () => context.pop(),
                onRefresh: () {
                  final token = context.read<StaffAuthProvider>().token;
                  if (token != null) {
                    context.read<OrdersProvider>().fetchOrders(token);
                  }
                },
                showNewestFirst: _showNewestFirst,
                onToggleSort: () =>
                    setState(() => _showNewestFirst = !_showNewestFirst),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats sidebar on large screens (shown inline on small)
                    _buildContent(
                      context,
                      newOrders,
                      acceptedCount,
                      provider,
                      isMobileBody,
                      isTabletBody,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Order> newOrders,
    int acceptedCount,
    OrdersProvider provider,
    bool isMobile,
    bool isTablet,
  ) {
    // PASS 6: tiered padding (mobile/tablet/laptop) instead of one fixed
    // value, plus a content max-width cap on tablet/laptop so the stats
    // row and order cards read as a deliberate, centered column instead
    // of stretching edge-to-edge on a wide laptop monitor. Mobile is
    // unaffected — `double.infinity` is the exact original behaviour.
    final double horizontalPadding = isMobile ? 20 : (isTablet ? 32 : 40);
    final double topPadding = isMobile ? 24 : (isTablet ? 28 : 32);
    final double bottomPadding = isMobile ? 32 : (isTablet ? 36 : 40);
    final double contentMaxWidth =
        isMobile ? double.infinity : (isTablet ? 900 : 1100);
    final double statSpacing = isMobile ? 16 : (isTablet ? 18 : 20);
    final double statsBottomGap = isMobile ? 22 : (isTablet ? 26 : 28);

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              children: [
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        icon: Icons.notifications_outlined,
                        iconColor: _Palette.milanoRedDeep,
                        iconBg: _Palette.milanoRed.withValues(alpha: 0.10),
                        accentColor: _Palette.milanoRed,
                        label: 'New Orders',
                        value: '${newOrders.length}',
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ).animate().fade().scale(
                            curve: Curves.easeOutBack,
                            duration: 400.ms,
                          ),
                    ),
                    SizedBox(width: statSpacing),
                    Expanded(
                      child: _StatBox(
                        icon: Icons.check_circle_outline,
                        iconColor: _Palette.lemonChiffonDeep,
                        iconBg:
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.14),
                        accentColor: _Palette.gold,
                        label: 'Accepted',
                        value: '$acceptedCount',
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ).animate().fade().scale(
                            curve: Curves.easeOutBack,
                            duration: 400.ms,
                            delay: 100.ms,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: statsBottomGap),

                if (newOrders.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    subtitle: 'New customer orders will appear here',
                  ).animate().fade(duration: 400.ms).slideY(
                        begin: 0.1,
                        duration: 400.ms,
                        curve: Curves.easeOutQuad,
                      )
                else
                  ...newOrders.asMap().entries.map(
                        (entry) => _OrderCard(
                          order: entry.value,
                          provider: provider,
                          isMobile: isMobile,
                          isTablet: isTablet,
                        )
                            .animate()
                            .fade(
                              duration: 400.ms,
                              delay: (entry.key * 100).ms,
                            )
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
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

// ─── Screen header — restyled to mirror the Create Order screen's header
// exactly: a two-stop maroon-to-wine gradient, two soft ambient gold
// glows, an icon-only back chip (with a small refresh chip beside it), a
// title block (small icon + subtitle label, then the big title), a
// plain-text tagline anchored by a small gold accent rule (no icon badge,
// no card, no border/shadow), a date/live row with an inline sort-order
// chip, and a thin gold gradient hairline underneath. The bottom edge is
// now a straight, flat line (no rounded corners) with a thin warm-gold
// hairline border along that edge, matching the Tables screen's
// flat-bottom topbar treatment. No watermark emblem, no dotted texture,
// no photo/avatar imagery — kept intentionally minimal per the Create
// Order screen's design language. The tagline is data-driven off
// `newOrdersCount` (already computed by the caller) purely as a text
// format — no new logic. Same callbacks (onBack / onRefresh /
// onToggleSort) as before — this is a purely presentational change.
//
// PASS 6: now classifies the screen into mobile / tablet / laptop using
// the same shared `_kTabletBreakpointWidth` / `_kLaptopBreakpointWidth`
// constants the body content uses (replacing the old standalone `800`
// cutoff), and every previously two-way `isMobile ? a : b` size below is
// now three-way `isMobile ? a : (isTablet ? c : b)` so tablets get their
// own properly proportioned numbers instead of inheriting either the
// phone or the laptop treatment.
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final int newOrdersCount;
  final int acceptedCount;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final bool showNewestFirst;
  final VoidCallback onToggleSort;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.newOrdersCount,
    required this.acceptedCount,
    required this.onBack,
    required this.onRefresh,
    required this.showNewestFirst,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < _kTabletBreakpointWidth;
    final isTablet = !isMobile && width < _kLaptopBreakpointWidth;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Two-stop Deep Wine Maroon → Wine gradient, matching the
        // Create Order hero exactly.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
        // Straight, flat bottom edge — no rounded corners — matching
        // the Tables screen's topbar shape, plus the same thin
        // warm-gold hairline Tables uses along that bottom edge.
        border: Border(
          bottom: BorderSide(
            color: _Palette.gold.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        boxShadow: _Palette.heroShadow,
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // A subtle deeper-wine wash toward the bottom, so content near
            // the header's lower edge reads clearly against the darkest
            // part of the banner.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _Palette.milanoRedDeep.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Two very soft decorative gold glows tucked behind the
            // content — purely decorative, mirroring the Create Order
            // hero.
            Positioned(
              top: -50,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.gold.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.gold.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 18 : (isTablet ? 26 : 32),
                  isMobile ? 14 : (isTablet ? 17 : 20),
                  isMobile ? 18 : (isTablet ? 26 : 32),
                  isMobile ? 24 : (isTablet ? 27 : 30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: icon-only back control, plus a matching
                    // small refresh chip on the right. Same onBack /
                    // onRefresh callbacks as before — presentation only.
                    Row(
                      children: [
                        _BackChip(onTap: onBack),
                        const Spacer(),
                        _RefreshChip(onTap: onRefresh),
                      ],
                    ),

                    SizedBox(height: isMobile ? 16 : (isTablet ? 18 : 20)),

                    // ── Title block: small icon + subtitle label, then
                    // the big title — matches the Create Order header's
                    // title block exactly.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 15,
                              color: _Palette.gold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              subtitle,
                              style: AppTheme.sans(
                                size: 13,
                                weight: FontWeight.w700,
                                color: _Palette.gold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: AppTheme.serif(
                            size: isMobile ? 26 : (isTablet ? 29 : 32),
                            weight: FontWeight.w900,
                            color: Colors.white,
                          ).copyWith(height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.15),

                    SizedBox(height: isMobile ? 16 : (isTablet ? 18 : 20)),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge — just
                    // clean, confident cream typography sitting directly
                    // in the header, with a small gold accent rule above
                    // it to anchor the line — matches the Create Order
                    // header's tagline treatment exactly. The copy itself
                    // reflects the live new-orders count already computed
                    // by the caller (a text format of existing data, not
                    // new logic).
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                _Palette.gold.withValues(alpha: 0.9),
                                _Palette.gold.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : (isTablet ? 9 : 10)),
                        Text(
                          newOrdersCount > 0
                              ? '$newOrdersCount new order${newOrdersCount == 1 ? '' : 's'} waiting for you.'
                              : 'All caught up — no new orders right now.',
                          style: AppTheme.serif(
                            size: isMobile ? 15.5 : (isTablet ? 16.5 : 18),
                            weight: FontWeight.w800,
                            color: _Palette.canvasDeep,
                          ).copyWith(height: 1.3, letterSpacing: 0.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(
                          begin: 0.1,
                        ),

                    SizedBox(height: isMobile ? 14 : (isTablet ? 16 : 18)),

                    // ── Date + Live row, with the sort-order toggle
                    // aligned to the right — same information as before,
                    // matching the Create Order header's date/live row
                    // with the existing sort control folded in inline.
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateLabel,
                          style: AppTheme.sans(
                            size: isMobile ? 11.5 : (isTablet ? 12 : 12.5),
                            weight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _Palette.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: AppTheme.sans(
                            size: isMobile ? 11 : (isTablet ? 11.5 : 12),
                            weight: FontWeight.w700,
                            color: _Palette.success,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        _SortChip(
                          icon: showNewestFirst
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          label: showNewestFirst ? 'Newest' : 'Oldest',
                          onTap: onToggleSort,
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 10 : (isTablet ? 11 : 12)),

                    // Thin gold gradient hairline underneath the date row.
                    Container(
                      width: 46,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            _Palette.gold.withValues(alpha: 0.9),
                            _Palette.gold.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.15, duration: 450.ms);
  }
}

// ─── Back chip — icon-only "‹" control ────────────────────────────────────
// A minimal "‹" glyph inside a rounded glass-gold chip, with a hover state
// in addition to the press state — matches the Create Order header's
// `_BackChip` exactly. Same onTap/onBack callback, no navigation logic
// touched.
class _BackChip extends StatefulWidget {
  final VoidCallback onTap;
  const _BackChip({required this.onTap});

  @override
  State<_BackChip> createState() => _BackChipState();
}

class _BackChipState extends State<_BackChip> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: 120.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: _isHovered
                    ? _Palette.gold.withValues(alpha: 0.85)
                    : _Palette.gold.withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _Palette.gold.withValues(alpha: _isHovered ? 0.3 : 0.18),
                  blurRadius: _isHovered ? 14 : 10,
                  spreadRadius: _isHovered ? 1 : 0.5,
                ),
              ],
            ),
            child: Text(
              '‹',
              style: AppTheme.sans(
                size: 24,
                weight: FontWeight.w900,
                color: Colors.white,
              ).copyWith(height: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Refresh chip — same minimal glass-gold circular control as the back
// chip, showing a refresh glyph instead of "‹". Same onRefresh callback as
// before — presentation only, no logic touched.
class _RefreshChip extends StatefulWidget {
  final VoidCallback onTap;
  const _RefreshChip({required this.onTap});

  @override
  State<_RefreshChip> createState() => _RefreshChipState();
}

class _RefreshChipState extends State<_RefreshChip> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: 120.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: _isHovered
                    ? _Palette.gold.withValues(alpha: 0.85)
                    : _Palette.gold.withValues(alpha: 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _Palette.gold.withValues(alpha: _isHovered ? 0.3 : 0.18),
                  blurRadius: _isHovered ? 14 : 10,
                  spreadRadius: _isHovered ? 1 : 0.5,
                ),
              ],
            ),
            child: const Icon(
              Icons.refresh_rounded,
              size: 19,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sort chip — compact gold-outlined glass pill for the header's date
// row, showing the current sort direction. Same onToggleSort callback as
// before — presentation only, no logic touched.
class _SortChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SortChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SortChip> createState() => _SortChipState();
}

class _SortChipState extends State<_SortChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _Palette.gold.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: _Palette.gold, size: 13),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: AppTheme.sans(
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat box — carries a slim color-coded accent rail down the left
// edge, giving each stat box an instant color cue tying it to its
// meaning. Same content, same values — purely presentational.
//
// PASS 6: gained two new inputs, `isMobile` and `isTablet` (added
// alongside the existing fields — nothing renamed), used only to scale
// the box's own padding, icon size, and font sizes up a notch on tablet
// and laptop for a fuller, more professional feel on larger screens. The
// original mobile numbers are fully preserved.
class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
  final String label;
  final String value;
  final bool isMobile;
  final bool isTablet;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.isMobile,
    required this.isTablet,
    this.accentColor = _Palette.gold,
  });

  @override
  Widget build(BuildContext context) {
    final double iconContainerSize = isMobile ? 52 : (isTablet ? 56 : 60);
    final double iconSize = isMobile ? 26 : (isTablet ? 27 : 29);
    final double verticalPad = isMobile ? 22 : (isTablet ? 24 : 26);
    final double horizontalPad = isMobile ? 18 : (isTablet ? 20 : 22);
    final double valueFontSize = isMobile ? 34 : (isTablet ? 36 : 38);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
        boxShadow: _Palette.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.85),
                    accentColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: verticalPad,
              horizontal: horizontalPad,
            ),
            child: Column(
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _Palette.gold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: iconSize),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: AppTheme.sans(
                    size: 11,
                    color: _Palette.textMuted,
                    weight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.serif(
                    size: valueFontSize,
                    weight: FontWeight.w900,
                    color: _Palette.textDark,
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

// ─── Order Card ─────────────────────────────────────────────────────────
// Generous, evenly-balanced spacing so it reads as a proper, professional
// card rather than a tightly-packed list row. A slim status-colored accent
// rail runs down the left edge — maroon while the order is still
// new/unaccepted, brand gold once it's been accepted. Same data, same
// callbacks — only sizing, radii, and color values changed.
//
// PASS 6: gained two new inputs, `isMobile` and `isTablet` (added
// alongside the existing fields — nothing renamed), used only to scale
// the card's own padding, thumbnail/icon sizes, and font sizes up a
// notch on tablet and laptop for a fuller, more professional feel on
// larger screens. The exact original mobile numbers are fully preserved,
// and the card's content, arrangement, status logic, and the accept /
// view-details buttons' `onTap` callbacks are all completely unchanged.
class _OrderCard extends StatelessWidget {
  final Order order;
  final OrdersProvider provider;
  final bool isMobile;
  final bool isTablet;

  const _OrderCard({
    required this.order,
    required this.provider,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.placed;
    final railColor = isNew ? _Palette.milanoRed : _Palette.success;

    // PASS 6: three-tier sizing metrics — mobile numbers are the exact
    // originals, tablet sits between mobile and laptop, laptop is a
    // modest step up from the original desktop numbers for a fuller,
    // more professional card on large screens.
    final double cardMarginBottom = isMobile ? 22 : (isTablet ? 24 : 26);
    final double cardRadius = isMobile ? 26 : (isTablet ? 28 : 30);
    final double statusHPad = isMobile ? 22 : (isTablet ? 24 : 26);
    final double statusVPad = isMobile ? 16 : (isTablet ? 17 : 18);
    final double newOrderLabelFontSize = isMobile ? 16 : (isTablet ? 17 : 18);
    final double acceptedLabelFontSize = isMobile ? 15 : (isTablet ? 15.5 : 16);
    final double contentPad = isMobile ? 22 : (isTablet ? 24 : 26);
    final double thumbSize = isMobile ? 62 : (isTablet ? 66 : 70);
    final double thumbIconSize = isMobile ? 30 : (isTablet ? 32 : 34);
    final double tableFontSize = isMobile ? 20 : (isTablet ? 21 : 22);
    final double itemsCountFontSize = isMobile ? 13 : (isTablet ? 13.5 : 14);
    final double totalFontSize = isMobile ? 25 : (isTablet ? 26 : 28);
    final double customerBoxPad = isMobile ? 13 : (isTablet ? 14 : 15);
    final double itemsBoxPad = isMobile ? 16 : (isTablet ? 17 : 18);
    final double itemTextFontSize = isMobile ? 13 : (isTablet ? 13.5 : 14);
    final double acceptBtnVPad = isMobile ? 17 : (isTablet ? 18 : 19);
    final double acceptLabelFontSize = isMobile ? 15 : (isTablet ? 15.5 : 16);
    final double viewBtnVPad = isMobile ? 15 : (isTablet ? 16 : 17);

    return Container(
      margin: EdgeInsets.only(bottom: cardMarginBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: isNew
              ? _Palette.milanoRed.withValues(alpha: 0.30)
              : _Palette.milanoRedDeep.withValues(alpha: 0.08),
          width: isNew ? 1.3 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _Palette.lemonChiffon.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ]
            : _Palette.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Slim status-colored accent rail down the left edge — an
          // instant color cue for the card's state, purely decorative.
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    railColor.withValues(alpha: 0.85),
                    railColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Status Header
              Container(
                decoration: BoxDecoration(
                  gradient: isNew
                      ? const LinearGradient(
                          colors: [
                            _Palette.milanoRedLight,
                            _Palette.milanoRedDeep,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isNew ? null : _Palette.successBg,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: statusHPad,
                  vertical: statusVPad,
                ),
                child: Row(
                  children: [
                    if (isNew) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEW ORDER',
                              style: AppTheme.sans(
                                size: newOrderLabelFontSize,
                                weight: FontWeight.w900,
                                color: Colors.white,
                              ).copyWith(letterSpacing: 0.4),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  order.time,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                LiveTimeAgo(
                                  dt: order.createdAt,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _Palette.gold.withValues(alpha: 0.65),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.orderNumber,
                          style: AppTheme.sans(
                            size: 12,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: _Palette.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACCEPTED',
                              style: AppTheme.sans(
                                size: acceptedLabelFontSize,
                                weight: FontWeight.w900,
                                color: _Palette.successDeep,
                              ).copyWith(letterSpacing: 0.3),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  order.time,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Text(
                                  order.orderNumber,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPad,
                  contentPad,
                  contentPad,
                  contentPad,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: _Palette.canvas,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: _Palette.milanoRedDeep,
                            size: thumbIconSize,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.table,
                                style: AppTheme.serif(
                                  size: tableFontSize,
                                  weight: FontWeight.w900,
                                  color: _Palette.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${order.items} items',
                                style: AppTheme.sans(
                                  size: itemsCountFontSize,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyUtils.format(order.total),
                          style: AppTheme.serif(
                            size: totalFontSize,
                            weight: FontWeight.w900,
                            color: _Palette.milanoRedDeep,
                          ),
                        ),
                      ],
                    ),
                    if (order.customerName != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(customerBoxPad),
                        decoration: BoxDecoration(
                          color: _Palette.canvas,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: _Palette.milanoRedDeep,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CUSTOMER',
                                  style: AppTheme.sans(
                                    size: 10,
                                    color: _Palette.textMuted,
                                    weight: FontWeight.w700,
                                  ).copyWith(letterSpacing: 0.4),
                                ),
                                Text(
                                  order.customerName!,
                                  style: AppTheme.sans(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: _Palette.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(itemsBoxPad),
                      decoration: BoxDecoration(
                        color: _Palette.canvas,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER ITEMS',
                            style: AppTheme.sans(
                              size: 10,
                              weight: FontWeight.w700,
                              color: _Palette.textMuted,
                            ).copyWith(letterSpacing: 0.4),
                          ),
                          const SizedBox(height: 10),
                          ...order.itemsPreview.take(3).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: _Palette.milanoRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: AppTheme.sans(
                                            size: itemTextFontSize,
                                            color: _Palette.textDark
                                                .withValues(alpha: 0.85),
                                            weight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          if (order.itemsPreview.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 2,
                              ),
                              child: Text(
                                '+${order.itemsPreview.length - 3} more items',
                                style: AppTheme.sans(
                                  size: 12,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons
                    if (isNew)
                      GestureDetector(
                        onTap: () {
                          final token = context.read<StaffAuthProvider>().token;
                          provider.updateOrderStatus(
                            order.id,
                            OrderStatus.confirmed,
                            token!,
                          );
                          context.push('/staff/order-details/${order.id}');
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(vertical: acceptBtnVPad),
                          decoration: BoxDecoration(
                            // Darkened primary CTA: gradient now runs from
                            // the deeper gold tone into the base gold tone
                            // (was gold -> soft-yellow, which read too
                            // light). Same shape, same tap target, same
                            // onTap/status-update/navigation logic.
                            gradient: const LinearGradient(
                              colors: [
                                _Palette.lemonChiffonDeep,
                                _Palette.gold,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _Palette.lemonChiffonDeep.withValues(
                                alpha: 0.85,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.lemonChiffonDeep.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ACCEPT ORDER',
                                style: AppTheme.sans(
                                  size: acceptLabelFontSize,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(letterSpacing: 0.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () =>
                            context.push('/staff/order-details/${order.id}'),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: viewBtnVPad),
                          decoration: BoxDecoration(
                            color: _Palette.canvas,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Details',
                                style: AppTheme.sans(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: _Palette.textDark.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: _Palette.milanoRedDeep,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
