import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/orders_service.dart';
import 'package:restaurant_unified_app/admin/services/tables_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// MenuScreen / AdminDashboardScreen / CategoryFormDialog / ItemFormDialog
/// exactly. Used ONLY for this dialog's restyle. Nothing here touches
/// AppColors or any other file — pure UI enhancement, no logic changed
/// anywhere here. The header mirrors the same decorative language (ribbon
/// accents, dotted texture line, radial glow, gold underline) used across
/// the other admin dialogs, so this screen reads as part of the same
/// cohesive, professional brand.
///
/// UI-ENHANCEMENT PASS 2: brings this dialog's header up to the same
/// richer "command bar" identity used on the Orders/Menu screens and the
/// Item Form dialog — a deeper four-stop diagonal gradient, a large faint
/// watermark emblem behind the title copy, and a fine glass highlight
/// line along the very top edge. No table loading, order submission,
/// validation, quantity, or category/item navigation logic was touched
/// anywhere in this pass — presentation only.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF2E0909); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFC62828);

  /// Themed soft shadow for resting surfaces — mirrors the shared shadow
  /// language used across MenuScreen / AdminDashboardScreen.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Themed elevated glow shadow — used for the whole dialog card and the
  /// primary action button so both read as "lifted" above the backdrop.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.28),
          blurRadius: 44,
          offset: const Offset(0, 22),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}

class ManualOrderDialog extends StatefulWidget {
  final List<MenuItem> menuItems;
  final List<MenuCategory> categories;

  const ManualOrderDialog({
    super.key,
    required this.menuItems,
    required this.categories,
  });

  @override
  State<ManualOrderDialog> createState() => _ManualOrderDialogState();
}

class _ManualOrderDialogState extends State<ManualOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  List<TableModel> _tables = [];
  String? _selectedTableId;
  String _paymentMode = 'Cash';
  String _orderMode = 'Dine-in';

  bool _isLoadingTables = true;
  bool _isSubmitting = false;

  final Map<String, int> _selectedItems = {}; // menuItemId -> quantity

  // Navigation State for Menu Items
  String _viewMode = 'categories'; // 'categories' or 'items'
  MenuCategory? _activeCategory;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await TablesService.getTables();
      setState(() {
        _tables = tables;
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() => _isLoadingTables = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tables: $e')));
      }
    }
  }

  double get _totalAmount {
    double total = 0;
    _selectedItems.forEach((itemId, qty) {
      final item = widget.menuItems.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_orderMode == 'Dine-in' && _selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _themedSnack('Please select a table for Dine-in', isError: true),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _themedSnack('Please add at least one item', isError: true),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final itemsList = _selectedItems.entries.map((e) {
        return {"menu_item_id": e.key, "quantity": e.value};
      }).toList();

      final orderTypeMap = {
        'Dine-in': 'DINE_IN',
        'Takeaway': 'TAKEAWAY',
        'Delivery': 'DELIVERY',
      };

      final payload = {
        "order_type": orderTypeMap[_orderMode] ?? 'DINE_IN',
        "table_id": _orderMode == 'Dine-in' ? _selectedTableId : null,
        "customer_name": _nameCtrl.text.trim(),
        "customer_phone": _phoneCtrl.text.trim(),
        "payment_mode": _paymentMode,
        "items": itemsList,
      };

      await OrdersService.createOrder(payload);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          _themedSnack('Order created successfully!'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _themedSnack('Failed to create order: $e', isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  SnackBar _themedSnack(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? _Palette.danger : _Palette.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        width: isDesktop ? 1000 : size.width * 0.95,
        height: size.height * 0.9,
        decoration: BoxDecoration(
          color: _Palette.cardWhite,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          boxShadow: _Palette.glowShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Header (mini navbar) ─────────────────────────────────────
            // Mirrors the Menu screen's header + the other admin dialogs:
            // brand gradient, decorative diagonal ribbons, a soft radial
            // glow behind the icon block, a fine dotted accent line, and a
            // gold underline beneath the title.
            //
            // UI-ENHANCEMENT PASS 2: upgraded from a three-stop to a
            // richer four-stop diagonal gradient, a large faint watermark
            // emblem tucked behind the copy, and a fine glass highlight
            // line along the very top edge — matching the Orders/Menu
            // screens' and Item Form dialog's Pass-2 "command bar"
            // treatment.
            ClipRect(
              child: Container(
                decoration: BoxDecoration(
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
                  border: const Border(
                    bottom: BorderSide(
                      color: _Palette.lemonChiffon,
                      width: 3.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.milanoRed.withValues(alpha: 0.34),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: _Palette.lemonChiffon.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative diagonal ribbon accents (purely cosmetic)
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Container(
                          width: 200,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _Palette.lemonChiffon.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -44,
                      left: -44,
                      child: Transform.rotate(
                        angle: 0.4,
                        child: Container(
                          width: 170,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.07),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Soft radial glow behind the icon block, adding depth
                    // without affecting any layout or logic.
                    Positioned(
                      top: -30,
                      left: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _Palette.lemonChiffon.withValues(alpha: 0.14),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // UI-ENHANCEMENT PASS 2: large faint watermark emblem
                    // — a unique signature touch this header didn't
                    // previously have, sitting low-opacity and large
                    // behind the copy, never competing with the title or
                    // the close button. Matches the receipt-style icon
                    // already used in the header's icon chip.
                    Positioned(
                      right: -14,
                      bottom: -18,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.07,
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 118,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Fine dotted texture accent — matches the dashed dot
                    // row used on the Menu/Dashboard headers.
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
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _Palette.lemonChiffon.withValues(
                                  alpha: i == 2 ? 0.85 : 0.28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // UI-ENHANCEMENT PASS 2: fine glass highlight line
                    // along the very top edge of the header — purely
                    // cosmetic, gives the header a more polished,
                    // "premium panel" finish matching the Menu/Orders
                    // headers' and Item Form dialog's top edge treatment.
                    Positioned(
                      top: 0,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.32),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 22),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isDesktop ? 48 : 42,
                            height: isDesktop ? 48 : 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _Palette.lemonChiffon
                                    .withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _Palette.lemonChiffon
                                      .withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: _Palette.lemonChiffon,
                              size: isDesktop ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Manual Order',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: isDesktop ? 26 : 19,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 9),
                                Container(
                                  width: 48,
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        _Palette.lemonChiffon
                                            .withValues(alpha: 0.9),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Take an order on behalf of a customer',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body
            Expanded(
              child: isDesktop ? _buildDesktopBody() : _buildMobileBody(),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: isDesktop ? 20 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _Palette.milanoRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TOTAL AMOUNT',
                            style: GoogleFonts.inter(
                              color: _Palette.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${_totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isDesktop ? 27 : 20,
                          fontWeight: FontWeight.bold,
                          color: _Palette.milanoRed,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _Palette.textMuted,
                            backgroundColor: _Palette.canvas,
                            side: BorderSide(
                              color: _Palette.milanoRedDeep
                                  .withValues(alpha: 0.14),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 24 : 12,
                              vertical: isDesktop ? 18 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 8),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isSubmitting
                                  ? const []
                                  : [
                                      BoxShadow(
                                        color: _Palette.milanoRed
                                            .withValues(alpha: 0.32),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: _Palette.lemonChiffon
                                            .withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _Palette.milanoRedDeep,
                                disabledBackgroundColor:
                                    _Palette.milanoRedDeep.withValues(
                                  alpha: 0.6,
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 40 : 8,
                                  vertical: isDesktop ? 18 : 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                            color: _Palette.lemonChiffon,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Submit Order',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
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
      ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOut).scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1, 1),
            duration: 220.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  // ── Body layouts ──────────────────────────────────────────────────────
  // Both desktop and mobile bodies are now wrapped in a SINGLE
  // SingleChildScrollView so the whole dialog body (customer details +
  // menu selection) scrolls together under one shared scrollbar, instead
  // of each side owning its own independent scroll area. To make that
  // work, the inner GridView/ListView are set to `shrinkWrap: true` with
  // `NeverScrollableScrollPhysics` so they size to their content and let
  // the single outer scroll view own all the scrolling.

  Widget _buildDesktopBody() {
    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Details
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _Palette.cardWhite,
                  border: Border(
                    right: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: _buildOrderDetailsForm(),
              ),
            ),
            // Right side: Menu selection
            Expanded(
              flex: 6,
              child: Container(
                color: _Palette.canvas,
                child: _buildMenuSelection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildOrderDetailsForm(),
          ),
          Container(
            height: 1,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          Container(
            color: _Palette.canvas,
            child: _buildMenuSelection(),
          ),
        ],
      ),
    );
  }

  InputDecoration _themedInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13),
      filled: true,
      fillColor: _Palette.canvas,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.milanoRedDeep, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _Palette.danger.withValues(alpha: 0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.danger, width: 1.6),
      ),
    );
  }

  Widget _buildOrderDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _Palette.milanoRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Order Configuration',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 50,
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    _Palette.milanoRedDeep.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Order Mode
          _fieldLabel('Order Mode'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Dine-in',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Dine-in')),
                  icon: Icon(Icons.restaurant, size: 14),
                ),
                ButtonSegment(
                  value: 'Takeaway',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Takeaway')),
                  icon: Icon(Icons.shopping_bag, size: 14),
                ),
                ButtonSegment(
                  value: 'Delivery',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Delivery')),
                  icon: Icon(Icons.delivery_dining, size: 14),
                ),
              ],
              selected: {_orderMode},
              onSelectionChanged: (v) => setState(() => _orderMode = v.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _Palette.milanoRedDeep,
                selectedForegroundColor: Colors.white,
                foregroundColor: _Palette.milanoRedDeep,
                side: BorderSide(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.3),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Table selection (only for Dine-in)
          if (_orderMode == 'Dine-in') ...[
            _fieldLabel('Select Table'),
            _isLoadingTables
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      color: _Palette.milanoRedDeep,
                      backgroundColor:
                          _Palette.milanoRedDeep.withValues(alpha: 0.1),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _selectedTableId,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _Palette.milanoRedDeep,
                    ),
                    style: GoogleFonts.inter(
                      color: _Palette.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _themedInputDecoration(),
                    hint: Text(
                      'Choose a table',
                      style: GoogleFonts.inter(color: _Palette.textMuted),
                    ),
                    items: _tables
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('Table ${t.tableNumber}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTableId = v),
                    validator: (v) => _orderMode == 'Dine-in' && v == null
                        ? 'Required'
                        : null,
                  ),
            const SizedBox(height: 20),
          ],

          // Payment Mode
          _fieldLabel('Payment Mode'),
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _Palette.milanoRedDeep,
            ),
            style: GoogleFonts.inter(
              color: _Palette.textDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: _themedInputDecoration(),
            items: [
              'Cash',
              'Card',
              'UPI',
              'Online',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMode = v!),
          ),

          const SizedBox(height: 24),

          // ── Customer Details ─────────────────────────────────────────
          // Pulled into its own clearly-bordered, titled section (icon +
          // heading + gold-tinted card) so it can no longer be missed while
          // scrolling the form. BOTH Name and Phone are REQUIRED fields —
          // each carries a red asterisk and a "REQUIRED" chip, and both
          // are wired into the existing form validator, so
          // `_submitOrder`'s already-present
          // `_formKey.currentState!.validate()` check will block
          // submission (with inline error messages) until both are
          // filled in.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _Palette.canvas,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _Palette.milanoRedDeep.withValues(alpha: 0.16),
                width: 1.2,
              ),
              boxShadow: _Palette.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 15,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Customer Details',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    'Both fields are required to place this order',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _Palette.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Customer Name', required: true),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.inter(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _themedInputDecoration(
                    hintText: "Enter the customer's name",
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Customer name is required'
                      : null,
                ),
                const SizedBox(height: 18),
                _fieldLabel('Customer Phone', required: true),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _themedInputDecoration(
                    hintText: 'Enter a contact number',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Customer phone is required'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {String? badge, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: required ? _Palette.danger : _Palette.milanoRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: _Palette.milanoRedDeep,
              letterSpacing: 0.5,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 3),
            Text(
              '*',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: _Palette.danger,
              ),
            ),
          ],
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _Palette.lemonChiffon.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _Palette.milanoRedDeep,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
          if (required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _Palette.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _Palette.danger.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                'REQUIRED',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _Palette.danger,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSelection() {
    if (_viewMode == 'categories') {
      return _buildCategoriesGrid();
    } else {
      return _buildItemsList();
    }
  }

  Widget _buildCategoriesGrid() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: _Palette.milanoRedDeep,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Category',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (ctx, i) {
            final cat = widget.categories[i];
            return _CategoryCard(
              category: cat,
              onTap: () {
                setState(() {
                  _activeCategory = cat;
                  _viewMode = 'items';
                });
              },
            ).animate().fadeIn(delay: (i * 40).ms, duration: 300.ms);
          },
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = widget.menuItems
        .where((i) => i.isAvailable && i.categoryId == _activeCategory?.id)
        .toList();

    return Column(
      children: [
        // Back Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _Palette.milanoRedDeep,
                  ),
                  onPressed: () => setState(() => _viewMode = 'categories'),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _activeCategory?.name ?? 'Items',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length} items',
                  style: GoogleFonts.inter(
                    color: _Palette.milanoRedDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No items in this category.',
                    style: GoogleFonts.inter(color: _Palette.textMuted),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final qty = _selectedItems[item.id] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: qty > 0 ? 0.10 : 0.04,
                          ),
                          blurRadius: qty > 0 ? 16 : 10,
                          offset: Offset(0, qty > 0 ? 6 : 3),
                        ),
                      ],
                      border: Border.all(
                        color: qty > 0
                            ? _Palette.milanoRed.withValues(alpha: 0.45)
                            : _Palette.milanoRedDeep.withValues(alpha: 0.12),
                        width: qty > 0 ? 1.6 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _Palette.canvasDeep,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: _Palette.textMuted,
                              size: 28,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _Palette.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: _Palette.milanoRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (qty > 0) ...[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: _Palette.milanoRed,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (qty == 1) {
                                      _selectedItems.remove(item.id);
                                    } else {
                                      _selectedItems[item.id] = qty - 1;
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  '$qty',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _Palette.textDark,
                                  ),
                                ),
                              ),
                            ],
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                qty > 0
                                    ? Icons.add_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: _Palette.success,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedItems[item.id] = qty + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final MenuCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
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
          transform: _isHovered
              ? (Matrix4.identity()..scaleByDouble(1.02, 1.02, 1.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                  )
                : null,
            color: _isHovered ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _Palette.milanoRedDeep.withValues(
                  alpha: _isHovered ? 0.22 : 0.06,
                ),
                blurRadius: _isHovered ? 18 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? _Palette.milanoRedDeep
                  : _Palette.milanoRedDeep.withValues(alpha: 0.15),
              width: _isHovered ? 1.5 : 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.18)
                      : _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color:
                      _isHovered ? _Palette.lemonChiffon : _Palette.milanoRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.category.name,
                style: GoogleFonts.inter(
                  fontWeight: _isHovered ? FontWeight.w800 : FontWeight.bold,
                  fontSize: 14,
                  color: _isHovered ? Colors.white : _Palette.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
