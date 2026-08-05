import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../contexts/auth_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import '../../core/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / New Orders / Create Order / Menu Management screens
/// exactly (#8B1D1D primary / #F4C430 gold accent), so this screen now
/// reads as part of the same cohesive, professional brand instead of its
/// own one-off theme. Used ONLY for this screen's visual layer. Nothing
/// here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (four-stop gradient, a large faint
/// watermark emblem, a glass highlight line, and a new live status
/// readout strip built from the exact same per-status counts the filter
/// chips already use), the full-screen backdrop gained an extra diagonal
/// sheen + a second ambient glow for more depth, the sidebar filter chips
/// now carry a per-status icon, and each order card picked up a slim
/// status-colored accent rail and a slightly richer "View Details" chip.
/// No provider, controller, route, filtering, or data value was touched
/// anywhere in this pass — only Container/Decoration/TextStyle-level
/// presentation changed.
///
/// NOTE: this is a private class redeclared identically to the one in
/// order_details_screen.dart / new_orders_screen.dart / menu_screen.dart
/// (private classes can't be shared across files without a new shared
/// import, which would go beyond a pure UI-only change here).
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
  /// softShadow used on Order Details/Menu/Create Order/New Orders so
  /// every card on this screen carries the same warm, branded elevation.
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

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the Order Details / New Orders / Create Order /
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

  /// Soft inner "glass" shadow used on the header's stats readout strip —
  /// pure decoration, gives the capsule a faint pressed-glass depth.
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

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const OrdersScreen({super.key, this.onGoHome});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // Use read instead of watch in methods
    final ordersProvider = context.read<OrdersProvider>();
    final auth = context.read<StaffAuthProvider>();

    if (auth.token != null) {
      await ordersProvider.fetchOrders(auth.token!);
    }
  }

  Map<String, dynamic> _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return {
          'label': 'CONFIRMED',
          'bg': const Color(0xFFFEF3C7),
          'color': const Color(0xFFD97706),
          'icon': Icons.access_time,
        };
      case OrderStatus.preparing:
        return {
          'label': 'PREPARING',
          'bg': const Color(0xFFDBEAFE),
          'color': const Color(0xFF2563EB),
          'icon': Icons.local_fire_department,
        };
      case OrderStatus.ready:
        return {
          'label': 'READY TO SERVE',
          'bg': const Color(0xFFD1FAE5),
          'color': const Color(0xFF059669),
          'icon': Icons.check_circle_outline,
        };
      default:
        return {
          'label': 'SERVED',
          'bg': const Color(0xFFF1F5F9),
          'color': const Color(0xFF64748B),
          'icon': Icons.done_all,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final allOrders = ordersProvider.orders
        .where(
          (o) =>
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.ready ||
              o.status == OrderStatus.served,
        )
        .toList();

    final confirmedCount =
        allOrders.where((o) => o.status == OrderStatus.confirmed).length;
    final preparingCount =
        allOrders.where((o) => o.status == OrderStatus.preparing).length;
    final readyCount =
        allOrders.where((o) => o.status == OrderStatus.ready).length;
    final servedCount = ordersProvider.orders
        .where((o) => o.status == OrderStatus.served)
        .length;

    final filters = [
      {
        'id': 'all',
        'label': 'All',
        'count': allOrders.length,
        'icon': Icons.grid_view_rounded,
      },
      {
        'id': 'CONFIRMED',
        'label': 'Confirmed',
        'count': confirmedCount,
        'icon': Icons.access_time_rounded,
      },
      {
        'id': 'PREPARING',
        'label': 'Preparing',
        'count': preparingCount,
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'id': 'READY',
        'label': 'Ready',
        'count': readyCount,
        'icon': Icons.check_circle_outline_rounded,
      },
      {
        'id': 'SERVED',
        'label': 'Served',
        'count': servedCount,
        'icon': Icons.done_all_rounded,
      },
    ];

    List<Order> filteredOrders;
    if (_activeFilter == 'all') {
      filteredOrders = allOrders;
    } else {
      final statusMap = {
        'CONFIRMED': OrderStatus.confirmed,
        'PREPARING': OrderStatus.preparing,
        'READY': OrderStatus.ready,
        'SERVED': OrderStatus.served,
      };
      final targetStatus = statusMap[_activeFilter];
      filteredOrders =
          ordersProvider.orders.where((o) => o.status == targetStatus).toList();
    }

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / New Orders screens.
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
                  // Extra low, wide glow further down the page — gives a
                  // long orders list a second soft focal point instead of
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
          // flat behind the header, echoing the glass-highlight language
          // used in the header itself.
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
              // ── Header — same Dark Maroon gradient + gold accents used
              // throughout every other staff screen, now restyled into a
              // richer "command bar" with a live status readout. ────────
              _ScreenHeader(
                title: 'Active Orders',
                subtitle: 'Manage Real-time Dining Service',
                dateLabel: _todayLabel(),
                confirmedCount: confirmedCount,
                preparingCount: preparingCount,
                readyCount: readyCount,
                servedCount: servedCount,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    widget.onGoHome?.call();
                  }
                },
                onCreateOrder: () => context.push('/staff/create-order'),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768; // md breakpoint

                    Widget filterList = isWide
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: filters
                                .map((f) => _buildFilterButton(f, isWide))
                                .toList(),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: filters
                                  .map(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildFilterButton(f, isWide),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );

                    Widget content = filteredOrders.isEmpty
                        ? const EmptyState(
                            icon: Icons.receipt_long,
                            title: 'No orders found',
                            subtitle: 'Try a different filter',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide
                                  ? (constraints.maxWidth >= 1024 ? 3 : 2)
                                  : 1, // lg: 3, md: 2, default: 1
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio:
                                  1.05, // Slightly taller, more generous cards
                            ),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final config = _getStatusConfig(order.status);
                              return _OrderCard(order: order, config: config)
                                  .animate()
                                  .fade(
                                      duration: 400.ms, delay: (index * 50).ms)
                                  .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 400.ms,
                                    curve: Curves.easeOutQuad,
                                  );
                            },
                          );

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1280,
                          ), // max-w-7xl
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sidebar Filter
                                    Container(
                                      width: 256, // w-64
                                      margin: const EdgeInsets.only(
                                        right: 32,
                                      ), // gap-8
                                      padding: const EdgeInsets.all(22), // p-6
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            _Palette.canvasDeep.withValues(
                                              alpha: 0.35,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          24,
                                        ), // rounded-3xl
                                        border: Border.all(
                                          color: _Palette.milanoRedDeep
                                              .withValues(alpha: 0.10),
                                        ),
                                        boxShadow: _Palette.softShadow,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 4,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _Palette.gold,
                                                      _Palette.goldLight,
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    2,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'FILTER STATUS',
                                                style: AppTheme.sans(
                                                  size: 12,
                                                  weight: FontWeight.w700,
                                                  color: _Palette.textMuted,
                                                ).copyWith(
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          filterList,
                                        ],
                                      ).animate().fade().slideX(
                                            begin: -0.1,
                                            duration: 400.ms,
                                            curve: Curves.easeOutQuad,
                                          ),
                                    ),
                                    // Grid
                                    Expanded(child: content),
                                  ],
                                )
                              : Column(
                                  children: [
                                    filterList,
                                    const SizedBox(height: 24),
                                    content,
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(Map<String, dynamic> f, bool isWide) {
    final isActive = _activeFilter == f['id'];
    final icon = f['icon'] as IconData;
    return Padding(
      padding: isWide ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: InkWell(
        onTap: () => setState(() => _activeFilter = f['id'] as String),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      _Palette.milanoRedLight,
                      _Palette.milanoRedDeep,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: _Palette.gold.withValues(alpha: 0.5))
                : Border.all(color: Colors.transparent),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.22)
                          : _Palette.milanoRedDeep.withValues(alpha: 0.06),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: isActive ? Colors.white : _Palette.milanoRedDeep,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    f['label'] as String,
                    style: AppTheme.sans(
                      size: 14,
                      weight: FontWeight.w700,
                      color: isActive ? Colors.white : _Palette.textDark,
                    ),
                  ),
                ],
              ),
              if (isWide) const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : _Palette.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${f['count']}',
                  style: AppTheme.sans(
                    size: 12,
                    weight: FontWeight.w700,
                    color: isActive ? Colors.white : _Palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the accent used under section titles on the
/// Order Details / Menu Management / Create Order / New Orders screens
/// for a consistent brand language.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider({this.width = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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

// ─── Screen header — restyled into its own distinctive "command bar"
// identity: a richer four-stop diagonal gradient, a large faint watermark
// emblem behind the title, a fine glass highlight line along the top
// edge, layered ribbon glows, a dotted texture accent, a floating date
// pill, and a brand icon chip matching every other staff screen's header.
// UI-ENHANCEMENT PASS 2 adds a live status readout strip (Confirmed /
// Preparing / Ready / Served) built from the exact same per-status counts
// the filter chips already use — no new data source, purely a display of
// values already available at the call site. The back control remains
// the same compact, icon-only "‹" chip, and the primary "Create Order"
// action remains the same small circular "+" chip pinned to the top-right
// of the navbar. The onBack/onCreateOrder callbacks are identical to
// before — this is a purely presentational change. ─────────────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final int confirmedCount;
  final int preparingCount;
  final int readyCount;
  final int servedCount;
  final VoidCallback onBack;
  final VoidCallback onCreateOrder;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.confirmedCount,
    required this.preparingCount,
    required this.readyCount,
    required this.servedCount,
    required this.onBack,
    required this.onCreateOrder,
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
            // Subtle decorative diagonal ribbon accents — purely cosmetic,
            // matches every other staff screen's header for a consistent
            // brand feel.
            Positioned(
              top: -60,
              right: -40,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 220,
                  height: 84,
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
                  width: 200,
                  height: 66,
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
            // Soft gold radial glow behind the brand icon, echoing the
            // Dashboard / Order Details hero treatment.
            Positioned(
              top: -50,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
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
            // "full-screen backdrop" glow used on the Order Details header.
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
            // with the title or the stats strip.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -22 : -16,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: isMobile ? 140 : 190,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the refined decorative
            // language used on the dashboard / menu-management headers.
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
            // matches the Dashboard hero's top edge treatment.
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
                  16,
                  isMobile ? 16 : 24,
                  22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ── Icon-only back control — a single "‹" glyph,
                        // no arrow icon and no "Back" label, matching the
                        // Order Details screen's header control. ────────
                        _BackChevronButton(onTap: onBack),
                        const Spacer(),
                        if (!isMobile) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
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
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ).copyWith(letterSpacing: 0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // ── Compact circular "Create Order" action,
                        // pinned to the top-right of the navbar right next
                        // to the back control. Same gold gradient +
                        // lemon-chiffon edge as before, just re-shaped
                        // into a small icon-only chip instead of a
                        // full-width labeled button. ────────────────────
                        Tooltip(
                          message: 'Create Order',
                          child: _CreateOrderCircleButton(
                            onTap: onCreateOrder,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Brand icon chip — thin gold border + soft
                        // gold glow, matching the Order Details / Create
                        // Order / New Orders header icon. ───────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _Palette.gold.withValues(alpha: 0.8),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.gold.withValues(alpha: 0.3),
                                blurRadius: 14,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: _Palette.lemonChiffon,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTheme.serif(
                                  size: isMobile ? 22 : 26,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(height: 1.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const _TitleDivider(),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: AppTheme.sans(
                                  size: 12.5,
                                  weight: FontWeight.w600,
                                  color: _Palette.lemonChiffon,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
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
                                style: AppTheme.sans(
                                  size: 10.5,
                                  weight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // ── Live status readout strip — Confirmed / Preparing
                    // / Ready / Served, built straight from the same
                    // per-status counts already powering the filter chips
                    // below. Purely a display addition; no new data
                    // source and no logic change.
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.22),
                            Colors.black.withValues(alpha: 0.14),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                        boxShadow: _Palette.statCapsuleShadow,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _HeaderStatPill(
                              icon: Icons.access_time_rounded,
                              value: '$confirmedCount',
                              label: 'Confirmed',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.local_fire_department_rounded,
                              value: '$preparingCount',
                              label: 'Preparing',
                              accent: const Color(0xFF60A5FA),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.check_circle_outline_rounded,
                              value: '$readyCount',
                              label: 'Ready',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.done_all_rounded,
                              value: '$servedCount',
                              label: 'Served',
                              accent: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 550.ms, delay: 200.ms)
                        .slideY(begin: 0.2, duration: 550.ms, delay: 200.ms),
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

/// Slim vertical divider used between stat pills in the header's readout
/// strip — purely decorative spacing element, no logic.
class _HeaderStatDivider extends StatelessWidget {
  const _HeaderStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withValues(alpha: 0.10),
    );
  }
}

/// A single stat readout module (icon badge + value + label) used inside
/// the header's live stats strip. Purely presentational — takes whatever
/// value/label/accent it's given.
class _HeaderStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _HeaderStatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: Icon(icon, size: 13, color: accent),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.sans(
                  size: 15,
                  weight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: AppTheme.sans(
                  size: 8.5,
                  weight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.6),
                ).copyWith(letterSpacing: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing
/// only a plain "‹" glyph. Replaces the previous arrow-icon + "Back"
/// label combo with the same minimal, professional control used on the
/// Order Details screen's header, for a consistent brand-wide top bar.
class _BackChevronButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackChevronButton({required this.onTap});

  @override
  State<_BackChevronButton> createState() => _BackChevronButtonState();
}

class _BackChevronButtonState extends State<_BackChevronButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
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
                  ? _Palette.lemonChiffon.withValues(alpha: 0.7)
                  : _Palette.lemonChiffon.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _Palette.lemonChiffon.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
    );
  }
}

// ─── "Create Order" action — a small circular gold chip pinned to the
// top-right of the navbar, right beside the back control. Same gold
// gradient + lemon-chiffon edge as the ACCEPT ORDER button on the New
// Orders screen, so the primary call to action still carries the same
// premium look, just condensed into an icon-only "+" glyph that matches
// the compact, icon-only back control on the opposite side of the bar.
class _CreateOrderCircleButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CreateOrderCircleButton({required this.onTap});

  @override
  State<_CreateOrderCircleButton> createState() =>
      _CreateOrderCircleButtonState();
}

class _CreateOrderCircleButtonState extends State<_CreateOrderCircleButton> {
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
          scale: _pressed ? 0.92 : (_isHovered ? 1.06 : 1.0),
          duration: 120.ms,
          curve: Curves.easeOut,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_Palette.gold, _Palette.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _Palette.lemonChiffonDeep.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _Palette.gold.withValues(
                    alpha: _isHovered ? 0.55 : 0.4,
                  ),
                  blurRadius: _isHovered ? 16 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order Card ─────────────────────────────────────────────────────────
// UI-ENHANCEMENT PASS 2: picked up a slim status-colored accent rail down
// the left edge (matching the Dashboard's mini order cards and the Tables
// screen's floor-plan tiles), a soft ring around the status icon chip,
// and a slightly richer "View Details" pill with its own circular arrow
// badge. Still wrapped in the same AppCard with the exact same onTap
// route — no navigation or data logic changed.
class _OrderCard extends StatelessWidget {
  final Order order;
  final Map<String, dynamic> config;

  const _OrderCard({required this.order, required this.config});

  @override
  Widget build(BuildContext context) {
    final statusColor = config['color'] as Color;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () =>
          context.push('/staff/order-details/${order.id}?from=/staff/orders'),
      child: Stack(
        children: [
          // Slim status-colored accent rail down the left edge — an
          // instant color cue for the card's status, purely decorative.
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
                    statusColor.withValues(alpha: 0.85),
                    statusColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Status Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      (config['bg'] as Color).withValues(alpha: 0.65),
                      (config['bg'] as Color).withValues(alpha: 0.35),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        config['icon'] as IconData,
                        size: 20,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config['label'] as String,
                            style: AppTheme.sans(
                              size: 13,
                              weight: FontWeight.w900,
                              color: statusColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                order.time,
                                style: AppTheme.sans(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: statusColor.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                ' • ',
                                style: AppTheme.sans(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: statusColor.withValues(alpha: 0.7),
                                ),
                              ),
                              LiveTimeAgo(
                                dt: order.createdAt,
                                style: AppTheme.sans(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: statusColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: statusColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _Palette.milanoRed.withValues(alpha: 0.10),
                                    _Palette.milanoRed.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.table_bar_rounded,
                                size: 22,
                                color: _Palette.milanoRedDeep,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.table,
                                  style: AppTheme.serif(
                                    size: 18,
                                    weight: FontWeight.w800,
                                    color: _Palette.textDark,
                                  ),
                                ),
                                if (order.customerName != null)
                                  Text(
                                    order.customerName!,
                                    style: AppTheme.sans(
                                      size: 14,
                                      weight: FontWeight.w700,
                                      color: _Palette.textDark.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                Text(
                                  '${order.items} items ordered',
                                  style: AppTheme.sans(
                                    size: 13,
                                    color: _Palette.textMuted,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          CurrencyUtils.format(order.total),
                          style: AppTheme.serif(
                            size: 22,
                            weight: FontWeight.w900,
                            color: _Palette.milanoRedDeep,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Quick actions or more info could go here
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            _Palette.canvas,
                            _Palette.canvasDeep.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: _Palette.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Assigned to Staff',
                            style: AppTheme.sans(
                              size: 11,
                              weight: FontWeight.w600,
                              color: _Palette.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'View Details',
                            style: AppTheme.sans(
                              size: 11,
                              weight: FontWeight.w700,
                              color: _Palette.milanoRedDeep,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.08,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 13,
                              color: _Palette.milanoRedDeep,
                            ),
                          ),
                        ],
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
