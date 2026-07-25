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
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the New Orders / Create Order / Menu Management / Dashboard screens
/// exactly (#8B1D1D primary / #F4C430 gold accent), so this screen now
/// reads as part of the same cohesive, professional brand instead of its
/// own one-off theme. Used ONLY for this screen's visual layer. Nothing
/// here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// NOTE: this is a private class redeclared identically to the one in
/// new_orders_screen.dart / create_order_screen.dart / menu_screen.dart
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
  /// softShadow used on Menu/Create Order/New Orders/Dashboard so every
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
  /// language used on the New Orders / Create Order / Dashboard headers
  /// (deep maroon drop shadow + soft ambient gold bloom + fine black
  /// contact shadow).
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
}

const List<String> _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _todayLabel() {
  final now = DateTime.now();
  return '${_kMonthNames[now.month - 1]} ${now.day}, ${now.year}';
}

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

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the New Orders / Create Order screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Menu Management screen's
          // "foggy" backdrop so every staff/admin screen feels like one
          // cohesive brand. No logic touched — visuals only.
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
                ],
              ),
            ),
          ),
          Column(
            children: [
              // ── Header — same Dark Maroon gradient + gold accents used
              // throughout every other staff screen. ────────────────────
              _ScreenHeader(
                tableName: order.table,
                orderNumber: order.orderNumber,
                statusLabel: config['label'] as String,
                statusBg: config['bg'] as Color,
                statusColor: config['color'] as Color,
                dateLabel: _todayLabel(),
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
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    children: [
                      // Order summary card
                      _SectionCard(
                        title: 'Order Summary',
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
                      const SizedBox(height: 18),

                      // Items
                      _SectionCard(
                        title: 'Order Items',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...order.itemsDetails.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _Palette.milanoRed.withValues(
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
                                            size: 12,
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
                                          size: 14,
                                          weight: FontWeight.w500,
                                          color: _Palette.textDark.withValues(
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
                                        size: 14,
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
                                    size: 16,
                                    weight: FontWeight.w800,
                                    color: _Palette.textDark,
                                  ),
                                ),
                                Text(
                                  '₹${order.total.round()}',
                                  style: AppTheme.serif(
                                    size: 24,
                                    weight: FontWeight.w900,
                                    color: _Palette.milanoRedDeep,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 400.ms, delay: 80.ms).slideY(
                            begin: 0.06,
                            duration: 400.ms,
                            curve: Curves.easeOutQuad,
                          ),
                      const SizedBox(height: 22),

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
            ],
          ),
        ],
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the accent used under section titles on the
/// Menu Management / Create Order / New Orders screens for a consistent
/// brand language.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider({this.width = 40});

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
            _Palette.lemonChiffon.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Screen header — same Dark Maroon gradient treatment as the New
// Orders / Create Order / Menu Management screens: bigger rounded bottom
// corners, a richer 3-layer shadow stack, layered ribbon glows, a fine
// dotted texture accent, a floating date pill, and a brand icon chip
// matching every other staff screen's header. The back control is now a
// compact, icon-only "‹" chip — no label, no arrow glyph — matching the
// Menu Management screen's header control. The onBack callback (from/pop)
// is identical to before, and the status badge keeps its own semantic
// color so workflow state stays legible. ─────────────────────────────────
class _ScreenHeader extends StatelessWidget {
  final String tableName;
  final String orderNumber;
  final String statusLabel;
  final Color statusBg;
  final Color statusColor;
  final String dateLabel;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.tableName,
    required this.orderNumber,
    required this.statusLabel,
    required this.statusBg,
    required this.statusColor,
    required this.dateLabel,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
            ],
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
            // Dashboard hero treatment.
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
            // "full-screen backdrop" glow used on the other headers.
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
                        // Menu Management screen's header control. ──────
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
                            Icons.table_restaurant_rounded,
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
                                tableName,
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
                                orderNumber,
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
                        const SizedBox(width: 8),
                        // ── Status badge — same thin gold-outlined glass
                        // chip language used elsewhere, tinted with the
                        // status's own semantic color so workflow state
                        // stays legible. ────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTheme.sans(
                              size: 11,
                              weight: FontWeight.w800,
                              color: statusColor,
                            ),
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
/// only a plain "‹" glyph. Replaces the previous arrow-icon + "Back"
/// label combo with the same minimal, professional control used on the
/// Menu Management screen's header, for a consistent brand-wide top bar.
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

// ─── Section Card — same white, softly bordered, softly shadowed card
// language used by the stat boxes / order cards across the staff app,
// plus the same thin gold accent bar used as a section marker, so every
// card on this screen reads as part of the same Theme 1 brand. Sizing
// bumped slightly (radius, padding, divider height) for a more generous,
// professional footprint. Purely presentational — wraps the exact same
// child content as before. ────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
        boxShadow: _Palette.softShadow,
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
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                      size: 18,
                      weight: FontWeight.w800,
                      color: _Palette.textDark,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
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
// Theme 1 Dark Maroon / Gold palette so the call-to-action reads as part
// of the same brand. Blue/green are kept for "Preparing"/"Ready" since
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