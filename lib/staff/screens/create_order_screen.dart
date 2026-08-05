import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contexts/auth_provider.dart';
import '../contexts/menu_provider.dart';
import '../contexts/orders_provider.dart';
import '../contexts/tables_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Dark Maroon / Soft Cream / Gold Glow" palette — Theme 1.
/// Used ONLY for this screen's restyle. Nothing here touches AppColors,
/// AppTheme, or any other file — pure UI enhancement, no logic changed
/// anywhere here. Field names are kept identical to the previous palette
/// so every usage below the class still lines up — only the color VALUES
/// have changed to the new Dark Maroon × Soft Cream × Gold Glow theme.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header, section cards, and
/// summary panel up to the same distinctive "command bar" identity used
/// on the New Orders / Orders / Order Details screens — a four-stop
/// diagonal gradient header, a large faint watermark emblem, a glass
/// highlight line along the top edge, and a new live quick-stats readout
/// strip (Items Selected / Estimated Total / Tables Free) built entirely
/// from values already computed in build(). The full-screen backdrop
/// gained an extra ambient glow + a diagonal sheen for more depth, and
/// each section card picked up a slim color-coded accent rail down the
/// left edge, matching the New Orders / Orders screens' card treatment.
/// No provider, controller, route, submit, or pricing logic was touched
/// anywhere in this pass — only presentation changed.
///
/// NOTE: This is a private class, so it can't be imported from
/// dashboard_screen.dart / new_orders_screen.dart — it must be
/// redeclared identically in every screen that wants this look. That
/// duplication is intentional (private classes can't be shared across
/// files without a new shared import, which would go beyond a pure
/// UI-only change here).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Dark Maroon primary (was Milano Red)
  static const Color milanoRed = Color(0xFF8B1D1D);
  static const Color milanoRedDeep = Color(0xFF5E1212);
  static const Color milanoRedLight = Color(0xFFA62828);
  // Deepest maroon — fourth stop of the header's richer diagonal gradient.
  static const Color milanoRedDarkest = Color(0xFF3A0B0B);

  // Soft Cream + Gold Glow accents (was Lemon Chiffon)
  static const Color lemonChiffon = Color(0xFFFFF8E7);
  static const Color lemonChiffonDeep = Color(0xFFF4E4C1);

  // Soft cream canvas background
  static const Color canvas = Color(0xFFFFFBF5);
  static const Color canvasDeep = Color(0xFFFCF1DD);

  static const Color textDark = Color(0xFF2A1610);
  static const Color textMuted = Color(0xFF8B7D6B);

  // Gold Glow accent
  static const Color gold = Color(0xFFF4C430);
  static const Color goldDeep = Color(0xFFD9A61E);

  /// Themed soft shadow for resting cards/panels — mirrors the shadow
  /// language used on the Menu Management / New Orders screens so every
  /// card on this page reads as one consistent brand.
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

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the New Orders / Orders / Order Details headers
  /// (deep maroon drop shadow + soft ambient gold bloom + fine black
  /// contact shadow).
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.38),
          blurRadius: 32,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.12),
          blurRadius: 38,
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
  /// depth. Matches the New Orders / Orders / Order Details screens'
  /// statCapsuleShadow exactly.
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

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedTableId;
  String _selectedTableName = 'Takeaway / Walk-in';
  bool _isSubmitting = false;
  final Map<String, int> _qty = {}; // menuItemId -> quantity

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<StaffAuthProvider>();
      context.read<MenuProvider>().fetchMenuItems(authToken: auth.token);
      if (auth.token != null) {
        context.read<TablesProvider>().fetchTables(auth.token!);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _orderItems {
    return _qty.entries
        .where((e) => e.value > 0)
        .map((e) => {'menu_item_id': e.key, 'quantity': e.value})
        .toList();
  }

  double _calcTotal(List<MenuItem> menuItems) {
    double t = 0;
    for (final e in _qty.entries) {
      if (e.value <= 0) continue;
      final item = menuItems.where((m) => m.id == e.key).firstOrNull;
      if (item != null) t += item.price * e.value;
    }
    return t;
  }

  Future<void> _submit() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to the order.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final ordersProvider = context.read<OrdersProvider>();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("No authentication token found.");

      await ordersProvider.createOrder({
        "table_id": _selectedTableId,
        "order_type": _selectedTableId == null ? "TAKEAWAY" : "DINE_IN",
        "customer_name": _nameCtrl.text.trim().isEmpty
            ? 'Walk-in Customer'
            : _nameCtrl.text.trim(),
        "customer_phone": _phoneCtrl.text.trim(),
        "items": _orderItems,
      }, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order created successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tables = context.watch<TablesProvider>().tables;
    final menu = context.watch<MenuProvider>();

    // Group menu items by category
    final Map<String, List<MenuItem>> grouped = {};
    for (final item in menu.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final selectedCount = _qty.values.fold(0, (a, b) => a + b);
    final total = _calcTotal(menu.items);
    // Purely a display value for the header's quick-stats strip — derived
    // from the same `tables` list already used below. No new data source,
    // no logic change.
    final availableTablesCount =
        tables.where((t) => t.status == TableStatus.available).length;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft cream/gold glows layered over the
          // existing canvas wash, matching the Menu Management / New
          // Orders screens' "foggy" backdrop so the whole admin experience
          // feels like one cohesive brand. No logic touched — visuals only.
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
                  // Extra low, wide glow further down the page — gives a
                  // long form/menu list a second soft focal point instead
                  // of all the ambient light sitting only near the header.
                  // Matches the New Orders / Orders screens' Pass-2
                  // backdrop treatment.
                  Positioned(
                    top: 620,
                    right: -110,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.goldDeep.withValues(alpha: 0.07),
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
          // used in the header itself. Matches the New Orders / Orders /
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
              // ── Header — same Dark Maroon gradient theme as the Order
              // Summary card below, now restyled into a richer "command
              // bar" with a live quick-stats readout, so both read as one
              // brand ────────────────────────────────────────────────────
              _ScreenHeader(
                title: 'Create Order',
                subtitle: 'Manual order entry',
                dateLabel: _todayLabel(),
                onBack: () => context.pop(),
                selectedCount: selectedCount,
                total: total,
                availableTablesCount: availableTablesCount,
              ),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildLeftPanel(
                                        tables,
                                        grouped,
                                        menu,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 320,
                                      child: _buildSummaryPanel(
                                        menu.items,
                                        selectedCount,
                                        total,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildLeftPanel(tables, grouped, menu),
                                    const SizedBox(height: 24),
                                    _buildSummaryPanel(
                                      menu.items,
                                      selectedCount,
                                      total,
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

  // ─── Left panel: table + customer + menu ──────────────────────────
  Widget _buildLeftPanel(
    List<TableModel> tables,
    Map<String, List<MenuItem>> grouped,
    MenuProvider menu,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          icon: Icons.table_restaurant,
          title: 'Table & Customer',
          railColor: _Palette.milanoRed,
          child: _buildTableAndCustomer(tables),
        )
            .animate()
            .fade(duration: 350.ms)
            .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOut),
        const SizedBox(height: 20),
        _buildSection(
          icon: Icons.restaurant_menu,
          title: 'Menu Items',
          railColor: _Palette.goldDeep,
          child: _buildMenuSection(grouped, menu),
        )
            .animate()
            .fade(duration: 350.ms, delay: 80.ms)
            .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOut),
      ],
    );
  }

  // UI-ENHANCEMENT PASS 2: each section card now carries a slim
  // color-coded accent rail down the left edge (matching the New Orders /
  // Orders screens' card treatment), giving "Table & Customer" and "Menu
  // Items" an instant visual identity. Same content, same children —
  // purely presentational, wrapped with Clip.antiAlias so the rail
  // respects the card's rounded corners.
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
    Color railColor = _Palette.milanoRed,
  }) {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(icon, color: _Palette.milanoRedDeep, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: AppTheme.sans(
                        size: 16,
                        weight: FontWeight.w800,
                        color: _Palette.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Divider(
                  height: 1,
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Table & Customer fields ──────────────────────────────────────
  Widget _buildTableAndCustomer(List<TableModel> tables) {
    final availableTables =
        tables.where((t) => t.status == TableStatus.available).toList();
    final tableOptions = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '', child: Text('Takeaway / Walk-in')),
      ...availableTables.map(
        (t) => DropdownMenuItem(
          value: t.id,
          child: Text(
            t.name.toLowerCase().startsWith('table')
                ? t.name
                : 'Table ${t.name}',
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Table'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedTableId ?? '',
          isExpanded: true,
          decoration: _inputDecoration('Select a table'),
          items: tableOptions,
          onChanged: (v) => setState(() {
            _selectedTableId = (v == null || v.isEmpty) ? null : v;
            _selectedTableName = v == null || v.isEmpty
                ? 'Takeaway / Walk-in'
                : (tables.firstWhere((t) => t.id == v).name);
          }),
        ),
        const SizedBox(height: 16),
        _label('Customer Name (optional)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameCtrl,
          decoration: _inputDecoration('Walk-in Customer'),
          style: AppTheme.sans(size: 14, color: _Palette.textDark),
        ),
        const SizedBox(height: 16),
        _label('Customer Phone (optional)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('e.g. 9876543210'),
          style: AppTheme.sans(size: 14, color: _Palette.textDark),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTheme.sans(
          size: 12,
          weight: FontWeight.w700,
          color: _Palette.textMuted,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.sans(
          size: 14,
          color: _Palette.textMuted.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: _Palette.canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.14),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _Palette.milanoRed.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
      );

  // ── Menu section ─────────────────────────────────────────────────
  Widget _buildMenuSection(
    Map<String, List<MenuItem>> grouped,
    MenuProvider menu,
  ) {
    if (menu.isLoading) {
      return Column(
        children: List.generate(
          5,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: ShimmerLoading(
              width: double.infinity,
              height: 60,
              borderRadius: 12,
            ),
          ),
        ),
      );
    }
    if (menu.error != null || menu.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 48,
              color: _Palette.textMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              menu.error != null ? menu.error! : 'No menu items available',
              style: AppTheme.sans(size: 14, color: _Palette.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Retry',
              onTap: () async {
                final auth = context.read<StaffAuthProvider>();
                menu.fetchMenuItems(authToken: auth.token);
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _Palette.milanoRedLight,
                          _Palette.milanoRed,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key.toUpperCase(),
                    style: AppTheme.sans(
                      size: 12,
                      weight: FontWeight.w900,
                      color: _Palette.textDark,
                    ).copyWith(letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            ...entry.value.map(
              (item) => _MenuItemRow(
                item: item,
                qty: _qty[item.id] ?? 0,
                onAdd: () =>
                    setState(() => _qty[item.id] = (_qty[item.id] ?? 0) + 1),
                onRemove: () {
                  final cur = _qty[item.id] ?? 0;
                  setState(() {
                    if (cur <= 1) {
                      _qty.remove(item.id);
                    } else {
                      _qty[item.id] = cur - 1;
                    }
                  });
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Summary panel ─────────────────────────────────────────────────
  Widget _buildSummaryPanel(
    List<MenuItem> allItems,
    int selectedCount,
    double total,
  ) {
    final selected = _qty.entries
        .where((e) => e.value > 0)
        .map((e) {
          final item = allItems.where((m) => m.id == e.key).firstOrNull;
          if (item == null) return null;
          return (item: item, qty: e.value);
        })
        .whereType<({MenuItem item, int qty})>()
        .toList();

    return Column(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary header — UI-ENHANCEMENT PASS 2: richer four-stop
              // diagonal gradient (matching the main header exactly), a
              // fine glass highlight line along the top edge, and a large
              // faint watermark emblem behind the copy, so this card reads
              // as part of the same "command bar" brand language as the
              // header above. Same content, same badge count — purely
              // presentational.
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _Palette.milanoRedLight,
                        _Palette.milanoRed,
                        _Palette.milanoRedDeep,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Large faint watermark emblem — echoes the main
                      // header's signature touch at a smaller scale.
                      Positioned(
                        right: -16,
                        bottom: -18,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.08,
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 88,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Fine glass highlight line along the top edge.
                      Positioned(
                        top: 0,
                        left: 4,
                        right: 4,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _Palette.gold.withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.receipt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order Summary',
                            style: AppTheme.serif(
                              size: 18,
                              weight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _Palette.gold.withValues(alpha: 0.45),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$selectedCount',
                              style: AppTheme.sans(
                                size: 12,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table info
                    _SummaryRow(
                      label: 'Table',
                      value: _selectedTableName,
                      icon: Icons.table_bar_rounded,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Customer',
                      value: _nameCtrl.text.trim().isEmpty
                          ? 'Walk-in Customer'
                          : _nameCtrl.text.trim(),
                      icon: Icons.person_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(
                        height: 1,
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                      ),
                    ),

                    if (selected.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 32,
                                color: _Palette.textMuted.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No items selected',
                                style: AppTheme.sans(
                                  size: 14,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...selected.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.qty}',
                                    style: AppTheme.sans(
                                      size: 11,
                                      weight: FontWeight.w900,
                                      color: _Palette.milanoRedDeep,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.item.name,
                                  style: AppTheme.sans(
                                    size: 14,
                                    color: _Palette.textDark.withValues(
                                      alpha: 0.85,
                                    ),
                                    weight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '₹${(e.item.price * e.qty).toStringAsFixed(0)}',
                                style: AppTheme.serif(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: _Palette.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (selected.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1,
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      _SummaryDetailRow(
                        label: 'Subtotal',
                        value: '₹${total.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tax (if applicable) is calculated on the final bill.',
                        style: AppTheme.sans(
                          size: 11,
                          color: _Palette.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Amount',
                            style: AppTheme.sans(
                              size: 14,
                              weight: FontWeight.w700,
                              color: _Palette.textMuted,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: AppTheme.serif(
                              size: 24,
                              weight: FontWeight.w900,
                              color: _Palette.milanoRedDeep,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fade(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.05, curve: Curves.easeOutQuad),

        const SizedBox(height: 20),

        // Create Order button
        PrimaryButton(
          label: 'CREATE ORDER',
          onTap: _isSubmitting ? null : _submit,
          isLoading: _isSubmitting,
          color: _Palette.milanoRedDeep,
          textColor: Colors.white,
          icon: Icons.check_circle_rounded,
        )
            .animate()
            .fade(duration: 400.ms, delay: 300.ms)
            .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
      ],
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the accent used under section titles on the
/// Menu Management / New Orders screens for a consistent brand language.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider({this.width = 54});

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
            _Palette.gold.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Screen header — restyled into its own distinctive "command bar"
// identity, matching the New Orders / Orders / Order Details screens'
// Pass-2 treatment exactly: a richer four-stop diagonal gradient, a large
// faint watermark emblem behind the title, a fine glass highlight line
// along the top edge, layered ribbon glows, a dotted texture accent, and
// a floating date pill. UI-ENHANCEMENT PASS 2 adds a live quick-stats
// readout strip (Items Selected / Estimated Total / Tables Free) built
// from values already computed in build() — no new data source, purely a
// display of values already available at the call site. The back control
// remains the same compact, icon-only "‹" chip (now with a hover state
// to feel more alive), and no submit/navigation/pricing logic was
// touched — this is a purely presentational change. ─────────────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onBack;
  final int selectedCount;
  final double total;
  final int availableTablesCount;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onBack,
    required this.selectedCount,
    required this.total,
    required this.availableTablesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat two-stop wash, matching the New
          // Orders / Orders / Order Details screens' "faceted" surface
          // language.
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
              color: _Palette.gold.withValues(alpha: 0.9),
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
                        _Palette.gold.withValues(alpha: 0.16),
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
            // Soft radial glow behind the brand icon, echoing the
            // Dashboard / New Orders hero treatment.
            Positioned(
              top: -50,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
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
            // Extra ambient glow, lower-right, for a fuller "full-screen"
            // backdrop feel — purely decorative.
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
                      _Palette.gold.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Large faint watermark emblem — a unique signature touch,
            // sits low-opacity and large behind the copy, never competing
            // with the title or the stats strip. Matches the New Orders /
            // Orders / Order Details screens' Pass-2 header exactly.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -22 : -16,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.restaurant_menu_rounded,
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
                        color: _Palette.gold.withValues(
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
            // matches the Dashboard / New Orders / Order Details hero's
            // top edge treatment.
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
                        // no arrow icon and no "Back" label, inside a
                        // compact glass-gold chip that now brightens on
                        // hover, matching the New Orders / Orders / Order
                        // Details screens' header control. ─────────────
                        _BackChip(onTap: onBack),
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
                                color: _Palette.gold.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: _Palette.gold.withValues(
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
                        // gold glow layered under the glass background.
                        // Purely decorative; no logic touched. ─────────
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
                            Icons.receipt_long_rounded,
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
                              Text(
                                subtitle,
                                style: AppTheme.sans(
                                  size: 12.5,
                                  weight: FontWeight.w600,
                                  color: _Palette.gold,
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
                              color: _Palette.gold.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 10,
                                color: _Palette.gold.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                dateLabel,
                                style: AppTheme.sans(
                                  size: 10.5,
                                  weight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ── Live quick-stats readout strip — Items Selected /
                    // Estimated Total / Tables Free, built straight from
                    // values already computed in build(). Purely a
                    // display addition; no new data source and no logic
                    // change.
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
                              value: '$selectedCount',
                              label: 'Items',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.payments_rounded,
                              value: '₹${total.toStringAsFixed(0)}',
                              label: 'Est. Total',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.table_bar_rounded,
                              value: '$availableTablesCount',
                              label: 'Tables Free',
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
/// strip — purely decorative spacing element, no logic. Matches the New
/// Orders / Orders / Order Details screens' Pass-2 header strip exactly.
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

// ─── Back chip — icon-only "‹" control ────────────────────────────────────
// Same minimal "‹" glyph inside a rounded glass-gold chip as before, now
// with a hover state (in addition to the existing press state) so it
// feels a touch more responsive on desktop/web, matching the New Orders
// screen's back control. Purely a visual upgrade — same onTap/onBack
// callback, no navigation logic touched.
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

// ─── Menu Item Row ────────────────────────────────────────────────────────────
class _MenuItemRow extends StatefulWidget {
  final MenuItem item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemRow({
    required this.item,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow> {
  bool _addPressed = false;
  bool _incPressed = false;
  bool _decPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.qty > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? _Palette.milanoRed.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? _Palette.milanoRedDeep.withValues(alpha: 0.2)
              : _Palette.milanoRedDeep.withValues(alpha: 0.08),
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _Palette.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: isSelected
                  ? _Palette.milanoRedDeep
                  : _Palette.textMuted.withValues(alpha: 0.4),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: AppTheme.sans(
                    size: 15,
                    weight: FontWeight.w700,
                    color: _Palette.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${widget.item.price.toStringAsFixed(0)}',
                  style: AppTheme.serif(
                    size: 13,
                    weight: FontWeight.w700,
                    color: _Palette.milanoRedDeep,
                  ),
                ),
              ],
            ),
          ),
          if (widget.qty == 0)
            GestureDetector(
              onTap: widget.onAdd,
              onTapDown: (_) => setState(() => _addPressed = true),
              onTapUp: (_) => setState(() => _addPressed = false),
              onTapCancel: () => setState(() => _addPressed = false),
              child: AnimatedScale(
                scale: _addPressed ? 0.9 : 1.0,
                duration: 120.ms,
                curve: Curves.easeOut,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _Palette.milanoRedLight,
                        _Palette.milanoRedDeep,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              decoration: BoxDecoration(
                color: _Palette.canvas,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onRemove,
                    onTapDown: (_) => setState(() => _decPressed = true),
                    onTapUp: (_) => setState(() => _decPressed = false),
                    onTapCancel: () => setState(() => _decPressed = false),
                    child: AnimatedScale(
                      scale: _decPressed ? 0.88 : 1.0,
                      duration: 120.ms,
                      curve: Curves.easeOut,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: _Palette.milanoRedDeep,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.qty}',
                      style: AppTheme.sans(
                        size: 16,
                        weight: FontWeight.w900,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onAdd,
                    onTapDown: (_) => setState(() => _incPressed = true),
                    onTapUp: (_) => setState(() => _incPressed = false),
                    onTapCancel: () => setState(() => _incPressed = false),
                    child: AnimatedScale(
                      scale: _incPressed ? 0.88 : 1.0,
                      duration: 120.ms,
                      curve: Curves.easeOut,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _Palette.milanoRedLight,
                              _Palette.milanoRedDeep,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .shimmer(duration: 400.ms, color: Colors.white.withValues(alpha: 0.2));
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _Palette.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.sans(size: 12, color: _Palette.textMuted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTheme.sans(
              size: 13,
              weight: FontWeight.w600,
              color: _Palette.textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _SummaryDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryDetailRow({required this.label, required this.value});

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
            size: 13,
            color: _Palette.textDark,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}