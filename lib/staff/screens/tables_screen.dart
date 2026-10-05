import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/auth_provider.dart';
import '../contexts/tables_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// PUREDINE Maroon + Cream palette — matches the New Orders / Create Order
/// / Menu Management / Order Details screens exactly, so this screen now
/// reads as part of the same cohesive, professional brand instead of its
/// own one-off theme. Used ONLY for this screen's visual layer. Nothing
/// here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 3: the header (`_ScreenHeader`) was rebuilt to
/// match the New Orders screen's header language — a two-stop
/// maroon-to-wine gradient, a soft pair of ambient gold glows, an
/// icon-only back chip, a title block (small icon + subtitle label, then
/// the big title), a plain typographic tagline with a small gold accent
/// rule, a date/live row, and a thin gold gradient hairline underneath.
/// The tagline is a direct text formatting of the same
/// available/occupied/total counts already computed in `build()` — not a
/// new data source. The screen is full-bleed (`extendBodyBehindAppBar:
/// true`). The per-status counts remain visible exactly as before on the
/// filter chips in the sidebar — untouched.
///
/// UI-ENHANCEMENT PASS 4: `_ScreenHeader`'s bottom edge is now
/// a straight, flat line instead of the previous rounded 32px corners —
/// matching the flat-bottom topbar treatment used on Create Order's
/// header. The rounded `BorderRadius` on the header `Container`/`ClipRRect`
/// was removed (so the banner is now a plain rectangle) and a thin
/// warm-gold hairline border was added along the bottom edge, mirroring
/// Create Order's own bottom-edge accent. Everything else inside the
/// header — the gradient, the drop shadow, the ambient gold glows, the
/// title block, the tagline, and the date/live row — is
/// completely unchanged, as is every other part of this file (filters,
/// `_TableCard`, `_TableDisplayConfig`, and all provider/filtering logic
/// in `_TablesScreenState`). Presentation only.
///
/// UI-ENHANCEMENT PASS 5: removed the icon-only back chip
/// that previously sat in the top-left of the header. The `_BackChip`
/// widget class has been removed since it's no longer used anywhere in
/// this file. The `onBack` callback is still accepted by `_ScreenHeader`
/// and still wired up from `_TablesScreenState.build()` exactly as
/// before — no navigation logic was touched, only the visible icon was
/// removed. Everything else in the header and the rest of the file is
/// unchanged.
///
/// UI-ENHANCEMENT PASS 6 (this pass — full three-tier responsive
/// layout): responsive-layout-only — no provider, controller, route,
/// filtering, callback, or data value anywhere in this file was touched,
/// and no state field or keyword was renamed.
///   1. RESPONSIVE BREAKPOINTS: the screen now measures the available
///      width via a `_DeviceType` breakpoint (mobile < 700, tablet
///      700–1100, desktop ≥ 1100) instead of the previous single splits
///      (`isWide` at 768px in the body, `isMobile` at 800px in the
///      header, and a separate ad-hoc `>= 1024` check for the 3-column
///      grid). The sidebar-vs-stacked filter layout still switches at
///      the same tablet-and-up point (`isWide` is now simply "not
///      mobile"), but the grid's column count/tile height, the sidebar's
///      width/margin/padding, the outer scroll padding, and the header's
///      padding/type-scale all now scale through the same three tiers
///      instead of two mismatched breakpoints.
///   2. TABLET / DESKTOP POLISH: the sidebar filter panel is slightly
///      narrower with tighter margin/padding on tablet than on desktop
///      (mirroring the Orders screen's sidebar), so it sits comfortably
///      instead of crowding the grid at mid-size widths, and each table
///      tile gets a touch more height on tablet/mobile than on desktop
///      so its content never feels cramped. `_ScreenHeader` gained its
///      own tablet tier between the existing mobile and desktop sizing
///      for its padding, title/tagline type scale, and internal spacing,
///      matching the tuning already used on the Orders screen's header.
///      Every filter chip, table card, callback and piece of copy is
///      unchanged.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// order_details_screen.dart / new_orders_screen.dart / create_order_
/// screen.dart / menu_screen.dart (private classes can't be shared across
/// files without a new shared import, which would go beyond a pure UI-only
/// change here).
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

  // Gold accent family — Warm Gold (accent) / a deeper gold used for
  // borders and hover/emphasis states, plus the Soft Yellow highlight.
  static const Color gold = Color(0xFFF3C564);
  static const Color goldLight = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color lemonChiffon = Color(0xFFF3C564); // alias, same as gold
  static const Color lemonChiffonDeep = Color(0xFFD9A63E); // deeper gold

  // Extra brand tints from the PUREDINE palette.
  static const Color dustyBlush = Color(0xFFF3D9DC); // Blush/Pink tint
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background

  // Live / Success — Fresh Green, used for the header's "Live" indicator.
  static const Color success = Color(0xFF44AF70);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Order Details/Menu/Create Order/New Orders so
  /// every card on this screen carries the same warm, branded elevation.
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

  /// Header/hero drop shadow — matches the New Orders hero exactly.
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

  /// Elevated/hover glow used on interactive table tiles — a warmer,
  /// stronger shadow that pairs with the new palette's gold + burgundy.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.20),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

/// PASS 6: simple responsive breakpoint helper — layout-only, does not
/// touch any provider/filtering/navigation logic anywhere in this file.
/// Mirrors the same breakpoint values used on the Orders screen so both
/// screens switch layouts at exactly the same widths.
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

class TablesScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const TablesScreen({super.key, this.onGoHome});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final token = context.read<StaffAuthProvider>().token;
    if (token != null) {
      context.read<TablesProvider>().fetchTables(token);
    }
  }

  _TableDisplayConfig _getStatusConfig(TableModel table) {
    if (table.status == TableStatus.occupied) {
      return const _TableDisplayConfig(
        bg: Color(0xFFEFF6FF),
        textColor: Color(0xFF2563EB),
        label: 'Occupied',
        icon: Icons.people_rounded,
        gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        cardBorder: Color(0xFFBFDBFE),
      );
    } else {
      return const _TableDisplayConfig(
        bg: Color(0xFFF0FDF4),
        textColor: Color(0xFF16A34A),
        label: 'Available',
        icon: Icons.check_circle_rounded,
        gradient: [Color(0xFF34D399), Color(0xFF10B981)],
        cardBorder: Color(0xFFBBF7D0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablesProvider = context.watch<TablesProvider>();
    final allTables = tablesProvider.tables;

    final availableCount =
        allTables.where((t) => t.status == TableStatus.available).length;
    final occupiedCount =
        allTables.where((t) => t.status == TableStatus.occupied).length;

    final filters = [
      {
        'id': 'all',
        'label': 'All',
        'count': allTables.length,
        'icon': Icons.grid_view_rounded,
      },
      {
        'id': 'available',
        'label': 'Available',
        'count': availableCount,
        'icon': Icons.check_circle_rounded,
      },
      {
        'id': 'occupied',
        'label': 'Occupied',
        'count': occupiedCount,
        'icon': Icons.people_rounded,
      },
    ];

    List<TableModel> filteredTables;
    if (_activeFilter == 'all') {
      filteredTables = allTables;
    } else if (_activeFilter == 'available') {
      filteredTables =
          allTables.where((t) => t.status == TableStatus.available).toList();
    } else {
      filteredTables =
          allTables.where((t) => t.status == TableStatus.occupied).toList();
    }

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / New Orders screens.
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
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Extra low, wide glow further down the page — gives a
                  // long floor plan a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  Positioned(
                    top: 620,
                    left: -70,
                    child: Container(
                      width: 260,
                      height: 260,
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
              // ── Header — restyled to match the New Orders screen's
              // header design language exactly (two-stop maroon-to-wine
              // gradient, flat bottom edge with a gold hairline, title
              // block, plain-text tagline with a gold accent rule,
              // date/live row, gold hairline). No imagery/watermark.
              _ScreenHeader(
                title: 'Floor Plan',
                subtitle: 'Real-time Table Status',
                dateLabel: _todayLabel(),
                totalCount: allTables.length,
                availableCount: availableCount,
                occupiedCount: occupiedCount,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    widget.onGoHome?.call();
                  }
                },
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // PASS 6: three-tier breakpoint replaces the old
                    // mismatched `isWide` (768px) / `>= 1024` splits.
                    // `isWide` is kept as a convenience flag ("tablet or
                    // desktop") so the sidebar-vs-stacked switch below
                    // reads exactly as before.
                    final deviceType =
                        _deviceTypeForWidth(constraints.maxWidth);
                    final isWide = deviceType != _DeviceType.mobile;
                    final isTablet = deviceType == _DeviceType.tablet;
                    final isDesktop = deviceType == _DeviceType.desktop;

                    // PASS 6: each table tile gets a touch more height on
                    // tablet/mobile than on desktop, so its content never
                    // feels cramped at narrower card widths.
                    final double tileExtent =
                        isDesktop ? 122 : (isTablet ? 130 : 126);

                    // Filter buttons
                    Widget filterList = isWide
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: filters
                                .map((f) => _buildFilterButton(f, isWide: true))
                                .toList(),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: filters
                                  .map(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child:
                                          _buildFilterButton(f, isWide: false),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );

                    Widget content = tablesProvider.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: CircularProgressIndicator(
                                color: _Palette.milanoRed,
                              ),
                            ),
                          )
                        : filteredTables.isEmpty
                            ? const EmptyState(
                                icon: Icons.grid_view_rounded,
                                title: 'No tables found',
                                subtitle: 'Try a different filter',
                              ).animate().fade(duration: 400.ms).slideY(
                                  begin: 0.1,
                                  duration: 400.ms,
                                  curve: Curves.easeOutQuad,
                                )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  // PASS 6: mobile 1 / tablet 2 / desktop 3,
                                  // driven by the same three-tier
                                  // breakpoint used everywhere else in
                                  // this build (replaces the old ad-hoc
                                  // `>= 1024 ? 3 : 2` check).
                                  crossAxisCount:
                                      isDesktop ? 3 : (isTablet ? 2 : 1),
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  mainAxisExtent: tileExtent,
                                ),
                                itemCount: filteredTables.length,
                                itemBuilder: (context, index) {
                                  final table = filteredTables[index];
                                  final config = _getStatusConfig(table);
                                  return _TableCard(
                                          table: table, config: config)
                                      .animate(
                                        delay:
                                            Duration(milliseconds: index * 60),
                                      )
                                      .fade(duration: 350.ms)
                                      .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        duration: 350.ms,
                                        curve: Curves.easeOutQuad,
                                      );
                                },
                              );

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        // PASS 6: tier-specific outer padding instead of a
                        // single fixed value for every width.
                        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                        vertical: isDesktop ? 32 : (isTablet ? 26 : 20),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sidebar Filter Panel — PASS 6:
                                    // slightly narrower with tighter
                                    // margin/padding on tablet than on
                                    // desktop (mirroring the Orders
                                    // screen's sidebar), so it sits
                                    // comfortably instead of crowding the
                                    // grid at mid-size widths.
                                    Container(
                                      width: isTablet ? 220 : 256,
                                      margin: EdgeInsets.only(
                                        right: isTablet ? 24 : 32,
                                      ),
                                      padding: EdgeInsets.all(
                                        isTablet ? 18 : 22,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            _Palette.canvasDeep
                                                .withValues(alpha: 0.4),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(26),
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
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      _Palette.gold,
                                                      _Palette.goldLight,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'VIEW OPTIONS',
                                                style: AppTheme.sans(
                                                  size: 10,
                                                  weight: FontWeight.w800,
                                                  color: _Palette.textMuted,
                                                ).copyWith(letterSpacing: 1.5),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          filterList,
                                        ],
                                      ),
                                    ).animate().fade(duration: 400.ms).slideX(
                                          begin: -0.08,
                                          duration: 400.ms,
                                          curve: Curves.easeOutQuad,
                                        ),
                                    // Grid
                                    Expanded(child: content),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    filterList,
                                    const SizedBox(height: 20),
                                    content,
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

  Widget _buildFilterButton(Map<String, dynamic> f, {required bool isWide}) {
    final isActive = _activeFilter == f['id'];
    final count = f['count'] as int;
    final icon = f['icon'] as IconData;

    return Padding(
      padding: isWide ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = f['id'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      _Palette.milanoRedLight,
                      _Palette.milanoRedDeep,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive
                  ? _Palette.gold.withValues(alpha: 0.55)
                  : _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : _Palette.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.22)
                          : _Palette.milanoRedDeep.withValues(alpha: 0.06),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: isActive ? Colors.white : _Palette.milanoRedDeep,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    f['label'] as String,
                    style: AppTheme.sans(
                      size: 13,
                      weight: FontWeight.w700,
                      color: isActive ? Colors.white : _Palette.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : _Palette.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w800,
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

// ─── Screen header — restyled to mirror the Create Order screen's header:
// a two-stop maroon-to-wine gradient, two soft ambient gold glows, a
// title block (small icon + subtitle label, then the big title), a
// plain-text tagline anchored by a small gold accent rule (no icon badge,
// no card, no border/shadow), and a date/live row with a thin gold
// gradient hairline underneath. The bottom edge is a straight, flat line
// (no rounded corners) with a thin warm-gold hairline border along that
// edge, matching Create Order's flat-bottom topbar treatment. No
// watermark emblem, no dotted texture, no photo/avatar imagery. The
// tagline is data-driven off the available/occupied/total counts (already
// computed by the caller) purely as a text format — no new logic. The
// back icon that previously sat above the title block has been removed;
// `onBack` is still accepted and passed through from the caller (no
// navigation logic touched), it is simply no longer rendered.
//
// PASS 6: the single `isMobile` split at 800px was stepped up into three
// tiers (mobile/tablet/desktop) using the same `_deviceTypeForWidth`
// breakpoint the rest of the screen now uses, so the header's padding,
// title/tagline type scale, and internal spacing read with a bit more
// breathing room on tablets instead of jumping straight from the compact
// phone sizing to the full desktop sizing — matching the tuning already
// used on the Orders screen's header. Structure, text, callbacks and data
// are unchanged.
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final int totalCount;
  final int availableCount;
  final int occupiedCount;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.totalCount,
    required this.availableCount,
    required this.occupiedCount,
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
        // New Orders / Create Order hero exactly.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRed,
            _Palette.milanoRedLight,
          ],
        ),
        // Straight, flat bottom edge — no rounded corners — matching
        // Create Order's topbar shape, plus the same thin warm-gold
        // hairline Create Order uses along that bottom edge.
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
            // content — purely decorative, mirroring the New Orders hero.
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
                    // ── Title block: small icon + subtitle label, then
                    // the big title — matches the New Orders header's
                    // title block exactly. (Back chip removed — no top
                    // row above this anymore.)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                    // it to anchor the line — matches the New Orders
                    // header's tagline treatment exactly. The copy itself
                    // reflects the live available/occupied/total counts
                    // already computed by the caller (a text format of
                    // existing data, not new logic).
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
                          totalCount > 0
                              ? '$availableCount available • $occupiedCount occupied of $totalCount total.'
                              : 'No tables added yet.',
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
                            color: _Palette.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: AppTheme.sans(
                            size: liveTextSize,
                            weight: FontWeight.w700,
                            color: _Palette.success,
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

// ─── Table Card ─────────────────────────────────────────────────────────
// Sits on the warm PUREDINE cream background and picks up the same
// rounded-corner, soft-shadow, gold-touch language as the rest of the app,
// with a generous, professional footprint, while keeping each table's own
// status color (blue = occupied, green = available) fully intact. Carries
// a subtle hover/press lift (scale + stronger glow + warmer border), so
// each tile in the floor plan reads as an interactive surface rather than
// a static row — no logic changed, same table data, same config, same
// layout structure.
class _TableCard extends StatefulWidget {
  final TableModel table;
  final _TableDisplayConfig config;

  const _TableCard({required this.table, required this.config});

  @override
  State<_TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<_TableCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final table = widget.table;
    final bool isElevated = _isHovered || _isPressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : (_isHovered ? 1.01 : 1.0),
          duration: 150.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: 200.ms,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isElevated
                    ? config.textColor.withValues(alpha: 0.45)
                    : config.cardBorder,
                width: isElevated ? 1.5 : 1.2,
              ),
              boxShadow: isElevated ? _Palette.glowShadow : _Palette.softShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Left gradient strip
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: config.gradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: config.bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _Palette.gold.withValues(alpha: 0.28),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: config.textColor.withValues(
                                  alpha: isElevated ? 0.22 : 0.14,
                                ),
                                blurRadius: isElevated ? 14 : 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            config.icon,
                            size: 26,
                            color: config.textColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                table.name,
                                style: AppTheme.serif(
                                  size: 17,
                                  weight: FontWeight.w800,
                                  color: _Palette.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                config.label,
                                style: AppTheme.sans(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: config.textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status pill on right
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: config.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: config.textColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: config.textColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                config.label,
                                style: AppTheme.sans(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: config.textColor,
                                ),
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
          ),
        ),
      ),
    );
  }
}

// ─── Table Display Config ──────────────────────────────────────────────────
class _TableDisplayConfig {
  final Color bg;
  final Color textColor;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color cardBorder;

  const _TableDisplayConfig({
    required this.bg,
    required this.textColor,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.cardBorder,
  });
}
