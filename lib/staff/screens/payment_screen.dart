import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../contexts/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the Billing / Dashboard /
/// Orders / New Orders / Create Order / Menu Management screens exactly,
/// so this screen now reads as part of the same cohesive, professional
/// brand. Field names are kept identical to the previous palette so every
/// usage below the class still lines up — only the color VALUES changed.
/// Nothing here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: brought this screen's header and section cards
/// up to the "command bar" identity used on the Create Order / Orders
/// screens — a four-stop diagonal gradient header, a watermark emblem, a
/// glass highlight line, and a live quick-stats readout strip built from
/// values already computed in build(). No provider, controller, route, or
/// payment-processing logic was touched in that pass — only presentation.
///
/// UI-ENHANCEMENT PASS 3:
///   1. The header (`_ScreenHeader`) has been rebuilt to match the
///      Billing screen's top-navbar exactly — a clean two-stop Deep Wine
///      Maroon → Wine gradient, rounded bottom corners, a subtle
///      deeper-wine wash toward the bottom, two soft ambient gold glows,
///      a small icon + label row above the big serif title, a plain
///      typographic tagline anchored by a small gold accent rule (no
///      photo, no watermark emblem, no dotted texture row, no four-stop
///      gradient), a single unified date/live row, and a thin gold
///      gradient hairline underneath. The existing back-navigation
///      control (`onBack`) is preserved exactly as before — it now sits
///      in a simple top row above the icon/title block instead of beside
///      a boxed date pill.
///   2. The header's old in-banner "Items / Amount Due / Method" readout
///      strip was pulled OUT of the header entirely and now renders as
///      its own `_StatsRow` of three `_StatCard`s directly below the
///      header — mirroring the Billing screen's `_StatsRow`/`_StatCard`
///      pattern exactly. This is a pure layout relocation: `itemsCount`,
///      `amountDue`, and `methodLabel` are the exact same values already
///      computed in `build()`, simply passed to `_StatsRow` instead of
///      the header. `_HeaderStatPill`/`_HeaderStatDivider` and the old
///      `statCapsuleShadow` are no longer needed and were removed.
///   3. `_Palette`'s underlying `Color` values were swapped for the
///      PUREDINE Maroon + Cream brand palette (Deep Wine Maroon, Wine,
///      Burgundy, Warm Off-White, Soft Cream, Warm Gold, Soft Yellow, Deep
///      Brown/Black, Muted Taupe, Fresh Green, Dusty Blush, Pale Rose,
///      Pale Mint) — matching the Billing screen's palette exactly. No
///      provider, controller, route, or payment-processing logic was
///      touched anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 4: `_ScreenHeader`'s bottom edge is now
/// a straight, flat line instead of the previous rounded 32px bottom
/// corners — matching the flat-bottom topbar treatment used on the
/// Tables (Floor Plan) screen's header. The rounded `BorderRadius` on the
/// header `Container`/`ClipRRect` was removed (so the banner is now a
/// plain rectangle, using `ClipRect` instead of `ClipRRect`) and a thin
/// warm-gold hairline border was added along the bottom edge, mirroring
/// the Tables screen's own bottom-edge accent. Everything else inside the
/// header — the gradient, the drop shadow, the ambient gold glows, the
/// back-navigation control, the title block, the tagline, and the
/// date/live row — is completely unchanged, as is every other part of
/// this file (`_StatsRow`, `_StatCard`, `_SectionCard`, payment method
/// selection, and all provider/payment-processing logic in
/// `_PaymentScreenState`). Presentation only.
///
/// UI-ENHANCEMENT PASS 5 (this pass): RESPONSIVE LAYOUT PASS
/// (MOBILE / TABLET / LAPTOP) — no navigation, provider/payment-processing
/// logic, callbacks, routes, copy, or any existing field/keyword anywhere
/// in this file was renamed, removed, or otherwise touched. Previously
/// `_ScreenHeader` used its own standalone `800` cutoff (inconsistent
/// with the rest of the app's `600` mobile threshold), the body's content
/// column was capped at a flat `1280px` regardless of device (far too
/// wide for a single-column checkout form on a laptop monitor), and
/// `_StatCard`/`_SectionCard` had no tablet/laptop tier at all. This pass
/// fixes all three:
///   1. SHARED BREAKPOINTS: two new top-level constants,
///      `_kTabletBreakpointWidth` (`600`) and `_kLaptopBreakpointWidth`
///      (`1024`), are now used consistently everywhere a device tier is
///      needed. The screen's existing top-level `isMobile` (already
///      `width < 600`) now reads from `_kTabletBreakpointWidth` instead
///      of a bare `600` literal (identical value, just named), and new
///      `isTablet`/`isDesktop` flags (`600–1023` / `1024+`) sit alongside
///      it — all computed once in `build()` and threaded down to
///      `_StatsRow`/`_StatCard` and both `_SectionCard`s. `_ScreenHeader`'s
///      old standalone `800` cutoff is replaced with the same shared
///      constants, so the header and the rest of the screen now agree on
///      exactly where "tablet" starts and ends.
///   2. A SENSIBLE, DEVICE-AWARE CONTENT WIDTH: the body's `ConstrainedBox`
///      now caps the single-column payment form at a device-appropriate
///      reading width — `double.infinity` on mobile (unchanged), `760`
///      on tablet, and `860` on laptop — instead of one flat `1280`, so
///      the order-details/items/total/payment-method cards read as a
///      deliberate, comfortably-wide checkout column on a laptop monitor
///      instead of stretching edge-to-edge across the whole screen. The
///      body's outer padding is also now tiered (mobile/tablet/laptop)
///      instead of a single fixed value.
///   3. THREE-TIER SIZING: every metric in `_ScreenHeader` that used to
///      be a two-way `isMobile ? a : b` ternary (padding, title font
///      size, tagline font size, date/live font sizes, and row gaps) is
///      now three-way (`isMobile ? a : (isTablet ? c : b)`), with the
///      tablet number sitting sensibly between the existing mobile and
///      desktop numbers. `_StatCard` and `_SectionCard` each gained new
///      `isTablet`/`isDesktop` boolean inputs (added alongside their
///      existing fields — nothing renamed) used only to scale their own
///      icon sizes, padding, and font sizes up a notch on tablet and
///      laptop. The "Total Amount" card and the payment-method list
///      (built inline in `build()`, not their own widget classes) were
///      similarly given their own tablet/laptop tier via three-tier local
///      variables replacing what were previously fixed numbers. The exact
///      original mobile numbers are fully preserved everywhere, and every
///      card keeps the exact same content, arrangement, payment-method
///      selection logic, and the Confirm Payment / Cancel Payment
///      callbacks exactly as before — only sizing changed.
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
  // Deepest wine tone — kept for potential shadow/overlay depth use.
  static const Color milanoRedDarkest = Color(0xFF3D0F1B);

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
  static const Color goldDeep = Color(0xFFD9A63E);
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
  /// softShadow used on Billing/Dashboard/Menu/Order Details so every
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

  /// Header/hero drop shadow — matches the Billing screen's header
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

  /// A dedicated, slightly stronger "floating card" shadow used by the
  /// stat cards now that they sit outside the header — matches the
  /// Billing screen's `floatingShadow` treatment exactly.
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
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

// PASS 5: shared responsive breakpoints used across this screen's header,
// stats row, section cards, the total card, and the payment-method list,
// so mobile / tablet / laptop all get their own properly proportioned
// layout instead of tablets being silently treated as either phones or
// laptops.
const double _kTabletBreakpointWidth = 600;
const double _kLaptopBreakpointWidth = 1024;

class PaymentScreen extends StatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _isProcessing = false;

  final _methods = [
    {'id': 'cash', 'label': 'Cash', 'icon': Icons.payments_outlined},
    {'id': 'upi', 'label': 'UPI', 'icon': Icons.phone_android_outlined},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrderDetail());
  }

  Future<void> _loadOrderDetail() async {
    if (!mounted) return;
    final token = context.read<StaffAuthProvider>().token;
    if (token != null) {
      await context.read<OrdersProvider>().fetchOrderDetail(
            widget.orderId,
            token,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order = provider.findById(widget.orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final finalTotal = order.total.round();

    // Purely display values for the stats row below the header — derived
    // from data already computed/available here. No new data source, no
    // logic change.
    final itemsCount = order.itemsDetails.length;
    final selectedMethodLabel = _selectedMethod == null
        ? 'Not Selected'
        : _methods.firstWhere((m) => m['id'] == _selectedMethod)['label']
            as String;

    // PASS 5: `isMobile` keeps its exact original meaning and value
    // (`width < 600`), just reading from the shared named constant
    // instead of a bare literal. `isTablet`/`isDesktop` are new — so the
    // stats row, section cards, total card, and payment-method list can
    // each get their own properly proportioned tablet/laptop sizing
    // instead of jumping straight from "mobile" numbers to one flat
    // "everything else" treatment.
    final isMobile =
        MediaQuery.of(context).size.width < _kTabletBreakpointWidth;
    final isTablet = !isMobile &&
        MediaQuery.of(context).size.width < _kLaptopBreakpointWidth;
    final isDesktop = !isMobile && !isTablet;

    // PASS 5: tiered outer padding (mobile/tablet/laptop) instead of one
    // fixed value, plus a device-appropriate content width cap — a
    // single-column checkout form reads far better capped at a
    // comfortable reading width than stretched to the old flat `1280px`
    // on a laptop monitor. Mobile is unaffected (`double.infinity` is the
    // exact original behaviour).
    final double bodyHorizontalPadding = isMobile ? 16 : (isTablet ? 28 : 36);
    final double bodyTopPadding = isMobile ? 16 : (isTablet ? 20 : 24);
    final double bodyBottomPadding = isMobile ? 32 : (isTablet ? 36 : 40);
    final double contentMaxWidth =
        isMobile ? double.infinity : (isTablet ? 760 : 860);

    // PASS 5: three-tier sizing for the "Total Amount" card and the
    // payment-method list — mobile numbers are the exact originals,
    // tablet sits between mobile and laptop, laptop is a modest step up
    // for a fuller, more professional look on large screens.
    final double totalHeaderVPad = isMobile ? 22 : (isTablet ? 24 : 26);
    final double totalFigureFontSize = isMobile ? 38 : (isTablet ? 41 : 44);
    final double totalContentPad = isMobile ? 22 : (isTablet ? 24 : 26);
    final double methodListPad = isMobile ? 16 : (isTablet ? 18 : 20);
    final double methodRowPad = isMobile ? 15 : (isTablet ? 16 : 17);
    final double methodIconChipPad = isMobile ? 9 : (isTablet ? 10 : 11);
    final double methodLabelFontSize = isMobile ? 16 : (isTablet ? 16.5 : 17);

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header draws behind the
      // status bar, matching the Billing / Order Details / Orders
      // screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Billing / Menu Management
          // screens' "foggy" backdrop so the whole admin/staff experience
          // feels like one cohesive brand. No logic touched — visuals
          // only.
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
                  // long scroll area a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  Positioned(
                    top: 600,
                    left: -70,
                    child: Container(
                      width: 250,
                      height: 250,
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
          // used in the header itself. Matches the Billing / Dashboard
          // screens' backdrop treatment.
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
              // ── Header — rebuilt to match the Billing screen's top
              // navbar for its content (icon + label, big title, tagline,
              // date/live row), now with a flat, straight bottom edge and
              // gold hairline matching the Tables screen's header shape.
              // The existing `onBack` control is preserved exactly as
              // before. ──────────────────────────
              _ScreenHeader(
                title: 'Process Payment',
                subtitle: order.table,
                dateLabel: _todayLabel(),
                onBack: () => context.pop(),
              ),

              // BODY — the three stat cards now live at the top of this
              // scrollable area instead of sitting fixed on the canvas
              // below the header, so the scroll region starts right from
              // the cards. Same three values (`itemsCount` / `finalTotal`
              // / `selectedMethodLabel`) already computed above — purely
              // a layout relocation, no new data source.
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
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Column(
                        children: [
                          // ── Live Stats Row — mirrors the Billing
                          // screen's `_StatsRow`/`_StatCard` pattern
                          // exactly, now scrolling together with the rest
                          // of the body content.
                          _StatsRow(
                            itemsCount: itemsCount,
                            amountDue: finalTotal,
                            methodLabel: selectedMethodLabel,
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 20),

                          // 🔥 ORDER DETAILS
                          _SectionCard(
                            icon: Icons.receipt_long_rounded,
                            title: 'Order Details',
                            railColor: _Palette.milanoRed,
                            isMobile: isMobile,
                            isTablet: isTablet,
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
                          ),
                          const SizedBox(height: 18),

                          // 🔥 ORDER ITEMS
                          _SectionCard(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'Items',
                            railColor: _Palette.gold,
                            isMobile: isMobile,
                            isTablet: isTablet,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...order.itemsDetails.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _Palette.milanoRed
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _Palette.gold.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '${item.quantity}x',
                                            style: AppTheme.sans(
                                              size: 12,
                                              weight: FontWeight.w800,
                                              color: _Palette.milanoRedDeep,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: AppTheme.sans(
                                              size: 14,
                                              color: _Palette.textDark
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${(item.quantity * (double.tryParse(item.price) ?? 0)).round()}',
                                          style: AppTheme.sans(
                                            size: 14,
                                            weight: FontWeight.w700,
                                            color: _Palette.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 🔥 TOTAL CARD (CENTERED - FIXED, now themed)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                              boxShadow: _Palette.softShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Themed header strip, echoing the Order
                                // Summary card on the Order Details
                                // screen, now with a richer ribbon glow +
                                // gold trim.
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: totalHeaderVPad,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _Palette.milanoRedLight,
                                        _Palette.milanoRed,
                                        _Palette.milanoRedDeep,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _Palette.lemonChiffon,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: -30,
                                        right: -30,
                                        child: Transform.rotate(
                                          angle: -0.5,
                                          child: Container(
                                            width: 140,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  _Palette.lemonChiffon
                                                      .withValues(alpha: 0.16),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -30,
                                        left: -30,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0.06,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _Palette.lemonChiffon
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              'TOTAL AMOUNT',
                                              style: AppTheme.sans(
                                                size: 11,
                                                weight: FontWeight.w800,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ).copyWith(letterSpacing: 1.0),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '₹$finalTotal',
                                            style: AppTheme.serif(
                                              size: totalFigureFontSize,
                                              weight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(totalContentPad),
                                  child: Column(
                                    children: [
                                      if (order.subtotal > 0)
                                        _AmountRow(
                                          'Subtotal',
                                          '₹${order.subtotal.round()}',
                                        ),
                                      if (order.tax > 0)
                                        _AmountRow(
                                          'Tax',
                                          '₹${order.tax.round()}',
                                        ),
                                      const SizedBox(height: 10),
                                      Divider(
                                        color: _Palette.milanoRedDeep
                                            .withValues(alpha: 0.10),
                                      ),
                                      const SizedBox(height: 10),
                                      _AmountRow(
                                        'Total',
                                        '₹$finalTotal',
                                        bold: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 🔥 PAYMENT METHOD TITLE
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        _Palette.gold,
                                        _Palette.goldLight,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Payment Method",
                                  style: AppTheme.sans(
                                    size: 16,
                                    weight: FontWeight.bold,
                                    color: _Palette.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 🔥 PAYMENT METHODS (GOOD UI PRESERVED, now themed)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(methodListPad),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: Column(
                              children: _methods.map((m) {
                                final isSelected = _selectedMethod == m['id'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMethod = m['id'] as String;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 200,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(methodRowPad),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                _Palette.milanoRed.withValues(
                                                  alpha: 0.08,
                                                ),
                                                _Palette.lemonChiffon
                                                    .withValues(alpha: 0.06),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(13),
                                      border: Border.all(
                                        color: isSelected
                                            ? _Palette.milanoRedDeep
                                            : _Palette.milanoRedDeep
                                                .withValues(alpha: 0.14),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: _Palette.milanoRedDeep
                                                    .withValues(alpha: 0.14),
                                                blurRadius: 12,
                                                offset: const Offset(0, 5),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            methodIconChipPad,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      _Palette.milanoRed,
                                                      _Palette.milanoRedDeep,
                                                    ],
                                                  )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : _Palette.canvas,
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            border: isSelected
                                                ? Border.all(
                                                    color: _Palette.gold
                                                        .withValues(
                                                      alpha: 0.5,
                                                    ),
                                                  )
                                                : Border.all(
                                                    color: _Palette
                                                        .milanoRedDeep
                                                        .withValues(
                                                      alpha: 0.08,
                                                    ),
                                                  ),
                                          ),
                                          child: Icon(
                                            m['icon'] as IconData,
                                            color: isSelected
                                                ? Colors.white
                                                : _Palette.textMuted,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 13),
                                        Expanded(
                                          child: Text(
                                            m['label'] as String,
                                            style: AppTheme.sans(
                                              size: methodLabelFontSize,
                                              weight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: _Palette.textDark,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: _Palette.milanoRedDeep,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 🔥 BUTTON (NO ERROR) — themed gold-trimmed
                          // maroon to match the primary actions on the
                          // other screens
                          PrimaryButton(
                            label: _isProcessing
                                ? "Processing..."
                                : 'Confirm Payment · ₹$finalTotal',
                            onTap: (_selectedMethod == null || _isProcessing)
                                ? null
                                : () async {
                                    await _handlePayment(
                                      context,
                                      provider,
                                      finalTotal,
                                    );
                                  },
                            color: _Palette.milanoRedDeep,
                            textColor: Colors.white,
                            icon: Icons.check_circle_rounded,
                          ),

                          const SizedBox(height: 10),

                          PremiumBackButton(
                            label: 'Cancel Payment',
                            onTap: () => context.pop(),
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

  // 🔥 CLEAN HANDLER
  Future<void> _handlePayment(
    BuildContext context,
    OrdersProvider provider,
    int finalTotal,
  ) async {
    setState(() => _isProcessing = true);

    final token = context.read<StaffAuthProvider>().token;

    if (token == null) {
      setState(() => _isProcessing = false);
      return;
    }

    try {
      await provider.payOrder(widget.orderId, token);

      if (!context.mounted) return;

      // BillScreen reads straight from the provider and can't fetch on its
      // own — make sure it has the real subtotal/tax_amount before we go.
      await provider.fetchOrderDetail(widget.orderId, token);

      if (!context.mounted) return;

      context.pushReplacement(
        '/staff/bill',
        extra: {
          'orderId': widget.orderId,
          'tipAmount': 0,
          'finalTotal': finalTotal,
          'paymentMethod': _selectedMethod,
        },
      );
    } catch (e) {
      debugPrint("Payment error: $e");
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }
}

/// Small decorative gradient divider placed beneath a section title —
/// purely cosmetic, mirrors the same accent used on the Billing / Order
/// Details / Menu Management screens.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider() : width = 46;

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
            _Palette.gold.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Section Card — same white, softly bordered, softly shadowed card
// language used by the Order Details screen, plus the same thin gold
// accent bar used as a section marker, so every card on this screen reads
// as part of the same brand. Each card carries a slim color-coded accent
// rail down the left edge (matching the Create Order / Orders screens'
// card treatment), and the icon chip picked up a soft colored glow.
// Purely presentational — wraps the exact same child content as before.
//
// PASS 5: gained two new inputs, `isMobile` and `isTablet` (added
// alongside the existing fields — nothing renamed), used only to scale
// the card's own padding, icon chip size, and title font size up a notch
// on tablet and laptop for a fuller, more professional feel on larger
// screens. The original mobile numbers are fully preserved.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color railColor;
  final bool isMobile;
  final bool isTablet;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.isMobile,
    required this.isTablet,
    this.railColor = _Palette.milanoRed,
  });

  @override
  Widget build(BuildContext context) {
    final double cardPad = isMobile ? 20 : (isTablet ? 22 : 24);
    final double iconChipSize = isMobile ? 34 : (isTablet ? 36 : 38);
    final double iconSize = isMobile ? 17 : (isTablet ? 18 : 19);
    final double titleFontSize = isMobile ? 18 : (isTablet ? 19 : 20);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    railColor.withValues(alpha: 0.85),
                    railColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconChipSize,
                      height: iconChipSize,
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
                        color: _Palette.milanoRedDeep,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 11),
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
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 45),
                  child: _TitleDivider(),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Screen header — content matches the Billing screen's top-navbar
// exactly (icon + label above the big serif title, plain-text tagline
// anchored by a small gold accent rule, unified date/live row, thin gold
// hairline underneath, two soft ambient gold glows, and the preserved
// `onBack` control sitting in its own top row). The SHAPE now matches the
// Tables (Floor Plan) screen's header instead of Billing's: a straight,
// flat bottom edge (no rounded corners) with a thin warm-gold hairline
// border along that edge, using `ClipRect` in place of `ClipRRect`. No
// photo, no watermark, no icon badge box of any kind.
//
// PASS 5: now classifies the screen into mobile / tablet / laptop using
// the same shared `_kTabletBreakpointWidth` / `_kLaptopBreakpointWidth`
// constants the rest of the screen uses (replacing the old standalone
// `800` cutoff), and every previously two-way `isMobile ? a : b` size
// below is now three-way `isMobile ? a : (isTablet ? c : b)` so tablets
// get their own properly proportioned numbers instead of inheriting
// either the phone or the laptop treatment.
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
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
        // Two-stop Deep Wine Maroon → Wine gradient, matching the Billing
        // screen's header exactly.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
        // Straight, flat bottom edge — no rounded corners — matching the
        // Tables screen's topbar shape, plus the same thin warm-gold
        // hairline the Tables screen uses along that bottom edge.
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
            // content — purely decorative, mirroring the Billing screen's
            // header exactly.
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
                    // ── Top row: the existing back-navigation control —
                    // preserved exactly as before (same `onBack`
                    // callback), just restyled to sit cleanly above the
                    // title block instead of beside a boxed date pill.
                    Row(
                      children: [
                        _BackChevronButton(onTap: onBack),
                      ],
                    ),

                    SizedBox(height: isMobile ? 14 : (isTablet ? 16 : 18)),

                    // ── Title block: small icon + label, then the big
                    // title — matches the Billing header's title block
                    // language exactly.
                    Row(
                      children: [
                        Icon(
                          Icons.table_restaurant_rounded,
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

                    SizedBox(height: isMobile ? 16 : (isTablet ? 18 : 20)),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge, no
                    // image of any kind — just clean, confident cream
                    // typography sitting directly in the header, with a
                    // small gold accent rule above it to anchor the line
                    // — matches the Billing screen's tagline treatment
                    // exactly.
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
                      'Complete the payment, seamlessly.',
                      style: AppTheme.serif(
                        size: isMobile ? 15.5 : (isTablet ? 16.5 : 18),
                        weight: FontWeight.w800,
                        color: _Palette.canvasDeep,
                      ).copyWith(height: 1.3, letterSpacing: 0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isMobile ? 14 : (isTablet ? 16 : 18)),

                    // ── Date + Live row ──────────────────────────────
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

// ─── Live Stats Row (fully outside the header) ─────────────────────────
// Mirrors the Billing screen's `_StatsRow`/`_StatCard` pattern exactly:
// three floating white cards sitting on the plain canvas directly below
// the header, built from the exact same `itemsCount` / `amountDue` /
// `methodLabel` values already computed at the call site. No data,
// provider, or navigation logic lives here — purely a display of values
// already available at the call site.
//
// PASS 5: gained a new `isTablet` input (added alongside the existing
// `isMobile` — nothing renamed), used only to widen the gap between the
// three cards a touch on tablet and to scale `_StatCard`'s own sizing.
class _StatsRow extends StatelessWidget {
  final int itemsCount;
  final int amountDue;
  final String methodLabel;
  final bool isMobile;
  final bool isTablet;

  const _StatsRow({
    required this.itemsCount,
    required this.amountDue,
    required this.methodLabel,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double gap = isMobile ? 10 : (isTablet ? 12 : 14);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_basket_rounded,
            value: '$itemsCount',
            label: 'Items',
            iconBg: _Palette.lemonChiffon.withValues(alpha: 0.55),
            iconColor: _Palette.goldDeep,
            isTablet: isTablet,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            icon: Icons.payments_rounded,
            value: '₹$amountDue',
            label: 'Amount Due',
            iconBg: _Palette.dustyBlush,
            iconColor: _Palette.milanoRedDeep,
            isTablet: isTablet,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            icon: Icons.credit_card_rounded,
            value: methodLabel,
            label: 'Method',
            iconBg: _Palette.paleMint,
            iconColor: _Palette.successDeep,
            isTablet: isTablet,
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, delay: 150.ms).slideY(begin: 0.25);
  }
}

// ─── Individual Stat Card ────────────────────────────────────────────────
// A horizontal icon + value/label layout on its own white rounded card
// with a floating drop shadow — matches the Billing screen's `_StatCard`
// exactly, designed to read clearly straddling the maroon header above it
// and the white canvas beneath it.
//
// PASS 5: gained a new `isTablet` input (added alongside the existing
// fields — nothing renamed), used only to scale the icon circle, value
// font size, and padding up a notch on tablet/laptop (the "not tablet"
// branch already covers laptop, matching how this card was originally
// sized for anything wider than mobile). The original mobile numbers are
// fully preserved.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isTablet;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double iconContainerSize = isTablet ? 40 : 38;
    final double iconSize = isTablet ? 18 : 17;
    final double valueFontSize = isTablet ? 18 : 17;
    final double horizontalPad = isTablet ? 13 : 12;
    final double verticalPad = isTablet ? 15 : 14;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: _Palette.floatingShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            child: Icon(
              icon,
              size: iconSize,
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
                    size: valueFontSize,
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

/// Compact icon-only "back" control — a circular glass button showing
/// only a plain "‹" glyph. Same minimal, professional control used on the
/// Billing / Order Details screens' headers, for a consistent brand-wide
/// top bar. The `onTap` callback is unchanged — still calls `context.pop()`
/// exactly as before.
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

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _AmountRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.sans(
              size: bold ? 15 : 13,
              weight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? _Palette.textDark : _Palette.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTheme.sans(
              size: bold ? 18 : 13,
              weight: bold ? FontWeight.w900 : FontWeight.w600,
              color: bold ? _Palette.milanoRedDeep : _Palette.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: _Palette.milanoRedDeep.withValues(alpha: 0.06),
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
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.sans(
              size: 14,
              weight: FontWeight.w700,
              color: _Palette.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
