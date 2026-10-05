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
/// UI-ENHANCEMENT PASS 6: the title block (small icon + subtitle
/// label, then the big title) now sits in the same row as the
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
/// UI-ENHANCEMENT PASS 7: responsive-layout-only, exactly
/// like every pass above — no provider, controller, route, filtering, or
/// data value anywhere in this file was touched, and no state field,
/// callback, or keyword was renamed.
///   1. RESPONSIVE BREAKPOINTS: the screen now measures the available
///      width via a `_DeviceType` breakpoint (mobile < 700, tablet
///      700–1100, desktop ≥ 1100) instead of the previous single
///      `isWide` split at 768px. The sidebar-vs-stacked filter layout
///      still switches at the same tablet-and-up point (`isWide` is now
///      simply "not mobile"), but the grid's column count, the sidebar's
///      width/margin/padding, the outer scroll padding, and the header's
///      padding/type-scale all now scale through three tiers instead of
///      two.
///   2. TABLET / DESKTOP POLISH: on tablet the orders grid now shows 2
///      columns (desktop keeps its existing 3 columns; mobile keeps its
///      existing single column) and the sidebar filter panel is slightly
///      narrower with tighter margin/padding on tablet than on desktop,
///      so it sits comfortably instead of crowding the grid at mid-size
///      widths. `_ScreenHeader` gained its own tablet tier between the
///      existing mobile and desktop sizing for its padding, title/
///      tagline type scale, and spacing. Every filter chip, order card,
///      callback and piece of copy is unchanged.
///
/// UI-ENHANCEMENT PASS 8: overflow bug fix, layout-only:
/// fixes the reported `RenderFlex overflowed` errors inside the order
/// cards (`_OrderCard`) at tablet/mid-size and mobile widths — no
/// provider, controller, route, filtering, data value, callback, or
/// keyword anywhere in this file was touched; every fix below is a
/// layout/sizing adjustment only.
///   1. GRID CELL HEIGHT: `childAspectRatio` in the orders grid is now
///      tier-specific (mobile `0.62` / tablet `0.78` / desktop `0.92`)
///      instead of a single fixed `1.05` for every width, giving each
///      grid cell noticeably more vertical room at narrower widths,
///      where the same card content previously no longer fit inside a
///      near-square cell — this is what was throwing the "overflowed by
///      33 pixels on the bottom" errors. (SUPERSEDED ON MOBILE BY
///      PASS 9 BELOW — the mobile figure was later found to be too
///      generous, making cards read as oversized. Tablet/desktop values
///      are unchanged.)
///   2. SAFETY NET: `_OrderCard`'s content column is now wrapped in a
///      scrollbar-free `SingleChildScrollView` (the same
///      `_NoScrollbarBehavior` pattern already used elsewhere in this
///      codebase), so on the rare device/content combination where the
///      grid cell is still shorter than the card's natural content
///      height, the card scrolls internally instead of throwing a
///      "RenderFlex overflowed ... on the bottom" error. On every normal
///      screen size nothing visibly scrolls — this is purely a guard.
///   3. HORIZONTAL OVERFLOW GUARDS: three rows inside `_OrderCard` that
///      previously had no way to shrink when the card got narrower
///      (tablet's 2-column grid, in particular) now do:
///        • the status banner's "time • live-time-ago" row is now a
///          `Wrap` instead of a `Row`, so it wraps onto a second line
///          instead of overflowing to the right when both pieces of text
///          don't fit on one line;
///        • the table-name/customer/items block is now wrapped in
///          `Expanded`, with each of its text lines given
///          `maxLines: 1` plus ellipsis, so a long table/customer name
///          truncates instead of pushing the price off the right edge;
///          the price itself is wrapped in a `Flexible` + `FittedBox` so
///          it can scale down slightly rather than overflow on an
///          extremely narrow card;
///        • the "Assigned to Staff" label in the footer row is now
///          wrapped in a `Flexible` with ellipsis, so it yields space to
///          the "View Details" pill instead of overflowing past it.
///      No copy, color, icon, font weight, or the card's tap
///      navigation/route was changed — only how these rows behave when
///      they run out of horizontal room.
///
/// UI-ENHANCEMENT PASS 9 (this pass — MOBILE-ONLY GRID SIZE FIX,
/// layout-only): fixes the reported issue where each order card in the
/// mobile (single-column) grid read as far too tall — a big, oversized
/// box — instead of a normal, proportioned card. No provider, controller,
/// route, filtering, data value, callback, or keyword anywhere in this
/// file was touched.
///   1. MOBILE GRID ASPECT RATIO INCREASED: `gridAspectRatio` for mobile
///      (`_DeviceType.mobile`) is now `0.90` (up from PASS 8's `0.62`).
///      A `childAspectRatio` is width ÷ height, so PASS 8's very low
///      `0.62` value forced every single-column mobile card into a tall,
///      narrow rectangle far taller than its content actually needed —
///      exactly the "too big in height" cards reported. `0.90` gives
///      each mobile card a normal, compact, close-to-square proportion
///      that comfortably fits its content (status banner, table/price
///      row, footer pill) without the excess empty height. Tablet
///      (`0.78`) and desktop (`0.92`) aspect ratios are completely
///      unchanged from PASS 8.
///   2. SAFETY NET UNCHANGED: `_OrderCard`'s PASS 8 scrollbar-free
///      `SingleChildScrollView` safety net, and all three PASS 8
///      horizontal-overflow guards (the status-time `Wrap`, the
///      table-info `Expanded` + ellipsis, the price `Flexible` +
///      `FittedBox`, and the footer label `Flexible`), are fully
///      preserved, so cards still can never throw a "RenderFlex
///      overflowed" error on any device — they simply now size more
///      proportionately on phones. Grid column counts (mobile 1 / tablet
///      2 / desktop 3), spacing, filters, header, and every other part of
///      this screen are unchanged.
///
/// UI-ENHANCEMENT PASS 10 (this pass — MOBILE-ONLY GRID SIZE
/// FIX, ROUND 2, layout-only): PASS 9's mobile figure (`0.90`) was
/// reported as still too tall/oversized on an actual phone screenshot —
/// each single mobile order card was still reading as a big block rather
/// than a compact, proper "table row" style card. No provider,
/// controller, route, filtering, data value, callback, or keyword
/// anywhere in this file was touched.
///   1. MOBILE GRID ASPECT RATIO INCREASED AGAIN: `gridAspectRatio` for
///      mobile is now `1.3` (up from PASS 9's `0.90`). Since
///      `childAspectRatio` is width ÷ height, a bigger number means a
///      shorter cell for the same width — `1.3` gives each mobile card a
///      noticeably shorter, wider, more compact proportion (closer to a
///      list-row card) instead of the taller block from PASS 9. Tablet
///      (`0.78`) and desktop (`0.92`) aspect ratios are completely
///      unchanged from PASS 8/9.
///   2. SAFETY NET UNCHANGED: exactly as PASS 9 — `_OrderCard`'s PASS 8
///      scrollbar-free `SingleChildScrollView` safety net and all three
///      PASS 8 horizontal-overflow guards are fully preserved, so on any
///      device where a card's content is ever taller than the new
///      shorter cell, the card simply scrolls internally instead of
///      overflowing — it can never throw a "RenderFlex overflowed"
///      error. Grid column counts, spacing, filters, header, and every
///      other part of this screen are unchanged.
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

/// PASS 7: simple responsive breakpoint helper — layout-only, does not
/// touch any provider/filtering/navigation logic anywhere in this file.
enum _DeviceType { mobile, tablet, desktop }

_DeviceType _deviceTypeForWidth(double width) {
  if (width < 700) return _DeviceType.mobile;
  if (width < 1100) return _DeviceType.tablet;
  return _DeviceType.desktop;
}

/// PASS 8: a `ScrollBehavior` that never paints a scrollbar. Used only to
/// wrap `_OrderCard`'s content-safety `SingleChildScrollView` below so
/// that, even on the rare cell size small enough to need the extra
/// scroll room, no visible scrollbar ever appears — purely a rendering/
/// behaviour detail, not a feature change.
class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
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
                    // PASS 7: three-tier breakpoint replaces the old single
                    // `isWide` split at 768px. `isWide` is kept as a
                    // convenience flag ("tablet or desktop") so the
                    // sidebar-vs-stacked switch below reads exactly as
                    // before.
                    final deviceType =
                        _deviceTypeForWidth(constraints.maxWidth);
                    final isWide = deviceType != _DeviceType.mobile;
                    final isTablet = deviceType == _DeviceType.tablet;

                    // PASS 8: tier-specific grid-cell aspect ratio, in
                    // place of the old single fixed `1.05` — gives each
                    // card noticeably more vertical room at narrower
                    // widths so its content fits without overflowing.
                    //
                    // PASS 9: the mobile figure alone is raised from
                    // PASS 8's `0.62` to `0.90` — `0.62` was making every
                    // single-column mobile card far taller than its
                    // content needed (the reported "too big in height"
                    // boxes). Tablet (`0.78`) and desktop (`0.92`) are
                    // unchanged from PASS 8.
                    //
                    // PASS 10: mobile raised again, from PASS 9's `0.90`
                    // to `1.3` — the cards were still reading as too tall
                    // on an actual phone screenshot, so mobile cards are
                    // now noticeably shorter/more compact, closer to a
                    // proper table-row card. Tablet (`0.78`) and desktop
                    // (`0.92`) remain unchanged from PASS 8/9.
                    final double gridAspectRatio =
                        deviceType == _DeviceType.desktop
                            ? 0.92
                            : (isTablet ? 0.78 : 1.3);

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
                              // PASS 7: mobile 1 / tablet 2 / desktop 3,
                              // driven by the same three-tier breakpoint
                              // used everywhere else in this build.
                              crossAxisCount: deviceType == _DeviceType.desktop
                                  ? 3
                                  : (isTablet ? 2 : 1),
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              // PASS 8/9/10: tier-specific ratio (see
                              // above) — taller cells at narrower widths
                              // so card content always has room to fit,
                              // with the mobile figure corrected in
                              // PASS 9 and then PASS 10 so mobile cards
                              // read as properly proportioned/compact
                              // instead of oversized.
                              childAspectRatio: gridAspectRatio,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceType == _DeviceType.mobile
                            ? 16
                            : (isTablet ? 24 : 32),
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
                                    // Sidebar Filter — PASS 7: slightly
                                    // narrower with tighter margin/padding
                                    // on tablet than on desktop, so it sits
                                    // comfortably instead of crowding the
                                    // grid at mid-size widths.
                                    Container(
                                      width: isTablet ? 220 : 256, // w-64
                                      margin: EdgeInsets.only(
                                        right: isTablet ? 24 : 32,
                                      ), // gap-8
                                      padding: EdgeInsets.all(
                                        isTablet ? 18 : 22,
                                      ), // p-6
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
//
// PASS 7: the single `isMobile` split at 800px was stepped up into three
// tiers (mobile/tablet/desktop) using the same `_deviceTypeForWidth`
// breakpoint the rest of the screen now uses, so the header's padding,
// title/tagline type scale, and internal spacing read with a bit more
// breathing room on tablets instead of jumping straight from the compact
// phone sizing to the full desktop sizing. Structure, text, callbacks and
// data are unchanged.
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
    final deviceType = _deviceTypeForWidth(MediaQuery.of(context).size.width);
    final isMobile = deviceType == _DeviceType.mobile;
    final isTablet = deviceType == _DeviceType.tablet;
    final inProgressCount = confirmedCount + preparingCount + readyCount;

    final double padLeftRight = isMobile ? 18 : (isTablet ? 26 : 32);
    final double padTop = isMobile ? 14 : (isTablet ? 17 : 20);
    final double padBottom = isMobile ? 24 : (isTablet ? 27 : 30);
    final double titleSize = isMobile ? 26 : (isTablet ? 29 : 32);
    final double taglineSize = isMobile ? 15.5 : (isTablet ? 16.5 : 18);
    final double spaceAfterTitleRow = isMobile ? 16 : (isTablet ? 18 : 20);
    final double spaceAfterRule = isMobile ? 8 : (isTablet ? 9 : 10);
    final double spaceAfterTagline = isMobile ? 14 : (isTablet ? 16 : 18);
    final double dateTextSize = isMobile ? 11.5 : (isTablet ? 12 : 12.5);
    final double liveTextSize = isMobile ? 11 : (isTablet ? 11.5 : 12);
    final double spaceAfterDateRow = isMobile ? 10 : (isTablet ? 11 : 12);

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
                  padLeftRight,
                  padTop,
                  padLeftRight,
                  padBottom,
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
                                  size: titleSize,
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

                    SizedBox(height: spaceAfterTitleRow),

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
                        SizedBox(height: spaceAfterRule),
                        Text(
                          inProgressCount > 0
                              ? '$inProgressCount order${inProgressCount == 1 ? '' : 's'} currently in progress.'
                              : 'No orders in progress right now.',
                          style: AppTheme.serif(
                            size: taglineSize,
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

                    SizedBox(height: spaceAfterTagline),

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
                            size: dateTextSize,
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
                            size: liveTextSize,
                            weight: FontWeight.w700,
                            color: _Palette.success,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spaceAfterDateRow),

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
//
// PASS 8: the card's content column is now wrapped in a scrollbar-free
// `SingleChildScrollView` safety net, and three internal rows (the
// status banner's time row, the table-info-vs-price row, and the
// "Assigned to Staff" footer row) were made to shrink/wrap instead of
// overflow when the card gets narrower (see the PASS 8 note above the
// `_Palette` class for the full rationale). No data binding, callback,
// or navigation route was touched — layout only.
//
// PASS 9/10: no changes to this class itself in either pass — both
// mobile card-height fixes were made entirely at the grid level (see
// `gridAspectRatio` in `_OrdersScreenState.build()` above); this card's
// own content, safety net, and overflow guards are unchanged.
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
          // PASS 8: the banner + content column is now wrapped in a
          // scrollbar-free `SingleChildScrollView` so that, on the rare
          // grid cell that's still shorter than this content's natural
          // height, the card scrolls internally instead of throwing a
          // "RenderFlex overflowed ... on the bottom" error. On any
          // normal-sized cell nothing visibly scrolls.
          ScrollConfiguration(
            behavior: _NoScrollbarBehavior(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
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
                              // PASS 8: `Wrap` instead of `Row` — the
                              // "time • live-time-ago" pair now wraps
                              // onto a second line instead of overflowing
                              // to the right on a narrow card. Same text,
                              // same data, same styling.
                              Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    order.time,
                                    style: AppTheme.sans(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: statusColor.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '•',
                                    style: AppTheme.sans(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: statusColor.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  LiveTimeAgo(
                                    dt: order.createdAt,
                                    style: AppTheme.sans(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: statusColor.withValues(
                                        alpha: 0.7,
                                      ),
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
                        // PASS 8: the table/customer/items block is now
                        // wrapped in `Expanded` with each line given
                        // `maxLines: 1` + ellipsis, and the price is
                        // wrapped in a `Flexible` + `FittedBox`, so a long
                        // table/customer name truncates and the price can
                        // scale down slightly instead of either one
                        // overflowing off the right edge of a narrow
                        // card. Same data, same styling, same order.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          _Palette.milanoRed.withValues(
                                            alpha: 0.10,
                                          ),
                                          _Palette.milanoRed.withValues(
                                            alpha: 0.04,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                      border: Border.all(
                                        color: _Palette.milanoRedDeep
                                            .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.table_bar_rounded,
                                      size: 22,
                                      color: _Palette.milanoRedDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.table,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.serif(
                                            size: 18,
                                            weight: FontWeight.w800,
                                            color: _Palette.textDark,
                                          ),
                                        ),
                                        if (order.customerName != null)
                                          Text(
                                            order.customerName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.sans(
                                              size: 14,
                                              weight: FontWeight.w700,
                                              color: _Palette.textDark
                                                  .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        Text(
                                          '${order.items} items ordered',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.sans(
                                            size: 13,
                                            color: _Palette.textMuted,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  CurrencyUtils.format(order.total),
                                  style: AppTheme.serif(
                                    size: 22,
                                    weight: FontWeight.w900,
                                    color: _Palette.milanoRedDeep,
                                  ),
                                ),
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
                              // PASS 8: wrapped in `Flexible` + ellipsis so
                              // this label yields space to the "View
                              // Details" pill instead of overflowing past
                              // it on a narrow card.
                              Flexible(
                                child: Text(
                                  'Assigned to Staff',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.sans(
                                    size: 11,
                                    weight: FontWeight.w600,
                                    color: _Palette.textMuted,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}
