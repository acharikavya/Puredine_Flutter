import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/auth_provider.dart';
import '../contexts/orders_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../utils/printing_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the New Orders / Create Order
/// / Menu Management / Orders / Tables / Profile screens exactly, so this
/// screen now reads as part of the same cohesive, professional brand
/// instead of its own one-off theme. Used ONLY for this screen's visual
/// layer. Nothing here touches AppColors, AppTheme, or any other file —
/// pure UI enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 3: the header (`_ScreenHeader`) was rebuilt from
/// scratch to match the Profile/Tables/Orders screens' header language —
/// a two-stop maroon-to-wine gradient, a soft pair of ambient gold glows,
/// a title block (small icon + subtitle label, then the big title), a
/// plain typographic tagline with a small gold accent rule, a date/live
/// row, and a thin gold gradient hairline underneath. The back-navigation
/// control and the status badge are real features, so they were kept —
/// restyled into the same minimal glass-chip language used elsewhere. No
/// provider, controller, route, status-transition, or data value was
/// touched — only presentation changed.
///
/// UI-ENHANCEMENT PASS 4: `_ScreenHeader`'s bottom edge is now
/// a straight, flat line instead of the previous rounded 32px corners —
/// matching the flat-bottom topbar treatment used on the Tables screen's
/// header. The rounded `BorderRadius` on the header `Container`/`ClipRRect`
/// was removed (so the banner is now a plain rectangle, using `ClipRect`
/// instead of `ClipRRect`) and a thin warm-gold hairline border was added
/// along the bottom edge, mirroring Tables' own bottom-edge accent.
/// Everything else inside the header — the gradient, the drop shadow, the
/// ambient gold glows, the back chip, the status chip, the title block,
/// the tagline, and the date/live row — is completely unchanged, as is
/// every other part of this file (order summary, items, totals, action
/// buttons, and all provider/status logic in `_OrderDetailsScreenState`).
/// Presentation only.
///
/// UI-ENHANCEMENT PASS 5 (this pass): RESPONSIVE LAYOUT PASS
/// (MOBILE / TABLET / LAPTOP) — no navigation, provider/status logic,
/// callbacks, routes, copy, or any existing field/keyword anywhere in
/// this file was renamed, removed, or otherwise touched. Previously
/// `_ScreenHeader` only ever branched on a single `isMobile` check
/// (`width < 800`), so every tablet was silently forced into either the
/// cramped "mobile" numbers or the full "desktop" numbers depending only
/// on which side of 800px it happened to fall on, and the scrollable body
/// below the header had no tablet/laptop tier at all — its padding was a
/// single fixed value and its content had no max-width cap, so the
/// summary/items cards could stretch unnaturally wide on a laptop/desktop
/// screen. This pass fixes both:
///   1. SHARED BREAKPOINTS: two new top-level constants,
///      `_kTabletBreakpointWidth` (`600`) and `_kLaptopBreakpointWidth`
///      (`1024`), are now used consistently by both `_ScreenHeader` and
///      the scrollable body, replacing the header's old standalone `800`
///      threshold. `isMobile` now means `width < 600` and a new `isTablet`
///      flag covers `600–1023`; `1024` and above is laptop/desktop — the
///      same three-tier split used elsewhere in the app.
///   2. THREE-TIER SIZING: every metric that used to be a two-way
///      `isMobile ? mobileValue : desktopValue` ternary in `_ScreenHeader`
///      (padding, title font size, tagline font size, date/live font
///      sizes, and the vertical gaps between the header's rows) is now a
///      three-way `isMobile ? mobileValue : (isTablet ? tabletValue :
///      desktopValue)` ternary, with the tablet number always sitting
///      sensibly between the existing mobile and desktop numbers.
///   3. BODY CONTENT — WIDTH CAP + TIERED PADDING: the body's
///      `SingleChildScrollView` padding is now three-tier
///      (mobile/tablet/laptop) instead of one fixed value, and its
///      content `Column` is wrapped in a `Center` + `ConstrainedBox`
///      capping the content at a sensible max width on tablet (`820`)
///      and laptop (`960`) — so on a wide laptop monitor the order
///      summary, items, and action buttons read as a deliberate,
///      centered, professional column instead of stretching edge-to-edge
///      across the whole screen. Mobile is unaffected (`double.infinity`,
///      i.e. the exact original behaviour) since phone screens are
///      always narrower than either cap anyway.
///   4. CARD POLISH ON TABLET & LAPTOP: `_SectionCard` gained two new
///      boolean inputs, `isMobile` and `isTablet` (new parameters added
///      alongside the existing ones — nothing existing was renamed), used
///      only to scale its own padding, corner radius, and title font size
///      up a notch on tablet and laptop for a fuller, more professional
///      feel on larger screens. The order-items row's quantity badge and
///      the Subtotal/Tax/Total figures were similarly given their own
///      tablet/laptop tier, computed inline in
///      `_OrderDetailsScreenState.build()` (no new widget/field, just
///      three-tier local variables replacing the previous fixed numbers).
///      The exact original mobile numbers are fully preserved everywhere,
///      and every card keeps the exact same content, arrangement, status
///      logic, and action-button callbacks as before — only sizing
///      changed.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// the other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
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
  /// softShadow used on Menu/Create Order/New Orders/Orders/Tables/
  /// Profile so every card on this screen carries the same warm, branded
  /// elevation.
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

  /// Header/hero drop shadow — matches the Profile/Tables/New Orders hero
  /// exactly.
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

// PASS 5: shared responsive breakpoints used by both `_ScreenHeader` and
// the scrollable body content below it, so mobile / tablet / laptop all
// get their own properly proportioned layout instead of tablets being
// silently treated as either phones or laptops depending only on which
// side of a single cutoff they happened to fall on.
const double _kTabletBreakpointWidth = 600;
const double _kLaptopBreakpointWidth = 1024;

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final String? from;

  const OrderDetailsScreen({super.key, required this.orderId, this.from});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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
      if (!mounted) return;
      // The list endpoint above doesn't include subtotal/tax_amount —
      // fetch the single-order detail so the real tax shows correctly.
      await ordersProvider.fetchOrderDetail(widget.orderId, auth.token!);
    }
  }

  Map<String, dynamic> _getConfig(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return {
          'label': 'CONFIRMED',
          'bg': const Color(0xFFFEF3C7),
          'color': const Color(0xFFD97706),
        };
      case OrderStatus.preparing:
        return {
          'label': 'PREPARING',
          'bg': const Color(0xFFDBEAFE),
          'color': const Color(0xFF2563EB),
        };
      case OrderStatus.ready:
        return {
          'label': 'READY TO SERVE',
          'bg': const Color(0xFFD1FAE5),
          'color': const Color(0xFF059669),
        };
      case OrderStatus.served:
        return {
          'label': 'SERVED',
          'bg': _Palette.canvasDeep,
          'color': _Palette.textMuted,
        };
      case OrderStatus.billed:
        return {
          'label': 'BILLED',
          'bg': const Color(0xFFFEF3C7),
          'color': const Color(0xFFD97706),
        };
      case OrderStatus.paid:
        return {
          'label': 'PAID',
          'bg': const Color(0xFFD1FAE5),
          'color': const Color(0xFF059669),
        };
      default:
        return {
          'label': 'PLACED',
          'bg': _Palette.canvasDeep,
          'color': _Palette.textMuted,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order = provider.findById(widget.orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: _Palette.canvas,
        appBar: AppBar(
          title: const Text('Order Not Found'),
          backgroundColor: _Palette.milanoRedDeep,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Order not found')),
      );
    }

    final config = _getConfig(order.status);
    final statusColor = config['color'] as Color;

    // PASS 5: shared mobile/tablet/laptop classification for the
    // scrollable body below the header (the header computes its own copy
    // internally using the same shared breakpoint constants).
    final bodyWidth = MediaQuery.of(context).size.width;
    final isMobileBody = bodyWidth < _kTabletBreakpointWidth;
    final isTabletBody = !isMobileBody && bodyWidth < _kLaptopBreakpointWidth;

    // PASS 5: tiered padding (mobile/tablet/laptop) instead of one fixed
    // value, plus a content max-width cap on tablet/laptop so the order
    // summary, items, and action buttons read as a deliberate, centered
    // column instead of stretching edge-to-edge on a wide laptop monitor.
    // Mobile is unaffected — `double.infinity` is the exact original
    // behaviour.
    final double bodyHorizontalPadding =
        isMobileBody ? 20 : (isTabletBody ? 32 : 40);
    final double bodyTopPadding = isMobileBody ? 24 : (isTabletBody ? 28 : 32);
    final double bodyBottomPadding =
        isMobileBody ? 32 : (isTabletBody ? 36 : 40);
    final double bodyContentMaxWidth =
        isMobileBody ? double.infinity : (isTabletBody ? 820 : 960);
    final double sectionGapSmall = isMobileBody ? 18 : (isTabletBody ? 20 : 22);
    final double sectionGapLarge = isMobileBody ? 22 : (isTabletBody ? 24 : 26);

    // PASS 5: three-tier sizing for the order-items row's quantity badge
    // and the Subtotal/Tax/Total figures — mobile numbers are the exact
    // originals, tablet sits between mobile and laptop, laptop is a
    // modest step up for a fuller, more professional look on large
    // screens.
    final double itemBadgeSize = isMobileBody ? 38 : (isTabletBody ? 41 : 44);
    final double itemBadgeFontSize =
        isMobileBody ? 12 : (isTabletBody ? 12.5 : 13);
    final double itemNameFontSize =
        isMobileBody ? 14 : (isTabletBody ? 14.5 : 15);
    final double itemPriceFontSize =
        isMobileBody ? 14 : (isTabletBody ? 14.5 : 15);
    final double totalLabelFontSize =
        isMobileBody ? 16 : (isTabletBody ? 17 : 18);
    final double totalValueFontSize =
        isMobileBody ? 24 : (isTabletBody ? 26 : 28);

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the New Orders / Create Order / Orders /
      // Tables / Profile screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Menu Management / Orders /
          // Tables / Profile screens' "foggy" backdrop so every staff/admin
          // screen feels like one cohesive brand. No logic touched —
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
                  // long item list / summary a second soft focal point
                  // instead of all the ambient light sitting only near
                  // the header.
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
              // ── Header — restyled to match the Profile/Tables/Orders
              // screens' header design language exactly (two-stop
              // maroon-to-wine gradient, flat bottom edge with a gold
              // hairline, back chip, title block, plain-text tagline with
              // a gold accent rule, date/live row, gold hairline). No
              // imagery/watermark/stats-strip. The status badge and back
              // control remain, restyled into the same minimal chip
              // language. ──
              _ScreenHeader(
                tableName: order.table,
                orderNumber: order.orderNumber,
                statusLabel: config['label'] as String,
                statusBg: config['bg'] as Color,
                statusColor: statusColor,
                dateLabel: _todayLabel(),
                itemsCount: order.items,
                totalLabel: '₹${order.total.round()}',
                timeLabel: order.time,
                onBack: () {
                  if (widget.from != null) {
                    context.go(widget.from!);
                  } else {
                    context.pop();
                  }
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    bodyHorizontalPadding,
                    bodyTopPadding,
                    bodyHorizontalPadding,
                    bodyBottomPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: bodyContentMaxWidth),
                      child: Column(
                        children: [
                          // Order summary card
                          _SectionCard(
                            title: 'Order Summary',
                            accentColor: statusColor,
                            isMobile: isMobileBody,
                            isTablet: isTabletBody,
                            trailing: Text(
                              order.time,
                              style: AppTheme.sans(
                                size: 13,
                                color: _Palette.textMuted,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (order.customerName != null) ...[
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Customer',
                                    value: order.customerName!,
                                  ),
                                  Divider(
                                    height: 24,
                                    color: _Palette.milanoRedDeep.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ],
                                _InfoRow(
                                  icon: Icons.table_restaurant_outlined,
                                  label: 'Table',
                                  value: order.table,
                                ),
                                Divider(
                                  height: 24,
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                                _InfoRow(
                                  icon: Icons.access_time,
                                  label: 'Time',
                                  value: order.time,
                                ),
                              ],
                            ),
                          ).animate().fade(duration: 400.ms).slideY(
                                begin: 0.06,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          SizedBox(height: sectionGapSmall),

                          // Items
                          _SectionCard(
                            title: 'Order Items',
                            accentColor: _Palette.gold,
                            isMobile: isMobileBody,
                            isTablet: isTabletBody,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...order.itemsDetails.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: itemBadgeSize,
                                          height: itemBadgeSize,
                                          decoration: BoxDecoration(
                                            color:
                                                _Palette.milanoRed.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            border: Border.all(
                                              color: _Palette.gold.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${item.quantity}x',
                                              style: AppTheme.sans(
                                                size: itemBadgeFontSize,
                                                weight: FontWeight.w800,
                                                color: _Palette.milanoRedDeep,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: AppTheme.sans(
                                              size: itemNameFontSize,
                                              weight: FontWeight.w500,
                                              color:
                                                  _Palette.textDark.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '₹${(item.quantity * (double.tryParse(item.price) ?? 0)).round()}',
                                          style: AppTheme.sans(
                                            size: itemPriceFontSize,
                                            weight: FontWeight.w700,
                                            color: _Palette.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _TotalRow(
                                  'Subtotal',
                                  '₹${order.subtotal.round()}',
                                ),
                                if (order.tax > 0) ...[
                                  const SizedBox(height: 8),
                                  _TotalRow('Tax', '₹${order.tax.round()}'),
                                ],
                                const SizedBox(height: 14),
                                Container(
                                  height: 1,
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: AppTheme.sans(
                                        size: totalLabelFontSize,
                                        weight: FontWeight.w800,
                                        color: _Palette.textDark,
                                      ),
                                    ),
                                    Text(
                                      '₹${order.total.round()}',
                                      style: AppTheme.serif(
                                        size: totalValueFontSize,
                                        weight: FontWeight.w900,
                                        color: _Palette.milanoRedDeep,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 400.ms, delay: 80.ms)
                              .slideY(
                                begin: 0.06,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
                          SizedBox(height: sectionGapLarge),

                          // Action buttons based on status
                          _ActionButtons(order: order, provider: provider)
                              .animate()
                              .fade(duration: 400.ms, delay: 160.ms)
                              .slideY(
                                begin: 0.06,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
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
}

// ─── Screen header — restyled to mirror the Profile/Tables/Orders
// screens' header exactly: a two-stop maroon-to-wine gradient, two soft
// ambient gold glows, a title block (small icon + subtitle label, then
// the big title), a plain-text tagline anchored by a small gold accent
// rule (no icon badge, no card, no border/shadow), and a date/live row
// with a thin gold gradient hairline underneath. No watermark emblem, no
// dotted texture, no photo imagery, no quick-stats readout strip — kept
// intentionally minimal per the Profile/Tables/Orders screens' design
// language. The back-navigation control and the status badge are real
// features, so they remain in the header's top row, restyled into the
// same minimal glass-chip language used for the back chip on
// Tables/Orders. The bottom edge is now a straight, flat line (no
// rounded corners) with a thin warm-gold hairline border along that
// edge, matching the Tables screen's flat-bottom topbar treatment. The
// tagline is data-driven off the itemsCount/totalLabel/timeLabel fields
// (already computed by the caller) purely as a text format — no new
// logic. Same onBack callback as before — this is a purely
// presentational change.
//
// PASS 5: now classifies the screen into mobile / tablet / laptop using
// the same shared `_kTabletBreakpointWidth` / `_kLaptopBreakpointWidth`
// constants the body content uses (replacing the old standalone `800`
// cutoff), and every previously two-way `isMobile ? a : b` size below is
// now three-way `isMobile ? a : (isTablet ? c : b)` so tablets get their
// own properly proportioned numbers instead of inheriting either the
// phone or the laptop treatment.
class _ScreenHeader extends StatelessWidget {
  final String tableName;
  final String orderNumber;
  final String statusLabel;
  final Color statusBg;
  final Color statusColor;
  final String dateLabel;
  final int itemsCount;
  final String totalLabel;
  final String timeLabel;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.tableName,
    required this.orderNumber,
    required this.statusLabel,
    required this.statusBg,
    required this.statusColor,
    required this.dateLabel,
    required this.itemsCount,
    required this.totalLabel,
    required this.timeLabel,
    required this.onBack,
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
        // Profile/Tables/New Orders hero exactly.
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
            // content — purely decorative, mirroring the Profile/Tables/
            // New Orders hero.
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
                    // ── Top row: icon-only back control, plus the order's
                    // status badge on the right — both real features, kept
                    // as-is, restyled into the same minimal glass-chip
                    // language used elsewhere. Same onBack callback as
                    // before — presentation only.
                    Row(
                      children: [
                        _BackChip(onTap: onBack),
                        const Spacer(),
                        _StatusChip(
                          label: statusLabel,
                          bg: statusBg,
                          color: statusColor,
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 16 : (isTablet ? 18 : 20)),

                    // ── Title block: small icon + subtitle label, then
                    // the big title — matches the Profile/Tables/New
                    // Orders header's title block exactly.
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
                              orderNumber,
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
                          tableName,
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
                    // it to anchor the line — matches the Profile/Tables/
                    // New Orders header's tagline treatment exactly. The
                    // copy itself formats the same itemsCount/totalLabel/
                    // timeLabel fields already computed by the caller —
                    // not a new data source.
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
                          '$itemsCount item${itemsCount == 1 ? '' : 's'} • $totalLabel • placed at $timeLabel.',
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
// in addition to the press state — matches the Tables/New Orders header's
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

// ─── Status chip — a thin gold-outlined glass chip tinted with the
// order's own semantic status color, so workflow state stays legible in
// the header's top row exactly where it used to live, just restyled to
// the minimal chip language used elsewhere. Same label/bg/color inputs
// as before — presentation only.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color color;

  const _StatusChip(
      {required this.label, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTheme.sans(
          size: 11,
          weight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Section Card — same white, softly bordered, softly shadowed card
// language used by the stat boxes / order cards across the staff app,
// plus the same thin gold accent bar used as a section marker, so every
// card on this screen reads as part of the same PUREDINE brand. Keeps
// the slim color-coded accent rail down the left edge (Order Summary
// picks up the current order-status color, Order Items keeps the brand
// gold) matching the Orders screen's order-card treatment. Purely
// presentational — wraps the exact same child content as before.
//
// PASS 5: gained two new inputs, `isMobile` and `isTablet` (added
// alongside the existing fields — nothing renamed), used only to scale
// the card's own padding, corner radius, and title font size up a notch
// on tablet and laptop for a fuller, more professional feel on larger
// screens. The original mobile numbers are fully preserved.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final Color accentColor;
  final bool isMobile;
  final bool isTablet;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isMobile,
    required this.isTablet,
    this.trailing,
    this.accentColor = _Palette.gold,
  });

  @override
  Widget build(BuildContext context) {
    final double cardPadding = isMobile ? 22 : (isTablet ? 24 : 26);
    final double cardRadius = isMobile ? 22 : (isTablet ? 24 : 26);
    final double titleFontSize = isMobile ? 18 : (isTablet ? 19 : 20);
    final double accentBarHeight = isMobile ? 20 : (isTablet ? 21 : 22);
    final double headerGap = isMobile ? 18 : (isTablet ? 19 : 20);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _Palette.canvasDeep.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: _Palette.paleRose.withValues(alpha: 0.7),
        ),
        boxShadow: _Palette.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Slim status/brand-colored accent rail down the left edge —
          // an instant visual cue tying this card to its context,
          // purely decorative. Matches the Orders screen's order-card
          // accent rail.
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
            padding: EdgeInsets.fromLTRB(
              cardPadding,
              cardPadding,
              cardPadding,
              cardPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: accentBarHeight,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_Palette.gold, _Palette.goldLight],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: AppTheme.serif(
                            size: titleFontSize,
                            weight: FontWeight.w800,
                            color: _Palette.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: headerGap),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info row — restyled onto the warm canvas/white card language, same
// icon/label/value content as before. ────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _Palette.dustyBlush,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _Palette.milanoRedDeep, size: 17),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTheme.sans(
            size: 13,
            color: _Palette.textMuted,
            weight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.sans(
            size: 14,
            weight: FontWeight.w700,
            color: _Palette.textDark,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sans(
            size: 13,
            color: _Palette.textMuted,
            weight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTheme.sans(
            size: 14,
            weight: FontWeight.w600,
            color: _Palette.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Action buttons — same PrimaryButton widget and same status-driven
// branching as before; only the colors passed in are recolored onto the
// PUREDINE Maroon / Gold palette so the call-to-action reads as part of
// the same brand. Blue/green are kept for "Preparing"/"Ready" since
// those carry real workflow meaning (in-progress vs. done) that's worth
// keeping visually distinct. No callback or condition changed. ─────────
class _ActionButtons extends StatelessWidget {
  final Order order;
  final OrdersProvider provider;

  const _ActionButtons({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    final token = context.read<StaffAuthProvider>().token;

    if (token == null) {
      return const Center(child: Text("Not authenticated"));
    }

    switch (order.status) {
      case OrderStatus.confirmed:
        return PrimaryButton(
          label: 'Mark as Preparing',
          color: const Color(0xFF2563EB),
          onTap: () => provider.updateOrderStatus(
            order.id,
            OrderStatus.preparing,
            token,
          ),
        );

      case OrderStatus.preparing:
        return PrimaryButton(
          label: 'Mark as Ready',
          color: const Color(0xFF059669),
          onTap: () =>
              provider.updateOrderStatus(order.id, OrderStatus.ready, token),
        );

      case OrderStatus.ready:
        return PrimaryButton(
          label: 'Mark as Served',
          color: _Palette.milanoRedDeep,
          onTap: () =>
              provider.updateOrderStatus(order.id, OrderStatus.served, token),
        );

      case OrderStatus.served:
        final role = context.read<StaffAuthProvider>().role;
        if (role == StaffRole.billingStaff) {
          return PrimaryButton(
            label: 'Generate Bill',
            color: _Palette.gold,
            textColor: _Palette.milanoRedDeep,
            onTap: () async {
              await provider.generateBill(order.id, token);
              if (!context.mounted) return;
              context.push('/staff/billing');
            },
          );
        }
        // Serving staff can print bill
        final authUser = context.read<StaffAuthProvider>().user;
        return Column(
          children: [
            PrimaryButton(
              label: 'Print Bill',
              icon: Icons.print_rounded,
              color: _Palette.gold,
              textColor: _Palette.milanoRedDeep,
              onTap: () => PrintingUtils.printOrderBill(
                order,
                restaurantName: authUser?.restaurantName,
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Download as PDF',
              icon: Icons.picture_as_pdf_rounded,
              color: _Palette.milanoRedDeep,
              onTap: () => PrintingUtils.downloadOrderBillPdf(
                order,
                restaurantName: authUser?.restaurantName,
              ),
            ),
          ],
        );

      case OrderStatus.billed:
        final billingRole = context.read<StaffAuthProvider>().role;
        if (billingRole == StaffRole.billingStaff) {
          return Column(
            children: [
              PrimaryButton(
                label: 'Process Payment',
                color: _Palette.milanoRedDeep,
                onTap: () => context.push('/staff/payment/${order.id}'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }
}
