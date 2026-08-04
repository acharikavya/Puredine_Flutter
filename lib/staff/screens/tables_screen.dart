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
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / Dashboard / Menu Management screens exactly (#8B1D1D
/// primary / #F4C430 gold accent), so this screen now reads as part of the
/// same cohesive, professional brand instead of its own one-off theme. Used
/// ONLY for this screen's visual layer. Nothing here touches AppColors,
/// AppTheme, or any other file — pure UI enhancement, no logic changed
/// anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (four-stop gradient, large faint
/// watermark emblem, glass highlight line, and a live "Available /
/// Occupied / Total" readout strip built from the exact same counts the
/// filter chips already use), the full-screen backdrop gained an extra
/// diagonal sheen + a second ambient glow for more depth, the sidebar
/// filter panel and its chips were restyled with per-filter icons and a
/// richer active state, and each table tile now has a subtle hover/press
/// lift so the floor plan feels like a considered, premium surface rather
/// than a plain list of rows. No provider, controller, route, filtering,
/// or data value was touched anywhere in this pass — only Container/
/// Decoration/TextStyle-level presentation changed.
///
/// NOTE: this is a private class redeclared identically to the one in the
/// other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
/// change here).
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

  /// Elevated/hover glow — a slightly stronger, warmer shadow used for
  /// interactive/elevated elements, matching the Dashboard's feature cards.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: lemonChiffonDeep.withValues(alpha: 0.26),
          blurRadius: 24,
          offset: const Offset(0, 9),
        ),
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.16),
          blurRadius: 14,
          offset: const Offset(0, 5),
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

  /// Soft inner "glass" shadow used on the header's stats readout strip —
  /// pure decoration, gives the capsule a faint pressed-glass depth.
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
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/ruby glows layered over the
          // existing canvas wash, matching the Menu Management / Dashboard
          // screens' "foggy" backdrop so every staff/admin screen feels
          // like one cohesive brand. No logic touched — visuals only.
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
                    top: 320,
                    right: -120,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.09),
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
                    top: 640,
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
          // extra layer of depth so the cream backdrop doesn't read as flat
          // behind the header, echoing the glass-highlight language used
          // in the header itself.
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
              // richer "command bar" with a live stats readout. ─────────
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
                    final isWide = constraints.maxWidth >= 768;

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
                                  crossAxisCount: isWide
                                      ? (constraints.maxWidth >= 1024 ? 3 : 2)
                                      : 1,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  mainAxisExtent: 122,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Sidebar Filter Panel
                                    Container(
                                      width: 240,
                                      margin: const EdgeInsets.only(right: 24),
                                      padding: const EdgeInsets.all(20),
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
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      _Palette.milanoRedLight,
                                                      _Palette.milanoRed,
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
                ? LinearGradient(
                    colors: [_Palette.gold, _Palette.goldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive
                  ? _Palette.lemonChiffonDeep.withValues(alpha: 0.7)
                  : _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _Palette.gold.withValues(alpha: 0.35),
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
                          ? Colors.white.withValues(alpha: 0.28)
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
                      ? Colors.white.withValues(alpha: 0.25)
                      : _Palette.milanoRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: AppTheme.sans(
                    size: 11,
                    weight: FontWeight.w800,
                    color: isActive ? Colors.white : _Palette.milanoRedDeep,
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

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the accent used under section titles on the
/// Menu Management / Dashboard / Order Details screens for a consistent
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

// ─── Screen header — restyled into its own distinctive "command bar"
// identity: a richer four-stop diagonal gradient, a large faint watermark
// emblem behind the title, a fine glass highlight line along the top edge,
// layered ribbon glows, a dotted texture accent, and (new) a live
// "Available / Occupied / Total" readout strip built from the exact same
// counts already computed for the filter chips — no new data source, no
// logic, purely a display of values already available at the call site.
// The back control remains the same compact, icon-only "‹" chip used on
// the Order Details screen's header, wired to the identical onBack
// callback as before. ────────────────────────────────────────────────────
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
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the
          // Dashboard hero's "faceted" surface language.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              Color(0xFF320A0A),
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
                      _Palette.gold.withValues(alpha: 0.16),
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
                      _Palette.gold.withValues(alpha: 0.08),
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
                    Icons.table_restaurant_rounded,
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
            // matches the Dashboard hero's top edge treatment.
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
                            Icons.grid_view_rounded,
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
                                  size: isMobile ? 22 : 27,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 10,
                                color: _Palette.lemonChiffon.withValues(
                                  alpha: 0.8,
                                ),
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

                    const SizedBox(height: 18),

                    // ── Live stats readout strip — Available / Occupied /
                    // Total, built straight from the same counts already
                    // powering the filter chips below. Purely a display
                    // addition; no new data source and no logic change.
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
                              icon: Icons.check_circle_rounded,
                              value: '$availableCount',
                              label: 'Available',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.people_rounded,
                              value: '$occupiedCount',
                              label: 'Occupied',
                              accent: const Color(0xFF60A5FA),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.grid_view_rounded,
                              value: '$totalCount',
                              label: 'Total',
                              accent: _Palette.lemonChiffon,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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

/// Compact icon-only "back" control — a circular glass button showing only
/// a plain "‹" glyph. Replaces the previous arrow-icon + "Back" label combo
/// with the same minimal, professional control used on the Order Details
/// screen's header, for a consistent brand-wide top bar. Tapping it calls
/// the exact same `onBack` callback as before — only the visual shell
/// changed.
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

// ─── Table Card ─────────────────────────────────────────────────────────
// Restyled to sit on the warm canvas background and pick up the same
// rounded-corner, soft-shadow, gold-touch language as the rest of the app,
// with a more generous, professional footprint (bigger icon chip, more
// breathing room), while keeping each table's own status color (blue =
// occupied, green = available) fully intact. UI-ENHANCEMENT PASS 2: now a
// stateful widget with a subtle hover/press lift (scale + stronger glow +
// warmer border), so each tile in the floor plan reads as an interactive
// surface rather than a static row — no logic changed, same table data,
// same config, same layout structure.
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
