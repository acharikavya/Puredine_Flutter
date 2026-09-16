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
/// PUREDINE Maroon + Cream palette — matches the New Orders / Create Order
/// / Menu Management / Order Details screens exactly, so this screen now
/// reads as part of the same cohesive, professional brand instead of its
/// own one-off theme. Used ONLY for this screen's visual layer. Nothing
/// here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 3: the header (`_ScreenHeader`) was rebuilt to
/// match the New Orders screen's header language exactly — a two-stop
/// maroon-to-wine gradient, a soft pair of ambient gold glows, an
/// icon-only back chip, a title block (small icon + subtitle label, then
/// the big title), a plain typographic tagline with a small gold accent
/// rule (no icon badge, no card, no border/shadow), a date/live row, and a
/// thin gold gradient hairline underneath. No big watermark emblem, no
/// dotted texture, no four-stop gradient, no photo/avatar imagery
/// anywhere — kept intentionally plain per the New Orders screen's design
/// language. The header's existing "Create Order" action is preserved
/// (same callback, same behavior) but restyled into the same minimal
/// glass-chip language as the back button, and the tagline reflects the
/// live count of orders currently in progress — a direct text formatting
/// of the same confirmed/preparing/ready counts already computed in
/// `build()`, not a new data source. The per-status counts remain visible
/// exactly as before on the filter chips in the sidebar — untouched. No
/// provider, controller, route, filtering, or data value was touched
/// anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 4: `_ScreenHeader`'s bottom edge is now
/// a straight, flat line — matching the Create Order screen's topbar
/// treatment (its own UI-ENHANCEMENT PASS 7) — instead of the previous
/// rounded 32px bottom corners. The `BorderRadius.only(bottomLeft/
/// bottomRight: Radius.circular(32))` on the header `Container` and its
/// matching `ClipRRect` were removed (so the banner is now a plain
/// rectangle, using a plain `ClipRect` in place of the `ClipRRect`), and
/// a thin warm-gold hairline border was added along the bottom edge, the
/// same treatment the Create Order screen uses. Everything else inside
/// the header — the gradient, the drop shadow, the ambient gold glows,
/// the back chip, the "Create Order" chip, the title block, the tagline,
/// and the date/live row — is completely unchanged, as is every other
/// part of this file (filters, `_OrderCard`, and all provider/fetch
/// logic in `_OrdersScreenState`). Presentation only.
///
/// UI-ENHANCEMENT PASS 5: removed the icon-only back chip that
/// previously sat in the top-left of the header, alongside the
/// "Create Order" chip. The `_BackChip` widget class was removed since
/// it's no longer used anywhere in this file. The "Create Order" chip
/// (`_CreateOrderChip`) is untouched and still sits in the header's top
/// row, aligned to the right on its own. The `onBack` callback is still
/// accepted by `_ScreenHeader` and still wired up from
/// `_OrdersScreenState.build()` exactly as before — no navigation logic
/// was touched, only the visible back icon was removed.
///
/// UI-ENHANCEMENT PASS 6 (this pass): the title block (small icon +
/// subtitle label, then the big title) now sits in the same row as the
/// `_CreateOrderChip`, side by side, instead of in its own row
/// underneath. The previously separate "top row" (which used to hold
/// only the Create Order chip) and the title block's own row have been
/// merged into a single `Row` — the title block on the left (wrapped in
/// `Expanded` so long titles still ellipsis correctly) and the chip on
/// the right, vertically centered against each other. This removes one
/// row's worth of vertical spacing from the header, so the banner reads
/// as a little more compact/"pulled up." No text, callback, styling
/// values (sizes/colors/weights), or animation on the title block itself
/// were changed — only its position relative to the Create Order chip.
/// Everything else in the header (tagline, date/live row, hairline,
/// gradient, shadows, glows) and the rest of the file is unchanged.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// order_details_screen.dart / new_orders_screen.dart / create_order_
/// screen.dart / menu_screen.dart (private classes can't be shared across
/// files without a new shared import, which would go beyond a pure UI-only
/// change here).
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

  // Live / Success — Fresh Green, used for the header's "Live" indicator.
  static const Color success = Color(0xFF44AF70);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Order Details/Menu/Create Order/New Orders so
  /// every card on this screen carries the same warm, branded elevation.
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

  /// Header/hero drop shadow — matches the New Orders hero exactly.
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
              // ── Header — restyled to match the New Orders screen's
              // header design language exactly (two-stop maroon-to-wine
              // gradient, title block, plain-text tagline with a gold
              // accent rule, date/live row, gold hairline), and with a
              // straight, flat bottom edge (see PASS 4 above) matching the
              // Create Order screen's topbar. The "Create Order" action is
              // preserved, restyled into the same minimal glass-chip
              // language, and (PASS 6) now sits inline with the title. ─
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
                                                  gradient:
                                                      const LinearGradient(
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
                ? const LinearGradient(
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

// ─── Screen header — restyled to mirror the New Orders screen's header
// exactly: a two-stop maroon-to-wine gradient, two soft ambient gold
// glows, a small "Create Order" chip, a title block (small icon +
// subtitle label, then the big title), a plain-text tagline anchored by a
// small gold accent rule (no icon badge, no card, no border/shadow), and
// a date/live row with a thin gold gradient hairline underneath. No
// watermark emblem, no dotted texture, no photo/avatar imagery — kept
// intentionally minimal per the New Orders screen's design language. The
// tagline is data-driven off the confirmed/preparing/ready counts
// (already computed by the caller) purely as a text format — no new
// logic. Same callbacks (onBack / onCreateOrder) as before — this is a
// purely presentational change.
//
// PASS 4: the bottom edge is now a straight, flat line — matching the
// Create Order screen's topbar treatment — instead of the previous
// rounded 32px bottom corners. The `BorderRadius.only(bottomLeft/
// bottomRight)` on the `Container` and the matching `ClipRRect` were
// removed (replaced with a plain `ClipRect`), and a thin warm-gold
// hairline border was added along the bottom edge.
//
// PASS 5: the icon-only back chip that used to sit to the left of the
// "Create Order" chip has been removed. `onBack` is still accepted here
// and still passed through from the caller unchanged — no navigation
// logic touched, only the visible icon was removed.
//
// PASS 6: the title block (icon + subtitle label, then the big title)
// now sits in the same row as the "Create Order" chip instead of in its
// own row beneath it, pulling the header content up and making the
// banner a bit more compact. The title block is wrapped in `Expanded` so
// the big title's existing `maxLines: 1` / ellipsis behavior still works
// correctly next to the chip, and the row uses
// `CrossAxisAlignment.center` so the title block and the chip line up
// visually. No text, callback, or styling value was changed — only the
// position of the title block relative to the chip.
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
    final inProgressCount = confirmedCount + preparingCount + readyCount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Two-stop Deep Wine Maroon → Wine gradient, matching the
        // New Orders hero exactly.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
        // PASS 4: straight, flat bottom edge — no rounded corners —
        // matching the Create Order screen's topbar shape, plus the same
        // thin warm-gold hairline the Create Order screen uses along
        // that bottom edge.
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
            // content — purely decorative, mirroring the New Orders hero.
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
                  isMobile ? 18 : 32,
                  isMobile ? 14 : 20,
                  isMobile ? 18 : 32,
                  isMobile ? 24 : 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: title block (icon + subtitle label, then
                    // the big title) on the left, "Create Order" chip on
                    // the right — merged into a single row (PASS 6) so the
                    // header sits more compact. Same onCreateOrder
                    // callback as before — presentation only.
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
                                  size: isMobile ? 26 : 32,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(height: 1.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ).animate().fade(duration: 500.ms).slideY(
                                begin: -0.15,
                              ),
                        ),
                        const SizedBox(width: 12),
                        _CreateOrderChip(onTap: onCreateOrder),
                      ],
                    ),

                    SizedBox(height: isMobile ? 16 : 20),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge — just
                    // clean, confident cream typography sitting directly
                    // in the header, with a small gold accent rule above
                    // it to anchor the line — matches the New Orders
                    // header's tagline treatment exactly. The copy itself
                    // reflects the live in-progress order count already
                    // computed by the caller (a text format of existing
                    // data, not new logic).
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
                        SizedBox(height: isMobile ? 8 : 10),
                        Text(
                          inProgressCount > 0
                              ? '$inProgressCount order${inProgressCount == 1 ? '' : 's'} currently in progress.'
                              : 'No orders in progress right now.',
                          style: AppTheme.serif(
                            size: isMobile ? 15.5 : 18,
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

                    SizedBox(height: isMobile ? 14 : 18),

                    // ── Date + Live row ──────────────────────────────────
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
                            size: isMobile ? 11.5 : 12.5,
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
                            size: isMobile ? 11 : 12,
                            weight: FontWeight.w700,
                            color: _Palette.success,
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

// ─── Create Order chip — same minimal glass-gold circular control as the
// former back chip, showing a "+" glyph. Same onCreateOrder callback as
// before — presentation only, no logic touched.
class _CreateOrderChip extends StatefulWidget {
  final VoidCallback onTap;
  const _CreateOrderChip({required this.onTap});

  @override
  State<_CreateOrderChip> createState() => _CreateOrderChipState();
}

class _CreateOrderChipState extends State<_CreateOrderChip> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Create Order',
      child: MouseRegion(
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
                    color: _Palette.gold.withValues(
                      alpha: _isHovered ? 0.3 : 0.18,
                    ),
                    blurRadius: _isHovered ? 14 : 10,
                    spreadRadius: _isHovered ? 1 : 0.5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order Card ─────────────────────────────────────────────────────────
// Carries a slim status-colored accent rail down the left edge (matching
// the Dashboard's mini order cards and the Tables screen's floor-plan
// tiles), a soft ring around the status icon chip, and a richer "View
// Details" pill with its own circular arrow badge. Still wrapped in the
// same AppCard with the exact same onTap route — no navigation or data
// logic changed.
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
                              child: const Icon(
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
                          const Icon(
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
                            child: const Icon(
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
