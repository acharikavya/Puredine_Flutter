import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../contexts/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / Orders / New Orders / Create Order / Menu
/// Management screens exactly (#8B1D1D primary / #F4C430 gold accent), so
/// this screen now reads as part of the same cohesive, professional brand
/// instead of its own one-off theme. Used ONLY for this screen's visual
/// layer. Nothing here touches AppColors, AppTheme, or any other file —
/// pure UI enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header and section cards up
/// to the same distinctive "command bar" identity used on the Create
/// Order / Orders screens — a four-stop diagonal gradient header, a large
/// faint watermark emblem, a glass highlight line along the top edge, and
/// a new live quick-stats readout strip (Items / Amount Due / Method)
/// built entirely from values already computed in build(). The full-
/// screen backdrop gained an extra diagonal sheen for more depth, and
/// each section card picked up a slim color-coded accent rail down the
/// left edge, matching the Create Order / Orders screens' card treatment.
/// No provider, controller, route, or payment-processing logic was
/// touched anywhere in this pass — only presentation changed.
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
  static const Color milanoRedDarkest =
      Color(0xFF320A0A); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color gold = Color(0xFFF4C430);
  static const Color goldLight = Color(0xFFF7D66B);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Order Details/Orders/Menu/Create Order so every
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

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the Order Details / Orders / Create Order /
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

  /// Soft inner "glass" shadow used on the header's quick-stats readout
  /// strip — pure decoration, gives the capsule a faint pressed-glass
  /// depth. Matches the Create Order / Orders screens' statCapsuleShadow.
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

    // Purely display values for the header's quick-stats strip — derived
    // from data already computed/available here. No new data source, no
    // logic change.
    final itemsCount = order.itemsDetails.length;
    final selectedMethodLabel = _selectedMethod == null
        ? 'Not Selected'
        : _methods.firstWhere((m) => m['id'] == _selectedMethod)['label']
            as String;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / Orders screens.
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
              // richer "command bar" with a live quick-stats readout. ────
              _ScreenHeader(
                title: 'Process Payment',
                subtitle: order.table,
                dateLabel: _todayLabel(),
                onBack: () => context.pop(),
                itemsCount: itemsCount,
                amountDue: finalTotal,
                methodLabel: selectedMethodLabel,
              ),

              // BODY
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    children: [
                      // 🔥 ORDER DETAILS
                      _SectionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Order Details',
                        railColor: _Palette.milanoRed,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...order.itemsDetails.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _Palette.milanoRed.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                          color: _Palette.textDark.withValues(
                                            alpha: 0.85,
                                          ),
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
                            // Summary card on the Order Details screen,
                            // now with a richer ribbon glow + gold trim.
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 22,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _Palette.milanoRedLight,
                                    _Palette.milanoRed,
                                    _Palette.milanoRedDeep,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: const Border(
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
                                          size: 38,
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
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                children: [
                                  if (order.subtotal > 0)
                                    _AmountRow(
                                      'Subtotal',
                                      '₹${order.subtotal.round()}',
                                    ),
                                  if (order.tax > 0)
                                    _AmountRow('Tax', '₹${order.tax.round()}'),
                                  const SizedBox(height: 10),
                                  Divider(
                                    color: _Palette.milanoRedDeep.withValues(
                                      alpha: 0.10,
                                    ),
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
                                gradient: LinearGradient(
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
                        padding: const EdgeInsets.all(16),
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
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            _Palette.milanoRed.withValues(
                                              alpha: 0.08,
                                            ),
                                            _Palette.lemonChiffon.withValues(
                                              alpha: 0.06,
                                            ),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: isSelected
                                        ? _Palette.milanoRedDeep
                                        : _Palette.milanoRedDeep.withValues(
                                            alpha: 0.14,
                                          ),
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
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  _Palette.milanoRed,
                                                  _Palette.milanoRedDeep,
                                                ],
                                              )
                                            : null,
                                        color:
                                            isSelected ? null : _Palette.canvas,
                                        borderRadius: BorderRadius.circular(
                                          11,
                                        ),
                                        border: isSelected
                                            ? Border.all(
                                                color: _Palette.gold
                                                    .withValues(alpha: 0.5),
                                              )
                                            : Border.all(
                                                color: _Palette.milanoRedDeep
                                                    .withValues(alpha: 0.08),
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
                                          size: 16,
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
                                        decoration: BoxDecoration(
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

                      // 🔥 BUTTON (NO ERROR) — themed gold-trimmed maroon
                      // to match the primary actions on the other screens
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
/// purely cosmetic, mirrors the same accent used on the Order Details /
/// Menu Management screens.
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
// as part of the same Theme 1 brand. UI-ENHANCEMENT PASS 2: each card now
// carries a slim color-coded accent rail down the left edge (matching the
// Create Order / Orders screens' card treatment), and the icon chip
// picked up a soft colored glow. Purely presentational — wraps the exact
// same child content as before.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color railColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.railColor = _Palette.milanoRed,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
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
                      child:
                          Icon(icon, color: _Palette.milanoRedDeep, size: 17),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      title,
                      style: AppTheme.serif(
                        size: 18,
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

// ─── Screen header — restyled into its own distinctive "command bar"
// identity: a richer four-stop diagonal gradient, a large faint watermark
// emblem behind the title, a fine glass highlight line along the top
// edge, layered ribbon glows, a dotted texture accent, a floating date
// pill, and a brand icon chip matching every other staff screen's header.
// UI-ENHANCEMENT PASS 2 adds a live quick-stats readout strip (Items /
// Amount Due / Method) built from values already computed in build() — no
// new data source, purely a display of values already available at the
// call site. The back control remains the same compact, icon-only "‹"
// chip matching the Order Details screen's header control exactly. The
// onBack callback and all content are identical to before — this is a
// purely presentational change. ─────────────────────────────────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onBack;
  final int itemsCount;
  final int amountDue;
  final String methodLabel;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onBack,
    required this.itemsCount,
    required this.amountDue,
    required this.methodLabel,
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
          // Order / Orders screens' "faceted" surface language.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              _Palette.milanoRedDarkest,
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
                    Icons.point_of_sale_rounded,
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
                        if (!isMobile)
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
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Brand icon chip — thin gold border + soft
                        // gold glow, matching every other staff screen's
                        // header icon. ────────────────────────────────
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
                            Icons.point_of_sale_rounded,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _Palette.gold.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  subtitle,
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: _Palette.lemonChiffon,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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

                    const SizedBox(height: 16),

                    // ── Live quick-stats readout strip — Items / Amount
                    // Due / Method, built straight from values already
                    // computed in build(). Purely a display addition; no
                    // new data source and no logic change.
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
                              icon: Icons.shopping_basket_rounded,
                              value: '$itemsCount',
                              label: 'Items',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.payments_rounded,
                              value: '₹$amountDue',
                              label: 'Amount Due',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.credit_card_rounded,
                              value: methodLabel,
                              label: 'Method',
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
      constraints: const BoxConstraints(maxWidth: 130),
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.sans(
                    size: 14,
                    weight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing
/// only a plain "‹" glyph. Replaces the previous arrow-icon box with the
/// same minimal, professional control used on the Order Details screen's
/// header, for a consistent brand-wide top bar.
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
