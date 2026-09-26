import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../contexts/auth_provider.dart';
import '../contexts/orders_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../../core/currency_utils.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the Billing / Dashboard /
/// Create Order / Menu Management screens exactly, so this screen now
/// reads as part of the same cohesive, professional brand. Field names are
/// kept identical to the previous palette so every usage below the class
/// still lines up — only the color VALUES changed. Nothing here touches
/// AppColors, AppTheme, or any other file, and no logic — PDF generation,
/// printing, sharing, navigation — changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 3:
///   1. The header (`_ScreenHeader`) was rebuilt to match the Billing
///      screen's top-navbar language exactly — a clean two-stop Deep Wine
///      Maroon → Wine gradient, rounded bottom corners, a subtle
///      deeper-wine wash toward the bottom, two soft ambient gold glows
///      (no images, no watermark emblem, no dotted texture), a small icon
///      + subtitle label above the big serif title, a plain typographic
///      tagline anchored by a small gold accent rule, a date/status row,
///      and a thin gold gradient hairline underneath. The back button is
///      still the exact same `onBack` callback as before — it now sits in
///      its own compact row at the top of the header, unchanged behavior.
///   2. The header's old in-banner "Total Paid / Items / Method" readout
///      strip was pulled OUT of the header entirely and now renders as
///      its own `_StatsRow` of three `_StatCard`s directly inside the
///      scrollable body (mirroring the Billing screen's
///      `_StatsRow`/`_StatCard` pattern exactly). `finalTotal`,
///      `itemsCount`, and `paymentMethod` are the exact same values
///      already computed in `build()`, simply passed to `_StatsRow` — no
///      new data source, no logic change.
///   3. `_Palette`'s underlying `Color` values were swapped for the
///      PUREDINE Maroon + Cream brand palette (Deep Wine Maroon, Wine,
///      Burgundy, Warm Off-White, Soft Cream, Warm Gold, Soft Yellow, Deep
///      Brown/Black, Muted Taupe, Fresh Green, Dusty Blush, Pale Rose,
///      Pale Mint). No provider, controller, route, PDF, or payment logic
///      was touched anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 4: `_ScreenHeader`'s bottom edge is now a straight,
/// flat line instead of the previous rounded 32px bottom corners —
/// matching the flat-bottom topbar treatment used on the Tables (Floor
/// Plan) screen's header. The rounded `BorderRadius` on the header
/// `Container`/`ClipRRect` was removed (so the banner is now a plain
/// rectangle, using `ClipRect` instead of `ClipRRect`) and a thin
/// warm-gold hairline border was added along the bottom edge, mirroring
/// the Tables screen's own bottom-edge accent. Everything else inside the
/// header — the gradient, the drop shadow, the ambient gold glows, the
/// back-navigation control, the title block, the tagline, and the
/// date/status row — is completely unchanged, as is every other part of
/// this file (`_StatsRow`, `_StatCard`, receipt content, PDF generation,
/// printing, and sharing logic in `BillScreen`). Presentation only.
///
/// UI-ENHANCEMENT PASS 5 (this pass): RESPONSIVE LAYOUT + TABLET/LAPTOP
/// POLISH ONLY. No provider, controller, route, PDF generation, printing,
/// sharing, or navigation logic anywhere in this file was touched, and no
/// field, callback, or keyword was renamed.
///   1. BREAKPOINT FIX: `BillScreen.build()` used to check
///      `width < 600` for `isMobile` while `_ScreenHeader` separately,
///      independently, checked `width < 800` — two different screens'
///      worth of "mobile" living in the same file. `BillScreen.build()`
///      now computes one three-tier breakpoint (`isMobile` <700,
///      `isTablet` 700–1099, `isDesktop` ≥1100) a single time and passes
///      `isMobile`/`isTablet` into `_ScreenHeader` and `_StatsRow` as
///      constructor parameters (both default to `false` so nothing else
///      calling these widgets breaks), so the header and the body below
///      it always agree on which layout tier is active.
///   2. READABLE WIDTH ON TABLET/LAPTOP: the stats row and receipt card
///      used to stretch to the full available width on every screen
///      size, which looks fine on a phone but reads as an oddly wide,
///      unprofessional receipt on a tablet or laptop. The scrollable
///      content is now centered inside a comfortable max width (640px on
///      tablet, 720px on desktop) — mobile is completely unaffected and
///      still uses the full available width exactly as before.
///   3. FIT-AND-FINISH: header padding, title size, and tagline size, the
///      page's outer padding, and the stat-row gutter now step through
///      mobile → tablet → desktop instead of jumping straight from phone
///      sizing to desktop sizing. Purely cosmetic sizing — no widget was
///      removed, reordered, or given new behaviour.
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
  // Deepest wine tone — used only for shadow/overlay depth.
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
  /// softShadow used on Menu/Dashboard/Order Details/Billing so every
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

  /// Header/hero drop shadow — matches the Billing / Dashboard hero
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
  /// stat cards, matching the Billing screen's `floatingShadow` treatment
  /// exactly.
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

class BillScreen extends StatelessWidget {
  final String orderId;

  final int finalTotal;
  final String paymentMethod;

  const BillScreen({
    super.key,
    required this.orderId,
    required this.finalTotal,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final auth = context.read<StaffAuthProvider>();
    final order = provider.findById(orderId);
    final billNumber =
        'BILL-${orderId.substring(0, orderId.length < 8 ? orderId.length : 8).toUpperCase()}';

    void goBack() => auth.role == StaffRole.billingStaff
        ? context.go('/staff/billing')
        : context.go('/staff/dashboard');

    // Purely display values for the stats row below the header — derived
    // from data already available here (order + constructor fields). No
    // new data source, no logic change.
    final itemsCount = order?.itemsDetails.length ?? 0;

    // PASS 5 — RESPONSIVE LAYOUT: a single three-tier breakpoint system
    // (mobile / tablet / laptop-desktop), computed once here and passed
    // down to `_ScreenHeader` and `_StatsRow`, replaces the two
    // previously-mismatched breakpoints (this method used to check
    // `width < 600` while `_ScreenHeader` separately checked
    // `width < 800`), so the header and the scrollable body below it
    // always agree on which layout tier is active. Presentation only —
    // no provider, PDF, printing, sharing, or navigation logic was
    // touched.
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;
    final isDesktop = width >= 1100;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/wine glows plus a faint textured
          // photograph, matching the Menu Management / Dashboard / Billing
          // screens' "foggy" backdrop so the whole app feels like one
          // cohesive brand.
          Positioned.fill(
            child: Container(
              color: _Palette.canvas,
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
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.20),
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
                    top: 300,
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
                  // Matches the Billing / Dashboard screens' backdrop
                  // treatment.
                  Positioned(
                    top: 640,
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
                  Opacity(
                    opacity: 0.04,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Faint diagonal sheen sweeping across the whole page — a subtle
          // extra layer of depth so the cream backdrop doesn't read as
          // flat behind the header, echoing the glass-highlight language
          // used in the header itself. Matches the Billing / Dashboard /
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
              // ── Header — content matches the Billing screen's
              // top-navbar language exactly: clean two-stop maroon-to-wine
              // gradient, soft ambient gold glows (no images, no
              // watermark), small icon + subtitle label, big serif title,
              // plain-text tagline with a gold accent rule, date/status
              // row, gold hairline. The SHAPE now matches the Tables
              // (Floor Plan) screen's header instead of Billing's: a
              // straight, flat bottom edge with a thin gold hairline
              // border, using `ClipRect` in place of `ClipRRect`. The back
              // control is the exact same `onBack` callback as before —
              // no navigation behavior changed, only its visual
              // treatment. The header no longer paints the Total
              // Paid/Items/Method readout; that renders inside the
              // scrollable content below as `_StatsRow`. ────────────────
              _ScreenHeader(
                title: 'Payment Receipt',
                subtitle: billNumber,
                dateLabel: _todayLabel(),
                onBack: goBack,
                isMobile: isMobile,
                isTablet: isTablet,
              ),

              // ── Scrollable content — `_StatsRow` (Total Paid / Items /
              // Method) now lives right here, as the first item in the
              // scrollable column, so the scrollable area (and its
              // scrollbar) starts exactly at the top of these three
              // cards. The header above stays fixed. Same values
              // (`finalTotal` / `itemsCount` / `paymentMethod`) already
              // computed above — purely a layout relocation, no logic
              // changed. ─────────────────────────────────────────────────
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isMobile ? 16 : (isTablet ? 24 : 32),
                    ),
                    child: Center(
                      // PASS 5: on tablet/laptop widths the stats row and
                      // receipt card no longer stretch edge-to-edge — the
                      // whole scrollable column is centered inside a
                      // comfortable reading width (640px tablet / 720px
                      // desktop), matching how a printed receipt is meant
                      // to read. Mobile is unaffected — `double.infinity`
                      // keeps the exact same full-width behaviour as
                      // before.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 720
                              : (isTablet ? 640 : double.infinity),
                        ),
                        child: Column(
                          children: [
                            _StatsRow(
                              totalPaidLabel: '₹$finalTotal',
                              itemsCount: itemsCount,
                              methodLabel: paymentMethod.toUpperCase(),
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 20),

                            // Receipt card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                                boxShadow: _Palette.softShadow,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  // Top accent bar — same Deep Wine Maroon
                                  // gradient used across the app.
                                  Container(
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _Palette.milanoRedLight,
                                          _Palette.milanoRedDeep,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      children: [
                                        // Success Icon
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: const BoxDecoration(
                                            color: _Palette.successBg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: _Palette.success,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _Palette.gold.withValues(
                                                  alpha: 0.5,
                                                ),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _Palette.success
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Payment Successful',
                                          style: AppTheme.serif(
                                            size: 24,
                                            weight: FontWeight.w900,
                                            color: _Palette.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Transaction Completed',
                                          style: AppTheme.sans(
                                            size: 14,
                                            color: _Palette.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Receipt details — wrapped with a
                                        // slim maroon accent rail down the
                                        // left edge, matching the Billing /
                                        // Payment / Create Order screens'
                                        // card treatment. Same content as
                                        // before.
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _Palette.canvas,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: _Palette.milanoRedDeep
                                                  .withValues(alpha: 0.08),
                                            ),
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
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        _Palette.milanoRed
                                                            .withValues(
                                                          alpha: 0.85,
                                                        ),
                                                        _Palette.milanoRed
                                                            .withValues(
                                                          alpha: 0.35,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Total Amount',
                                                          style: AppTheme.sans(
                                                            size: 12,
                                                            weight:
                                                                FontWeight.w700,
                                                            color: _Palette
                                                                .textMuted,
                                                          ),
                                                        ),
                                                        Text(
                                                          '₹$finalTotal',
                                                          style: AppTheme.serif(
                                                            size: 32,
                                                            weight:
                                                                FontWeight.w900,
                                                            color: _Palette
                                                                .textDark,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 12,
                                                      ),
                                                      child: Divider(
                                                        color: _Palette
                                                            .milanoRedDeep
                                                            .withValues(
                                                          alpha: 0.10,
                                                        ),
                                                        height: 1,
                                                      ),
                                                    ),
                                                    _ReceiptRow(
                                                      'Bill Number',
                                                      billNumber,
                                                      mono: true,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    if (order != null) ...[
                                                      _ReceiptRow(
                                                        'Table',
                                                        order.table,
                                                      ),
                                                      if (order.customerName !=
                                                          null) ...[
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        _ReceiptRow(
                                                          'Customer',
                                                          order.customerName!,
                                                        ),
                                                      ],
                                                    ],
                                                    const SizedBox(height: 10),
                                                    _ReceiptRow(
                                                      'Date',
                                                      _formatDate(),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    _ReceiptRow(
                                                      'Payment Method',
                                                      paymentMethod
                                                          .toUpperCase(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Breakdown — wrapped with a slim gold
                                        // accent rail down the left edge,
                                        // matching the "Items" section on the
                                        // Payment / Billing screens. Same
                                        // content as before.
                                        if (order != null)
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                18,
                                              ),
                                              border: Border.all(
                                                color: _Palette.milanoRedDeep
                                                    .withValues(alpha: 0.08),
                                              ),
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
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          _Palette.gold
                                                              .withValues(
                                                            alpha: 0.85,
                                                          ),
                                                          _Palette.gold
                                                              .withValues(
                                                            alpha: 0.35,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    18,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const _SectionHeader(
                                                        'Order Items',
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      ...order.itemsDetails.map(
                                                        (item) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: 6,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${item.quantity}x ${item.name}',
                                                                style: AppTheme
                                                                    .sans(
                                                                  size: 13,
                                                                  color: _Palette
                                                                      .textMuted,
                                                                ),
                                                              ),
                                                              Text(
                                                                '₹${(item.quantity * (double.tryParse(item.price) ?? 0)).round()}',
                                                                style: AppTheme
                                                                    .sans(
                                                                  size: 13,
                                                                  weight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: _Palette
                                                                      .textDark,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(
                                                        height: 20,
                                                        color: _Palette
                                                            .milanoRedDeep
                                                            .withValues(
                                                          alpha: 0.10,
                                                        ),
                                                      ),
                                                      if (order.subtotal >
                                                          0) ...[
                                                        _BreakdownRow(
                                                          'Subtotal',
                                                          '₹${order.subtotal.round()}',
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                      ],
                                                      if (order.tax > 0) ...[
                                                        _BreakdownRow(
                                                          'Tax',
                                                          '₹${order.tax.round()}',
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                      ],
                                                      Divider(
                                                        height: 16,
                                                        color: _Palette
                                                            .milanoRedDeep
                                                            .withValues(
                                                          alpha: 0.10,
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Total Paid',
                                                            style:
                                                                AppTheme.sans(
                                                              size: 16,
                                                              weight: FontWeight
                                                                  .w800,
                                                              color: _Palette
                                                                  .textDark,
                                                            ),
                                                          ),
                                                          Text(
                                                            '₹$finalTotal',
                                                            style:
                                                                AppTheme.sans(
                                                              size: 20,
                                                              weight: FontWeight
                                                                  .w900,
                                                              color: _Palette
                                                                  .milanoRedDeep,
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

                                        const SizedBox(height: 24),

                                        // Action buttons
                                        PrimaryButton(
                                          label: 'Print Receipt',
                                          icon: Icons.print_rounded,
                                          color: _Palette.milanoRedDeep,
                                          onTap: () => _printReceiptPdf(
                                            context,
                                            order,
                                            billNumber,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        PrimaryButton(
                                          label: 'Download as PDF',
                                          icon: Icons.picture_as_pdf_rounded,
                                          color: _Palette.textDark,
                                          onTap: () => _downloadReceiptPdf(
                                            context,
                                            order,
                                            billNumber,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        PremiumBackButton(
                                          label: auth.role ==
                                                  StaffRole.billingStaff
                                              ? 'Back to Billing'
                                              : 'Back to Dashboard',
                                          onTap: goBack,
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generatePdfDoc(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final restaurantName =
        context.read<StaffAuthProvider>().user?.restaurantName;
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      restaurantName?.isNotEmpty == true
                          ? restaurantName!.toUpperCase()
                          : 'RESTAURANT',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(fontSize: 14, font: font),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(height: 2, color: PdfColors.black),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Bill info
              _pdfInfoRow('Bill Number', billNumber, font, boldFont),
              if (order != null) ...[
                _pdfInfoRow('Table', order.table, font, boldFont),
                if (order.customerName != null)
                  _pdfInfoRow('Customer', order.customerName!, font, boldFont),
              ],
              _pdfInfoRow('Date', _formatDate(), font, boldFont),
              _pdfInfoRow(
                'Payment Method',
                paymentMethod.toUpperCase(),
                font,
                boldFont,
              ),

              pw.SizedBox(height: 16),
              pw.Container(height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 16),

              // Order items header
              if (order != null) ...[
                pw.Text(
                  'Order Items',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 10),
                // Items table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Item',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...order.itemsDetails.map<pw.TableRow>(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              item.name,
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${item.quantity}',
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              CurrencyUtils.format(
                                (item.quantity *
                                        (double.tryParse(item.price) ?? 0))
                                    .round(),
                              ),
                              style: pw.TextStyle(font: font),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Totals
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                if (order.subtotal > 0)
                  _pdfInfoRow(
                    'Subtotal',
                    CurrencyUtils.format(order.subtotal.round()),
                    font,
                    boldFont,
                  ),
                if (order.tax > 0)
                  _pdfInfoRow(
                    'Tax',
                    CurrencyUtils.format(order.tax.round()),
                    font,
                    boldFont,
                  ),
                //f (tipAmount > 0)

                pw.SizedBox(height: 6),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                    pw.Text(
                      CurrencyUtils.format(finalTotal),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'Thank you for dining with us!',
                  style: pw.TextStyle(fontSize: 12, font: font),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _printReceiptPdf(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final pdf = await _generatePdfDoc(context, order, billNumber);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$billNumber',
    );
  }

  Future<void> _downloadReceiptPdf(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final pdf = await _generatePdfDoc(context, order, billNumber);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Receipt_$billNumber.pdf',
    );
  }

  pw.Widget _pdfInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, font: font)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    return '${now.day} ${_month(now.month)} ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';
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

// ─── Screen header — content matches the Billing screen's top-navbar
// language exactly: two soft ambient gold glows tucked behind the content
// (no images, no watermark emblem, no dotted texture), a compact
// back-button row, a small icon + subtitle label above the big serif
// title, a plain-text tagline anchored by a small gold accent rule, a
// date/status row, and a thin gold gradient hairline underneath. The
// SHAPE now matches the Tables (Floor Plan) screen's header instead of
// Billing's: a straight, flat bottom edge (no rounded corners) with a
// thin warm-gold hairline border along that edge, using `ClipRect` in
// place of `ClipRRect`. The back control still calls the exact same
// `onBack` callback as before — no navigation behavior changed, only its
// visual treatment. The header no longer paints the Total Paid/Items/
// Method readout strip; those same values now render inside the
// scrollable content via `_StatsRow`.
//
// PASS 5: now takes `isMobile`/`isTablet` as constructor parameters
// (both default to `false`) instead of independently recomputing its own
// `isMobile` from `MediaQuery` at a different breakpoint than the caller
// used — see the PASS 5 note at the top of the file. Same gradient, same
// glows, same back control, same title/tagline/date content as before.
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onBack;
  final bool isMobile;
  final bool isTablet;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onBack,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Two-stop Deep Wine Maroon → Wine gradient, matching the
        // Billing / Dashboard hero exactly.
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
            // content — purely decorative, mirroring the Billing hero.
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
                    // ── Compact back-button row — same `onBack` callback
                    // as before, restyled into the minimal glass chip
                    // used on the other staff screens' headers. ───────
                    Row(
                      children: [
                        _BackChevronButton(onTap: onBack),
                      ],
                    ),

                    SizedBox(height: isMobile ? 14 : (isTablet ? 16 : 18)),

                    // ── Title block: small icon + subtitle label, then
                    // the big title — matches the Billing header's title
                    // block language exactly.
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

                    SizedBox(height: isMobile ? 16 : (isTablet ? 18 : 20)),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge, no
                    // image of any kind — just clean, confident cream
                    // typography sitting directly in the header, with a
                    // small gold accent rule above it to anchor the
                    // line — matches the Billing header's tagline
                    // treatment exactly.
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
                      'Your transaction has been completed successfully.',
                      style: AppTheme.serif(
                        size: isMobile ? 15.5 : (isTablet ? 16.5 : 18),
                        weight: FontWeight.w800,
                        color: _Palette.canvasDeep,
                      ).copyWith(height: 1.3, letterSpacing: 0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isMobile ? 14 : (isTablet ? 16 : 18)),

                    // ── Date + status row ────────────────────────────
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
                          'Paid',
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

/// Compact icon-only "back" control — a circular glass button showing
/// only a plain "‹" glyph. Matches the minimal, professional control used
/// on the Payment / Order Details / Billing screens' header, for a
/// consistent brand-wide top bar. Still calls the exact same onTap/onBack
/// callback — no navigation logic touched.
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

// ─── Live Stats Row (inside the scrollable content) ────────────────────
// Mirrors the Billing screen's `_StatsRow`/`_StatCard` pattern exactly:
// three floating white cards, sitting as the first item of the scrollable
// content directly beneath the fixed header, built from the exact same
// `finalTotal` / `itemsCount` / `paymentMethod` values already available
// at the call site. No data, provider, or navigation logic lives here —
// purely a display of values already available.
//
// PASS 5: accepts an optional `isTablet` flag (defaults to `false`) so
// the gutter between the three cards can step through mobile → tablet →
// desktop instead of jumping straight from phone spacing to desktop
// spacing. Same three cards, same values, same icons as before.
class _StatsRow extends StatelessWidget {
  final String totalPaidLabel;
  final int itemsCount;
  final String methodLabel;
  final bool isMobile;
  final bool isTablet;

  const _StatsRow({
    required this.totalPaidLabel,
    required this.itemsCount,
    required this.methodLabel,
    required this.isMobile,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final gutter = isMobile ? 10.0 : (isTablet ? 12.0 : 14.0);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.payments_rounded,
            value: totalPaidLabel,
            label: 'Total Paid',
            iconBg: _Palette.paleMint,
            iconColor: _Palette.successDeep,
          ),
        ),
        SizedBox(width: gutter),
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_basket_rounded,
            value: '$itemsCount',
            label: 'Items',
            iconBg: _Palette.lemonChiffon.withValues(alpha: 0.55),
            iconColor: _Palette.goldDeep,
          ),
        ),
        SizedBox(width: gutter),
        Expanded(
          child: _StatCard(
            icon: Icons.credit_card_rounded,
            value: methodLabel,
            label: 'Method',
            iconBg: _Palette.dustyBlush,
            iconColor: _Palette.milanoRedDeep,
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, delay: 150.ms).slideY(begin: 0.25);
  }
}

// ─── Individual Stat Card ────────────────────────────────────────────────
// A horizontal icon + value/label layout on its own white rounded card
// with a floating drop shadow — matches the Billing screen's `_StatCard`
// exactly.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    size: 15,
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

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _ReceiptRow(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sans(size: 13, color: _Palette.textMuted),
        ),
        Text(
          value,
          style: mono
              ? const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _Palette.textDark,
                )
              : AppTheme.sans(
                  size: 13,
                  weight: FontWeight.w700,
                  color: _Palette.textDark,
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: _Palette.milanoRed,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTheme.sans(
              size: 11,
              weight: FontWeight.w800,
              color: _Palette.textMuted,
            ).copyWith(letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  const _BreakdownRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sans(size: 13, color: _Palette.textMuted),
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
