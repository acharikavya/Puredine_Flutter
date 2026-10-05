import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../contexts/auth_provider.dart';
import '../contexts/menu_provider.dart';
import '../contexts/orders_provider.dart';
import '../contexts/tables_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the Dashboard / Menu / Orders
/// screens exactly, so this screen shares one consistent brand identity.
/// Field names are kept identical to the previous palette so every usage
/// below the class still lines up — only the color VALUES and the shadow
/// helpers changed. Nothing here touches AppColors, AppTheme, or any other
/// file — pure UI enhancement, no logic changed anywhere here.
///
/// UI-ENHANCEMENT PASS 5: the header's title row (`_ScreenHeader`) no
/// longer shows the top-right icon badge (the white-ringed circle avatar
/// with the receipt icon and the small green status dot). The title block
/// (subtitle label + big title) now simply takes the full width of the
/// row. Nothing else in the header changed — same back chip, same
/// tagline pill, same date/live row, same gold hairline, same animations.
/// No provider, controller, route, submit, or pricing logic was touched
/// anywhere in this pass — presentation only.
///
/// UI-ENHANCEMENT PASS 6: the tagline pill ("Add items and finalize the
/// order.") no longer has a drop shadow/border edge and no longer shows
/// the small circular icon badge in front of it — it's now just clean
/// cream text sitting flush in the header. The copy itself is unchanged,
/// only its presentation (centered, bolder, letter-spaced, slightly
/// larger) for a more polished, "less boxed-in" look. No callback,
/// navigation, or data logic lives in this widget — presentation only.
///
/// UI-ENHANCEMENT PASS 7: `_ScreenHeader`'s bottom edge is now
/// a straight, flat line instead of the previous rounded 32px corners —
/// matching the flat-bottom topbar treatment used on StaffScreen. The
/// rounded `BorderRadius` on the header `Container`/`ClipRRect` was
/// removed (so the banner is now a plain rectangle) and a thin warm-gold
/// hairline border was added along the bottom edge, mirroring the same
/// subtle bottom-edge accent StaffScreen's topbar uses. Everything else
/// inside the header — the gradient, the drop shadow, the ambient gold
/// glows, the back chip, the title block, the tagline, and the date/live
/// row — is completely unchanged, as is every other part of this file
/// (`_StatsRow`, `_StatCard`, `_MenuItemRow`, `_SummaryRow`,
/// `_SummaryDetailRow`, and all provider/submit/pricing logic in
/// `_CreateOrderScreenState`). Presentation only.
///
/// UI-ENHANCEMENT PASS 8 (this pass — full three-tier responsive layout):
/// responsive-layout-only — no provider, controller, route, submit, or
/// pricing logic anywhere in this file was touched, and no state field or
/// keyword was renamed.
///   1. RESPONSIVE BREAKPOINTS: the body now measures the available width
///      via a `_DeviceType` breakpoint (mobile < 700, tablet 700–1100,
///      desktop ≥ 1100) — matching the same breakpoint already used on
///      the Orders / Tables / Staff Profile screens — instead of the
///      previous single `isWide` split at 768px. The two-column-vs-
///      stacked switch still happens at the same tablet-and-up point
///      (`isWide` is now simply "not mobile"), but the outer scroll
///      padding, the spacing above the two-column area, and the summary
///      panel's fixed width all now scale through three tiers instead of
///      two.
///   2. TABLET / DESKTOP POLISH: the summary panel is slightly narrower
///      on tablet (280px) than on desktop (320px), so the left panel
///      (table/customer fields + menu list) keeps more breathing room at
///      mid-size widths instead of being squeezed by a desktop-width
///      sidebar. `_ScreenHeader` gained its own tablet tier between the
///      existing mobile and desktop sizing for its padding, title/
///      tagline type scale, and internal spacing, matching the tuning
///      already used on the Orders/Tables screens' headers. Every field,
///      button, menu row, summary row, and callback is unchanged.
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

  // Gold accent family — Warm Gold (accent) / a deeper gold for borders
  // and emphasis states.
  static const Color gold = Color(0xFFF3C564);
  static const Color goldDeep = Color(0xFFD9A63E);

  // Extra brand tints from the PUREDINE palette.
  static const Color dustyBlush = Color(0xFFF3D9DC); // Blush/Pink tint
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background
  static const Color freshGreen = Color(0xFF44AF70); // Live / Success

  /// Themed soft shadow for resting cards/panels.
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

  /// Floating stat-card shadow — used by `_StatCard`, needs enough depth
  /// to read clearly whether it sits near the header or on plain canvas.
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];

  /// Soft, borderless shadow used by the header's tagline pill — a single
  /// gentle drop shadow (no ring/outline) so the pill reads as a clean
  /// floating cream card rather than a bordered chip.
  static List<BoxShadow> get taglineShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
}

/// PASS 8: simple responsive breakpoint helper — layout-only, does not
/// touch any provider/submit/pricing logic anywhere in this file. Matches
/// the same breakpoint values already used on the Orders / Tables / Staff
/// Profile screens so every staff screen switches layouts at exactly the
/// same widths.
enum _DeviceType { mobile, tablet, desktop }

_DeviceType _deviceTypeForWidth(double width) {
  if (width < 700) return _DeviceType.mobile;
  if (width < 1100) return _DeviceType.tablet;
  return _DeviceType.desktop;
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
      final auth = context.read<StaffAuthProvider>();
      final token = auth.token;

      if (token == null || token.isEmpty) {
        throw Exception(
          "Staff authentication token not found. Please login again.",
        );
      }

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
    // Purely a display value for the stats row below the header — derived
    // from the same `tables` list already used elsewhere. No new data
    // source, no logic change.
    final availableTablesCount =
        tables.where((t) => t.status == TableStatus.available).length;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft cream/gold glows layered over the
          // canvas wash, matching the Dashboard / Menu Management / New
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
          // flat behind the header.
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
              // ── Header — restyled to match the Dashboard's hero banner
              // design language (two-stop maroon-to-wine gradient, title
              // block, cream tagline pill, date/live row, gold hairline).
              // No photo/avatar image anywhere, and no top-right icon
              // badge. This is the ONLY fixed/non-scrolling element on
              // the page — the live stats now live in `_StatsRow`, which
              // scrolls with the content below (see immediately below).
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
                    // PASS 8: three-tier breakpoint replaces the old
                    // single `isWide` split at 768px. `isWide` is kept as
                    // a convenience flag ("tablet or desktop") so the
                    // two-column-vs-stacked switch below reads exactly as
                    // before.
                    final deviceType =
                        _deviceTypeForWidth(constraints.maxWidth);
                    final isWide = deviceType != _DeviceType.mobile;
                    final isTablet = deviceType == _DeviceType.tablet;
                    final isDesktop = deviceType == _DeviceType.desktop;

                    // PASS 8: tier-specific outer padding and summary
                    // panel width instead of a single fixed value for
                    // every screen width.
                    final double outerPadding =
                        isDesktop ? 28 : (isTablet ? 22 : 16);
                    final double panelGap = isDesktop ? 24 : 18;
                    final double summaryPanelWidth = isDesktop ? 320 : 280;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(outerPadding),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Live Stats Row — first thing in the
                              // scroll view, directly below the header,
                              // mirroring the Dashboard's `_StatsRow`
                              // pattern. Same three values (selectedCount /
                              // total / availableTablesCount) already
                              // computed above — no data or logic change,
                              // only where/how they're displayed.
                              _StatsRow(
                                selectedCount: selectedCount,
                                total: total,
                                availableTablesCount: availableTablesCount,
                                isMobile: !isWide,
                              ),
                              SizedBox(
                                height: isDesktop ? 28 : (isTablet ? 24 : 20),
                              ),
                              isWide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: _buildLeftPanel(
                                            tables,
                                            grouped,
                                            menu,
                                          ),
                                        ),
                                        SizedBox(width: panelGap),
                                        SizedBox(
                                          width: summaryPanelWidth,
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
                                        _buildLeftPanel(
                                          tables,
                                          grouped,
                                          menu,
                                        ),
                                        const SizedBox(height: 24),
                                        _buildSummaryPanel(
                                          menu.items,
                                          selectedCount,
                                          total,
                                        ),
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

  // Each section card carries a slim color-coded accent rail down the left
  // edge, giving "Table & Customer" and "Menu Items" an instant visual
  // identity. Same content, same children — purely presentational, wrapped
  // with Clip.antiAlias so the rail respects the card's rounded corners.
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
                      gradient: const LinearGradient(
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
                      letterSpacing: 1.5,
                    ),
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
              // Summary header — richer three-stop diagonal gradient with a
              // fine glass highlight line along the top edge and a large
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
                      const Positioned(
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

// ─── Screen header — matches the Dashboard's hero banner design language:
// a two-stop maroon-to-wine gradient, soft ambient gold glows, a title
// block (no icon badge), a borderless cream tagline pill (icon + text, no
// image, no trailing chevron), and a date/live row with a gold hairline
// underneath. The old in-header stats capsule was moved out into
// `_StatsRow` (see below), and the top-right icon badge has been removed
// entirely — the title row is now just the subtitle/title column at full
// width.
//
// UI-ENHANCEMENT PASS 7: the bottom edge is now a straight, flat line —
// matching StaffScreen's flat-bottom topbar — instead of the previous
// rounded 32px corners. A thin warm-gold hairline border was added along
// that bottom edge (mirroring StaffScreen's own bottom-edge accent). No
// submit/navigation/pricing logic lives here.
//
// UI-ENHANCEMENT PASS 8: the single `isMobile` split at 800px was stepped
// up into three tiers (mobile/tablet/desktop) using the same
// `_deviceTypeForWidth` breakpoint the rest of the screen now uses, so
// the header's padding, title/tagline type scale, and internal spacing
// read with a bit more breathing room on tablets instead of jumping
// straight from the compact phone sizing to the full desktop sizing —
// matching the tuning already used on the Orders/Tables screens' headers.
// Structure, text, callbacks and data are unchanged.
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
    final deviceType = _deviceTypeForWidth(MediaQuery.of(context).size.width);
    final isMobile = deviceType == _DeviceType.mobile;
    final isTablet = deviceType == _DeviceType.tablet;

    final double padLeftRight = isMobile ? 18 : (isTablet ? 26 : 32);
    final double padTop = isMobile ? 14 : (isTablet ? 17 : 20);
    final double padBottom = isMobile ? 24 : (isTablet ? 27 : 30);
    final double titleSize = isMobile ? 26 : (isTablet ? 29 : 32);
    final double taglineSize = isMobile ? 15.5 : (isTablet ? 16.5 : 18);
    final double spaceAfterBackRow = isMobile ? 16 : (isTablet ? 18 : 20);
    final double spaceAfterTitleBlock = isMobile ? 16 : (isTablet ? 18 : 20);
    final double spaceAfterRule = isMobile ? 8 : (isTablet ? 9 : 10);
    final double spaceAfterTagline = isMobile ? 14 : (isTablet ? 16 : 18);
    final double dateTextSize = isMobile ? 11.5 : (isTablet ? 12 : 12.5);
    final double liveTextSize = isMobile ? 11 : (isTablet ? 11.5 : 12);
    final double spaceAfterDateRow = isMobile ? 10 : (isTablet ? 11 : 12);

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
        // PASS 7: straight, flat bottom edge — no rounded corners —
        // matching StaffScreen's topbar shape, plus the same thin
        // warm-gold hairline StaffScreen uses along that bottom edge.
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
                  padLeftRight,
                  padTop,
                  padLeftRight,
                  padBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: icon-only back control ─────────────────
                    Row(
                      children: [
                        _BackChip(onTap: onBack),
                      ],
                    ),

                    SizedBox(height: spaceAfterBackRow),

                    // ── Title block: label + big title, now full width
                    // since the top-right icon badge has been removed.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
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
                            size: titleSize,
                            weight: FontWeight.w900,
                            color: Colors.white,
                          ).copyWith(height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.15),

                    SizedBox(height: spaceAfterTitleBlock),

                    // ── Tagline ───────────────────────────────────────
                    // No card, no border/drop-shadow, no icon badge — just
                    // clean, confident cream typography sitting directly
                    // in the header, with a small gold accent rule above
                    // it to anchor the line. Purely decorative and purely
                    // presentational: no callback, no navigation, no data
                    // lives in this widget.
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
                        SizedBox(height: spaceAfterRule),
                        Text(
                          'Add items and finalize the order.',
                          style: AppTheme.serif(
                            size: taglineSize,
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

                    SizedBox(height: spaceAfterTagline),

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
                            size: dateTextSize,
                            weight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _Palette.freshGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: AppTheme.sans(
                            size: liveTextSize,
                            weight: FontWeight.w700,
                            color: _Palette.freshGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spaceAfterDateRow),

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

// ─── Live Stats Row (fully outside the header) ─────────────────────────────
// Mirrors the Dashboard's `_StatsRow`/`_StatCard` pattern: a thin layout
// wrapper around three floating white stat cards, placed as the first item
// in the scrollable content directly below the header. Same three values
// (selectedCount / total / availableTablesCount) already computed in
// `build()` — no data, provider, or navigation logic lives here.
class _StatsRow extends StatelessWidget {
  final int selectedCount;
  final double total;
  final int availableTablesCount;
  final bool isMobile;

  const _StatsRow({
    required this.selectedCount,
    required this.total,
    required this.availableTablesCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_basket_rounded,
            value: '$selectedCount',
            label: 'Items',
            iconBg: _Palette.paleRose,
            iconColor: _Palette.milanoRedDeep,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.payments_rounded,
            value: '₹${total.toStringAsFixed(0)}',
            label: 'Est. Total',
            isAlert: selectedCount > 0,
            iconBg: _Palette.gold,
            iconColor: _Palette.textDark,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: _StatCard(
            icon: Icons.table_bar_rounded,
            value: '$availableTablesCount',
            label: 'Tables Free',
            iconBg: _Palette.dustyBlush,
            iconColor: _Palette.milanoRedDeep,
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.25);
  }
}

// ─── Individual Stat Card ───────────────────────────────────────────────────
// Horizontal icon + value/label layout on a white (or, when `isAlert` is
// true, warm-gold) rounded card with a floating drop shadow — designed to
// read clearly whether it sits near the header or on the plain canvas
// beneath it. Matches the Dashboard's `_StatCard` treatment.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isAlert;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isAlert ? _Palette.gold.withValues(alpha: 0.22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAlert
              ? _Palette.goldDeep.withValues(alpha: 0.45)
              : _Palette.milanoRedDeep.withValues(alpha: 0.08),
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

// ─── Back chip — icon-only "‹" control ────────────────────────────────────
// A minimal "‹" glyph inside a rounded glass-gold chip, with a hover state
// (in addition to the existing press state) so it feels a touch more
// responsive on desktop/web. Same onTap/onBack callback, no navigation
// logic touched.
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
                    gradient: const LinearGradient(
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
                        child: const Icon(
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
                          gradient: const LinearGradient(
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
