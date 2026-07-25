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
/// NOTE: This is a private class, so it can't be imported from
/// dashboard_screen.dart — it must be redeclared identically in every
/// screen that wants this look. That duplication (or the lack of it) is
/// exactly why this screen previously fell back to AppColors.* and looked
/// different from the Dashboard.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // Dark Maroon primary (was Milano Red)
  static const Color milanoRed = Color(0xFF8B1D1D);
  static const Color milanoRedDeep = Color(0xFF5E1212);
  static const Color milanoRedLight = Color(0xFFA62828);

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
  /// language used on the Menu Management screen so both screens read
  /// as one consistent brand.
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

    return Scaffold(
      backgroundColor: _Palette.canvas,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft cream/gold glows layered over the
          // existing canvas wash, matching the Menu Management screen's
          // "foggy" backdrop so the whole admin experience feels like one
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
                ],
              ),
            ),
          ),

          Column(
            children: [
              // ── Header — same Dark Maroon gradient theme as the Order
              // Summary card below, so both read as one brand ──────────
              _ScreenHeader(
                title: 'Create Order',
                subtitle: 'Manual order entry',
                dateLabel: _todayLabel(),
                onBack: () => context.pop(),
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
          child: _buildTableAndCustomer(tables),
        )
            .animate()
            .fade(duration: 350.ms)
            .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOut),
        const SizedBox(height: 20),
        _buildSection(
          icon: Icons.restaurant_menu,
          title: 'Menu Items',
          child: _buildMenuSection(grouped, menu),
        )
            .animate()
            .fade(duration: 350.ms, delay: 80.ms)
            .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
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
      child: Column(
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
                  child: Icon(icon, color: _Palette.milanoRedDeep, size: 18),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              // Summary header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_rounded,
                      color: Colors.white,
                      size: 24,
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
/// Menu Management screen for a consistent brand language.
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

// ─── Screen header — Dark Maroon gradient treatment that matches the Order
// Summary card (color, gradient direction, and shadow language match) and
// mirrors the Menu Management screen's navbar language: soft rounded
// bottom corners, a gold-glow accent border, layered ribbon glows, a fine
// dotted texture accent, and the current date shown on wide screens. The
// back control is now a compact, icon-only "‹" chip — no label, no arrow
// glyph — for a cleaner, more premium top bar. The leading icon carries a
// thin gold outline (gold on dark maroon is a classic premium / heritage
// restaurant pairing) so it reads as a polished brand mark rather than a
// plain glass chip. Nothing here changes behaviour — purely a richer,
// more unique visual treatment, and the header now draws behind the
// status bar for a true full-screen, edge-to-edge look. ──────────────────
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
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 36),
            bottomRight: Radius.circular(isMobile ? 28 : 36),
          ),
          border: Border(
            bottom: BorderSide(
              color: _Palette.gold.withValues(alpha: 0.85),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.38),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: _Palette.gold.withValues(alpha: 0.10),
              blurRadius: 40,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle decorative diagonal ribbon accents — purely cosmetic,
            // matches the Menu Management header for a consistent brand feel.
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
            // Dashboard hero treatment — now a warm gold glow.
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
            // backdrop feel on wider headers — purely decorative.
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
                        // compact glass-gold chip for a cleaner top bar.
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
                                  size: isMobile ? 25 : 29,
                                  weight: FontWeight.w800,
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
                                  weight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isMobile)
                          Container(
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
                            child: Text(
                              dateLabel,
                              style: AppTheme.sans(
                                size: 10.5,
                                weight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                      ],
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
// Replaces the previous arrow_back_rounded icon + "Back" label combo with
// a single, minimal "‹" glyph inside a rounded glass-gold chip. Purely a
// visual swap — same onTap/onBack callback, no navigation logic touched.
class _BackChip extends StatefulWidget {
  final VoidCallback onTap;
  const _BackChip({required this.onTap});

  @override
  State<_BackChip> createState() => _BackChipState();
}

class _BackChipState extends State<_BackChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.10),
            border: Border.all(
              color: _Palette.gold.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.gold.withValues(alpha: 0.18),
                blurRadius: 10,
                spreadRadius: 0.5,
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
