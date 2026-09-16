import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../contexts/auth_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../../core/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the Dashboard / Create Order /
/// New Orders / Menu Management screens exactly, so this screen now reads
/// as part of the same cohesive, professional brand. Field names are kept
/// identical to the previous palette so every usage below the class still
/// lines up — only the color VALUES changed. Nothing here touches
/// AppColors, AppTheme, or any other file — pure UI enhancement, no logic
/// changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 3:
///   1. The header (`_ScreenHeader`) was rebuilt to match the Dashboard
///      hero's top-navbar language exactly — a clean two-stop Deep Wine
///      Maroon → Wine gradient, rounded bottom corners, a subtle
///      deeper-wine wash toward the bottom, two soft ambient gold glows, a
///      small icon + subtitle label above the big title, a plain
///      typographic tagline anchored by a small gold accent rule (no photo
///      badge, no image of any kind), a date/live row, and a thin gold
///      gradient hairline underneath. The old four-stop gradient, dotted
///      texture row, and large watermark emblem were removed.
///   2. The header's old in-banner "Unpaid / Paid / Total" readout strip
///      was pulled OUT of the header entirely and rendered as its own
///      `_StatsRow` of three `_StatCard`s — mirroring the Dashboard's
///      `_StatsRow`/`_StatCard` pattern exactly. `unpaidCount`,
///      `paidCount`, and `billingOrders.length` are the exact same values
///      already computed in `build()`, simply passed to `_StatsRow`.
///   3. `_Palette`'s underlying `Color` values were swapped for the
///      PUREDINE Maroon + Cream brand palette (Deep Wine Maroon, Wine,
///      Burgundy, Warm Off-White, Soft Cream, Warm Gold, Soft Yellow, Deep
///      Brown/Black, Muted Taupe, Fresh Green, Dusty Blush, Pale Rose,
///      Pale Mint). No provider, controller, route, or filtering/pricing
///      logic was touched anywhere in this pass — only presentation
///      changed.
///
/// UI-ENHANCEMENT PASS 4: `_StatsRow` (Unpaid / Paid / Total Bills) used
/// to sit in its own fixed `Padding` between the header and the
/// scrollable body, so it never moved when the page scrolled. It has now
/// been moved to be the first child inside the scrollable content itself
/// (right above the Revenue stats grid), so the scrollable area — and the
/// scrollbar — now starts exactly at the top of these three cards, while
/// the header above them stays fixed. Same three values (`unpaidCount` /
/// `paidCount` / `billingOrders.length`), same widget, same styling —
/// purely a layout relocation, no data/provider/navigation logic changed.
///
/// UI-ENHANCEMENT PASS 5: the "Pay Now" CTA button on each billing card
/// used a lighter gold-to-soft-yellow gradient (`_Palette.gold` →
/// `_Palette.goldLight`) that read as too light. It now uses a darker
/// gold-to-gold gradient (`_Palette.goldDeep` → `_Palette.gold`), with the
/// matching glow shadow updated to `_Palette.goldDeep` so it stays
/// visually consistent. Nothing else about the button — its border,
/// label, icon, tap target, or navigation — was touched.
///
/// UI-ENHANCEMENT PASS 6 (this pass): `_ScreenHeader`'s bottom edge is
/// now a straight, flat line instead of the previous rounded 32px bottom
/// corners — matching the flat-bottom topbar treatment used on the Tables
/// / Orders / Create Order screens. The `BorderRadius.only(bottomLeft/
/// bottomRight: Radius.circular(32))` on the header `Container` and its
/// matching `ClipRRect` were removed (replaced with a plain `ClipRect`,
/// so the banner is now a plain rectangle), and a thin warm-gold hairline
/// border was added along the bottom edge, mirroring the Tables screen's
/// own bottom-edge accent. Everything else inside the header — the
/// gradient, the drop shadow, the ambient gold glows, the title block,
/// the tagline, and the date/live row — is completely unchanged, as is
/// every other part of this file (`_StatsRow`, `_StatCard`,
/// `_RevenueStatBox`, `_BillingCard`, filters, and all provider/fetch
/// logic in `_BillingScreenState`). Presentation only.
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
  /// softShadow used on Menu/Dashboard/Order Details so every card on this
  /// screen carries the same warm, branded elevation.
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

  /// Header/hero drop shadow — matches the Dashboard hero exactly.
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

  /// Soft ambient gold glow — used behind icon chips for a premium lift.
  static List<BoxShadow> goldGlow({double alpha = 0.30}) => [
        BoxShadow(
          color: gold.withValues(alpha: alpha),
          blurRadius: 12,
          spreadRadius: 0.5,
        ),
      ];

  /// A dedicated, slightly stronger "floating card" shadow used by the
  /// stat cards, matching the Dashboard's `floatingShadow` treatment
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

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
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
    final ordersProvider = context.read<OrdersProvider>();
    final auth = context.read<StaffAuthProvider>();

    if (auth.token != null) {
      await ordersProvider.fetchOrders(auth.token!);
    }
  }

  Map<String, dynamic> _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.served:
      case OrderStatus.billed:
        return {
          'label': 'BILLED',
          'bg': _Palette.lemonChiffonDeep.withValues(alpha: 0.45),
          'color': _Palette.goldDeep,
          'icon': Icons.access_time,
        };
      case OrderStatus.paid:
        return {
          'label': 'PAID',
          'bg': _Palette.successBg,
          'color': _Palette.success,
          'icon': Icons.check_circle_outline,
        };
      default:
        return {
          'label': 'PENDING',
          'bg': _Palette.lemonChiffonDeep.withValues(alpha: 0.45),
          'color': _Palette.goldDeep,
          'icon': Icons.pending_actions,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    // In actual app, we only show billed/paid or served items in billing
    final billingOrders = ordersProvider.orders
        .where(
          (o) =>
              o.status == OrderStatus.served ||
              o.status == OrderStatus.billed ||
              o.status == OrderStatus.paid,
        )
        .toList();

    final totalRevenue = billingOrders
        .where((o) => o.status == OrderStatus.paid)
        .fold(0.0, (sum, o) => sum + o.total);

    final totalBilled = billingOrders
        .where(
          (o) =>
              o.status == OrderStatus.served || o.status == OrderStatus.billed,
        )
        .fold(0.0, (sum, o) => sum + o.total);

    final grandTotal = totalRevenue + totalBilled;

    // Purely display values reused below for both the filter chips and
    // the stats row inside the scrollable content — same expressions, no
    // new data source, no logic change.
    final unpaidCount = billingOrders
        .where(
          (o) =>
              o.status == OrderStatus.served || o.status == OrderStatus.billed,
        )
        .length;
    final paidCount =
        billingOrders.where((o) => o.status == OrderStatus.paid).length;

    final filters = [
      {'id': 'all', 'label': 'All Bills', 'count': billingOrders.length},
      {'id': 'unpaid', 'label': 'Unpaid', 'count': unpaidCount},
      {'id': 'paid', 'label': 'Paid', 'count': paidCount},
    ];

    List<Order> filteredOrders;
    if (_activeFilter == 'all') {
      filteredOrders = billingOrders;
    } else if (_activeFilter == 'unpaid') {
      filteredOrders = billingOrders
          .where(
            (o) =>
                o.status == OrderStatus.served ||
                o.status == OrderStatus.billed,
          )
          .toList();
    } else {
      filteredOrders =
          billingOrders.where((o) => o.status == OrderStatus.paid).toList();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/wine glows plus a faint textured
          // photograph, matching the Menu Management / Dashboard screens'
          // "foggy" backdrop so the whole app feels like one cohesive
          // brand.
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
                    top: 340,
                    right: -120,
                    child: Container(
                      width: 230,
                      height: 230,
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
                  // long bills list a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  Positioned(
                    top: 700,
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
          // used in the header itself. Matches the Dashboard / Create
          // Order screens' backdrop treatment.
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
              // ── Header — matches the Dashboard hero's top navbar
              // language exactly: clean two-stop maroon-to-wine gradient,
              // now with a straight, flat bottom edge (PASS 6, matching
              // the Tables/Orders/Create Order screens) instead of rounded
              // bottom corners, soft ambient gold glows, small icon +
              // subtitle label, big title, plain-text tagline with a gold
              // accent rule (no images), date/live row, gold hairline. No
              // provider/logic touched — the header does not paint the
              // Unpaid/Paid/Total readout; that renders inside the
              // scrollable content below as `_StatsRow`. ────────────────
              _ScreenHeader(
                title: 'Billing & Payments',
                subtitle: 'Manage Transactions and Revenue',
                dateLabel: _todayLabel(),
              ),

              // ── Scrollable content — PASS 4: `_StatsRow` (Unpaid / Paid
              // / Total Bills) now lives right here, as the first item in
              // the scrollable column, so the scrollable area (and its
              // scrollbar) starts exactly at the top of these three
              // cards. The header above stays fixed. ─────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;

                    // Revenue Stats Row
                    final statsRow = GridView.count(
                      crossAxisCount:
                          isWide ? (constraints.maxWidth >= 1024 ? 3 : 2) : 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isWide ? 2.4 : 2.5,
                      children: [
                        _RevenueStatBox(
                          icon: Icons.account_balance_wallet,
                          iconColor: _Palette.milanoRedDeep,
                          iconBg: _Palette.milanoRed.withValues(alpha: 0.10),
                          accentColor: _Palette.milanoRed,
                          label: 'Total Revenue',
                          value: CurrencyUtils.format(grandTotal),
                        ).animate().fade().scale(
                              curve: Curves.easeOutBack,
                              duration: 400.ms,
                            ),
                        _RevenueStatBox(
                          icon: Icons.payments,
                          iconColor: _Palette.successDeep,
                          iconBg: _Palette.successBg,
                          accentColor: _Palette.success,
                          label: 'Collected',
                          value: CurrencyUtils.format(totalRevenue),
                        ).animate().fade().scale(
                              curve: Curves.easeOutBack,
                              duration: 400.ms,
                              delay: 100.ms,
                            ),
                        if (isWide && constraints.maxWidth >= 1024)
                          _RevenueStatBox(
                            icon: Icons.access_time,
                            iconColor: _Palette.goldDeep,
                            iconBg: _Palette.lemonChiffonDeep.withValues(
                              alpha: 0.55,
                            ),
                            accentColor: _Palette.gold,
                            label: 'Billed',
                            value: CurrencyUtils.format(totalBilled),
                          ).animate().fade().scale(
                                curve: Curves.easeOutBack,
                                duration: 400.ms,
                                delay: 200.ms,
                              ),
                      ],
                    );

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
                                      padding: const EdgeInsets.only(
                                        right: 8,
                                      ),
                                      child: _buildFilterButton(f, isWide),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );

                    Widget content = filteredOrders.isEmpty
                        ? const EmptyState(
                            icon: Icons.receipt,
                            title: 'No bills found',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide
                                  ? (constraints.maxWidth >= 1024 ? 2 : 1)
                                  : 1,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: isWide ? 1.7 : 1.2,
                            ),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final config = _getStatusConfig(order.status);
                              return _BillingCard(order: order, config: config)
                                  .animate()
                                  .fade(
                                    duration: 400.ms,
                                    delay: (index * 80).ms,
                                  )
                                  .slideY(
                                    begin: 0.08,
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
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PASS 4: the three Unpaid/Paid/Total Bills
                              // cards are now the first thing inside the
                              // scrollable content — same `unpaidCount` /
                              // `paidCount` / `billingOrders.length`
                              // values already computed in `build()`.
                              _StatsRow(
                                unpaidCount: unpaidCount,
                                paidCount: paidCount,
                                totalCount: billingOrders.length,
                                isMobile: isMobile,
                              ),
                              const SizedBox(height: 28),
                              statsRow,
                              const SizedBox(height: 32),
                              isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Sidebar Filter
                                        Container(
                                          width: 256,
                                          margin: const EdgeInsets.only(
                                            right: 32,
                                          ),
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white,
                                                _Palette.canvasDeep
                                                    .withValues(alpha: 0.35),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(26),
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
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          _Palette.gold,
                                                          _Palette.goldLight,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'PAYMENT STATUS',
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

  IconData _filterIcon(String id) {
    switch (id) {
      case 'unpaid':
        return Icons.pending_actions_rounded;
      case 'paid':
        return Icons.check_circle_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _buildFilterButton(Map<String, dynamic> f, bool isWide) {
    final isActive = _activeFilter == f['id'];
    return Padding(
      padding: isWide ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: InkWell(
        onTap: () => setState(() => _activeFilter = f['id'] as String),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? _Palette.gold.withValues(alpha: 0.55)
                  : _Palette.milanoRedDeep.withValues(alpha: 0.10),
              width: isActive ? 1.1 : 1,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _filterIcon(f['id'] as String),
                    size: 16,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.9)
                        : _Palette.textMuted,
                  ),
                  const SizedBox(width: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }
}

/// Small decorative gradient divider placed beneath a title — purely
/// cosmetic, mirrors the same accent used on the Menu Management screen.
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
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

// ─── Screen header — matches the Dashboard hero's top-navbar language
// exactly: a clean two-stop Deep Wine Maroon → Wine gradient, a subtle
// deeper-wine wash toward the bottom, two soft ambient gold glows tucked
// behind the content, a small icon + subtitle label above the big serif
// title, a plain-text tagline anchored by a small gold accent rule (no
// icon badge, no card, no photo/image of any kind), a date/live row, and
// a thin gold gradient hairline underneath. This screen never had a back
// button, refresh action, or sort toggle, so none were added here —
// purely a presentational rebuild. The old in-banner Unpaid/Paid/Total
// readout strip has been removed from this widget entirely; those same
// values now render inside the scrollable content via `_StatsRow`.
//
// PASS 6: the bottom edge is now a straight, flat line — matching the
// Tables / Orders / Create Order screens' topbar treatment — instead of
// the previous rounded 32px bottom corners. The `BorderRadius.only(
// bottomLeft/bottomRight)` on the `Container` and the matching
// `ClipRRect` were removed (replaced with a plain `ClipRect`), and a thin
// warm-gold hairline border was added along the bottom edge.
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Two-stop Deep Wine Maroon → Wine gradient, matching the
        // Dashboard hero exactly.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
        // PASS 6: straight, flat bottom edge — no rounded corners —
        // matching the Tables/Orders/Create Order screens' topbar shape,
        // plus the same thin warm-gold hairline those screens use along
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
            // content — purely decorative, mirroring the Dashboard hero.
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
                    // ── Title block: small icon + subtitle label, then
                    // the big title — matches the Dashboard header's
                    // title block language exactly.
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
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

                    SizedBox(height: isMobile ? 16 : 20),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge, no
                    // image of any kind — just clean, confident cream
                    // typography sitting directly in the header, with a
                    // small gold accent rule above it to anchor the
                    // line — matches the New Orders / Create Order
                    // header's tagline treatment exactly.
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
                      'Track every bill, from table to payment.',
                      style: AppTheme.serif(
                        size: isMobile ? 15.5 : 18,
                        weight: FontWeight.w800,
                        color: _Palette.canvasDeep,
                      ).copyWith(height: 1.3, letterSpacing: 0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isMobile ? 14 : 18),

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

// ─── Live Stats Row (inside the scrollable content) ────────────────────
// Mirrors the Dashboard's `_StatsRow`/`_StatCard` pattern exactly: three
// floating white cards, now sitting as the first item of the scrollable
// content directly beneath the fixed header, built from the exact same
// `unpaidCount` / `paidCount` / `totalCount` values the filter chips
// already use. No data, provider, or navigation logic lives here — purely
// a display of values already available at the call site.
class _StatsRow extends StatelessWidget {
  final int unpaidCount;
  final int paidCount;
  final int totalCount;
  final bool isMobile;

  const _StatsRow({
    required this.unpaidCount,
    required this.paidCount,
    required this.totalCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions_rounded,
            value: '$unpaidCount',
            label: 'Unpaid',
            iconBg: _Palette.lemonChiffon.withValues(alpha: 0.55),
            iconColor: _Palette.goldDeep,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            value: '$paidCount',
            label: 'Paid',
            iconBg: _Palette.paleMint,
            iconColor: _Palette.successDeep,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_rounded,
            value: '$totalCount',
            label: 'Total Bills',
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
// with a floating drop shadow — matches the Dashboard's `_StatCard`
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

// ─── Revenue Stat box — same white-card, gold-ringed icon language used
// across the app, with a generous, professional footprint (bigger icon
// circle, more padding, richer shadow) plus a slim accent-colored top cap
// so each figure has its own subtle identity at a glance, making the
// whole revenue strip feel like a premium dashboard component. ────────
class _RevenueStatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
  final String label;
  final String value;

  const _RevenueStatBox({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: _Palette.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slim accent cap along the top edge — quietly ties each stat
          // to its own color story (maroon / green / gold).
          Container(height: 3, color: accentColor.withValues(alpha: 0.6)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    _Palette.canvasDeep.withValues(alpha: 0.35),
                  ],
                ),
                border: Border.all(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _Palette.gold.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTheme.sans(
                            size: 11,
                            color: _Palette.textMuted,
                            weight: FontWeight.w700,
                          ).copyWith(letterSpacing: 0.4),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          value,
                          style: AppTheme.serif(
                            size: 23,
                            weight: FontWeight.w900,
                            color: _Palette.textDark,
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
        ],
      ),
    );
  }
}

// ─── Billing card — same brand language as the rest of the app: a
// colored status banner up top (Deep Wine Maroon gradient while the bill
// still needs action, flat success green once paid), a white body, and a
// gold-gradient CTA button for the primary action, with a generous,
// professional footprint (bigger icon chips, gold-ringed receipt icon, an
// arrow-tipped "Pay Now" button, richer shadow). Tap behavior, navigation
// targets, and which button appears for which status are all unchanged
// from before — only the visual shell changed.
class _BillingCard extends StatelessWidget {
  final Order order;
  final Map<String, dynamic> config;

  const _BillingCard({required this.order, required this.config});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;
    final isUnpaid = order.status == OrderStatus.served ||
        order.status == OrderStatus.billed;

    return GestureDetector(
      onTap: () {
        if (isUnpaid) {
          context.push('/staff/payment/${order.id}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isUnpaid
                ? _Palette.milanoRed.withValues(alpha: 0.24)
                : _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          boxShadow: isUnpaid
              ? [
                  BoxShadow(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : _Palette.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                gradient: isUnpaid
                    ? const LinearGradient(
                        colors: [
                          _Palette.milanoRedLight,
                          _Palette.milanoRedDeep,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUnpaid ? null : _Palette.successBg,
                border: Border(
                  bottom: BorderSide(
                    color: isUnpaid
                        ? _Palette.gold.withValues(alpha: 0.35)
                        : _Palette.success.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isUnpaid)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _Palette.gold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            config['icon'] as IconData,
                            size: 20,
                            color: Colors.white,
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: _Palette.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config['label'] as String,
                            style: AppTheme.sans(
                              size: isUnpaid ? 16 : 15,
                              weight: FontWeight.w900,
                              color: isUnpaid
                                  ? Colors.white
                                  : _Palette.successDeep,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                          Text(
                            'Order #${order.id.substring(0, 4)}',
                            style: AppTheme.sans(
                              size: 12,
                              color: isUnpaid
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isUnpaid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _Palette.gold.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: _Palette.successDeep,
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmall ? 18 : 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmall ? 44 : 52,
                            height: isSmall ? 44 : 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _Palette.milanoRed.withValues(alpha: 0.10),
                                  _Palette.milanoRed.withValues(alpha: 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: _Palette.milanoRedDeep,
                              size: isSmall ? 22 : 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.table,
                                  style: AppTheme.serif(
                                    size: isSmall ? 16 : 19,
                                    weight: FontWeight.w800,
                                    color: _Palette.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (order.customerName != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    order.customerName!,
                                    style: AppTheme.sans(
                                      size: isSmall ? 13 : 14,
                                      weight: FontWeight.w700,
                                      color: _Palette.textDark.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  '${order.items} items',
                                  style: AppTheme.sans(
                                    size: isSmall ? 12 : 13,
                                    color: _Palette.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyUtils.format(order.total),
                          style: AppTheme.serif(
                            size: isSmall ? 20 : 24,
                            weight: FontWeight.w900,
                            color: _Palette.milanoRedDeep,
                          ),
                        ),
                        if (isUnpaid) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: isSmall ? 36 : 40,
                            child: GestureDetector(
                              onTap: () =>
                                  context.push('/staff/payment/${order.id}'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  // PASS 5: darker gold-to-gold gradient
                                  // (previously gold → soft-yellow, which
                                  // read as too light). Border and label
                                  // are unchanged.
                                  gradient: const LinearGradient(
                                    colors: [
                                      _Palette.goldDeep,
                                      _Palette.gold,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _Palette.lemonChiffonDeep
                                        .withValues(alpha: 0.6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      // PASS 5: glow shadow updated to
                                      // goldDeep to match the darker
                                      // button fill.
                                      color: _Palette.goldDeep.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Pay Now',
                                      style: AppTheme.sans(
                                        size: 13,
                                        weight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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
