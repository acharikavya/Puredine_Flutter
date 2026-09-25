import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// Screen-local theme palette.
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
/// UI-ENHANCEMENT PASS 3: tightened the vertical space above the
/// "Orders Management" title inside the header — reduced the header's
/// top padding and swapped the title's vertical `Center` alignment for
/// a top-aligned `Align` so the heading sits right under the top edge
/// instead of floating in the middle of the bar. Purely a spacing/
/// alignment tweak; no provider, filtering, sorting, status-update, or
/// PDF/print logic was touched.
///
/// UI-ENHANCEMENT PASS 4 (brings this screen in line with
/// the Menu Management screen's current look, both structurally and in
/// color, so the two admin screens read as one consistent brand): zero
/// changes to data loading, filtering, sorting, status-update, dialog,
/// or PDF/print logic anywhere in this file — presentation only.
///   1. PALETTE: `_OrdersTheme`'s field names are unchanged — every
///      widget below already reads from these exact names — but the
///      underlying `Color` values were re-pointed at the shared brand
///      identity, automatically re-skinning every surface in this file
///      (header, stat cards, filters, table, badges, dialogs, buttons,
///      receipt) with no other code touched.
///   2. HEADER: `_buildHeader()` is rebuilt from the old dark maroon
///      gradient "command bar" into the standard header style the Menu
///      screen uses — a plain title row (two-tone `ShaderMask`, a small
///      gold accent-dot row, and a thin gold gradient hairline beneath
///      the subtitle) plus a large rounded pill search bar underneath,
///      using the exact same `_searchQuery` state and `onChanged`
///      handler the old inline search field (previously inside
///      `_buildFilterSection`) used to have — only relocated, not
///      changed, and a "N found" chip is shown next to it exactly like
///      on the Menu screen. The old inline search `TextField` was
///      removed from `_buildFilterSection` since the header now owns
///      search; the four filter dropdowns (Status, Payment, Type, Sort)
///      are unchanged and simply reflow to fill the row search used to
///      share.
///   3. CARDS: the filters panel and the orders table panel now use the
///      same 22px corner radius and softer bordered/shadowed treatment
///      as the Menu screen's cards, via the shared `_OrdersTheme.
///      softShadow`.
///
/// UI-ENHANCEMENT PASS 5: added a slim utility bar (`_buildTopBar`)
/// above the "Orders Management" header, with a circular profile/store
/// avatar and a short greeting.
///
/// UI-ENHANCEMENT PASS 6: removed the two small circular icon buttons
/// that used to sit on the right side of `_buildTopBar` (the scan/QR
/// icon and the notification bell): both were purely decorative — neither
/// carried an `onTap` handler nor was wired to any notification,
/// navigation, or scan feature — so removing them dropped zero logic.
///
/// UI-ENHANCEMENT PASS 7: PUREDINE Maroon + Cream re-theme, plus a
/// wine-gradient background on the top utility bar.
///
/// UI-ENHANCEMENT PASS 8: presentation-only, exactly like every pass
/// above — no provider, data loading, filtering, sorting, status-update,
/// dialog, or PDF/print logic anywhere in this file was touched, and no
/// state field, callback, route, or keyword was renamed.
///   1. TOP BAR REMOVED: the slim utility bar added in PASS 5 held only
///      two purely decorative things — the circular store avatar on the
///      left and the "Have a great day" line beside it. Neither carried
///      an `onTap`, a provider read, or any state, so both have been
///      removed per request, and with nothing left inside it the
///      `_buildTopBar()` method and its single call in `build()` were
///      dropped entirely. Nothing else moved: `_buildHeader()` is still
///      the first widget in the body `Column`, now owning the top
///      `SafeArea` inset that the utility bar used to absorb, so the
///      title still clears the status bar / notch correctly.
///   2. HEADER IS NOW THE BRANDED TOP BAR: with the utility strip gone,
///      `_buildHeader()` itself carries the PUREDINE Deep Wine Maroon →
///      Wine diagonal gradient (`#742A3C → #813244`) instead of sitting
///      on the plain cream canvas — a medium-depth, not-too-dark maroon
///      band running the full width from the very top of the screen down
///      to the scrollable body. It gained the same ambient dressing the
///      Menu screen's header uses (a soft warm-gold corner glow, a large
///      very faint watermark emblem, and a subtle diagonal glass sheen),
///      and a warm-gold hairline along its bottom edge. Everything
///      inside it is structurally identical to before — the same accent
///      dots, the same title/subtitle text, the same gold hairline, and
///      the same white pill search bar wired to the exact same
///      `_searchQuery` state, `onChanged` handler and "N found" chip.
///      Only the colors of the copy changed (white/soft-gold instead of
///      maroon/grey) so it reads clearly against the new wine backdrop.
///   3. PALETTE — full PUREDINE mapping: `_OrdersTheme`'s field names
///      are, as always, unchanged (every widget in this file reads from
///      these exact names) — only the `Color` values were set to the
///      supplied palette:
///        • `milanoRed`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `milanoRedLight`   → Wine `#813244` (topbar lighter gradient)
///        • `milanoRedDark`    → Burgundy `#8A183F` (primary accent)
///        • `milanoRedDarkest` → Deep Brown/Black `#2E0D16` (dark text)
///        • `canvas`           → Warm Off-White `#FBF8F5` (main background)
///        • `canvasDeep`       → Soft Cream `#F7F1ED` (card background)
///        • `blushTint`        → Dusty Blush `#F3D9DC` (icon BG)
///        • `paleRose`         → Pale Rose `#EFD7DA` (card border)
///        • `lemonChiffon`/`gold` → Warm Gold `#F3C564` (gold accent)
///        • `lemonChiffonSoft` → Soft Yellow `#FCE1AB` (gold highlight)
///        • `goldSoft`         → deeper gold `#D9A421` (derived companion)
///        • `successGreen`     → Fresh Green `#44AF70` (live / success)
///        • `mintBg`           → Pale Mint `#EAF6EF` (success chip backgrounds)
///        • `mutedTaupe`       → Muted Taupe `#9B707A` (secondary text)
///      `primaryButtonGradient` uses the supplied CTA gradient exactly:
///      `#6E1832 → #9B3E4E → #F3C564`, and `headerGradient` the supplied
///      header gradient exactly: `#742A3C → #813244`.
///   4. SUPPORTING SURFACES re-tuned to the same palette so the screen
///      reads as one brand from the top bar all the way to the bottom of
///      the scroll: the four stat cards now use maroon/wine/burgundy/
///      green accents instead of the old stray blue, the order-type chip
///      on each table row uses the Dusty Blush icon-BG with maroon text,
///      and the filter panel / table / mobile cards keep the Pale Rose
///      card border and Soft Cream tints. Every status and payment badge
///      keeps its own semantic color (blue = placed, orange = preparing,
///      purple = ready, teal = served, green = paid, red = cancelled) so
///      no status meaning changed.
///
/// FEATURE PASS 9: added TIME-RANGE FILTERING to the orders
/// list — and nothing else. No existing provider call, data loading,
/// search, status/payment/type filter, sorting, status-update, dialog, or
/// PDF/print logic was changed, and no existing field, callback, route or
/// keyword was renamed.
///   1. NEW STATE (in `_OrdersScreenState`): `_timeFilter`,
///      `_customTimeValue`, `_customTimeUnit` and a small
///      `_customTimeController` for the custom-duration input.
///   2. NEW FILTER RULE: `_timeCutoff` converts the chosen range into a
///      "show orders created after this moment" cut-off, and `_filtered`
///      gained one extra `matchTime` condition that is AND-ed with the
///      existing four. When the range is "All Time" (default) the new
///      condition is always true, so behaviour is identical to before.
///   3. NEW UI: a "Time Range" block at the bottom of the Filters panel
///      (`_buildTimeRangeSection`) with quick-pick chips — All Time,
///      Last 1 Hour, Last 6 Hours, Last 12 Hours, Today, Last 1 Day,
///      Last 1 Week, Last 1 Month — and a "Custom" chip that reveals a
///      "Last [N] [Minutes / Hours / Days]" input. A small info pill
///      shows the exact date/time the active range starts from.
///
/// FEATURE PASS 10: layout-only refinement of the Time Range
/// block from PASS 9 — no logic, state, filtering rule or keyword changed.
/// The time-range options previously wrapped onto two rows; they now sit
/// on a SINGLE line inside a soft segmented pill track (`_timeChip` was
/// restyled to match). If the screen is too narrow to show all options at
/// once, the track scrolls sideways instead of wrapping.
///
/// FIX (PASS 10): added `import 'dart:ui' show PointerDeviceKind;` — the
/// sideways-scroll drag settings on the Time Range track reference
/// `PointerDeviceKind`, which `material.dart` does not export. This import
/// is the only change; no logic was touched.
///
/// FEATURE PASS 11: layout/visual-only refinement of the Time
/// Range block — no logic, state, filtering rule or keyword changed. The
/// shared pill track from PASS 10 was removed; each time range is now its
/// own separate, icon-badged box (`_timeChip`, plus a small `_timeChipIcon`
/// helper), still on a single sideways-scrolling line.
///
/// FEATURE PASS 12: colour/theme-only restyle of the ORDER
/// DETAILS dialog (`_OrderDetailsDialog`) so it matches the Orders screen —
/// no logic, state, callback, PDF/print code or keyword was changed.
///   1. Dialog shell: Warm Off-White canvas, 24px corners, gold outline.
///   2. Header: the same wine-gradient top bar as the screen (gold accent
///      dots, white→gold title, gold hairline, watermark, glow, sheen) with
///      a glass-style close button.
///   3. Body: cream canvas with the screen's soft gold/wine/blush glows.
///   4. Cards: Soft Cream gradient, Pale Rose border and the shared
///      `_OrdersTheme.softShadow`; slate greys swapped for Muted Taupe /
///      Deep Brown; the update-status button uses wine shades instead of
///      blue/orange/purple/teal (status badges keep their semantic colours).
///
/// FEATURE PASS 13 (this pass): the "Orders since ..." golden
/// info pill inside the Time Range block (`_buildTimeRangeSection`) now
/// only appears when at least one order actually falls inside the
/// selected time range. Previously it showed as soon as any range other
/// than "All Time" was picked, even if zero orders matched — now it's
/// hidden in that empty case and shown exactly as before whenever there
/// is a matching order. This is checked with a new small helper,
/// `_hasOrdersInTimeRange`, which looks at the same `createdAt` field and
/// the same `_timeCutoff` the existing time filter already uses — no
/// filtering rule, provider call, sorting, status-update, dialog, or
/// PDF/print logic anywhere in this file was touched, and no existing
/// field, callback, route or keyword was renamed.
/// -----------------------------------------------------------------------
class _OrdersTheme {
  // Primary brand — the "PUREDINE Maroon + Cream" palette (see the
  // UI-ENHANCEMENT PASS 8 note above). Field names are unchanged on
  // purpose — every widget below already reads from these exact names,
  // so only the underlying Color values change.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedDark =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color milanoRedDarkest =
      Color(0xFF2E0D16); // Deep Brown/Black (dark text)

  // Gold accents — Warm Gold / Soft Yellow from the PUREDINE palette,
  // plus a deeper companion shade used for fine dividers.
  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color lemonChiffonSoft =
      Color(0xFFFCE1AB); // Soft Yellow (gold highlight)
  static const Color gold = Color(0xFFF3C564); // Warm Gold
  static const Color goldSoft = Color(0xFFD9A421); // Deeper gold (derived)

  // Warm off-white / soft cream canvas, per the PUREDINE palette.
  static const Color canvas = Color(0xFFFBF8F5); // Warm Off-White background
  static const Color canvasDeep = Color(0xFFF7F1ED); // Soft Cream card tint
  static const Color cardWhite = Colors.white;

  // Supporting PUREDINE tones — icon chips, card borders, and
  // success/paid states respectively.
  static const Color blushTint =
      Color(0xFFF3D9DC); // Dusty Blush — icon chip backgrounds
  static const Color paleRose = Color(0xFFEFD7DA); // Pale Rose — card borders
  static const Color successGreen =
      Color(0xFF44AF70); // Fresh Green — live/success/paid accents
  static const Color mintBg =
      Color(0xFFEAF6EF); // Pale Mint — success chip backgrounds
  static const Color mutedTaupe =
      Color(0xFF9B707A); // Muted Taupe — secondary text

  // Convenience gradients used for headers / primary buttons — exactly
  // the two gradients called out in the PUREDINE spec.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRed, milanoRedLight],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), lemonChiffon],
  );

  /// Themed soft shadow for resting cards/panels — mirrors the Menu
  /// screen's softShadow so every surface shares the same warm,
  /// branded tint.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDark.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.05),
          blurRadius: 6,
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

  // ── Time-range filter (FEATURE PASS 9) ────────────────────────────────
  // Quick-pick ranges shown as chips in the Filters panel. 'Custom' lets
  // the user type their own "Last N Minutes / Hours / Days".
  static const List<String> _timeFilterOptions = [
    'All Time',
    'Last 1 Hour',
    'Last 6 Hours',
    'Last 12 Hours',
    'Today',
    'Last 1 Day',
    'Last 1 Week',
    'Last 1 Month',
    'Custom',
  ];
  static const List<String> _customTimeUnits = ['Minutes', 'Hours', 'Days'];

  String _timeFilter = 'All Time';
  int _customTimeValue = 1;
  String _customTimeUnit = 'Hours';
  final TextEditingController _customTimeController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _checkHighlight();
  }

  @override
  void dispose() {
    _customTimeController.dispose();
    super.dispose();
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

  /// FEATURE PASS 9: turns the selected time range into a cut-off moment —
  /// orders created BEFORE this instant are hidden. Returns `null` when no
  /// time restriction applies ("All Time", or a "Custom" range whose number
  /// is empty / zero), which makes the time condition a no-op.
  DateTime? get _timeCutoff {
    final now = DateTime.now();
    switch (_timeFilter) {
      case 'Last 1 Hour':
        return now.subtract(const Duration(hours: 1));
      case 'Last 6 Hours':
        return now.subtract(const Duration(hours: 6));
      case 'Last 12 Hours':
        return now.subtract(const Duration(hours: 12));
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Last 1 Day':
        return now.subtract(const Duration(days: 1));
      case 'Last 1 Week':
        return now.subtract(const Duration(days: 7));
      case 'Last 1 Month':
        return now.subtract(const Duration(days: 30));
      case 'Custom':
        if (_customTimeValue <= 0) return null;
        switch (_customTimeUnit) {
          case 'Minutes':
            return now.subtract(Duration(minutes: _customTimeValue));
          case 'Days':
            return now.subtract(Duration(days: _customTimeValue));
          default:
            return now.subtract(Duration(hours: _customTimeValue));
        }
      default:
        return null;
    }
  }

  /// FEATURE PASS 13: whether at least one order actually falls inside the
  /// currently selected time range. Uses the exact same `createdAt`
  /// parsing / cut-off comparison the real `matchTime` condition in
  /// `_filtered` already uses, just checked against the full `_orders`
  /// list (independent of the other filters) so the golden "Orders
  /// since ..." pill only reflects whether the time range itself has any
  /// orders in it. Returns `true` when there's no active cut-off, since in
  /// that case the pill isn't shown anyway.
  bool get _hasOrdersInTimeRange {
    final cutoff = _timeCutoff;
    if (cutoff == null) return true;
    return _orders.any((o) {
      final created = DateTime.tryParse(o.createdAt);
      return created != null && !created.isBefore(cutoff);
    });
  }

  List<OrderModel> get _filtered {
    final cutoff = _timeCutoff;
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

      // FEATURE PASS 9: time-range condition. Always true when no range
      // is active; otherwise the order must have a valid creation time
      // that falls on/after the cut-off.
      bool matchTime = true;
      if (cutoff != null) {
        final created = DateTime.tryParse(o.createdAt);
        matchTime = created != null && !created.isBefore(cutoff);
      }

      return matchSearch &&
          matchStatus &&
          matchPayment &&
          matchType &&
          matchTime;
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
    final filtered = _filtered;
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: _OrdersTheme.canvas,
      body: Column(
        children: [
          // ── Header Section ───────────────────────────────────────────────
          // PASS 8: the slim utility bar that used to sit above this (the
          // store avatar + "Have a great day" line) has been removed
          // entirely — both were purely decorative with no callbacks or
          // state. This header is now the screen's branded top bar: it
          // owns the top SafeArea inset and carries the PUREDINE Deep
          // Wine Maroon → Wine gradient. It stays fixed at the top,
          // exactly like MenuScreen's custom header — it does not scroll
          // away with the content beneath it.
          _buildHeader(isMobile),

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────────
                // Purely decorative — soft gold/wine glows plus a faint
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
                        // only near the header.
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
                        // PASS 8: a soft blush glow low on the left, so the
                        // bottom of a long scroll carries the same warm
                        // brand tint as the top instead of fading to flat
                        // white. Purely decorative.
                        Positioned(
                          bottom: 60,
                          left: -60,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _OrdersTheme.blushTint
                                      .withValues(alpha: 0.45),
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
      ),
    ).animate().fadeIn();
  }

  /// PASS 4 rebuilt this into the standard header style the Menu screen
  /// uses — an accent-dot row, a two-tone `ShaderMask` title, a subtitle,
  /// a thin gold gradient hairline, and a large rounded pill search bar
  /// underneath. The search bar uses the exact same `_searchQuery` state
  /// and `onChanged` handler the old inline search field (previously
  /// inside `_buildFilterSection`) used to have — only relocated here,
  /// not changed.
  ///
  /// PASS 8: with the decorative utility bar above it removed (see the
  /// class doc comment), this header IS the screen's top bar now. It
  /// carries the PUREDINE Deep Wine Maroon → Wine gradient
  /// (`#742A3C → #813244`), owns the top `SafeArea` inset so the title
  /// clears the status bar, and gained the same ambient dressing the Menu
  /// screen's header uses — a soft warm-gold corner glow, a large very
  /// faint watermark emblem, and a subtle diagonal glass sheen — plus a
  /// warm-gold hairline along its bottom edge. Structurally nothing
  /// inside changed: same dots, same title/subtitle text, same hairline,
  /// same white pill search bar with the same state, handler and "N
  /// found" chip. Only the copy's colors changed so it reads clearly on
  /// the wine backdrop.
  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _OrdersTheme.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: _OrdersTheme.lemonChiffon.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Ambient dressing for the wine backdrop — a soft warm-gold
          // glow in the top-right corner, a large very faint watermark
          // emblem behind the copy, and a diagonal glass sheen. Purely
          // presentational, clipped to the header's own bounds.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -50,
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _OrdersTheme.lemonChiffon.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: isMobile ? -22 : -14,
                      bottom: isMobile ? -20 : -14,
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: isMobile ? 130 : 170,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 18 : 32,
                isMobile ? 16 : 22,
                isMobile ? 18 : 32,
                isMobile ? 18 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small gold accent-dot row above the title — same
                  // "dotted texture accent" language used on the Menu
                  // screen's header.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _OrdersTheme.lemonChiffon.withValues(
                              alpha: i == 2 ? 0.95 : 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        // Two-tone white→gold ShaderMask on the title, so
                        // it reads cleanly against the wine backdrop while
                        // keeping the same brand-title treatment.
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              _OrdersTheme.lemonChiffon,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            isMobile ? 'Orders' : 'Orders Management',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: isMobile ? 21 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    isMobile
                        ? 'Track customer orders'
                        : 'View and track customer orders',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: isMobile ? 12.5 : 14,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  // Thin gold gradient hairline — same soft divider
                  // language used on the Menu screen's header.
                  Container(
                    width: 46,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          _OrdersTheme.lemonChiffon.withValues(alpha: 0.95),
                          _OrdersTheme.lemonChiffon.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 14 : 18),
                  // Standard rounded pill search bar — same _searchQuery
                  // state and the exact same onChanged handler the old
                  // inline search field (previously inside
                  // _buildFilterSection) used to have, so search behaves
                  // identically to before, just relocated into the
                  // header, matching the Menu screen's pattern.
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _OrdersTheme.milanoRedDarkest
                              .withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        Icon(
                          Icons.search_rounded,
                          color: _OrdersTheme.milanoRed.withValues(
                            alpha: 0.55,
                          ),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.inter(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: _OrdersTheme.milanoRed,
                            decoration: InputDecoration(
                              hintText: 'Search by Order ID...',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: false,
                              hintStyle: GoogleFonts.inter(
                                color: _OrdersTheme.mutedTaupe,
                              ),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _OrdersTheme.lemonChiffon.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_filtered.length} found',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _OrdersTheme.milanoRed,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PASS 8: the four stat cards now draw their accents from the PUREDINE
  /// palette (Deep Wine Maroon, Wine, Fresh Green, Burgundy) instead of
  /// the old stray blue, so the row reads as one brand. The card widget,
  /// the values shown, and the filters they reflect are unchanged.
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
              _OrdersTheme.milanoRedLight,
              isMobile,
            ),
            const SizedBox(width: 12),
            _statCard(
              'Served',
              _orders.where((o) => o.status == 'SERVED').length.toString(),
              _OrdersTheme.successGreen,
              isMobile,
            ),
            const SizedBox(width: 12),
            _statCard(
              'Revenue',
              '₹${_totalRevenue.toStringAsFixed(0)}',
              _OrdersTheme.milanoRedDark,
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
            _OrdersTheme.milanoRedLight,
            false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _statCard(
            'Served',
            _orders.where((o) => o.status == 'SERVED').length.toString(),
            _OrdersTheme.successGreen,
            false,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _statCard(
            'Total Revenue',
            '₹${_totalRevenue.toStringAsFixed(0)}',
            _OrdersTheme.milanoRedDark,
            false,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, bool isMobile) {
    // A slim color-coded top cap so each figure has its own subtle
    // identity at a glance. Same title/value/color inputs as before.
    //
    // PASS 8: the card body sits on Soft Cream instead of flat white and
    // the corner radius was raised to 18 so it matches the rest of the
    // PUREDINE card language — decoration only.
    return Container(
      width: isMobile ? 130 : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _OrdersTheme.canvasDeep],
              ),
              border: Border.all(
                color: _OrdersTheme.paleRose,
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
                        color: _OrdersTheme.mutedTaupe,
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

  /// PASS 4: the inline search `TextField` this section used to hold was
  /// removed — search now lives in the header (see `_buildHeader`), wired
  /// to the exact same `_searchQuery` state and `onChanged` handler. The
  /// four filter dropdowns below (Status, Payment, Type, Sort) are
  /// completely unchanged — only the row/column layout that used to share
  /// space with the search field was simplified to fill that space
  /// instead. The panel's corner radius/border/shadow matches the Menu
  /// screen's card treatment (`_OrdersTheme.softShadow`).
  ///
  /// FEATURE PASS 9: a divider and the new "Time Range" block
  /// (`_buildTimeRangeSection`) were appended at the bottom of this panel.
  /// Everything above them is unchanged.
  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _OrdersTheme.paleRose,
          width: 1,
        ),
        boxShadow: _OrdersTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _OrdersTheme.blushTint,
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
            Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
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
                  child: _buildDropdown(
                      _sortOrder,
                      [
                        'Newest First',
                        'Oldest First',
                      ],
                      (v) => setState(() => _sortOrder = v!)),
                ),
              ],
            ),

          // ── FEATURE PASS 9: Time Range ──────────────────────────────────
          const SizedBox(height: 22),
          const Divider(height: 1, thickness: 1, color: _OrdersTheme.paleRose),
          const SizedBox(height: 22),
          _buildTimeRangeSection(isMobile),
        ],
      ),
    );
  }

  /// FEATURE PASS 9: the "Time Range" block — a labelled row of quick-pick
  /// chips, an optional custom "Last [N] [unit]" input, and an info pill
  /// showing the exact moment the active range starts from.
  ///
  /// FEATURE PASS 13: that info pill (the golden "Orders since ..." box)
  /// is now only shown when `_hasOrdersInTimeRange` is true — i.e. when at
  /// least one order actually falls inside the selected range. If the
  /// range has zero matching orders, the pill stays hidden entirely, the
  /// same as if no range were picked. Everything else in this block —
  /// chips, the custom-duration input, the cut-off calculation itself — is
  /// unchanged.
  Widget _buildTimeRangeSection(bool isMobile) {
    final cutoff = _timeCutoff;
    final isCustom = _timeFilter == 'Custom';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _OrdersTheme.blushTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: _OrdersTheme.milanoRed,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Time Range',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _OrdersTheme.milanoRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // FEATURE PASS 11: every time range is now its OWN box (card), still
        // on a single line. The row scrolls sideways (touch, trackpad or
        // mouse drag) when the screen is too narrow to show all nine boxes.
        // The bottom padding leaves room for each box's soft shadow.
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 14),
            child: Row(
              children: [
                for (int i = 0; i < _timeFilterOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _timeChip(_timeFilterOptions[i]),
                ],
              ],
            ),
          ),
        ),
        if (isCustom) ...[
          const SizedBox(height: 4),
          _buildCustomTimeInput(),
        ],
        // FEATURE PASS 13: the golden "Orders since ..." pill now also
        // requires `_hasOrdersInTimeRange` to be true — it no longer shows
        // for a range with zero matching orders. The cut-off value itself
        // and its formatting are unchanged.
        if (cutoff != null && _hasOrdersInTimeRange) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _OrdersTheme.lemonChiffon.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _OrdersTheme.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_toggle_off_rounded,
                  size: 14,
                  color: _OrdersTheme.milanoRed,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Orders since ${DateFormat('dd MMM yyyy, hh:mm a').format(cutoff)}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _OrdersTheme.milanoRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// FEATURE PASS 9: a single selectable time-range chip.
  ///
  /// FEATURE PASS 11: now a standalone rounded box (card). Unselected boxes
  /// are white with a Pale Rose border and a soft shadow; the selected box
  /// fills with the Deep Wine Maroon gradient, gets a warm-gold border and a
  /// maroon glow. Every box carries a small icon badge before its label.
  Widget _timeChip(String label) {
    final isSelected = _timeFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _timeFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _OrdersTheme.milanoRed,
                      _OrdersTheme.milanoRedLight,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _OrdersTheme.gold.withValues(alpha: 0.7)
                  : _OrdersTheme.paleRose,
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _OrdersTheme.milanoRed.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: _OrdersTheme.milanoRedDark.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : _OrdersTheme.blushTint,
                ),
                child: Icon(
                  _timeChipIcon(label),
                  size: 15,
                  color: isSelected
                      ? _OrdersTheme.lemonChiffon
                      : _OrdersTheme.milanoRed,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// FEATURE PASS 11: the icon shown inside each time-range box.
  IconData _timeChipIcon(String label) {
    switch (label) {
      case 'Last 1 Hour':
        return Icons.timer_outlined;
      case 'Last 6 Hours':
        return Icons.hourglass_bottom_rounded;
      case 'Last 12 Hours':
        return Icons.hourglass_top_rounded;
      case 'Today':
        return Icons.today_rounded;
      case 'Last 1 Day':
        return Icons.calendar_today_rounded;
      case 'Last 1 Week':
        return Icons.date_range_rounded;
      case 'Last 1 Month':
        return Icons.calendar_month_rounded;
      case 'Custom':
        return Icons.tune_rounded;
      default:
        return Icons.all_inclusive_rounded;
    }
  }

  /// FEATURE PASS 9: the "Last [N] [Minutes / Hours / Days]" input that
  /// appears when the "Custom" chip is selected. Digits only, max 4 digits;
  /// an empty or zero value simply applies no time restriction.
  Widget _buildCustomTimeInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Last',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _OrdersTheme.mutedTaupe,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 96,
          child: TextField(
            controller: _customTimeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (v) =>
                setState(() => _customTimeValue = int.tryParse(v) ?? 0),
            cursorColor: _OrdersTheme.milanoRed,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 3',
              hintStyle: GoogleFonts.inter(color: _OrdersTheme.mutedTaupe),
              filled: true,
              fillColor: _OrdersTheme.canvasDeep.withValues(alpha: 0.5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _OrdersTheme.paleRose),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _OrdersTheme.milanoRed,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: _buildDropdown(
              _customTimeUnit,
              _customTimeUnits,
              (v) => setState(() => _customTimeUnit = v!),
            ),
          ),
        ),
      ],
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
        color: _OrdersTheme.canvasDeep.withValues(alpha: 0.5),
        border: Border.all(color: _OrdersTheme.paleRose),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _OrdersTheme.milanoRed,
          ),
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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _OrdersTheme.paleRose),
          boxShadow: _OrdersTheme.softShadow,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 44,
                color: _OrdersTheme.milanoRed.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 12),
              Text(
                'No orders found',
                style: GoogleFonts.inter(
                  color: _OrdersTheme.mutedTaupe,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: _OrdersTheme.softShadow,
        border: Border.all(
          color: o.id == _highlightedOrderId
              ? _OrdersTheme.gold
              : _OrdersTheme.paleRose,
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
                  color: _OrdersTheme.milanoRedDark,
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
          const Divider(height: 24, color: _OrdersTheme.paleRose),
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
                        color: _OrdersTheme.mutedTaupe,
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
                      color: _OrdersTheme.mutedTaupe,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${o.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _OrdersTheme.milanoRedDark,
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
                  backgroundColor: _OrdersTheme.blushTint,
                  foregroundColor: _OrdersTheme.milanoRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _OrdersTheme.paleRose,
          width: 1,
        ),
        boxShadow: _OrdersTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                      color:
                          _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.65),
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
                                color: _OrdersTheme.milanoRedDark,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // PASS 8: the order-type chip now uses the
                            // PUREDINE Dusty Blush icon-BG with maroon
                            // text instead of the old pale blue — same
                            // text/value, decoration only.
                            _badge(
                              o.orderType.replaceAll('_', '-'),
                              _OrdersTheme.blushTint,
                              _OrdersTheme.milanoRed,
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
                              decoration: const BoxDecoration(
                                color: _OrdersTheme.canvasDeep,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: _OrdersTheme.milanoRed,
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
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: _OrdersTheme.mutedTaupe,
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
                            color: _OrdersTheme.milanoRedDark,
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
                            color: _OrdersTheme.mutedTaupe,
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
                              borderRadius: BorderRadius.circular(8),
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
      bg = _OrdersTheme.mintBg;
      text = _OrdersTheme.successGreen;
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
      bg = _OrdersTheme.mintBg;
      text = _OrdersTheme.successGreen;
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
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: _OrdersTheme.milanoRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
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
                          color: _OrdersTheme.lemonChiffonSoft,
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
                        color: _OrdersTheme.mutedTaupe,
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
                        color: _OrdersTheme.mutedTaupe,
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
                        fillColor: _OrdersTheme.canvasDeep,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(height: 64, color: _OrdersTheme.paleRose),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Total',
                          style: GoogleFonts.inter(
                            color: _OrdersTheme.mutedTaupe,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${widget.order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            color: _OrdersTheme.mutedTaupe,
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
                            color: _OrdersTheme.milanoRedDark,
                          ),
                        ),
                        Text(
                          '₹${_grandTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _OrdersTheme.milanoRedDark,
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
              color:
                  isSelected ? _OrdersTheme.milanoRed : _OrdersTheme.paleRose,
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
                color: isSelected
                    ? _OrdersTheme.milanoRed
                    : _OrdersTheme.mutedTaupe,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? _OrdersTheme.milanoRed
                      : _OrdersTheme.mutedTaupe,
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
          color: isSelected ? _OrdersTheme.milanoRed : _OrdersTheme.canvasDeep,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${percentage.toInt()}%',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : _OrdersTheme.mutedTaupe,
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
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: _OrdersTheme.gold.withValues(alpha: 0.4), width: 1.2),
      ),
      elevation: 20,
      clipBehavior: Clip.antiAlias,
      backgroundColor: _OrdersTheme.canvas,
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
            // Header — FEATURE PASS 12: the branded wine-gradient top bar,
            // same language as the Orders screen header (gold accent dots,
            // white→gold ShaderMask title, gold hairline, faint watermark
            // emblem, warm-gold corner glow and a glass sheen).
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _OrdersTheme.headerGradient,
                border: Border(
                  bottom: BorderSide(
                    color: _OrdersTheme.lemonChiffon.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRect(
                        child: Stack(
                          children: [
                            Positioned(
                              top: -70,
                              right: -50,
                              child: Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      _OrdersTheme.lemonChiffon
                                          .withValues(alpha: 0.16),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -14,
                              bottom: -18,
                              child: Icon(
                                Icons.receipt_long_rounded,
                                size: 130,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.06),
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 22, 16, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (i) => Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _OrdersTheme.lemonChiffon
                                            .withValues(
                                          alpha: i == 2 ? 0.95 : 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    _OrdersTheme.lemonChiffon,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Order Details',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 600
                                            ? 22
                                            : 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Review and manage this order',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: 46,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      _OrdersTheme.lemonChiffon
                                          .withValues(alpha: 0.95),
                                      _OrdersTheme.lemonChiffon
                                          .withValues(alpha: 0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.14),
                            border: Border.all(
                              color: _OrdersTheme.lemonChiffon
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body — cream canvas with the same soft ambient glows the
            // Orders screen uses, behind the scrolling content.
            Flexible(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          Positioned(
                            top: -60,
                            right: -60,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _OrdersTheme.lemonChiffon
                                        .withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -80,
                            left: -70,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _OrdersTheme.milanoRed
                                        .withValues(alpha: 0.06),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 120,
                            right: -70,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _OrdersTheme.blushTint
                                        .withValues(alpha: 0.45),
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Summary Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, _OrdersTheme.canvasDeep],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _OrdersTheme.paleRose,
                              width: 1,
                            ),
                            boxShadow: _OrdersTheme.softShadow,
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
                              children: children
                                  .map((c) => Expanded(child: c))
                                  .toList(),
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
                                ? _OrdersTheme.successGreen
                                : _OrdersTheme.mutedTaupe,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, _OrdersTheme.canvasDeep],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _OrdersTheme.paleRose,
                              width: 1,
                            ),
                            boxShadow: _OrdersTheme.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_currentOrder.status.toUpperCase() ==
                                  'PAID') ...[
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final useVertical =
                                        constraints.maxWidth < 450;
                                    final buttons = [
                                      _actionButton(
                                        context,
                                        'Print Receipt',
                                        Icons.print,
                                        _OrdersTheme.milanoRedDarkest,
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
                                        _OrdersTheme.milanoRedDark,
                                        () {
                                          final restaurantName = context
                                                  .read<RestaurantProvider>()
                                                  .restaurant
                                                  ?.name ??
                                              'RESTAURANT';
                                          _handleDownload(
                                              context, restaurantName);
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
                                    final useVertical =
                                        constraints.maxWidth < 550;

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
                                          _OrdersTheme.milanoRedDarkest,
                                          () {
                                            final restaurantName = context
                                                    .read<RestaurantProvider>()
                                                    .restaurant
                                                    ?.name ??
                                                'RESTAURANT';
                                            _handlePrint(
                                                context, restaurantName);
                                          },
                                        ),
                                        _actionButton(
                                          context,
                                          'Download Receipt',
                                          Icons.file_download,
                                          _OrdersTheme.milanoRedDark,
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
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Icon(_getButtonIcon(),
                                                  size: 20),
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                      color: _OrdersTheme.milanoRedDarkest,
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
                                  color: _OrdersTheme.mutedTaupe,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Divider(
                            thickness: 1, color: _OrdersTheme.paleRose),
                        const SizedBox(height: 24),

                        // Bill Details
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, _OrdersTheme.canvasDeep],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _OrdersTheme.paleRose,
                              width: 1,
                            ),
                            boxShadow: _OrdersTheme.softShadow,
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
                            color: _OrdersTheme.mutedTaupe,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Items Table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _OrdersTheme.paleRose,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _OrdersTheme.softShadow,
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
                                    top: Radius.circular(17),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 3, child: _tableHeader('Item')),
                                    Expanded(
                                      child: Center(child: _tableHeader('Qty')),
                                    ),
                                    Expanded(
                                      child:
                                          Center(child: _tableHeader('Price')),
                                    ),
                                    Expanded(
                                      child:
                                          Center(child: _tableHeader('Total')),
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
                                      top: BorderSide(
                                        color: _OrdersTheme.canvasDeep,
                                      ),
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
                                            color:
                                                _OrdersTheme.milanoRedDarkest,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            item.quantity.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: _OrdersTheme.mutedTaupe,
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
                                                color: _OrdersTheme.mutedTaupe,
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
                                                color: _OrdersTheme
                                                    .milanoRedDarkest,
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
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _OrdersTheme.gold.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: _OrdersTheme.softShadow,
                          ),
                          child: Column(
                            children: [
                              _priceRow(
                                'Subtotal',
                                _currentOrder.displaySubtotal
                                    .toStringAsFixed(0),
                              ),
                              if ((_currentOrder.taxAmount ?? 0) > 0) ...[
                                const SizedBox(height: 12),
                                _priceRow(
                                  'Tax',
                                  _currentOrder.taxAmount!.toStringAsFixed(0),
                                ),
                              ],
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  height: 1,
                                  color:
                                      _OrdersTheme.gold.withValues(alpha: 0.4),
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
                              _OrdersTheme.blushTint.withValues(alpha: 0.45),
                              _OrdersTheme.milanoRed,
                            );
                            final time = _infoBox(
                              Icons.schedule,
                              'Timestamps',
                              [
                                'Created: ${dateFormat.format(DateTime.tryParse(_currentOrder.createdAt) ?? DateTime.now())}',
                                'Updated: ${_currentOrder.updatedAt != null ? dateFormat.format(DateTime.tryParse(_currentOrder.updatedAt!) ?? DateTime.now()) : "N/A"}',
                              ],
                              _OrdersTheme.mintBg,
                              _OrdersTheme.successGreen,
                            );

                            if (useVertical) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  card,
                                  const SizedBox(height: 16),
                                  time
                                ],
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
                ],
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
    if (s == 'PLACED') return _OrdersTheme.milanoRed; // Deep Wine Maroon
    if (s == 'CONFIRMED') return _OrdersTheme.milanoRedLight; // Wine
    if (s == 'PREPARING') return _OrdersTheme.milanoRedDark; // Burgundy
    if (s == 'READY') return _OrdersTheme.milanoRed; // Deep Wine Maroon
    if (s == 'SERVED') return _OrdersTheme.milanoRedLight; // Wine
    return _OrdersTheme.milanoRedDarkest;
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
        color: _OrdersTheme.milanoRedDarkest.withValues(alpha: 0.75),
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
              color: _OrdersTheme.mutedTaupe,
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
                color: _OrdersTheme.milanoRedDarkest,
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
    Color badgeCol = _OrdersTheme.canvasDeep;
    Color textCol = _OrdersTheme.milanoRedDarkest;

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
        badgeCol = _OrdersTheme.mintBg;
        textCol = _OrdersTheme.successGreen;
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
            color: _OrdersTheme.mutedTaupe,
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
              color: _OrdersTheme.milanoRedDarkest,
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
            color: isTotal
                ? _OrdersTheme.milanoRedDarkest
                : _OrdersTheme.mutedTaupe,
          ),
        ),
        Text(
          '₹$value',
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w900,
            color: isTotal
                ? _OrdersTheme.milanoRedDark
                : _OrdersTheme.milanoRedDarkest,
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
