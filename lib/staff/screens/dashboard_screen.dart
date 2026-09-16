import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/auth_provider.dart';
import '../contexts/orders_provider.dart';
import '../contexts/tables_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local color palette for this screen's restyle. Nothing here touches
/// AppColors, AppTheme, or any other file — pure UI enhancement, no logic
/// changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the hero banner (this screen's navbar) has been
/// pushed further beyond a straight Menu-header clone into its own
/// distinctive "command bar" identity — a faceted, multi-layer gradient
/// surface with a large faint watermark emblem, a refined pill/avatar
/// header row, a bolder greeting block with an animated gold underline,
/// and a redesigned glass stats capsule with individually badged icons and
/// slim dividers between each stat. The full-screen backdrop behind the
/// scroll content also gained an extra layer of depth (a soft diagonal
/// sheen + more varied ambient glows) so the whole page feels like one
/// considered, premium surface rather than a plain cream background with a
/// banner on top.
///
/// UI-ENHANCEMENT PASS 3: the Quick Actions feature cards were rebuilt for
/// a more compact, premium "tile" feel — shorter overall height, a subtle
/// top accent rail in the card's own icon color, a soft ring around the
/// icon badge, a refined floating badge, and a small animated arrow chip
/// that reveals on hover/press so each tile reads as a clear, tappable
/// action rather than a static panel. Nothing here touches any provider,
/// controller, route, or data value — every stat pill, avatar initial, and
/// route still comes from the exact same values passed in from
/// DashboardScreen. Only Container/Decoration/TextStyle-level presentation
/// changed.
///
/// Note: order-status badges (pending/preparing/ready/served) and the
/// success/danger indicators keep their original semantic colors, since
/// those carry functional meaning rather than brand styling.
///
/// BUGFIX: guarded the greeting name against an empty string. Previously
/// `firstName[0]` would throw a RangeError (index out of range) if the
/// staff member's `name` ever came back empty from the backend, since
/// ''.split(' ').first still returns '' and you can't index into an empty
/// string. That crash was identical on web and mobile since it's Dart-level
/// logic, not a layout/overflow issue. Fixed by falling back to 'Staff'
/// whenever the resolved name is empty, and by defensively guarding the
/// avatar-initial lookup itself. No other behavior changed.
///
/// COLOR-THEME PASS ("Milano Red/Wine × Golden Chiffon × White") — this
/// pass: swapped the underlying color values in `_Palette` for a deep
/// Milano red/wine primary, a golden/yellow-chiffon accent, and a
/// background/surface palette that leans **majorly white** rather than
/// warm cream, matching the same request already applied to the Login,
/// Menu, and Orders screens so every part of the app shares one brand
/// identity. Every field name below (`milanoRed`, `milanoRedDeep`,
/// `milanoRedLight`, `lemonChiffon`, `lemonChiffonDeep`, `canvas`,
/// `canvasDeep`, etc.) is unchanged on purpose, since every other widget in
/// this file already reads from these exact names — only the `Color`
/// values themselves were updated. No data, provider, or navigation logic
/// was touched anywhere in this pass — presentation only.
///
/// UI-ENHANCEMENT PASS 4: the hero banner (`_DashboardHero`) was rebuilt
/// from a heavy, dark, multi-layer gradient "command bar" into a clean,
/// light, standard mobile top bar in the spirit of a payments-app home
/// screen — a slim greeting row (small wine/gold-ringed avatar top-right,
/// "Good Morning, {name}" on the left) laid directly on the app's own
/// majorly-white canvas, with NO search bar added. The live-stats readout
/// strip beneath it is kept (still the same `activeOrdersCount` /
/// `newOrdersCount` / `availableTablesCount` values) but restyled from a
/// dark glass capsule into light, softly-tinted stat chips so it reads as
/// part of the same white surface instead of a separate dark panel. No
/// data, provider, or navigation logic was touched — every stat value,
/// avatar initial, and route still comes from the exact same values passed
/// in from `DashboardScreen`.
///
/// UI-ENHANCEMENT PASS 5 (full-screen color consistency): the three
/// Quick Action tiles other than "Create Order" ("New Orders", "Active
/// Orders", "Tables") previously used ad-hoc, off-brand colors that
/// didn't belong to the shared palette used everywhere else on this
/// screen. Their `iconColor` / `iconBg` values were swapped for colors
/// drawn from the exact same `_Palette` already used by the hero, the
/// stat pills, the Active Orders panel, and the mini order cards. The
/// order-status colors inside `_MiniOrderCard` (pending/preparing/ready/
/// served) and the green "available tables" badge color are left exactly
/// as they were, since those convey functional/semantic meaning rather
/// than brand styling. Every `onTap`, badge value, route, and data value
/// passed into these cards is byte-for-byte unchanged — only the color
/// arguments changed.
///
/// PASS 6 / PASS 7: iterative visual refinements to the hero top bar
/// (gradient warmth, accent dots, illustration banner) — no data,
/// provider, or navigation logic touched at any point.
///
/// COLOR-THEME PASS 8 ("PUREDINE Maroon + Cream" palette):
/// zero changes to data, provider, navigation, or any field/class name in
/// this file — every stat value, avatar initial, badge value, route, and
/// status color mapping is still byte-for-byte what it was before. Only
/// two things changed, both purely presentational:
///   1. `_Palette`'s underlying `Color` values were swapped for the new
///      PUREDINE Maroon + Cream brand palette (Deep Wine Maroon, Wine,
///      Burgundy, Warm Off-White, Soft Cream, Warm Gold, Soft Yellow,
///      Deep Brown/Black, Muted Taupe, Fresh Green) — every field name
///      (`milanoRed`, `milanoRedDeep`, `milanoRedLight`, `lemonChiffon`,
///      `lemonChiffonDeep`, `canvas`, `canvasDeep`, `textDark`,
///      `textMuted`) is unchanged on purpose, since the rest of this file
///      already reads from these exact names. Three small additional
///      palette constants (`dustyBlush`, `paleRose`, `paleMint`,
///      `freshGreen`) were added purely as extra brand tints — nothing
///      existing was renamed or removed.
///   2. `_DashboardHero` was restyled from the light payments-app top bar
///      back into a rich, dark maroon-to-wine gradient banner (per the
///      requested reference look), with the greeting, tagline banner,
///      date/live row, and live-stats readout all re-themed for a dark
///      backdrop. The three live stats now render as individual white
///      "readout" cards rather than one pill strip. No prop, callback,
///      value, or route inside the hero changed — only how it's painted.
///
/// UI-ENHANCEMENT PASS 9: the three live-stat readouts ("Active", "New",
/// "Tables Free") were pulled out of `_DashboardHero` into their own
/// `_StatsRow` / `_StatCard` widgets. This is a pure layout relocation:
///   • `_DashboardHero` no longer takes `activeOrdersCount` /
///     `newOrdersCount` / `availableTablesCount` as props — it never used
///     them for anything but painting the old in-banner stats row, which
///     has been removed from the hero entirely.
///   • `DashboardScreen.build()` still computes the exact same
///     `activeOrdersCount`, `newOrdersCount`, and `availableTablesCount`
///     values from the exact same providers, in the exact same order —
///     they're simply now passed to `_StatsRow` instead of the hero.
///   • No onTap, route, provider call, or badge/count value changed
///     anywhere in this pass.
///
/// UI-ENHANCEMENT PASS 10: PASS 9 floated `_StatsRow` in a `Stack` with a
/// negative bottom offset, so it still visually overlapped the hero's
/// rounded bottom edge. Per the request to have the three stat boxes sit
/// **fully outside** the top bar, that overlap was removed:
/// `_DashboardHero` and `_StatsRow` became simple, non-overlapping
/// siblings in the page's `Column` — the hero rendered completely, then
/// the stats row rendered entirely below it on the plain white canvas,
/// with normal spacing (no negative offsets, no `Stack`/`Positioned`, no
/// `Clip.none`). Same three values, same order, same `_StatsRow`/
/// `_StatCard` widgets — only the positioning changed from "floating over
/// the hero edge" to "fully below the hero".
///
/// UI-ENHANCEMENT PASS 11: PASS 10 still kept `_StatsRow` as a *fixed*,
/// non-scrolling sibling between the hero and the
/// `Expanded`/`SingleChildScrollView`, so only the "Quick Actions" grid and
/// everything below it actually scrolled. Per the request for the
/// scrollbar/scrollable region to begin exactly where the three stat boxes
/// start, `_StatsRow` has been moved to be the *first* child inside the
/// scrollable `Column` (immediately above the "QUICK ACTIONS" section
/// label), instead of being a fixed sibling of the hero. Only
/// `_DashboardHero` remains fixed/non-scrolling now — everything from the
/// stats row downward (stats, quick actions, active orders) scrolls
/// together as one unit. Same three values
/// (`activeOrdersCount`/`newOrdersCount`/`availableTablesCount`), same
/// `_StatsRow`/`_StatCard` widgets, same padding/max-width treatment —
/// only which container it lives inside (fixed vs. scrollable) changed.
///
/// UI-ENHANCEMENT PASS 12 (this pass — straight-bottomed top bar,
/// matching MenuScreen's header): a single, purely presentational change
/// to `_DashboardHero`'s own outer `Container` — no data, provider,
/// navigation, prop, or callback anywhere in this file was touched, and
/// nothing about `_StatsRow`, the Quick Actions grid, or the Active
/// Orders section changed.
///   • The hero's outer `Container` previously rounded its bottom-left
///     and bottom-right corners (`Radius.circular(32)`) and cast its own
///     `heroShadow` drop shadow below that curved edge. `MenuScreen`'s
///     `_buildCustomHeader()` top bar, by contrast, is a plain, full-
///     width, straight-edged band with no rounded corners and no shadow
///     bleeding past its bottom edge (see that screen's Pass 26/27
///     notes). To match that same flat top-bar shape here, the
///     `borderRadius` was removed from the decoration (so the bottom
///     edge is now a straight, flat line instead of curved) and the
///     `heroShadow` entry was removed along with it, so no colored
///     shadow spills down past the header into `_StatsRow`/the
///     scrollable content beneath it.
///   • The inner `ClipRRect` (which existed only to clip the ambient
///     decorative glows/wash to the same rounded corners) was swapped
///     for a plain `ClipRect`, since the header is no longer rounded —
///     it still clips those purely-decorative Positioned glows to the
///     header's own straight-edged bounds so nothing decorative bleeds
///     outside the band, exactly the same way `MenuScreen`'s header
///     clips its own ambient dressing to a plain rectangle.
///   • Everything else inside the hero — the greeting row, the avatar
///     and its halo glow, the tagline banner, the date/live row, and the
///     gold hairline beneath it — is completely unchanged: same text,
///     same values (`greeting`, `firstName`, `dateLabel`), same layout,
///     same animations.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Primary brand — PUREDINE Maroon + Cream. Field names are unchanged on
  // purpose — every widget below already reads from these exact names, so
  // only the underlying Color values change.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedDeep =
      Color(0xFF8A183F); // Burgundy (Primary accent / deep)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (topbar lighter gradient)

  // Gold accent family — matching the Menu/Orders screens.
  static const Color lemonChiffon =
      Color(0xFFFCE1AB); // Soft Yellow (Gold highlight)
  static const Color lemonChiffonDeep =
      Color(0xFFF3C564); // Warm Gold (Gold accent)

  // Majorly-white/cream canvas + background.
  static const Color canvas =
      Color(0xFFFBF8F5); // Warm Off-White (main background)
  static const Color canvasDeep =
      Color(0xFFF7F1ED); // Soft Cream (card background)

  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe

  // Extra brand tints from the PUREDINE palette — additive only, nothing
  // existing was renamed or removed to make room for these.
  static const Color dustyBlush = Color(0xFFF3D9DC); // Blush/Pink tint
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background
  static const Color freshGreen = Color(0xFF44AF70); // Live / Success

  /// Shared soft resting-state shadow — matches the exact softShadow used
  /// on MenuScreen / StaffScreen / Orders screen, so every card on this
  /// page carries the same warm, branded elevation.
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

  /// Shared elevated/hover glow — a slightly stronger, warmer shadow used
  /// for interactive/elevated elements, matching the Menu/Staff screens.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: lemonChiffonDeep.withValues(alpha: 0.28),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.16),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// PASS 12: kept defined for palette-shape parity even though
  /// `_DashboardHero` no longer uses it (see the Pass 12 note above) — a
  /// deeper, warmer drop shadow, previously used to separate the rounded
  /// hero banner from the cream content beneath it.
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

  /// Ring/halo glow used behind the hero avatar — a slightly richer,
  /// two-tone glow so the avatar reads as a clear focal point in the top
  /// bar.
  static List<BoxShadow> get avatarHalo => [
        BoxShadow(
          color: lemonChiffonDeep.withValues(alpha: 0.30),
          blurRadius: 14,
          spreadRadius: 0.5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];

  /// PASS 9: a dedicated, slightly stronger "floating card" shadow used by
  /// the stat cards now that they sit outside the hero, straddling the
  /// maroon banner and the white canvas — needs enough depth to read as
  /// clearly elevated against both backgrounds at once.
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 3),
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final tablesProvider = context.read<TablesProvider>();

    if (auth.token != null) {
      await Future.wait([
        ordersProvider.fetchOrders(auth.token!),
        tablesProvider.fetchTables(auth.token!),
      ]);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final auth = context.watch<StaffAuthProvider>();
    final tablesProvider = context.watch<TablesProvider>();

    final recentOrders = ordersProvider.activeOrders.take(4).toList();
    final newOrdersCount = ordersProvider.newOrders.length;
    final activeOrdersCount = ordersProvider.activeOrders.length;
    final availableTablesCount = tablesProvider.tables
        .where((t) => t.status == TableStatus.available)
        .length;

    // BUGFIX: fall back to 'Staff' not just when auth.user?.name is null,
    // but also when it's an empty/whitespace-only string. Previously
    // `''.split(' ').first` still returned '', and `firstName[0]` on that
    // empty string threw a RangeError — a crash that showed up identically
    // on web and mobile any time a staff record had a blank name.
    final rawName = auth.user?.name.trim() ?? '';
    final userName = rawName.isNotEmpty ? rawName : 'Staff';
    final firstName = userName.split(' ').first;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // Soft ambient gradient wash behind everything
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _Palette.canvasDeep.withValues(alpha: 0.6),
                    _Palette.canvas,
                    _Palette.canvas,
                  ],
                  stops: const [0.0, 0.25, 1.0],
                ),
              ),
            ),
          ),

          // Faint diagonal sheen sweeping across the whole page — a subtle
          // extra layer of depth so the white backdrop doesn't read as flat.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative soft gold/wine glows, matching the same
          // "foggy" backdrop language used across the Menu/Staff/Orders
          // screens so this full-screen dashboard feels like one cohesive
          // brand.
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _Palette.lemonChiffonDeep.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -90,
            child: Container(
              width: 320,
              height: 320,
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
            top: 320,
            right: -130,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _Palette.lemonChiffonDeep.withValues(alpha: 0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Extra low, wide glow near the middle of the page — gives the
          // long scroll area a second soft focal point instead of all the
          // ambient light sitting only near the hero.
          Positioned(
            top: 560,
            left: -60,
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

          // Subtle background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          Column(
            children: [
              // ── Hero Greeting Banner (acts as the screen's top bar) ──────
              // PASS 11: this is now the ONLY fixed/non-scrolling element
              // on the page — `_StatsRow` moved into the scrollable
              // content below (see the comment above the scroll view) so
              // the scrollable area begins exactly where the three stat
              // boxes start.
              // PASS 12: the hero itself is now a straight, flat-bottomed
              // band (no rounded corners, no bleeding drop shadow),
              // matching MenuScreen's `_buildCustomHeader()` shape — see
              // the Pass 12 note above `_Palette` for details. Its props
              // (`greeting`, `firstName`, `dateLabel`) are unchanged.
              _DashboardHero(
                greeting: _getGreeting(),
                firstName: firstName,
                dateLabel: _todayLabel(),
              ),

              // ── Scrollable content ────────────────────────────────────────
              // PASS 11: `_StatsRow` is now the first child inside this
              // scrollable Column (see immediately below), so the
              // scrollbar/scrollable region starts right where the three
              // stat boxes start, and they scroll together with Quick
              // Actions / Active Orders beneath them.
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 16 : 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Live Stats Row — first thing in the scroll
                          // view, so it's exactly where scrolling begins.
                          // Same three values (`activeOrdersCount` /
                          // `newOrdersCount` / `availableTablesCount`),
                          // same order, same `_StatsRow`/`_StatCard`
                          // widgets as every prior pass — only its
                          // container (scrollable vs. fixed) changed.
                          _StatsRow(
                            activeOrdersCount: activeOrdersCount,
                            newOrdersCount: newOrdersCount,
                            availableTablesCount: availableTablesCount,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: isMobile ? 24 : 32),

                          // ── Section label ──
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      _Palette.milanoRedLight,
                                      _Palette.milanoRed,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'QUICK ACTIONS',
                                style: AppTheme.sans(
                                  color: _Palette.textMuted,
                                  size: 11,
                                  weight: FontWeight.w900,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _Palette.milanoRedDeep
                                            .withValues(alpha: 0.12),
                                        _Palette.lemonChiffonDeep
                                            .withValues(alpha: 0.10),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ── Feature Grid ──────────────────────────────────
                          // Cards are now shorter (higher aspect ratio) and
                          // individually restyled inside _FeatureCard for a
                          // more compact, premium tile look.
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              int crossAxisCount = 2;
                              if (width >= 1024) {
                                crossAxisCount = 4;
                              } else if (width >= 600) {
                                crossAxisCount = 2;
                              }

                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: isMobile ? 12 : 20,
                                mainAxisSpacing: isMobile ? 12 : 20,
                                childAspectRatio: isMobile ? 1.15 : 1.05,
                                children: [
                                  _FeatureCard(
                                    icon: Icons.add_shopping_cart_rounded,
                                    iconColor: _Palette.milanoRedDeep,
                                    iconBg: _Palette.dustyBlush
                                        .withValues(alpha: 0.55),
                                    title: 'Create Order',
                                    description: 'Start a new table order',
                                    onTap: () => context.push(
                                      '/staff/create-order',
                                    ),
                                  ),
                                  // PASS 5 / PASS 8: drawn from the same
                                  // Warm Gold / Soft Yellow family used
                                  // across the rest of the screen.
                                  _FeatureCard(
                                    icon: Icons.notifications_active_rounded,
                                    iconColor: _Palette.lemonChiffonDeep,
                                    iconBg: _Palette.lemonChiffon
                                        .withValues(alpha: 0.55),
                                    title: 'New Orders',
                                    description: 'View incoming orders',
                                    badge: newOrdersCount > 0
                                        ? '$newOrdersCount'
                                        : null,
                                    onTap: () => context.push(
                                      '/staff/new-orders',
                                    ),
                                  ),
                                  // PASS 5 / PASS 8: a lighter Milano
                                  // Red/Wine tone, matching
                                  // `milanoRedLight` used elsewhere on
                                  // this screen (section-label accent,
                                  // ambient glow, avatar halo).
                                  _FeatureCard(
                                    icon: Icons.receipt_long_rounded,
                                    iconColor: _Palette.milanoRedLight,
                                    iconBg: _Palette.paleRose
                                        .withValues(alpha: 0.65),
                                    title: 'Active Orders',
                                    description: 'Manage live orders',
                                    badge: activeOrdersCount > 0
                                        ? '$activeOrdersCount'
                                        : null,
                                    onTap: () => context.push('/staff/orders'),
                                  ),
                                  // PASS 5 / PASS 8: now a soft Pale Mint
                                  // tile (per the reference look) with a
                                  // deep wine icon. The "N free" badge
                                  // color stays AppColors.success (green),
                                  // since it conveys the same functional
                                  // "available" meaning the order-status
                                  // badges carry elsewhere in the app.
                                  _FeatureCard(
                                    icon: Icons.grid_view_rounded,
                                    iconColor: _Palette.milanoRedDeep,
                                    iconBg: _Palette.paleMint,
                                    title: 'Tables',
                                    description: 'Floor plan overview',
                                    badge: availableTablesCount > 0
                                        ? '$availableTablesCount free'
                                        : null,
                                    badgeColor: AppColors.success,
                                    onTap: () => context.push('/staff/tables'),
                                  ),
                                ]
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => e.value
                                          .animate(
                                            delay: Duration(
                                              milliseconds: e.key * 80,
                                            ),
                                          )
                                          .fade(duration: 400.ms)
                                          .slideY(
                                            begin: 0.15,
                                            end: 0,
                                            duration: 400.ms,
                                            curve: Curves.easeOutQuad,
                                          ),
                                    )
                                    .toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // ── Active Orders Section ─────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              // Slightly tighter radius than before (28
                              // instead of 40) so the panel sits cleanly on
                              // narrow/mobile widths without looking
                              // over-rounded, while still matching the
                              // softer, friendlier corners used across the
                              // Menu/Staff cards.
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                              boxShadow: _Palette.softShadow,
                            ),
                            padding: EdgeInsets.all(isMobile ? 20 : 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _Palette.freshGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                'Active Orders',
                                                style: AppTextStyles.headline(
                                                  color: _Palette.textDark,
                                                  size: isMobile ? 20 : 24,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Small brand-accent divider,
                                          // mirroring the gold underline
                                          // used beneath titles on the
                                          // Menu/Staff navbars.
                                          Container(
                                            width: 40,
                                            height: 2.5,
                                            margin: const EdgeInsets.only(
                                              left: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              gradient: LinearGradient(
                                                colors: [
                                                  _Palette.lemonChiffonDeep
                                                      .withValues(alpha: 0.55),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Live dining room updates',
                                            style: AppTheme.sans(
                                              color: _Palette.textMuted,
                                              size: isMobile ? 12 : 13,
                                              weight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GoldButton(
                                      label: isMobile ? 'All' : 'View All',
                                      icon: Icons.arrow_forward_rounded,
                                      onTap: () =>
                                          context.push('/staff/orders'),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                if (recentOrders.isEmpty)
                                  const EmptyState(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'No active orders',
                                    subtitle: 'Live orders will appear here',
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int cols = 1;
                                      if (constraints.maxWidth >= 1200) {
                                        cols = 4;
                                      } else if (constraints.maxWidth >= 900) {
                                        cols = 3;
                                      } else if (constraints.maxWidth >= 600) {
                                        cols = 2;
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: cols,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                          childAspectRatio:
                                              isMobile ? 2.1 : 1.6,
                                        ),
                                        itemCount: recentOrders.length,
                                        itemBuilder: (ctx, i) => _MiniOrderCard(
                                          order: recentOrders[i],
                                        )
                                            .animate(
                                              delay: Duration(
                                                milliseconds: i * 60,
                                              ),
                                            )
                                            .fade(duration: 300.ms)
                                            .slideY(
                                              begin: 0.1,
                                              end: 0,
                                              duration: 300.ms,
                                            ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 300.ms)
                              .slideY(
                                begin: 0.05,
                                duration: 500.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          const SizedBox(height: 24),
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
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ─── Hero Greeting Banner (Staff Dashboard's top bar) ──────────────────────
// PASS 9: this widget no longer receives or paints the live-stats readout
// (`newOrdersCount` / `activeOrdersCount` / `availableTablesCount`) — those
// now live outside the hero in `_StatsRow`.
// PASS 10: renders as a fully self-contained banner with no overlap from
// anything beneath it — `_StatsRow` is now a plain sibling below the hero
// (see `DashboardScreen.build()`), not positioned over its edge.
// PASS 12: the outer band is now straight-bottomed (no rounded corners, no
// bleeding `heroShadow`) to match `MenuScreen._buildCustomHeader()`'s flat
// top-bar shape — see the Pass 12 note above `_Palette` for the full
// rationale. Everything else about the hero is unchanged from PASS 8: a
// rich dark maroon-to-wine gradient banner — a greeting row (sun icon +
// "Good Morning" in gold, bold serif first name in white, top-right avatar
// with a white ring and a small live/green status dot), a floating cream
// tagline pill with a photo badge, and a light date/live row with a gold
// hairline beneath it. No data, provider, or navigation logic lives in
// this widget, same as every prior pass — the avatar's halo glow (already
// defined in `_Palette`) is applied for a touch more depth.
class _DashboardHero extends StatelessWidget {
  final String greeting;
  final String firstName;
  final String dateLabel;

  const _DashboardHero({
    required this.greeting,
    required this.firstName,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      // PASS 12: straight, flat bottom edge — matching MenuScreen's
      // `_buildCustomHeader()`, which is a plain full-width band with no
      // rounded corners and no bleeding drop shadow beneath it. The
      // previous bottomLeft/bottomRight 32px rounding and the separate
      // `heroShadow` (which cast a soft shadow past the header's curved
      // edge) have both been removed so this top bar reads as a clean,
      // straight-bottomed band exactly like the Menu screen's header.
      decoration: const BoxDecoration(
        // Rich dark maroon-to-wine gradient, matching the reference look —
        // Deep Wine Maroon at the top-left fading into the lighter Wine
        // tone toward the bottom-right.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // A subtle deeper-wine wash toward the bottom, so content near
            // the hero's lower edge reads clearly against the darkest part
            // of the banner.
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
            // content — purely decorative, mirroring the ambient-glow
            // language used across the rest of the page.
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
                        _Palette.lemonChiffonDeep.withValues(alpha: 0.22),
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
                        _Palette.lemonChiffon.withValues(alpha: 0.10),
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
                  isMobile ? 18 : 32,
                  isMobile ? 14 : 20,
                  isMobile ? 18 : 32,
                  // PASS 10: a normal, comfortable bottom padding — the
                  // hero no longer needs to reserve extra room for an
                  // overlapping stats row beneath it, since `_StatsRow`
                  // now sits fully outside/below the hero as a plain
                  // sibling.
                  isMobile ? 24 : 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: greeting (left) + avatar (right) ──────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 15,
                                    color: _Palette.lemonChiffon,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    greeting,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _Palette.lemonChiffon,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                firstName,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: isMobile ? 30 : 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Avatar — white-ringed circle, top-right, with a
                        // small live/green status dot overlapping its
                        // bottom-right edge. PASS 9: re-applies the
                        // `_Palette.avatarHalo` glow so the avatar reads
                        // as a clear focal point against the gradient.
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  width: 1.6,
                                ),
                                boxShadow: _Palette.avatarHalo,
                              ),
                              padding: const EdgeInsets.all(2.5),
                              child: CircleAvatar(
                                radius: isMobile ? 24 : 27,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.12),
                                child: Text(
                                  firstName.isNotEmpty
                                      ? firstName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: isMobile ? 19 : 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _Palette.freshGreen,
                                  border: Border.all(
                                    color: _Palette.milanoRedLight,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.15),

                    SizedBox(height: isMobile ? 16 : 20),

                    // ── Tagline banner ──────────────────────────────────────
                    // Floating cream pill on the dark maroon backdrop —
                    // fork/knife icon badge, tagline, a circular photo
                    // badge, and a trailing chevron. Purely decorative: if
                    // the image can't load, `errorBuilder` falls back to a
                    // plain restaurant-service icon instead — no data,
                    // callback, or navigation logic lives in this banner.
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: isMobile ? 10 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: _Palette.canvasDeep.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: isMobile ? 36 : 42,
                            height: isMobile ? 36 : 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _Palette.dustyBlush,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: isMobile ? 17 : 19,
                              color: _Palette.milanoRedDeep,
                            ),
                          ),
                          SizedBox(width: isMobile ? 10 : 14),
                          Expanded(
                            child: Text(
                              'Serve every table, seamlessly.',
                              style: GoogleFonts.playfairDisplay(
                                color: _Palette.textDark,
                                fontSize: isMobile ? 14.5 : 17,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: isMobile ? 10 : 14),
                          Container(
                            width: isMobile ? 40 : 48,
                            height: isMobile ? 40 : 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _Palette.lemonChiffonDeep
                                    .withValues(alpha: 0.7),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://images.unsplash.com/photo-1600891964092-4316c288032e?q=80&w=300&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: _Palette.milanoRedDeep,
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.5,
                            ),
                            size: 20,
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(
                          begin: 0.1,
                        ),

                    SizedBox(height: isMobile ? 14 : 18),

                    // ── Date + Live row ──────────────────────────────────────
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
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 11.5 : 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _Palette.freshGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: _Palette.freshGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 10 : 12),

                    // Thin gold gradient hairline underneath the date row.
                    Container(
                      width: 46,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.9),
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.15),
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
    );
  }
}

// ─── Live Stats Row (fully outside the hero) ───────────────────────────────
// PASS 9: this is the new home for the three live-stat readouts that used
// to render inside `_DashboardHero`. `_StatsRow` is a thin layout wrapper
// around three `_StatCard`s.
// PASS 10: `DashboardScreen.build()` now places it as a plain sibling
// directly below the hero (no `Stack`/`Positioned`/negative offset), so it
// sits entirely on the white canvas with zero overlap of the top bar. Same
// three values, same order, same semantics as before: no data, provider,
// or navigation logic lives here.
class _StatsRow extends StatelessWidget {
  final int activeOrdersCount;
  final int newOrdersCount;
  final int availableTablesCount;
  final bool isMobile;

  const _StatsRow({
    required this.activeOrdersCount,
    required this.newOrdersCount,
    required this.availableTablesCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_rounded,
            value: '$activeOrdersCount',
            label: 'Active',
            iconBg: _Palette.paleRose,
            iconColor: _Palette.milanoRedDeep,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.notifications_active_rounded,
            value: '$newOrdersCount',
            label: 'New',
            isAlert: newOrdersCount > 0,
            iconBg: _Palette.lemonChiffonDeep,
            iconColor: _Palette.textDark,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.grid_view_rounded,
            value: '$availableTablesCount',
            label: 'Tables Free',
            iconBg: _Palette.dustyBlush,
            iconColor: _Palette.milanoRedDeep,
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.25);
  }
}

// ─── Individual Stat Card ───────────────────────────────────────────────────
// PASS 9: replaces the old in-hero `_StatPill` (which rendered icon-on-top,
// number-below in a small dark-panel chip). This card is a horizontal
// icon + value/label layout on its own white (or, when `isAlert` is true,
// warm-gold) rounded card with a floating drop shadow — designed to read
// clearly whether it's sitting over the dark hero or the white canvas
// beneath it.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isAlert;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isAlert
            ? _Palette.lemonChiffon.withValues(alpha: 0.65)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAlert
              ? _Palette.lemonChiffonDeep.withValues(alpha: 0.45)
              : _Palette.milanoRedDeep.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: _Palette.floatingShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.sans(
                    size: 19,
                    weight: FontWeight.w900,
                    color: _Palette.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label.toUpperCase(),
                  style: AppTheme.sans(
                    size: 9,
                    weight: FontWeight.w700,
                    color: _Palette.textMuted,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Card ──────────────────────────────────────────────────────────
// UI-ENHANCEMENT PASS 3: rebuilt as a shorter, more compact "premium tile":
//   • A slim top accent rail rendered in the card's own icon color — gives
//     each tile a distinct brand identity at a glance, before you even
//     read the title.
//   • The icon badge now sits inside a soft ring border (instead of a
//     plain flat block), with a tighter footprint so the card needs less
//     vertical room overall.
//   • The floating count/status badge moved to overlap the top-right
//     corner of the icon badge as a small circular chip, instead of taking
//     up its own row — this alone saves meaningful height.
//   • A small circular "go" arrow chip appears bottom-right on hover/press,
//     making the tile read as clearly tappable/interactive.
//   • Title + description tightened to a single compact block.
// No data, callback, or navigation logic changed — onTap, badge value, and
// every color/icon are still exactly what DashboardScreen passes in.
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    final bool isElevated = _isHovered || _isPressed;
    final Color accent = widget.badgeColor ?? widget.iconColor;

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
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: 150.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: 200.ms,
            curve: Curves.easeOut,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  isElevated
                      ? _Palette.canvasDeep.withValues(alpha: 0.5)
                      : Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(isSmall ? 22 : 28),
              border: Border.all(
                color: isElevated
                    ? _Palette.milanoRedDeep.withValues(alpha: 0.4)
                    : _Palette.milanoRedDeep.withValues(alpha: 0.08),
                width: isElevated ? 1.6 : 1.5,
              ),
              boxShadow: isElevated ? _Palette.glowShadow : _Palette.softShadow,
            ),
            child: Stack(
              children: [
                // Slim top accent rail in the card's own icon color — an
                // instant brand cue for each tile, purely decorative.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.65),
                          accent.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ),

                // Very soft corner glow behind the icon, in the icon's own
                // color, for a touch more depth without adding height.
                Positioned(
                  top: -20,
                  left: -20,
                  child: IgnorePointer(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.iconColor.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmall ? 14 : 20,
                    isSmall ? 16 : 20,
                    isSmall ? 14 : 20,
                    isSmall ? 12 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon badge (with soft ring) + overlapping count chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: isSmall ? 42 : 50,
                                height: isSmall ? 42 : 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.iconBg,
                                      widget.iconBg.withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(isSmall ? 14 : 16),
                                  border: Border.all(
                                    color: widget.iconColor.withValues(
                                      alpha: 0.18,
                                    ),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.iconColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.iconColor,
                                  size: isSmall ? 20 : 24,
                                ),
                              ),
                              // Overlapping count/status chip — replaces the
                              // old full-width badge row to keep the card
                              // short while still surfacing the same value.
                              if (widget.badge != null)
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.badgeColor ??
                                          _Palette.milanoRed,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.6,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (widget.badgeColor ??
                                                  _Palette.milanoRed)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.badge!,
                                      textAlign: TextAlign.center,
                                      style: AppTheme.sans(
                                        size: 9,
                                        weight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          // Small circular "go" chip — reveals on hover or
                          // press so the tile reads as clearly tappable.
                          AnimatedOpacity(
                            duration: 180.ms,
                            opacity: isElevated ? 1 : 0,
                            child: AnimatedSlide(
                              duration: 180.ms,
                              curve: Curves.easeOut,
                              offset: isElevated
                                  ? Offset.zero
                                  : const Offset(-0.15, 0),
                              child: Container(
                                width: isSmall ? 24 : 28,
                                height: isSmall ? 24 : 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_outward_rounded,
                                  size: isSmall ? 13 : 15,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmall ? 10 : 14),

                      // Text content — title + single-line description,
                      // tightened up so the whole tile needs less height.
                      Text(
                        widget.title,
                        style: AppTextStyles.title(
                          color: _Palette.textDark,
                          size: isSmall ? 14 : 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: AppTextStyles.body(
                          color: _Palette.textMuted,
                          size: isSmall ? 10.5 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

// ─── Mini Order Card ───────────────────────────────────────────────────────
class _MiniOrderCard extends StatelessWidget {
  final Order order;
  const _MiniOrderCard({required this.order});

  _StatusConfig _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return const _StatusConfig(
          label: 'PENDING',
          bg: Color(0xFFFEF3C7),
          color: Color(0xFFD97706),
          leftBar: Color(0xFFF59E0B),
        );
      case OrderStatus.preparing:
        return const _StatusConfig(
          label: 'PREPARING',
          bg: Color(0xFFDBEAFE),
          color: Color(0xFF2563EB),
          leftBar: Color(0xFF3B82F6),
        );
      case OrderStatus.ready:
        return const _StatusConfig(
          label: 'READY',
          bg: Color(0xFFD1FAE5),
          color: Color(0xFF059669),
          leftBar: Color(0xFF10B981),
        );
      default:
        return const _StatusConfig(
          label: 'SERVED',
          bg: AppColors.slate100,
          color: AppColors.slate500,
          leftBar: AppColors.slate300,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(order.status);

    return GestureDetector(
      onTap: () => context.push('/staff/order-details/${order.id}'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
            ),
            boxShadow: _Palette.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Left accent bar carrying the status color
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 4,
                  color: config.leftBar,
                ),
              ),

              // Status corner accent
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: config.bg,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    config.label,
                    style: AppTheme.sans(
                      size: 9,
                      weight: FontWeight.w900,
                      color: config.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Number
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: _Palette.milanoRedDeep,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.table,
                                style: AppTextStyles.title(
                                  color: _Palette.textDark,
                                  size: 16,
                                ),
                              ),
                              if (order.customerName != null)
                                Text(
                                  order.customerName!,
                                  style: AppTheme.sans(
                                    size: 13,
                                    color: _Palette.textDark.withValues(
                                      alpha: 0.75,
                                    ),
                                    weight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                '#${order.id.substring(0, 6)}',
                                style: AppTheme.sans(
                                  size: 11,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: _Palette.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.time,
                                    style: AppTheme.sans(
                                      size: 11,
                                      color: _Palette.textMuted,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.06),
                    ),

                    // Details Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                              color: _Palette.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${order.items} items',
                              style: AppTheme.sans(
                                size: 12,
                                color: _Palette.textDark.withValues(
                                  alpha: 0.8,
                                ),
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${order.total.round()}',
                          style: AppTextStyles.numeric(
                            color: _Palette.textDark,
                            size: 18,
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
    );
  }
}

class _StatusConfig {
  final String label;
  final Color bg;
  final Color color;
  final Color leftBar;

  const _StatusConfig({
    required this.label,
    required this.bg,
    required this.color,
    required this.leftBar,
  });
}
