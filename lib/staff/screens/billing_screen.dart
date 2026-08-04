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
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / Dashboard / Menu Management screens exactly (#8B1D1D
/// primary / #F4C430 gold accent), so this screen now reads as part of the
/// same cohesive, professional brand. Used ONLY for this screen's visual
/// layer. Nothing here touches AppColors, AppTheme, or any other file —
/// pure UI enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (four-stop gradient, a large faint
/// watermark emblem, a glass highlight line along the top edge), matching
/// the Create Order / Orders / Tables screens' Pass-2 treatment. A new
/// live status readout strip (Unpaid / Paid / Total Bills) was added,
/// built entirely from the exact same per-status counts the filter chips
/// already use. The full-screen backdrop gained an extra diagonal sheen
/// for more depth. No provider, controller, route, or filtering/pricing
/// logic was touched anywhere in this pass — only presentation changed.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// the other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
/// change here).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest = Color(0xFF320A0A); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color gold = Color(0xFFF4C430);
  static const Color goldDeep = Color(0xFFD9A62A);
  static const Color goldLight = Color(0xFFF7D66B);
  static const Color success = Color(0xFF10B981);
  static const Color successDeep = Color(0xFF065F46);
  static const Color successBg = Color(0xFFECFDF5);

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

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the Order Details / Dashboard headers (deep maroon
  /// drop shadow + soft ambient gold bloom + fine black contact shadow).
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

  /// Soft ambient gold glow — used behind icon chips for a premium lift.
  static List<BoxShadow> goldGlow({double alpha = 0.30}) => [
        BoxShadow(
          color: gold.withValues(alpha: alpha),
          blurRadius: 12,
          spreadRadius: 0.5,
        ),
      ];

  /// Soft inner "glass" shadow used on the header's stats readout strip —
  /// pure decoration, gives the capsule a faint pressed-glass depth.
  /// Matches the Create Order / Orders / Tables screens' Pass-2 header.
  static List<BoxShadow> get statCapsuleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.06),
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
    // the header's new stats readout strip — same expressions, no new
    // data source, no logic change.
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

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/ruby glows plus a faint textured
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
                            _Palette.lemonChiffon.withValues(alpha: 0.30),
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
          // used in the header itself. Matches the Create Order / Orders
          // / Tables screens' Pass-2 backdrop treatment.
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
              // ── Header — same Dark Maroon gradient treatment, rounded
              // "floating navbar" corners, dotted texture accent, diagonal
              // ribbon glows, and a floating date pill, now restyled into
              // a richer "command bar" with a live status readout, so
              // every screen reads as one cohesive, unique brand. ───────
              _ScreenHeader(
                title: 'Billing & Payments',
                subtitle: 'Manage Transactions and Revenue',
                dateLabel: _todayLabel(),
                unpaidCount: unpaidCount,
                paidCount: paidCount,
                totalCount: billingOrders.length,
              ),
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
                        _StatBox(
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
                        _StatBox(
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
                          _StatBox(
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
                                                      gradient: const LinearGradient(
                                                        begin: Alignment
                                                            .topCenter,
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
                ? LinearGradient(
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

// ─── Screen header — restyled into its own distinctive "command bar"
// identity: a richer four-stop diagonal gradient, a large faint watermark
// emblem behind the title, a fine glass highlight line along the top
// edge, layered ribbon glows, a fine dotted texture accent, and a
// floating date pill, so the top bar reads as one cohesive, unique brand
// across the whole app. UI-ENHANCEMENT PASS 2 adds a live status readout
// strip (Unpaid / Paid / Total Bills) built from the exact same
// per-status counts the filter chips already use — no new data source,
// purely a display of values already available at the call site. This
// screen never had a back button, refresh action, or sort toggle, so
// none were added here — purely a presentational upgrade. ─────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final int unpaidCount;
  final int paidCount;
  final int totalCount;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.unpaidCount,
    required this.paidCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the Create
          // Order / Orders / Tables screens' "faceted" surface language.
          gradient: const LinearGradient(
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              _Palette.milanoRedDarkest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
          // Softly rounded bottom corners give the header a modern,
          // "floating navbar" feel that matches the rest of the app
          // exactly, instead of a flat hard-edged band.
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
            // Subtle decorative diagonal ribbon accents (purely
            // cosmetic, matches the rest of the app's headers for a
            // consistent brand feel).
            Positioned(
              top: -60,
              right: -40,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 240,
                  height: 90,
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
                  width: 220,
                  height: 70,
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
            // Dashboard/Order Details header treatment.
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
                      _Palette.gold.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Extra ambient gold glow, lower-right — matches the fuller
            // backdrop glow used on other screen headers.
            Positioned(
              bottom: -60,
              right: -20,
              child: Container(
                width: 170,
                height: 170,
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
              bottom: isMobile ? -24 : -18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: isMobile ? 140 : 190,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used on the other headers.
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
                          alpha: i == 2 ? 0.85 : 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Fine glass highlight line along the very top edge, giving
            // the full-width panel a polished, "premium glass" finish —
            // matches the Dashboard/Orders/Tables headers' top edge.
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
                  isMobile ? 20 : 24,
                  isMobile ? 18 : 16,
                  isMobile ? 20 : 24,
                  22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile)
                      Row(
                        children: [
                          const Spacer(),
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
                            child: Text(
                              dateLabel,
                              style: AppTheme.sans(
                                size: 12,
                                weight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.75),
                              ).copyWith(letterSpacing: 0.3),
                            ),
                          ),
                        ],
                      ),
                    if (!isMobile) const SizedBox(height: 14),
                    Row(
                      children: [
                        // ── Brand icon chip — thin gold border + soft
                        // gold glow, matching every other screen's
                        // header icon.
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _Palette.gold.withValues(alpha: 0.75),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.gold.withValues(alpha: 0.25),
                                blurRadius: 10,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: _Palette.lemonChiffon,
                            size: 20,
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
                                  size: 20,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              const _TitleDivider(),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: AppTheme.sans(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.75),
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
                          child: Text(
                            dateLabel,
                            style: AppTheme.sans(
                              size: 10.5,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // ── Live status readout strip — Unpaid / Paid /
                    // Total, built straight from the same per-status
                    // counts already powering the filter chips below.
                    // Purely a display addition; no new data source and
                    // no logic change.
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
                              icon: Icons.pending_actions_rounded,
                              value: '$unpaidCount',
                              label: 'Unpaid',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.check_circle_rounded,
                              value: '$paidCount',
                              label: 'Paid',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.receipt_long_rounded,
                              value: '$totalCount',
                              label: 'Total',
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

// ─── Stat box — same white-card, gold-ringed icon language used across
// the app, now with a more generous, professional footprint (bigger icon
// circle, more padding, richer shadow) plus a slim accent-colored top
// cap so each figure has its own subtle identity at a glance, making the
// whole revenue strip feel like a premium dashboard component. ────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
  final String label;
  final String value;

  const _StatBox({
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
// colored status banner up top (Dark Maroon gradient while the bill
// still needs action, flat success green once paid), a white body, and
// a gold-gradient CTA button for the primary action, now with a more
// generous, professional footprint (bigger icon chips, gold-ringed
// receipt icon, an arrow-tipped "Pay Now" button, richer shadow). Tap
// behavior, navigation targets, and which button appears for which
// status are all unchanged from before — only the visual shell changed.
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
                    ? LinearGradient(
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
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(
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
                                  gradient: LinearGradient(
                                    colors: [
                                      _Palette.gold,
                                      _Palette.goldLight,
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
                                      color: _Palette.gold.withValues(
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