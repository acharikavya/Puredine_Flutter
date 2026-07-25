import 'package:flutter/material.dart';
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
/// anywhere here. The hero banner now carries the exact same richer
/// decorative language used on the Create Order screen's navbar (extra
/// ambient gold glow, layered shadow stack, a floating date pill, and a
/// full-screen edge-to-edge treatment), and every card on the page shares
/// the same two branded shadow presets for a consistent, premium feel
/// end to end.
///
/// Note: order-status badges (pending/preparing/ready/served) and the
/// success/danger indicators keep their original semantic colors, since
/// those carry functional meaning rather than brand styling.
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

  /// Richer navbar/header shadow stack — mirrors the exact three-layer
  /// shadow language introduced on the Create Order screen's header
  /// (deep maroon drop shadow + soft ambient gold bloom + fine black
  /// contact shadow) so the Dashboard hero now matches it 1:1.
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.42),
          blurRadius: 36,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.14),
          blurRadius: 44,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

const List<String> _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
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

    final userName = auth.user?.name ?? 'Staff';
    final firstName = userName.split(' ').first;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — hero banner now draws behind
      // the status bar, matching the Create Order screen's navbar.
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
                                  gradient: LinearGradient(
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
                                childAspectRatio: isMobile ? 0.95 : 0.85,
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
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                              boxShadow: _Palette.softShadow,
                            ),
                            padding: EdgeInsets.all(isMobile ? 24 : 32),
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
                                                overflow:
                                                    TextOverflow.ellipsis,
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
// Restyled to mirror the Create Order screen's navbar enhancement language:
// larger rounded bottom corners, a richer 3-layer shadow stack (heroShadow),
// an extra ambient gold glow tucked in the lower-right corner, a fine
// dotted texture accent, and a floating date pill next to the LIVE SYSTEM
// badge — all purely decorative, no logic touched.
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
          color: _Palette.milanoRedDeep,
          image: DecorationImage(
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=2070&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _Palette.milanoRedDeep.withValues(alpha: 0.85),
              BlendMode.srcOver,
            ),
          ),
          // Deeper rounded bottom corners, matching the enlarged radius
          // used on the Create Order screen's header, so both read as the
          // same premium "floating navbar" shape.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 40),
            bottomRight: Radius.circular(isMobile ? 28 : 40),
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
            // Glass overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _Palette.milanoRedLight.withValues(alpha: 0.4),
                      _Palette.milanoRedDeep.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Background decorative elements
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
            // mirrors the same title-glow treatment used behind headings on
            // the Menu/Staff/Create Order navbars, adding depth without
            // touching layout.
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

            // Extra ambient gold glow, lower-right — matches the same
            // "fuller full-screen backdrop" glow added to the Create Order
            // screen's header for a richer, more attractive canvas.
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

            // Subtle decorative diagonal ribbon accents — the same brand
            // language used on the Menu/Staff/Create Order navbar headers.
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
                                  const SizedBox(width: 8),
                                  Text(
                                    'LIVE SYSTEM',
                                    style: AppTheme.sans(
                                      size: 10,
                                      weight: FontWeight.w900,
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
                              // date chip introduced on the Create Order
                              // screen's header.
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
                                child: Text(
                                  dateLabel,
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: Colors.white.withValues(
                                      alpha: 0.75,
                                    ),
                                  ).copyWith(letterSpacing: 0.3),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _Palette.lemonChiffon.withValues(
                                alpha: 0.45,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.lemonChiffon.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: _Palette.lemonChiffon.withValues(
                              alpha: 0.25,
                            ),
                            child: Text(
                              firstName[0],
                              style: AppTheme.serif(
                                size: 16,
                                weight: FontWeight.bold,
                                color: _Palette.lemonChiffon,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 600.ms).slideY(begin: -0.2),

                    const SizedBox(height: 16),

                    // Greeting Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greeting.toUpperCase()},',
                          style: AppTheme.sans(
                            size: 12,
                            weight: FontWeight.w800,
                            color: _Palette.lemonChiffon,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          firstName,
                          style: AppTheme.serif(
                            size: 32,
                            weight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title underline — mirrors the gold divider beneath
                        // the Menu/Staff/Create Order navbar titles.
                        Container(
                          width: 56,
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
                        ),
                        if (isMobile) ...[
                          const SizedBox(height: 10),
                          // On mobile the date pill drops below the title
                          // underline instead of sitting in the top row,
                          // so it never crowds the LIVE SYSTEM badge.
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
                            child: Text(
                              dateLabel,
                              style: AppTheme.sans(
                                size: 10.5,
                                weight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                        .animate()
                        .fade(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: -0.1),

                    const SizedBox(height: 18),

                    // Live Stats Row
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
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
                            _StatPill(
                              icon: Icons.notifications_active_rounded,
                              value: '$newOrdersCount',
                              label: 'New',
                              isAlert: newOrdersCount > 0,
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
          Icon(
            icon,
            size: 18,
            color: isAlert ? _Palette.milanoRedDeep : _Palette.lemonChiffon,
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
              borderRadius: BorderRadius.circular(isSmall ? 24 : 32),
              border: Border.all(
                color: isElevated
                    ? _Palette.milanoRedDeep.withValues(alpha: 0.4)
                    : _Palette.milanoRedDeep.withValues(alpha: 0.08),
                width: isElevated ? 1.6 : 1.5,
              ),
              boxShadow:
                  isElevated ? _Palette.glowShadow : _Palette.softShadow,
            ),
            padding: EdgeInsets.all(isSmall ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: isSmall ? 48 : 60,
                  height: isSmall ? 48 : 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.iconBg,
                        widget.iconBg.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: isSmall ? 24 : 28,
                  ),
                ),
                const Spacer(),
                // Badge
                if (widget.badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.badgeColor ?? _Palette.milanoRed)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (widget.badgeColor ?? _Palette.milanoRed)
                            .withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      widget.badge!,
                      style: AppTheme.sans(
                        size: 9,
                        weight: FontWeight.w900,
                        color: widget.badgeColor ?? _Palette.milanoRed,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                // Text content
                Text(
                  widget.title,
                  style: AppTextStyles.title(
                    color: _Palette.textDark,
                    size: isSmall ? 15 : 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.description,
                  style: AppTextStyles.body(
                    color: _Palette.textMuted,
                    size: isSmall ? 11 : 12,
                  ),
                  maxLines: isSmall ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
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
                          child: Icon(
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
                                  Icon(
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
                            Icon(
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