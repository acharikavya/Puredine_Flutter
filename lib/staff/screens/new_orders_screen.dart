import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../contexts/orders_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../../core/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../contexts/auth_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Menu Management / Create Order / Dashboard / Orders / Order Details
/// screens exactly (#8B1D1D primary / #F4C430 gold accent), so this screen
/// now reads as part of the same cohesive, professional brand instead of
/// its own one-off theme. Used ONLY for this screen's visual layer.
/// Nothing here touches AppColors, AppTheme, or any other file — pure UI
/// enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header up to the same
/// distinctive "command bar" identity used on the Orders / Order Details
/// screens — a four-stop diagonal gradient, a large faint watermark
/// emblem, a glass highlight line along the top edge, and a new live
/// quick-stats readout strip (New Orders / Accepted / Sort order) built
/// entirely from values already computed in build(). The full-screen
/// backdrop gained an extra ambient glow + a diagonal sheen for more
/// depth, and both the stat boxes and each order card picked up a slim
/// color-coded accent rail down the left edge, matching the Orders
/// screen's card treatment. No provider, controller, route, sort, or
/// status-transition logic was touched anywhere in this pass — only
/// presentation changed.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// create_order_screen.dart / menu_screen.dart / dashboard_screen.dart /
/// orders_screen.dart / order_details_screen.dart (private classes can't
/// be shared across files without a new shared import, which would go
/// beyond a pure UI-only change here).
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
  static const Color success = Color(0xFF2E9E5B);
  static const Color successDeep = Color(0xFF1B6B3D);
  static const Color successBg = Color(0xFFEAF7EF);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Menu/Create Order/Dashboard/Orders/Order Details
  /// so every card on this page carries the same warm, branded elevation.
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
  /// language used on the Create Order / Dashboard / Orders / Order
  /// Details headers (deep maroon drop shadow + soft ambient gold bloom
  /// + fine black contact shadow).
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
  /// depth. Matches the Orders / Order Details screens' statCapsuleShadow
  /// exactly.
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

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  bool _showNewestFirst = true;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final newOrders = List<Order>.from(provider.newOrders);

    // Sort by createdAt
    newOrders.sort(
      (a, b) => _showNewestFirst
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );

    final acceptedCount = provider.activeOrders.length;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Create Order / Dashboard / Orders /
      // Order Details screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows layered over the
          // existing canvas wash, matching the Menu Management / Orders /
          // Order Details screens' "foggy" backdrop so the whole
          // admin/staff experience feels like one cohesive brand. No
          // logic touched — visuals only.
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
                  // Extra low, wide glow further down the page — gives a
                  // long order list a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  // Matches the Orders / Order Details screens' Pass-2
                  // backdrop treatment.
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
          // used in the header itself. Matches the Orders / Order
          // Details screens exactly.
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
              // ── Header — same Dark Maroon gradient + thin gold accents
              // used throughout the Create Order / Menu Management /
              // Dashboard / Orders / Order Details screens, now restyled
              // into a richer "command bar" with a live quick-stats
              // readout. ───────────────────────────────────────────────
              _ScreenHeader(
                title: 'New Orders',
                subtitle: 'Incoming Kitchen Orders',
                dateLabel: _todayLabel(),
                newOrdersCount: newOrders.length,
                acceptedCount: acceptedCount,
                onBack: () => context.pop(),
                onRefresh: () {
                  final token = context.read<StaffAuthProvider>().token;
                  if (token != null) {
                    context.read<OrdersProvider>().fetchOrders(token);
                  }
                },
                showNewestFirst: _showNewestFirst,
                onToggleSort: () =>
                    setState(() => _showNewestFirst = !_showNewestFirst),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats sidebar on large screens (shown inline on small)
                    _buildContent(context, newOrders, acceptedCount, provider),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Order> newOrders,
    int acceptedCount,
    OrdersProvider provider,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          children: [
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icon: Icons.notifications_outlined,
                    iconColor: _Palette.milanoRedDeep,
                    iconBg: _Palette.milanoRed.withValues(alpha: 0.10),
                    accentColor: _Palette.milanoRed,
                    label: 'New Orders',
                    value: '${newOrders.length}',
                  ).animate().fade().scale(
                        curve: Curves.easeOutBack,
                        duration: 400.ms,
                      ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatBox(
                    icon: Icons.check_circle_outline,
                    iconColor: _Palette.lemonChiffonDeep,
                    iconBg: _Palette.lemonChiffonDeep.withValues(alpha: 0.14),
                    accentColor: _Palette.gold,
                    label: 'Accepted',
                    value: '$acceptedCount',
                  ).animate().fade().scale(
                        curve: Curves.easeOutBack,
                        duration: 400.ms,
                        delay: 100.ms,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            if (newOrders.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle: 'New customer orders will appear here',
              ).animate().fade(duration: 400.ms).slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    curve: Curves.easeOutQuad,
                  )
            else
              ...newOrders.asMap().entries.map(
                    (entry) =>
                        _OrderCard(order: entry.value, provider: provider)
                            .animate()
                            .fade(duration: 400.ms, delay: (entry.key * 100).ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutQuad,
                            ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the accent used under section titles on the
/// Menu Management / Create Order / Dashboard / Orders / Order Details
/// screens for a consistent brand language.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider({this.width = 48});

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
// identity, matching the Orders / Order Details screens' Pass-2
// treatment exactly: a richer four-stop diagonal gradient, a large faint
// watermark emblem behind the title, a fine glass highlight line along
// the top edge, layered ribbon glows, a dotted texture accent, a
// floating date pill, and the same thin-gold-border language used on
// the order-number chip below. UI-ENHANCEMENT PASS 2 adds a live
// quick-stats readout strip (New Orders / Accepted / Sort order) built
// from values already computed in build() — no new data source, purely
// a display of values already available at the call site. The back
// control remains the same compact, icon-only "‹" chip, and the
// refresh/sort controls are identical to before — this is a purely
// presentational change. ─────────────────────────────────────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final int newOrdersCount;
  final int acceptedCount;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final bool showNewestFirst;
  final VoidCallback onToggleSort;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.newOrdersCount,
    required this.acceptedCount,
    required this.onBack,
    required this.onRefresh,
    required this.showNewestFirst,
    required this.onToggleSort,
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
          // Orders / Order Details screens' "faceted" surface language.
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
            // Dashboard / Orders hero treatment.
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

            // ── Large faint watermark emblem — a unique signature touch,
            // sits low-opacity and large behind the copy, never competing
            // with the title or the stats strip. Matches the Orders /
            // Order Details screens' Pass-2 header exactly.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -22 : -16,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.receipt_long_rounded,
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
            // matches the Dashboard / Orders / Order Details hero's top
            // edge treatment.
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
                        // Menu Management / Orders / Order Details
                        // screens' header control. ────────────────────
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
                        // gold glow, matching the Create Order / Menu
                        // Management header icon. ─────────────────────
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
                                  color: _Palette.lemonChiffon,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _HeaderIconButton(
                          icon: Icons.refresh_rounded,
                          onTap: onRefresh,
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

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _HeaderSortChip(
                        icon: showNewestFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        label:
                            showNewestFirst ? 'Newest First' : 'Oldest First',
                        onTap: onToggleSort,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Live quick-stats readout strip — New Orders /
                    // Accepted / Sort order, built straight from values
                    // already computed in build(). Purely a display
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
                              icon: Icons.notifications_active_rounded,
                              value: '$newOrdersCount',
                              label: 'New',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.check_circle_outline_rounded,
                              value: '$acceptedCount',
                              label: 'Accepted',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: showNewestFirst
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              value: showNewestFirst ? 'Newest' : 'Oldest',
                              label: 'Sort',
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
/// strip — purely decorative spacing element, no logic. Matches the
/// Orders / Order Details screens' Pass-2 header strip exactly.
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
/// only a plain "‹" glyph. Replaces the previous arrow-icon + "Back"
/// label combo with the same minimal, professional control used on the
/// Menu Management / Orders / Order Details screens' header, for a
/// consistent brand-wide top bar.
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

// ─── Small round glass icon button for the header, with a thin gold
// ring — same visual family as the header's brand icon chip. ───────────
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _Palette.gold.withValues(alpha: 0.55),
              width: 1.1,
            ),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Pill-shaped sort toggle — same gold-outlined glass chip language
// as the order-number badge on each order card. ─────────────────────────
class _HeaderSortChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderSortChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HeaderSortChip> createState() => _HeaderSortChipState();
}

class _HeaderSortChipState extends State<_HeaderSortChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _Palette.gold.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: _Palette.lemonChiffon, size: 15),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTheme.sans(
                  size: 12,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat box — UI-ENHANCEMENT PASS 2 adds a slim color-coded accent
// rail down the left edge (matching the Orders / Order Details screens'
// card treatment), giving each stat box an instant color cue tying it
// to its meaning. Same content, same values — purely presentational.
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
    required this.label,
    required this.value,
    this.accentColor = _Palette.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
                    accentColor.withValues(alpha: 0.85),
                    accentColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _Palette.gold.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: AppTheme.sans(
                    size: 11,
                    color: _Palette.textMuted,
                    weight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.serif(
                    size: 34,
                    weight: FontWeight.w900,
                    color: _Palette.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ─────────────────────────────────────────────────────────
// Restyled to Theme 1 with more generous, evenly-balanced spacing and a
// slightly larger footprint so it reads as a proper, professional card
// rather than a tightly-packed list row. UI-ENHANCEMENT PASS 2 adds a
// slim status-colored accent rail down the left edge (matching the
// Orders / Order Details screens' card treatment) — maroon while the
// order is still new/unaccepted, brand gold once it's been accepted.
// Same data, same callbacks — only sizing, radii, and color values
// changed.
class _OrderCard extends StatelessWidget {
  final Order order;
  final OrdersProvider provider;

  const _OrderCard({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.placed;
    final railColor = isNew ? _Palette.milanoRed : _Palette.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isNew
              ? _Palette.milanoRed.withValues(alpha: 0.30)
              : _Palette.milanoRedDeep.withValues(alpha: 0.08),
          width: isNew ? 1.3 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _Palette.lemonChiffon.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ]
            : _Palette.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Slim status-colored accent rail down the left edge — an
          // instant color cue for the card's state, purely decorative.
          // Matches the Orders / Order Details screens' accent rail.
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
            children: [
              // Status Header
              Container(
                decoration: BoxDecoration(
                  gradient: isNew
                      ? LinearGradient(
                          colors: [
                            _Palette.milanoRedLight,
                            _Palette.milanoRedDeep,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isNew ? null : _Palette.successBg,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    if (isNew) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEW ORDER',
                              style: AppTheme.sans(
                                size: 16,
                                weight: FontWeight.w900,
                                color: Colors.white,
                              ).copyWith(letterSpacing: 0.4),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  order.time,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                LiveTimeAgo(
                                  dt: order.createdAt,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: Colors.white.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _Palette.gold.withValues(alpha: 0.65),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.orderNumber,
                          style: AppTheme.sans(
                            size: 12,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: _Palette.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACCEPTED',
                              style: AppTheme.sans(
                                size: 15,
                                weight: FontWeight.w900,
                                color: _Palette.successDeep,
                              ).copyWith(letterSpacing: 0.3),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  order.time,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Text(
                                  order.orderNumber,
                                  style: AppTheme.sans(
                                    size: 12,
                                    color: _Palette.successDeep.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: _Palette.canvas,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: _Palette.milanoRedDeep,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.table,
                                style: AppTheme.serif(
                                  size: 20,
                                  weight: FontWeight.w900,
                                  color: _Palette.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${order.items} items',
                                style: AppTheme.sans(
                                  size: 13,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyUtils.format(order.total),
                          style: AppTheme.serif(
                            size: 25,
                            weight: FontWeight.w900,
                            color: _Palette.milanoRedDeep,
                          ),
                        ),
                      ],
                    ),
                    if (order.customerName != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: _Palette.canvas,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: _Palette.milanoRedDeep,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CUSTOMER',
                                  style: AppTheme.sans(
                                    size: 10,
                                    color: _Palette.textMuted,
                                    weight: FontWeight.w700,
                                  ).copyWith(letterSpacing: 0.4),
                                ),
                                Text(
                                  order.customerName!,
                                  style: AppTheme.sans(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: _Palette.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _Palette.canvas,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER ITEMS',
                            style: AppTheme.sans(
                              size: 10,
                              weight: FontWeight.w700,
                              color: _Palette.textMuted,
                            ).copyWith(letterSpacing: 0.4),
                          ),
                          const SizedBox(height: 10),
                          ...order.itemsPreview.take(3).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: _Palette.milanoRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: AppTheme.sans(
                                            size: 13,
                                            color: _Palette.textDark
                                                .withValues(alpha: 0.85),
                                            weight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          if (order.itemsPreview.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 2,
                              ),
                              child: Text(
                                '+${order.itemsPreview.length - 3} more items',
                                style: AppTheme.sans(
                                  size: 12,
                                  color: _Palette.textMuted,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons
                    if (isNew)
                      GestureDetector(
                        onTap: () {
                          final token = context.read<StaffAuthProvider>().token;
                          provider.updateOrderStatus(
                            order.id,
                            OrderStatus.confirmed,
                            token!,
                          );
                          context.push('/staff/order-details/${order.id}');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_Palette.gold, _Palette.goldLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _Palette.lemonChiffonDeep.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.gold.withValues(alpha: 0.38),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ACCEPT ORDER',
                                style: AppTheme.sans(
                                  size: 15,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(letterSpacing: 0.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () =>
                            context.push('/staff/order-details/${order.id}'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _Palette.canvas,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Details',
                                style: AppTheme.sans(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: _Palette.textDark.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: _Palette.milanoRedDeep,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
