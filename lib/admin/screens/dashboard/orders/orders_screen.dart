import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/core/providers/restaurant_provider.dart';
import 'package:restaurant_unified_app/admin/services/orders_service.dart';

/// -----------------------------------------------------------------------
/// Screen-local theme palette: "Dark Maroon x Soft Cream x Gold Glow"
/// Kept local to this file so it layers on top of the app's existing
/// AppColors without requiring changes anywhere else. Only visual tokens
/// live here — no business logic is affected.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a large faint watermark emblem, and a fine glass highlight
/// line along the top edge) matching the Admin Dashboard / staff-side
/// screens' Pass-2 treatment, and the full-screen backdrop gained an
/// extra diagonal sheen for more depth. The stat cards picked up a slim
/// color-coded top cap so each figure has its own subtle identity at a
/// glance. No provider, filtering, sorting, status-update, or PDF/print
/// logic was touched anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 4 (desktop header title alignment): the desktop
/// header's title block used to be centered as its own standalone
/// element inside the header. It has been changed to a left-aligned
/// column — Title, then the gold divider, then the subtitle — matching
/// the Menu screen's desktop header layout exactly. Purely a layout/
/// alignment change; the same title text, subtitle text, divider
/// styling, and font choices are all unchanged.
/// -----------------------------------------------------------------------
class _OrdersTheme {
  // Primary brand — Dark Maroon (#8B1D1D) per Theme 1. Field names kept
  // identical to the previous palette so every widget below (which
  // references _OrdersTheme.milanoRed, .gold, etc.) is re-themed
  // automatically without touching any layout or logic.
  static const Color milanoRed = Color(0xFF8B1D1D); // Primary maroon
  static const Color milanoRedDark = Color(0xFF5E1212); // Deeper maroon
  static const Color milanoRedLight = Color(0xFFA5271F); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF3A0B0B); // Fourth gradient stop

  // Gold Glow accents (Theme 1: #F4C430) replacing the old lemon-chiffon
  // tones, plus soft cream companions for badges/backgrounds.
  static const Color lemonChiffon = Color(0xFFF4C430);
  static const Color lemonChiffonSoft = Color(0xFFFDF3E7);
  static const Color gold = Color(0xFFF4C430);
  static const Color goldSoft = Color(0xFFF9DE8B);

  // Soft Cream canvas + card white, matching Theme 1's "Light" swatch.
  static const Color canvas = Color(0xFFFDF3E7);
  static const Color canvasDeep = Color(0xFFF3E4CC);
  static const Color cardWhite = Colors.white;

  // Convenience gradients used for headers / primary buttons.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRedDark],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [milanoRedDark, milanoRed],
  );

  /// Themed soft shadow for resting cards/panels — mirrors the Menu
  /// screen's softShadow so every surface shares the same warm tint.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDark.withValues(alpha: 0.06),
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

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  String _statusFilter = 'All Status';
  String _paymentFilter = 'All Payments';
  String _typeFilter = 'All Types';
  String _searchQuery = '';
  String _sortOrder = 'Newest First';
  final Set<String> _updatingOrderIds = {};
  String? _highlightedOrderId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _checkHighlight();
  }

  void _checkHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final highlightId = state.uri.queryParameters['highlightOrderId'];
      if (highlightId != null) {
        setState(() {
          _highlightedOrderId = highlightId;
        });

        // Wait for list to load then scroll
        _scrollToHighlighted(highlightId);
      }
    });
  }

  void _scrollToHighlighted(String id) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final filtered = _filtered;
      final index = filtered.indexWhere((o) => o.id == id);
      if (index != -1) {
        // Approximate heights of the scrollable body only — the header is
        // now fixed outside the scroll view (matches the Menu screen
        // pattern), so its height is no longer part of this offset.
        // Stats ~120, Filters ~180, Spacings ~100, Rows 80 each.
        final offset = 120.0 + 180.0 + 100.0 + (index * 80.0);
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _loadOrders({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Fetch orders and conditionally fetch restaurant profile if missing
      final provider = context.read<RestaurantProvider>();
      final futures = <Future<dynamic>>[
        OrdersService.getOrders().then((list) {
          if (mounted) setState(() => _orders = list);
        }),
      ];

      if (provider.restaurant == null) {
        futures.add(provider.fetchRestaurant());
      }

      await Future.wait(futures);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  List<OrderModel> get _filtered {
    final filtered = _orders.where((o) {
      final matchSearch = _searchQuery.isEmpty ||
          o.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'All Status' ||
          o.status.toUpperCase() == _statusFilter.toUpperCase();
      final matchPayment = _paymentFilter == 'All Payments' ||
          o.paymentStatus.toUpperCase() == _paymentFilter.toUpperCase();
      final matchType = _typeFilter == 'All Types' ||
          o.orderType.toUpperCase().replaceAll('-', '_') ==
              _typeFilter.toUpperCase().replaceAll(' ', '_');

      return matchSearch && matchStatus && matchPayment && matchType;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt) ?? DateTime.now();
      final dateB = DateTime.tryParse(b.createdAt) ?? DateTime.now();
      if (_sortOrder == 'Newest First') {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  double get _totalRevenue => _orders
      .where((o) => o.paymentStatus.toUpperCase() == 'PAID')
      .fold(0, (sum, o) => sum + o.totalAmount);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: _OrdersTheme.canvas,
      // UI-ENHANCEMENT PASS 3 (admin navigation): mobile gets a fixed
      // cream bottom bar ("Menu / Staff / Tables / Order Bill");
      // desktop gets a fixed left-hand side rail instead, matching the
      // reference admin sidebar design (see `_AdminSideNav` below).
      // "Order Bill" is this screen's own destination, so its tile is
      // shown active (index 3) on both. Neither touches any provider,
      // filter, sort, status-update, or PDF/print logic above.
      bottomNavigationBar:
          isMobile ? const _AdminBottomNav(currentIndex: 3) : null,
      body: isMobile
          ? _buildScreenBody(isMobile)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AdminSideNav(currentIndex: 3),
                Expanded(child: _buildScreenBody(isMobile)),
              ],
            ),
    );
  }

  /// The header + scrollable content column that makes up the screen's
  /// main body — unchanged from before this pass, just pulled out into
  /// its own method so it can be reused both stand-alone (mobile, no
  /// side rail) and inside the desktop `Row` alongside `_AdminSideNav`.
  /// No layout, data, or navigation logic inside this block was touched.
  Widget _buildScreenBody(bool isMobile) {
    final filtered = _filtered;
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
          // ── Header Section ───────────────────────────────────────────────
          // Fixed at the top, exactly like MenuScreen's custom header — it
          // no longer scrolls away with the content beneath it.
          _buildHeader(isMobile),

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────────
                // Purely decorative — soft lemon/ruby glows plus a faint
                // textured photograph, matching the Menu and Dashboard
                // screens so the whole admin experience reads as one
                // cohesive brand.
                Positioned.fill(
                  child: Container(
                    color: _OrdersTheme.canvas,
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
                                  _OrdersTheme.lemonChiffon
                                      .withValues(alpha: 0.5),
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
                                  _OrdersTheme.milanoRed
                                      .withValues(alpha: 0.07),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Extra low, wide glow further down the page —
                        // gives the long orders list a second soft focal
                        // point instead of all the ambient light sitting
                        // only near the header. Matches the Admin
                        // Dashboard / staff-side screens' Pass-2 backdrop.
                        Positioned(
                          top: 640,
                          right: -110,
                          child: Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _OrdersTheme.milanoRedLight.withValues(
                                    alpha: 0.06,
                                  ),
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

                // Faint diagonal sheen sweeping across the body — a subtle
                // extra layer of depth so the cream backdrop doesn't read
                // as flat behind the header, echoing the glass-highlight
                // language used in the header itself.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content — same fixed-header / scrollable-body pattern as
                // MenuScreen: a SingleChildScrollView, instead of the header
                // scrolling away inside a CustomScrollView/sliver list.
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _OrdersTheme.milanoRed,
                        ),
                      )
                    : _error != null
                        ? _buildErrorState()
                        : SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isMobile ? 16 : (size.width > 1400 ? 64 : 40),
                              vertical: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsGrid(isMobile),
                                const SizedBox(height: 32),
                                _buildFilterSection(isMobile),
                                const SizedBox(height: 24),
                                Text(
                                  'Showing ${filtered.length > 50 ? 50 : filtered.length} of ${filtered.length} orders',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildOrdersList(
                                    filtered.take(50).toList(), isMobile),
                              ],
                            ),
                          ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          isMobile ? 20 : 40,
          isMobile ? 32 : 48,
          isMobile ? 20 : 40,
          32,
        ),
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the Admin
          // Dashboard / staff-side screens' Pass-2 "faceted" surface
          // language.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _OrdersTheme.milanoRedLight,
              _OrdersTheme.milanoRed,
              _OrdersTheme.milanoRedDark,
              _OrdersTheme.milanoRedDarkest,
            ],
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
          // Softly rounded bottom corners give the header a modern,
          // "floating navbar" feel that matches the Menu and Dashboard
          // screens, instead of a flat hard-edged band.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: Border(
            bottom: BorderSide(color: _OrdersTheme.gold, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _OrdersTheme.milanoRedDark.withValues(alpha: 0.35),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _OrdersTheme.gold.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Subtle decorative diagonal ribbon accents (purely cosmetic,
              // matches the Menu/Dashboard headers for a consistent brand)
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
                          _OrdersTheme.gold.withValues(alpha: 0.14),
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

              // ── Large faint watermark emblem — a unique signature
              // touch this header didn't previously have, sitting
              // low-opacity and large behind the copy, never competing
              // with the title or controls. Matches the Admin Dashboard
              // hero's Pass-2 watermark treatment.
              Positioned(
                right: isMobile ? -20 : -10,
                bottom: isMobile ? -18 : -14,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: isMobile ? 120 : 170,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Fine dotted texture accent, matching the app's refined
              // decorative language used on the Menu/Dashboard headers.
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
                          color: _OrdersTheme.gold.withValues(
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
              // matches the Admin Dashboard / staff-side headers' top
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

              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UI-ENHANCEMENT PASS 3: the top-left back-
                        // chevron control has been removed from this
                        // header per request; navigation between admin
                        // screens now happens via the bottom nav / side
                        // rail instead. The title block below is
                        // unchanged.
                        Text(
                          'Orders',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track customer orders',
                          style: GoogleFonts.inter(
                            color: _OrdersTheme.goldSoft,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 3,
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                _OrdersTheme.gold,
                                _OrdersTheme.gold.withValues(alpha: 0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _OrdersTheme.gold.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  // UI-ENHANCEMENT PASS 4: the desktop title block is now
                  // left-aligned inside an Expanded column — Title, then
                  // the gold divider, then the subtitle — matching the
                  // Menu screen's desktop header layout exactly, instead
                  // of being centered as a standalone block. The top-left
                  // back-chevron control remains removed (navigation
                  // happens via the desktop side rail).
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orders Management',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 3,
                                width: 84,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      _OrdersTheme.gold,
                                      _OrdersTheme.gold.withValues(alpha: 0.0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _OrdersTheme.gold
                                          .withValues(alpha: 0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'View and track customer orders',
                                style: GoogleFonts.inter(
                                  color: _OrdersTheme.goldSoft,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }

  Widget _buildStatsGrid(bool isMobile) {
    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _statCard(
              'Total Orders',
              _orders.length.toString(),
              _OrdersTheme.milanoRed,
              isMobile,
            ),
            const SizedBox(width: 12),
            _statCard(
              'Placed',
              _orders.where((o) => o.status == 'PLACED').length.toString(),
              const Color(0xFF0284C7),
              isMobile,
            ),
            const SizedBox(width: 12),
            _statCard(
              'Served',
              _orders.where((o) => o.status == 'SERVED').length.toString(),
              const Color(0xFF16A34A),
              isMobile,
            ),
            const SizedBox(width: 12),
            _statCard(
              'Revenue',
              '₹${_totalRevenue.toStringAsFixed(0)}',
              _OrdersTheme.milanoRed,
              isMobile,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total Orders',
            _orders.length.toString(),
            _OrdersTheme.milanoRed,
            false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _statCard(
            'Placed',
            _orders.where((o) => o.status == 'PLACED').length.toString(),
            const Color(0xFF0284C7),
            false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _statCard(
            'Served',
            _orders.where((o) => o.status == 'SERVED').length.toString(),
            const Color(0xFF16A34A),
            false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _statCard(
            'Total Revenue',
            '₹${_totalRevenue.toStringAsFixed(0)}',
            _OrdersTheme.milanoRed,
            false,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, bool isMobile) {
    // UI-ENHANCEMENT PASS 2: added a slim color-coded top cap, matching
    // the Billing screen's stat boxes, so each figure has its own subtle
    // identity at a glance. Same title/value/color inputs as before.
    return Container(
      width: isMobile ? 130 : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: color.withValues(alpha: 0.65)),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: color.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _OrdersTheme.milanoRed.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _OrdersTheme.milanoRed.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _OrdersTheme.lemonChiffon.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_alt_outlined,
                  size: 18,
                  color: _OrdersTheme.milanoRed,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Filters',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _OrdersTheme.milanoRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isMobile)
            Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                    _statusFilter,
                    [
                      'All Status',
                      'PLACED',
                      'CONFIRMED',
                      'PREPARING',
                      'READY',
                      'SERVED',
                      'CANCELLED',
                    ],
                    (v) => setState(() => _statusFilter = v!)),
                const SizedBox(height: 12),
                _buildDropdown(
                    _paymentFilter,
                    [
                      'All Payments',
                      'PAID',
                      'PENDING',
                    ],
                    (v) => setState(() => _paymentFilter = v!)),
                const SizedBox(height: 12),
                _buildDropdown(
                    _typeFilter,
                    [
                      'All Types',
                      'DINE_IN',
                      'TAKEAWAY',
                    ],
                    (v) => setState(() => _typeFilter = v!)),
                const SizedBox(height: 12),
                _buildDropdown(
                    _sortOrder,
                    [
                      'Newest First',
                      'Oldest First',
                    ],
                    (v) => setState(() => _sortOrder = v!)),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search by Order ID...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  _OrdersTheme.milanoRed.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _OrdersTheme.milanoRed
                                  .withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _OrdersTheme.milanoRed
                                  .withValues(alpha: 0.55),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                          _statusFilter,
                          [
                            'All Status',
                            'PLACED',
                            'CONFIRMED',
                            'PREPARING',
                            'READY',
                            'SERVED',
                            'CANCELLED',
                          ],
                          (v) => setState(() => _statusFilter = v!)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                          _paymentFilter,
                          [
                            'All Payments',
                            'PAID',
                            'PENDING',
                          ],
                          (v) => setState(() => _paymentFilter = v!)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                          _typeFilter,
                          [
                            'All Types',
                            'DINE_IN',
                            'TAKEAWAY',
                          ],
                          (v) => setState(() => _typeFilter = v!)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                          _sortOrder,
                          [
                            'Newest First',
                            'Oldest First',
                          ],
                          (v) => setState(() => _sortOrder = v!)),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border:
            Border.all(color: _OrdersTheme.milanoRed.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, bool isMobile) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('No orders found')),
      );
    }

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final o = orders[i];
          final isHighlighted = o.id == _highlightedOrderId;

          Widget card = _buildOrderMobileCard(o);
          if (isHighlighted) {
            card = card
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .shimmer(
                  duration: 1500.ms,
                  color: _OrdersTheme.milanoRed.withValues(alpha: 0.2),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.02, 1.02),
                  duration: 1000.ms,
                );
          }
          return card;
        },
      );
    }

    return _buildOrdersTable(orders);
  }

  Widget _buildOrderMobileCard(OrderModel o) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: o.id == _highlightedOrderId
            ? _OrdersTheme.lemonChiffon.withValues(alpha: 0.35)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
        border: Border.all(
          color: o.id == _highlightedOrderId
              ? _OrdersTheme.gold
              : _OrdersTheme.milanoRed.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${o.id.substring(0, 8)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: _OrdersTheme.milanoRed,
                ),
              ),
              _statusBadge(
                o.status,
                isLoading: _updatingOrderIds.contains(o.id),
                onTap: () {
                  final next = _getNextStatusFor(o.status);
                  if (next != null) {
                    _updateOrderStatus(o.id, next);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOMER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      o.customerName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${o.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _OrdersTheme.milanoRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _paymentBadge(o.paymentStatus),
              ElevatedButton(
                onPressed: () => _showOrderDetails(o),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _OrdersTheme.milanoRed.withValues(alpha: 0.08),
                  foregroundColor: _OrdersTheme.milanoRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<OrderModel> orders) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _OrdersTheme.milanoRed.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _OrdersTheme.milanoRed.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 80,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                _OrdersTheme.lemonChiffon.withValues(alpha: 0.35),
              ),
              dataRowMaxHeight: 80,
              horizontalMargin: 24,
              columnSpacing: 24,
              dividerThickness: 1,
              columns: [
                DataColumn(
                  label: Text(
                    'ORDER ID',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'CUSTOMER',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'TABLE',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'TOTAL AMOUNT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PAYMENT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DATE',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ACTIONS',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              rows: orders.map((o) {
                final isHighlighted = o.id == _highlightedOrderId;

                // Helper to wrap cell content in animation if highlighted
                Widget anim(Widget child) {
                  if (!isHighlighted) return child;
                  return child
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .shimmer(
                        duration: 1500.ms,
                        color: _OrdersTheme.milanoRed.withValues(alpha: 0.2),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                        duration: 1000.ms,
                      );
                }

                return DataRow(
                  color: isHighlighted
                      ? WidgetStateProperty.resolveWith(
                          (states) =>
                              _OrdersTheme.lemonChiffon.withValues(alpha: 0.45),
                        )
                      : null,
                  cells: [
                    DataCell(
                      anim(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${o.id.substring(0, 8)}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: _OrdersTheme.milanoRed,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _badge(
                              o.orderType.replaceAll('_', '-'),
                              const Color(0xFFE0F2FE),
                              const Color(0xFF0284C7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      anim(
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                o.customerName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      anim(
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                o.tableNumber ?? 'N/A',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      anim(
                        _statusBadge(
                          o.status,
                          isLoading: _updatingOrderIds.contains(o.id),
                          onTap: () {
                            final next = _getNextStatusFor(o.status);
                            if (next != null) {
                              _updateOrderStatus(o.id, next);
                            }
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      anim(
                        Text(
                          '₹${o.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: _OrdersTheme.milanoRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    DataCell(anim(_paymentBadge(o.paymentStatus))),
                    DataCell(
                      anim(
                        Text(
                          dateFormat.format(
                            (DateTime.tryParse(o.createdAt) ?? DateTime.now())
                                .toLocal(),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      anim(
                        ElevatedButton.icon(
                          onPressed: () => _showOrderDetails(o),
                          icon: const Icon(Icons.visibility, size: 14),
                          label: Text(
                            'View Details',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _OrdersTheme.milanoRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String? _getNextStatusFor(String currentStatus) {
    const statusFlow = [
      'PLACED',
      'CONFIRMED',
      'PREPARING',
      'READY',
      'SERVED',
      'BILLED',
      'PAID',
    ];

    final current = currentStatus.toUpperCase();
    final currentIndex = statusFlow.indexOf(current);

    if (currentIndex != -1 && currentIndex < statusFlow.length - 1) {
      return statusFlow[currentIndex + 1];
    }
    return null;
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: textCol,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusBadge(
    String status, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    Color bg = const Color(0xFFE0F2FE);
    Color text = const Color(0xFF0284C7);

    if (status.toUpperCase() == 'PLACED' ||
        status.toUpperCase() == 'CONFIRMED') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0284C7);
    } else if (status.toUpperCase() == 'PREPARING') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFF97316);
    } else if (status.toUpperCase() == 'READY') {
      bg = const Color(0xFFF3E8FF);
      text = const Color(0xFFA855F7);
    } else if (status.toUpperCase() == 'SERVED') {
      bg = const Color(0xFFF0FDFA);
      text = const Color(0xFF0D9488);
    } else if (status.toUpperCase() == 'BILLED' ||
        status.toUpperCase() == 'PAID') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else if (status.toUpperCase() == 'CANCELLED') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    }

    return MouseRegion(
      cursor: (onTap != null && !isLoading)
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: text.withValues(alpha: 0.3)),
            boxShadow: (onTap != null && !isLoading)
                ? [
                    BoxShadow(
                      color: text.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: text),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                status.toUpperCase() == 'PLACED' ? 'Placed' : status,
                style: GoogleFonts.inter(
                  color: text,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentBadge(String status) {
    Color bg = const Color(0xFFFEF9C3);
    Color text = const Color(0xFFCA8A04);

    if (status.toUpperCase() == 'PAID') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else if (status.toUpperCase() == 'BILLED') {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFF97316);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase() == 'PENDING' ? 'Pending' : status,
        style: GoogleFonts.inter(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    if (_updatingOrderIds.contains(orderId)) return;

    setState(() => _updatingOrderIds.add(orderId));
    try {
      await OrdersService.updateOrderStatus(orderId, newStatus);

      // Update local state instead of fetching all orders for immediate feedback
      setState(() {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: newStatus,
            paymentStatus:
                newStatus == 'PAID' ? 'PAID' : _orders[index].paymentStatus,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingOrderIds.remove(orderId));
    }
  }

  void _showOrderDetails(OrderModel order) {
    if (order.id == _highlightedOrderId) {
      setState(() {
        _highlightedOrderId = null;
      });
    }
    showDialog(
      context: context,
      builder: (ctx) => _OrderDetailsDialog(
        order: order,
        onStatusUpdate: (newStatus) async {
          await _updateOrderStatus(order.id, newStatus);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(_error!, style: GoogleFonts.inter(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onPaid;

  const _PaymentDialog({required this.order, required this.onPaid});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _paymentMethod = 'Cash';
  double _tipPercentage = 0;
  final TextEditingController _customTipController = TextEditingController();

  double get _tipAmount {
    if (_customTipController.text.isNotEmpty) {
      return double.tryParse(_customTipController.text) ?? 0;
    }
    return widget.order.totalAmount * (_tipPercentage / 100);
  }

  double get _grandTotal => widget.order.totalAmount + _tipAmount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: _OrdersTheme.gold.withValues(alpha: 0.4), width: 1.2),
      ),
      elevation: 16,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: _OrdersTheme.headerGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Process Payment',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Table ${widget.order.tableNumber ?? 'N/A'}',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT METHOD',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _methodCard('Cash', Icons.attach_money),
                        const SizedBox(width: 16),
                        _methodCard('UPI', Icons.qr_code_scanner),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ADD TIP',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        0.0,
                        10.0,
                        15.0,
                        20.0,
                      ].map((p) => _tipButton(p)).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customTipController,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Custom amount (₹)',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Total',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${widget.order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _OrdersTheme.milanoRed,
                          ),
                        ),
                        Text(
                          '₹${_grandTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _OrdersTheme.milanoRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onPaid();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'Confirm Payment',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _OrdersTheme.milanoRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 4,
                          shadowColor:
                              _OrdersTheme.milanoRed.withValues(alpha: 0.4),
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
    );
  }

  Widget _methodCard(String label, IconData icon) {
    final isSelected = _paymentMethod == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? _OrdersTheme.milanoRed : Colors.grey.shade200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isSelected
                ? _OrdersTheme.lemonChiffon.withValues(alpha: 0.35)
                : Colors.white,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? _OrdersTheme.milanoRed : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _OrdersTheme.milanoRed : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipButton(double percentage) {
    final isSelected =
        _tipPercentage == percentage && _customTipController.text.isEmpty;
    return InkWell(
      onTap: () {
        _customTipController.clear();
        setState(() => _tipPercentage = percentage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _OrdersTheme.milanoRed : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${percentage.toInt()}%',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _OrderDetailsDialog extends StatefulWidget {
  final OrderModel order;
  final Function(String) onStatusUpdate;

  const _OrderDetailsDialog({
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  State<_OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<_OrderDetailsDialog> {
  late OrderModel _currentOrder;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      // The orders list endpoint doesn't include subtotal/tax_amount —
      // fetch the single-order detail so the real tax reflects correctly.
      final detailed = await OrdersService.getOrderById(widget.order.id);
      if (mounted) {
        setState(() => _currentOrder = detailed);
      }
    } catch (e) {
      debugPrint('Failed to load order detail: $e');
    }
  }

  Future<void> _handleStatusUpdate(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await widget.onStatusUpdate(newStatus);
      // Update the local status immediately. Parent state is also updated.
      setState(() {
        _currentOrder = _currentOrder.copyWith(
          status: newStatus,
          paymentStatus:
              newStatus == 'PAID' ? 'PAID' : _currentOrder.paymentStatus,
        );
        _isUpdating = false;
      });
    } catch (e) {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("MMMM dd, yyyy 'at' hh:mm a");

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: _OrdersTheme.gold.withValues(alpha: 0.4), width: 1.2),
      ),
      elevation: 20,
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 1000
              ? 960
              : MediaQuery.of(context).size.width * 0.94,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _OrdersTheme.milanoRed,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Summary Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final useVertical = constraints.maxWidth < 600;
                        final children = [
                          _summaryItem(
                            'Order ID',
                            '#${_currentOrder.id.length > 8 ? _currentOrder.id.substring(0, 8) : _currentOrder.id}',
                            isBold: true,
                          ),
                          _summaryItem(
                            'Order Type',
                            _currentOrder.orderType
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            isBold: true,
                          ),
                          _summaryItem(
                            'Status',
                            _currentOrder.status.toUpperCase(),
                            isBadge: true,
                          ),
                          _summaryItem(
                            'Payment',
                            _currentOrder.paymentStatus.toUpperCase(),
                            isBadge: true,
                          ),
                        ];

                        if (useVertical) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: children[0]),
                                  Expanded(child: children[1]),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: children[2]),
                                  Expanded(child: children[3]),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children:
                              children.map((c) => Expanded(child: c)).toList(),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Update Order Status Section
                    Text(
                      _currentOrder.status.toUpperCase() == 'PAID'
                          ? 'ORDER COMPLETED'
                          : 'UPDATE ORDER STATUS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _currentOrder.status.toUpperCase() == 'PAID'
                            ? AppColors.success
                            : AppColors.slate600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentOrder.status.toUpperCase() == 'PAID') ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final useVertical = constraints.maxWidth < 450;
                                final buttons = [
                                  _actionButton(
                                    context,
                                    'Print Receipt',
                                    Icons.print,
                                    const Color(0xFF1E293B),
                                    () {
                                      final restaurantName = context
                                              .read<RestaurantProvider>()
                                              .restaurant
                                              ?.name ??
                                          'RESTAURANT';
                                      _handlePrint(context, restaurantName);
                                    },
                                  ),
                                  _actionButton(
                                    context,
                                    'Download Receipt',
                                    Icons.file_download,
                                    const Color(0xFF0284C7),
                                    () {
                                      final restaurantName = context
                                              .read<RestaurantProvider>()
                                              .restaurant
                                              ?.name ??
                                          'RESTAURANT';
                                      _handleDownload(context, restaurantName);
                                    },
                                  ),
                                ];

                                if (useVertical) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      buttons[0],
                                      const SizedBox(height: 12),
                                      buttons[1],
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: buttons[0]),
                                    const SizedBox(width: 16),
                                    Expanded(child: buttons[1]),
                                  ],
                                );
                              },
                            ),
                          ] else if (_getButtonLabel() != '') ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final useVertical = constraints.maxWidth < 550;

                                if (_currentOrder.status.toUpperCase() ==
                                    'BILLED') {
                                  final buttons = [
                                    _actionButton(
                                      context,
                                      'Proceed to Payment',
                                      Icons.payment,
                                      _OrdersTheme.milanoRed,
                                      () {
                                        _showPaymentDialog(context);
                                      },
                                    ),
                                    _actionButton(
                                      context,
                                      'Print Receipt',
                                      Icons.print,
                                      const Color(0xFF1E293B),
                                      () {
                                        final restaurantName = context
                                                .read<RestaurantProvider>()
                                                .restaurant
                                                ?.name ??
                                            'RESTAURANT';
                                        _handlePrint(context, restaurantName);
                                      },
                                    ),
                                    _actionButton(
                                      context,
                                      'Download Receipt',
                                      Icons.file_download,
                                      const Color(0xFF0284C7),
                                      () {
                                        final restaurantName = context
                                                .read<RestaurantProvider>()
                                                .restaurant
                                                ?.name ??
                                            'RESTAURANT';
                                        _handleDownload(
                                          context,
                                          restaurantName,
                                        );
                                      },
                                    ),
                                  ];

                                  if (useVertical) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        buttons[0],
                                        const SizedBox(height: 12),
                                        buttons[1],
                                        const SizedBox(height: 12),
                                        buttons[2],
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      Expanded(child: buttons[0]),
                                      const SizedBox(width: 12),
                                      Expanded(child: buttons[1]),
                                      const SizedBox(width: 12),
                                      Expanded(child: buttons[2]),
                                    ],
                                  );
                                } else {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () {
                                              final next = _getNextStatus();
                                              if (next != null) {
                                                _handleStatusUpdate(next);
                                              }
                                            },
                                      icon: _isUpdating
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(_getButtonIcon(), size: 20),
                                      label: Text(
                                        _isUpdating
                                            ? 'Updating...'
                                            : _getButtonLabel(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getButtonColor(),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Receipt Header
                    Center(
                      child: Column(
                        children: [
                          Consumer<RestaurantProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                (provider.restaurant?.name ?? 'RESTAURANT')
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 2.0,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PAYMENT RECEIPT',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(thickness: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 24),

                    // Bill Details
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _billDetailRow(
                            'Bill Number',
                            'BILL-${_currentOrder.id.toUpperCase()}',
                          ),
                          _billDetailRow(
                            'Date',
                            dateFormat.format(
                              DateTime.tryParse(_currentOrder.createdAt) ??
                                  DateTime.now(),
                            ),
                          ),
                          _billDetailRow(
                            'Payment Method',
                            _currentOrder.paymentMethod ?? 'Cash',
                          ),
                          _billDetailRow(
                            'Table',
                            'Table ${_currentOrder.tableNumber ?? 't1'}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'ORDER ITEMS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _OrdersTheme.lemonChiffon
                                  .withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: _tableHeader('Item')),
                                Expanded(
                                  child: Center(child: _tableHeader('Qty')),
                                ),
                                Expanded(
                                  child: Center(child: _tableHeader('Price')),
                                ),
                                Expanded(
                                  child: Center(child: _tableHeader('Total')),
                                ),
                              ],
                            ),
                          ),
                          ..._currentOrder.items.map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        item.quantity.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.slate700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${item.price.toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.slate700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.slate900,
                                          ),
                                        ),
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

                    const SizedBox(height: 24),

                    // Totals
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _OrdersTheme.lemonChiffonSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _OrdersTheme.gold.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _priceRow(
                            'Subtotal',
                            _currentOrder.displaySubtotal.toStringAsFixed(0),
                          ),
                          if ((_currentOrder.taxAmount ?? 0) > 0) ...[
                            const SizedBox(height: 12),
                            _priceRow(
                              'Tax',
                              _currentOrder.taxAmount!.toStringAsFixed(0),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              height: 1,
                              color: _OrdersTheme.gold.withValues(alpha: 0.4),
                            ),
                          ),
                          _priceRow(
                            'TOTAL',
                            _currentOrder.totalAmount.toStringAsFixed(0),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Bottom Info
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useVertical = constraints.maxWidth < 500;
                        final card = _infoBox(
                          Icons.credit_card,
                          'Payment Information',
                          [
                            'Method: ${_currentOrder.paymentMethod ?? "N/A"}',
                            'Status: ${_currentOrder.paymentStatus.toUpperCase()}',
                          ],
                          const Color(0xFFEFF6FF),
                          const Color(0xFF1E40AF),
                        );
                        final time = _infoBox(
                          Icons.schedule,
                          'Timestamps',
                          [
                            'Created: ${dateFormat.format(DateTime.tryParse(_currentOrder.createdAt) ?? DateTime.now())}',
                            'Updated: ${_currentOrder.updatedAt != null ? dateFormat.format(DateTime.tryParse(_currentOrder.updatedAt!) ?? DateTime.now()) : "N/A"}',
                          ],
                          const Color(0xFFFAF5FF),
                          const Color(0xFF6B21A8),
                        );

                        if (useVertical) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [card, const SizedBox(height: 16), time],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: card),
                            const SizedBox(width: 24),
                            Expanded(child: time),
                          ],
                        );
                      },
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

  String? _getNextStatus() {
    final s = _currentOrder.status.toUpperCase();
    if (s == 'PLACED') return 'CONFIRMED';
    if (s == 'CONFIRMED') return 'PREPARING';
    if (s == 'PREPARING') return 'READY';
    if (s == 'READY') return 'SERVED';
    if (s == 'SERVED') return 'BILLED';
    return null;
  }

  String _getButtonLabel() {
    final s = _currentOrder.status.toUpperCase();
    if (s == 'PLACED') return 'Confirm Order';
    if (s == 'CONFIRMED') return 'Start Preparing';
    if (s == 'PREPARING') return 'Mark as Ready';
    if (s == 'READY') return 'Mark as Served';
    if (s == 'SERVED') return 'Generate Bill';
    if (s == 'BILLED') return 'Proceed to Payment';
    return '';
  }

  IconData _getButtonIcon() {
    final s = _currentOrder.status.toUpperCase();
    if (s == 'PLACED') return Icons.check_circle_outline;
    if (s == 'CONFIRMED') return Icons.restaurant;
    if (s == 'PREPARING') return Icons.notifications_active;
    if (s == 'READY') return Icons.local_shipping;
    if (s == 'SERVED') return Icons.payments;
    if (s == 'BILLED') return Icons.payment;
    return Icons.sync;
  }

  Color _getButtonColor() {
    final s = _currentOrder.status.toUpperCase();
    if (s == 'PLACED') return const Color(0xFF2563EB); // Blue
    if (s == 'CONFIRMED') return const Color(0xFFF97316); // Orange
    if (s == 'PREPARING') return const Color(0xFFA855F7); // Purple
    if (s == 'READY') return const Color(0xFF0D9488); // Teal
    if (s == 'SERVED') return const Color(0xFF6366F1); // Indigo
    return const Color(0xFF1E293B);
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _PaymentDialog(
        order: _currentOrder,
        onPaid: () {
          _handleStatusUpdate('PAID');
        },
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.slate700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Future<void> _handlePrint(BuildContext context, String restaurantName) async {
    final pdf = await _generateReceiptPdf(restaurantName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${_currentOrder.id}',
    );
  }

  Future<void> _handleDownload(
    BuildContext context,
    String restaurantName,
  ) async {
    final pdf = await _generateReceiptPdf(restaurantName);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Receipt_${_currentOrder.id}.pdf',
    );
  }

  Future<pw.Document> _generateReceiptPdf(String restaurantName) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat("MMMM dd, yyyy 'at' hh:mm a");
    final dateStr = dateFormat.format(
      DateTime.tryParse(_currentOrder.createdAt) ?? DateTime.now(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      restaurantName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Payment Receipt',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(height: 2, color: PdfColors.black),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Bill info
              _pdfRow('Bill Number', 'BILL-${_currentOrder.id.toUpperCase()}'),
              _pdfRow('Date', dateStr),
              _pdfRow('Payment Method', _currentOrder.paymentMethod ?? 'Cash'),
              _pdfRow('Table', 'Table ${_currentOrder.tableNumber ?? 't1'}'),

              pw.SizedBox(height: 24),
              pw.Text(
                'Order Items',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  ..._currentOrder.items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.quantity.toString(),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rs. ${item.price.toStringAsFixed(0)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _pdfPriceRow(
                        'Subtotal',
                        _currentOrder.displaySubtotal.toStringAsFixed(0),
                      ),
                      if ((_currentOrder.taxAmount ?? 0) > 0)
                        _pdfPriceRow(
                          'Tax',
                          _currentOrder.taxAmount!.toStringAsFixed(0),
                        ),
                      pw.Divider(color: PdfColors.grey400),
                      _pdfPriceRow(
                        'TOTAL',
                        _currentOrder.totalAmount.toStringAsFixed(0),
                        isTotal: true,
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Thank you for dining with us!',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfPriceRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            'Rs. $value',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _billDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String value, {
    bool isBold = false,
    bool isBadge = false,
  }) {
    Color badgeCol = const Color(0xFFF1F5F9);
    Color textCol = const Color(0xFF475569);

    if (isBadge) {
      final v = value.toUpperCase();
      if (v == 'PLACED' || v == 'CONFIRMED') {
        badgeCol = const Color(0xFFE0F2FE);
        textCol = const Color(0xFF0284C7);
      } else if (v == 'PREPARING') {
        badgeCol = const Color(0xFFFFEDD5);
        textCol = const Color(0xFFF97316);
      } else if (v == 'READY') {
        badgeCol = const Color(0xFFF3E8FF);
        textCol = const Color(0xFFA855F7);
      } else if (v == 'SERVED') {
        badgeCol = const Color(0xFFF0FDFA);
        textCol = const Color(0xFF0D9488);
      } else if (v == 'BILLED' || v == 'PAID') {
        badgeCol = const Color(0xFFDCFCE7);
        textCol = const Color(0xFF16A34A);
      } else if (v == 'CANCELLED' || v == 'PENDING') {
        badgeCol = const Color(0xFFFEE2E2);
        textCol = const Color(0xFFDC2626);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.slate500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeCol,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: textCol,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
              fontSize: 16,
              color: AppColors.slate900,
            ),
          ),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            color: isTotal ? AppColors.slate900 : AppColors.slate600,
          ),
        ),
        Text(
          '₹$value',
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w900,
            color: isTotal ? _OrdersTheme.milanoRed : AppColors.slate900,
          ),
        ),
      ],
    );
  }

  Widget _infoBox(
    IconData icon,
    String title,
    List<String> lines,
    Color bg,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: accent.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// UI-ENHANCEMENT PASS 3 — Admin Navigation (mobile bottom bar + desktop
/// side rail)
///
/// Adds the same "Menu / Staff / Tables / Order Bill" destinations used
/// elsewhere in the admin console to this screen too:
///   • Mobile (width < 900) → `_AdminBottomNav`, a fixed cream bottom
///     bar with four icon+label tiles.
///   • Desktop (width >= 900) → `_AdminSideNav`, a fixed cream left-hand
///     sidebar (logo header, an "ADMIN PANEL" badge, the same four nav
///     tiles as a vertical list with the active tile highlighted as a
///     solid maroon pill with a trailing chevron, and a small profile
///     card pinned to the bottom), matching the reference sidebar
///     design supplied.
/// Both are purely presentational — tapping an inactive tile calls
/// `context.go(item.route)`, the same navigation call already used
/// elsewhere in this file. No provider, filter, sort, status-update, or
/// PDF/print logic was touched.
/// ─────────────────────────────────────────────────────────────────────────
class _AdminNavItem {
  final IconData icon;
  final String label;
  final String route;
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<_AdminNavItem> _kAdminNavItems = [
  _AdminNavItem(
    icon: Icons.restaurant_menu_rounded,
    label: 'Menu',
    route: '/admin/menu',
  ),
  _AdminNavItem(
    icon: Icons.groups_rounded,
    label: 'Staff',
    route: '/admin/staff',
  ),
  _AdminNavItem(
    icon: Icons.table_restaurant_rounded,
    label: 'Tables',
    route: '/admin/tables',
  ),
  _AdminNavItem(
    icon: Icons.receipt_long_rounded,
    label: 'Order Bill',
    route: '/admin/orders',
  ),
];

/// Fixed cream bottom navigation bar — mobile-only. Four evenly-spaced
/// tappable tiles, each an icon in a circular badge with a label
/// underneath; the active tile's badge is solid gold with a dark-maroon
/// icon and bold label, inactive tiles show a plain white badge with a
/// maroon icon and muted label.
class _AdminBottomNav extends StatelessWidget {
  final int? currentIndex;
  const _AdminBottomNav({this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _OrdersTheme.canvas,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: const Border(
          top: BorderSide(color: _OrdersTheme.gold, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < _kAdminNavItems.length; i++)
                _AdminBottomNavTile(
                  item: _kAdminNavItems[i],
                  isActive: currentIndex == i,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable tile inside `_AdminBottomNav`. Navigation is a plain
/// `context.go(item.route)` call; disabled entirely when the tile is
/// already the active tab so tapping it is a harmless no-op instead of
/// an unnecessary re-navigation.
class _AdminBottomNavTile extends StatelessWidget {
  final _AdminNavItem item;
  final bool isActive;
  const _AdminBottomNavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : () => context.go(item.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? _OrdersTheme.gold : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? _OrdersTheme.milanoRedDark.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: isActive ? 14 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isActive
                    ? _OrdersTheme.milanoRedDark
                    : _OrdersTheme.milanoRed,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? _OrdersTheme.milanoRedDark
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop-only fixed left sidebar — a "PUREDINE" logo header, an
/// "ADMIN PANEL" badge, the four nav tiles (the active one rendered as a
/// solid maroon gradient pill with a left gold accent bar and a trailing
/// chevron), and a small "Admin / Online" profile card pinned to the
/// bottom via a `Spacer`. Matches the supplied reference sidebar design.
/// Purely presentational — tapping an inactive tile calls
/// `context.go(item.route)`; no data/business logic lives here.
class _AdminSideNav extends StatelessWidget {
  final int? currentIndex;
  const _AdminSideNav({this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: _OrdersTheme.canvas,
        border: Border(
          right: BorderSide(
            color: _OrdersTheme.milanoRed.withValues(alpha: 0.10),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logo header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _OrdersTheme.milanoRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _OrdersTheme.gold.withValues(alpha: 0.6),
                        width: 1.4,
                      ),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PUREDINE',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                      color: _OrdersTheme.milanoRedDark,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: _OrdersTheme.milanoRed.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 20),
            // ── "ADMIN PANEL" badge ──────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _OrdersTheme.lemonChiffon.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: _OrdersTheme.milanoRedDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ADMIN PANEL',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _OrdersTheme.milanoRedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ── Nav items ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  for (int i = 0; i < _kAdminNavItems.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AdminSideNavTile(
                        item: _kAdminNavItems[i],
                        isActive: currentIndex == i,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // ── Profile card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _OrdersTheme.milanoRed.withValues(alpha: 0.10),
                  ),
                  boxShadow: _OrdersTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _OrdersTheme.milanoRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Online',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }
}

/// One tappable row inside `_AdminSideNav`. Inactive tiles are a plain
/// transparent row with a muted icon+label; the active tile becomes a
/// solid maroon gradient pill with a small gold accent bar on its left
/// edge and a trailing white chevron, matching the reference design's
/// highlighted "Home" tile. Navigation is a plain `context.go(item.
/// route)` call, disabled when already active.
class _AdminSideNavTile extends StatelessWidget {
  final _AdminNavItem item;
  final bool isActive;
  const _AdminSideNavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? null : () => context.go(item.route),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      _OrdersTheme.milanoRed,
                      _OrdersTheme.milanoRedDark,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color:
                          _OrdersTheme.milanoRedDark.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _OrdersTheme.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.16)
                      : _OrdersTheme.milanoRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 17,
                  color: isActive ? Colors.white : _OrdersTheme.milanoRedDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: isActive ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}