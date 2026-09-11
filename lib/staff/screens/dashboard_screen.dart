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
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the admin Menu Management, Staff, and Create Order screens exactly
/// (#8B1D1D primary / #F4C430 gold accent), so the Staff Dashboard now
/// reads as part of the same cohesive, professional brand instead of its
/// own one-off theme.
/// Used ONLY for this screen's restyle. Nothing here touches AppColors,
/// AppTheme, or any other file — pure UI enhancement, no logic changed
/// anywhere here.
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
/// BUGFIX (this pass): guarded the greeting name against an empty string.
/// Previously `firstName[0]` would throw a RangeError (index out of range)
/// if the staff member's `name` ever came back empty from the backend,
/// since ''.split(' ').first still returns '' and you can't index into an
/// empty string. That crash was identical on web and mobile since it's
/// Dart-level logic, not a layout/overflow issue. Fixed by falling back to
/// 'Staff' whenever the resolved name is empty, and by defensively guarding
/// the avatar-initial lookup itself. No other behavior changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Dark Maroon — primary brand color (Theme 1)
  static const Color milanoRed = Color(0xFF8B1D1D);
  static const Color milanoRedDeep = Color(0xFF5C1212);
  static const Color milanoRedLight = Color(0xFFA6302B);

  // Gold Glow — accent color (Theme 1)
  static const Color lemonChiffon = Color(0xFFF4C430);
  static const Color lemonChiffonDeep = Color(0xFFD4A017);

  // Soft Cream — canvas / background (Theme 1)
  static const Color canvas = Color(0xFFFDF6EC);
  static const Color canvasDeep = Color(0xFFF7ECD9);

  static const Color textDark = Color(0xFF2A1512);
  static const Color textMuted = Color(0xFF8B7F72);

  /// Shared soft resting-state shadow — matches the exact softShadow used
  /// on MenuScreen / StaffScreen / Create Order screen, so every card on
  /// this page carries the same warm, branded elevation.
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

  /// Navbar/header shadow stack — a rich three-layer shadow (deep maroon
  /// drop shadow + soft ambient gold bloom + fine black contact shadow)
  /// that gives the Dashboard hero real presence as a floating command
  /// surface rather than a flat banner.
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.34),
          blurRadius: 36,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Soft inner "glass" shadow used on the stats capsule inside the hero —
  /// pure decoration, gives the capsule a faint pressed-glass depth instead
  /// of a flat dark fill.
  static List<BoxShadow> get statCapsuleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ];

  /// Ring/halo glow used behind the hero avatar — a slightly richer,
  /// two-tone glow so the avatar reads as a clear focal point in the
  /// redesigned navbar.
  static List<BoxShadow> get avatarHalo => [
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.30),
          blurRadius: 20,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 4),
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
      // Full-screen, edge-to-edge treatment — hero banner now draws behind
      // the status bar, matching the Create Order / Menu screens' navbar.
      extendBodyBehindAppBar: true,
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
          // extra layer of depth so the cream backdrop doesn't read as flat
          // behind the hero, echoing the glass-highlight language used in
          // the hero itself.
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
          // Purely decorative soft gold/maroon glows, matching the same
          // "foggy" backdrop language used across the Menu/Staff/Create
          // Order screens so this full-screen dashboard feels like one
          // cohesive brand.
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
                    _Palette.lemonChiffon.withValues(alpha: 0.20),
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
              // ── Hero Greeting Banner (acts as the screen's navbar) ────────
              _DashboardHero(
                greeting: _getGreeting(),
                firstName: firstName,
                dateLabel: _todayLabel(),
                newOrdersCount: newOrdersCount,
                activeOrdersCount: activeOrdersCount,
                availableTablesCount: availableTablesCount,
              ),

              // ── Scrollable content ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 24 : 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    iconBg: _Palette.milanoRedDeep
                                        .withValues(alpha: 0.08),
                                    title: 'Create Order',
                                    description: 'Start a new table order',
                                    onTap: () => context.push(
                                      '/staff/create-order',
                                    ),
                                  ),
                                  _FeatureCard(
                                    icon: Icons.notifications_active_rounded,
                                    iconColor: const Color(0xFFD97706),
                                    iconBg: const Color(0xFFFFFBEB),
                                    title: 'New Orders',
                                    description: 'View incoming orders',
                                    badge: newOrdersCount > 0
                                        ? '$newOrdersCount'
                                        : null,
                                    onTap: () => context.push(
                                      '/staff/new-orders',
                                    ),
                                  ),
                                  _FeatureCard(
                                    icon: Icons.receipt_long_rounded,
                                    iconColor: const Color(0xFF0D9488),
                                    iconBg: const Color(0xFFF0FDFA),
                                    title: 'Active Orders',
                                    description: 'Manage live orders',
                                    badge: activeOrdersCount > 0
                                        ? '$activeOrdersCount'
                                        : null,
                                    onTap: () => context.push('/staff/orders'),
                                  ),
                                  _FeatureCard(
                                    icon: Icons.grid_view_rounded,
                                    iconColor: AppColors.slate600,
                                    iconBg: AppColors.slate50,
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
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF4ADE80),
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

// ─── Hero Greeting Banner (Staff Dashboard's "navbar") ─────────────────────
// Redesigned into its own distinctive "command bar" identity rather than a
// straight clone of the Menu header:
//   • A richer four-stop diagonal gradient surface (milanoRedLight →
//     milanoRed → milanoRedDeep → near-black maroon) for more tonal depth.
//   • A large, very faint watermark emblem (a restaurant glyph) sitting
//     behind the greeting text — a unique signature element this banner
//     didn't have before.
//   • The exact same bottom-corner radius (28 mobile / 38 desktop) and the
//     same three-layer `heroShadow` stack, so it still reads as part of
//     the same design system.
//   • A refined top row: the LIVE SYSTEM pill now has a soft pulsing halo
//     around its status dot, and the avatar sits inside a two-tone gold
//     ring with its own halo shadow.
//   • A bolder greeting block — bigger name type, a slim label row with a
//     small accent tick beside "GOOD MORNING," and an animated gold
//     underline that draws in on load.
//   • A rebuilt glass stats capsule: each stat now sits inside its own
//     soft icon badge, with slim vertical dividers between stats instead
//     of relying on padding alone — reads as a proper "readout strip"
//     rather than three icons in a row.
// No data, provider, or navigation logic was touched — every stat pill,
// avatar initial, and route still comes from the exact same values passed
// in from DashboardScreen.
class _DashboardHero extends StatelessWidget {
  final String greeting;
  final String firstName;
  final String dateLabel;
  final int newOrdersCount;
  final int activeOrdersCount;
  final int availableTablesCount;

  const _DashboardHero({
    required this.greeting,
    required this.firstName,
    required this.dateLabel,
    required this.newOrdersCount,
    required this.activeOrdersCount,
    required this.availableTablesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, giving the banner a
          // more "faceted" surface unique to this dashboard.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              Color(0xFF3A0B0B),
            ],
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: _Palette.heroShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background decorative glows — soft, ambient depth behind the
            // whole panel.
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
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
              bottom: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.milanoRedLight.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Soft radial glow anchored behind the greeting text block —
            // adds depth without touching layout.
            Positioned(
              top: 70,
              left: -40,
              child: Container(
                width: 260,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.lemonChiffon.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Extra ambient gold glow, lower-right — a fuller, richer
            // backdrop behind the stats capsule.
            Positioned(
              bottom: -90,
              right: -30,
              child: Container(
                width: 220,
                height: 220,
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

            // ── Large faint watermark emblem — a unique signature touch
            // this banner didn't previously have, giving it its own
            // identity beyond a plain gradient card. Sits low-opacity and
            // large behind the greeting text, never competing with copy.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -20 : -10,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: isMobile ? 150 : 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Subtle decorative diagonal ribbon accents — the same brand
            // language used on the Menu/Staff/Create Order navbar headers,
            // with a third ribbon added for extra texture.
            Positioned(
              top: -50,
              left: -40,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 200,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: 180,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 40,
              child: Transform.rotate(
                angle: 0.7,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used across the admin headers.
            Positioned(
              top: 6,
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

            // Fine glass highlight line along the very top edge, giving the
            // full-width panel a polished, "premium glass" finish.
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

            // Extra soft corner glows tucked behind each top corner —
            // frames the panel's full width with a touch more depth.
            Positioned(
              top: -20,
              left: -20,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
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
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Brand status + date pill + avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Status dot with a soft pulsing halo
                                  // ring around it — a subtle, purely
                                  // decorative "alive" cue.
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(
                                            0xFF4ADE80,
                                          ).withValues(alpha: 0.18),
                                        ),
                                      )
                                          .animate(
                                            onPlay: (c) => c.repeat(
                                              reverse: true,
                                            ),
                                          )
                                          .scale(
                                            begin: const Offset(0.6, 0.6),
                                            end: const Offset(1.15, 1.15),
                                            duration: 1400.ms,
                                            curve: Curves.easeInOut,
                                          ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4ADE80),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4ADE80)
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'LIVE SYSTEM',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isMobile) ...[
                              const SizedBox(width: 10),
                              // Floating date pill — same treatment as the
                              // date chip used on the Menu/Create Order
                              // screens' headers.
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _Palette.lemonChiffon.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: _Palette.lemonChiffon.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      dateLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Avatar — now sits inside a two-tone gold ring with
                        // its own halo shadow, reading as the clear focal
                        // point of the top row.
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _Palette.lemonChiffon.withValues(alpha: 0.9),
                                _Palette.lemonChiffonDeep.withValues(
                                  alpha: 0.5,
                                ),
                              ],
                            ),
                            boxShadow: _Palette.avatarHalo,
                          ),
                          padding: const EdgeInsets.all(2.4),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _Palette.milanoRedDeep,
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  _Palette.lemonChiffon.withValues(alpha: 0.25),
                              child: Text(
                                // BUGFIX: firstName is guaranteed non-empty
                                // by the caller now (falls back to 'Staff'),
                                // but this stays defensive in case firstName
                                // is ever passed in directly from elsewhere.
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _Palette.lemonChiffon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 600.ms).slideY(begin: -0.2),

                    const SizedBox(height: 18),

                    // Greeting Section — accent tick + label → big name →
                    // animated gold divider → subtitle.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _Palette.lemonChiffon,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              '${greeting.toUpperCase()},',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _Palette.lemonChiffon,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          firstName,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: isMobile ? 30 : 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title underline that draws in on load — same
                        // gold gradient as before, now with an entrance
                        // animation for a touch more polish.
                        Container(
                          width: 64,
                          height: 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                _Palette.lemonChiffon.withValues(alpha: 0.9),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fade(duration: 500.ms, delay: 250.ms)
                            .scaleX(
                              begin: 0,
                              end: 1,
                              alignment: Alignment.centerLeft,
                              duration: 500.ms,
                              delay: 250.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 8),
                        Text(
                          "Here's your live restaurant overview",
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                        if (isMobile) ...[
                          const SizedBox(height: 12),
                          // On mobile the date pill drops below the
                          // subtitle instead of sitting in the top row, so
                          // it never crowds the LIVE SYSTEM badge.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _Palette.lemonChiffon.withValues(
                                  alpha: 0.25,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 10,
                                  color: _Palette.lemonChiffon.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  dateLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: -0.1),

                    const SizedBox(height: 20),

                    // Live Stats Row — rebuilt as a "readout strip": each
                    // stat sits inside its own icon badge, with slim
                    // vertical dividers between stats instead of relying
                    // purely on padding, plus a refined glass shadow.
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.24),
                            Colors.black.withValues(alpha: 0.16),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                        boxShadow: _Palette.statCapsuleShadow,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatPill(
                              icon: Icons.receipt_long_rounded,
                              value: '$activeOrdersCount',
                              label: 'Active',
                            ),
                            const _StatDivider(),
                            _StatPill(
                              icon: Icons.notifications_active_rounded,
                              value: '$newOrdersCount',
                              label: 'New',
                              isAlert: newOrdersCount > 0,
                            ),
                            const _StatDivider(),
                            _StatPill(
                              icon: Icons.grid_view_rounded,
                              value: '$availableTablesCount',
                              label: 'Tables Free',
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.2),
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

// Slim vertical divider used between stat pills in the redesigned "readout
// strip" — purely decorative spacing element, no logic.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withValues(alpha: 0.10),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isAlert;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 250.ms,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isAlert
            ? _Palette.lemonChiffon.withValues(alpha: 0.92)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isAlert
            ? [
                BoxShadow(
                  color: _Palette.lemonChiffonDeep.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon now sits inside its own small round badge instead of
          // floating bare, so each stat reads as a distinct "readout"
          // module rather than a plain icon+text pairing.
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAlert
                  ? _Palette.milanoRedDeep.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.10),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isAlert ? _Palette.milanoRedDeep : _Palette.lemonChiffon,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.sans(
                  size: 16,
                  weight: FontWeight.w900,
                  color: isAlert ? _Palette.milanoRedDeep : Colors.white,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: AppTheme.sans(
                  size: 9,
                  weight: FontWeight.w700,
                  color: isAlert
                      ? _Palette.milanoRedDeep.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
