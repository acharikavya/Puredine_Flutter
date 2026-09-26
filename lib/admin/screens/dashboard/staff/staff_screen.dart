import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/staff_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local screen palette — matches AdminDashboardScreen, MenuScreen,
/// OrdersScreen, TablesScreen, and StaffLandingScreen exactly, so this
/// screen reads as part of the same consistent brand instead of its own
/// one-off theme. Used ONLY for this screen's restyle. Nothing here touches
/// AppColors or any other file — pure UI enhancement, no logic changed
/// anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a large faint watermark emblem, and a fine glass highlight
/// line along the top edge) matching the Orders / Admin Dashboard /
/// staff-landing screens' Pass-2 treatment, and the full-screen backdrop
/// gained an extra diagonal sheen plus a secondary ambient glow for more
/// depth. The stat cards picked up a slim color-coded top cap so each
/// figure has its own subtle identity at a glance, matching the Orders
/// screen's stat boxes. No provider/service calls, dialogs, filtering,
/// toggle/delete logic, or table rendering logic was touched anywhere in
/// this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 3: two purely presentational changes — zero changes
/// to any provider/service call, dialog, filtering, search, toggle/delete
/// logic, table rendering, or navigation target anywhere in this file.
///   1. HEADER: `_buildHeader()` was rebuilt from the old dark four-stop
///      maroon "command bar" into a flat, standard-mobile-app top bar — a
///      plain white bar with a soft bottom border/shadow, the same
///      back-chevron control and "add staff" icon button as before (same
///      `context.go('/admin/staff')` / `_showAddDialog` callbacks, only
///      restyled), the role title as a two-tone maroon→gold `ShaderMask`,
///      the same date text and subtitle as before, and a thin gold
///      underline accent.
///   2. PALETTE: `canvas` was brightened to a true, near-white tone.
///
/// UI-ENHANCEMENT PASS 4: presentation-only, exactly like every pass
/// above — no provider/service call, dialog, filtering, search,
/// toggle/delete logic, table rendering, or navigation target anywhere in
/// this file was touched, and no field, callback, route, or keyword was
/// renamed.
///   1. PALETTE — full PUREDINE mapping: every field name inside
///      `_Palette` is unchanged on purpose (every widget in this file
///      already reads from these exact names, so swapping only the
///      underlying `Color` values re-skins the whole screen with no other
///      code touched):
///        • `milanoRed`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `milanoRedLight`   → Wine `#813244` (topbar lighter gradient)
///        • `milanoRedDeep`    → Burgundy `#8A183F` (primary accent)
///        • `milanoRedDarkest` → Deep Brown/Black `#2E0D16`
///        • `canvas`           → Warm Off-White `#FBF8F5` (main background)
///        • `canvasDeep`       → Soft Cream `#F7F1ED` (card background)
///        • `lemonChiffon`     → Warm Gold `#F3C564` (gold accent)
///        • `lemonChiffonDeep` → deeper gold `#D9A421` (derived companion)
///        • `textDark`         → Deep Brown/Black `#2E0D16`
///        • `textMuted`        → Muted Taupe `#9B707A`
///        • `success`          → Fresh Green `#44AF70`
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so delete/error states stay legible.
///      Four supporting PUREDINE tones were ADDED as new fields — nothing
///      existing was removed — `dustyBlush` (`#F3D9DC`, icon backgrounds),
///      `paleRose` (`#EFD7DA`, card borders), `softYellow` (`#FCE1AB`,
///      gold highlight) and `paleMint` (`#EAF6EF`, success backgrounds).
///      `headerGradient` now holds the supplied header gradient exactly
///      (`#742A3C → #813244`), and a new `ctaGradient` field holds the
///      supplied CTA gradient exactly (`#6E1832 → #9B3E4E → #F3C564`) —
///      unused elsewhere in this file today, added only so the palette
///      matches the other admin screens' `_Palette` shape.
///   2. TOP BAR: `_buildHeader()` is no longer a flat white bar — it now
///      carries the PUREDINE Deep Wine Maroon → Wine diagonal gradient, a
///      medium-depth (not near-black) maroon band running the full width
///      of the screen. It gained the same ambient dressing the other admin
///      headers use — a soft warm-gold corner glow, a large very faint
///      watermark emblem, and a subtle diagonal glass sheen — plus a
///      warm-gold hairline along its bottom edge. Structurally nothing
///      inside changed: the same back-chevron control (still
///      `context.go('/admin/staff')`), the same two-tone `ShaderMask`
///      title, the same desktop-only date text, the same subtitle copy,
///      the same thin gold underline accent, and the exact same circular
///      "add staff" icon button (still `_showAddDialog`). Only the copy's
///      colors changed (white / soft-gold instead of maroon / taupe), and
///      the back-chevron button was restyled from its Pass-3 maroon-on-
///      white "glass" look back to a light glass-on-wine treatment so it
///      reads clearly against the new dark backdrop — its `onTap` callback
///      is completely unchanged.
///   3. TOP-TO-BOTTOM CONSISTENCY: so the whole screen reads as one brand
///      rather than just a re-colored header, the stat cards, filter bar,
///      staff table/cards, and empty state all use the Pale Rose border
///      and Soft Cream tints, small icon containers use the Dusty Blush
///      icon-BG, and an extra soft blush glow was added low in the
///      backdrop so the bottom of a long scroll keeps the same warm tint
///      as the top.
///
/// UI-ENHANCEMENT PASS 5 (this pass): RESPONSIVE LAYOUT + TABLET/LAPTOP
/// POLISH ONLY. No provider/service call, dialog, filtering, search,
/// toggle/delete logic, table rendering logic, field, callback, route, or
/// keyword anywhere in this file was touched or renamed.
///   1. BREAKPOINTS: the screen previously only understood two sizes
///      (`isMobile` true/false, split at 800px), so a real tablet
///      (~700–1100px) fell awkwardly between the two. `build()` now
///      computes three tiers — `isMobile` (<700), `isTablet`
///      (700–1099), `isDesktop` (≥1100) — and threads `isTablet` down
///      into `_buildHeader`, `_buildStatsRow`, `_buildStatCard`,
///      `_buildFiltersBar`, `_buildStaffList`, and
///      `_buildStaffMobileCard` as a new *optional, defaulted* parameter,
///      so every existing call site and every existing behaviour keeps
///      working exactly as before.
///   2. TABLET LIST: the six-column staff table was cramped below
///      ~1100px, so tablet widths now reuse the exact same per-member
///      card widget the phone layout already uses (`_buildStaffMobileCard`
///      — identical data, identical edit/delete/toggle callbacks), laid
///      out as a two-column `Wrap` instead of one long column, so tablets
///      get a proper grid instead of a squeezed table or an empty-feeling
///      single column.
///   3. FIT-AND-FINISH: header padding/title size, stat-card padding and
///      value size, page padding, and card padding now step through
///      mobile → tablet → desktop instead of jumping straight from phone
///      sizing to desktop sizing, and the stat-card label got
///      `maxLines`/`overflow` protection so it can never wrap awkwardly
///      at in-between widths. Purely cosmetic sizing — no widget was
///      removed, reordered, or given new behaviour.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  // PUREDINE Maroon + Cream — field names unchanged on purpose (see the
  // PASS 4 note above); only the underlying Color values changed.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedDeep =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color milanoRedDarkest = Color(0xFF2E0D16); // Deep Brown/Black

  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color lemonChiffonDeep =
      Color(0xFFD9A421); // Deeper Warm Gold (derived)

  static const Color canvas =
      Color(0xFFFBF8F5); // Warm Off-White (Main background)
  static const Color canvasDeep = Color(0xFFF7F1ED); // Soft Cream (Card bg)
  static const Color cardWhite = Colors.white;

  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black text
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color success = Color(0xFF44AF70); // Fresh Green
  static const Color danger = Color(0xFFE0323F); // Clear alert red

  // PASS 4: four supporting PUREDINE tones added — nothing above this
  // line was removed; these are new fields only.
  static const Color dustyBlush =
      Color(0xFFF3D9DC); // Dusty Blush — icon backgrounds
  static const Color paleRose = Color(0xFFEFD7DA); // Pale Rose — card borders
  static const Color softYellow = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color paleMint = Color(0xFFEAF6EF); // Pale Mint background

  /// The supplied top-header gradient, exactly: `#742A3C → #813244`.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRed, milanoRedLight],
  );

  /// The supplied CTA gradient, exactly: `#6E1832 → #9B3E4E → #F3C564`.
  /// Kept defined for palette-shape parity with the other admin screens;
  /// not referenced elsewhere in this file today, so an unused private
  /// static field here causes no compile error.
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), lemonChiffon],
  );

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on MenuScreen/ProfileScreen/StaffLandingScreen.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// A slightly stronger, warmer shadow used for elevated/hero elements.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: lemonChiffonDeep.withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.10),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}

class StaffScreen extends StatefulWidget {
  /// 'server' for Serving Staff, 'cashier' for Billing Staff
  final String role;
  const StaffScreen({super.key, required this.role});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<StaffMember> _allStaff = [];
  List<StaffMember> _filteredStaff = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _statusFilter = 'All Status';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  static const List<String> _monthNames = [
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
    return '${_monthNames[now.month - 1]} ${now.day}, ${now.year}';
  }

  String get _roleLabel =>
      widget.role == 'server' ? 'Serving Staff' : 'Billing Staff';
  String get _roleSubtitle => widget.role == 'server'
      ? 'Manage floor staff and service assignments'
      : 'Manage cashier terminals and transaction logs';

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final list = await StaffService.getStaff();

      setState(() {
        _allStaff = list.where((s) {
          final r = s.role.toLowerCase().trim();
          if (widget.role == 'server') {
            return r == 'serving_staff' ||
                r == 'server' ||
                r.contains('serv') ||
                r == 'waiter';
          } else {
            return r == 'billing_staff' ||
                r == 'cashier' ||
                r.contains('bill') ||
                r.contains('cash');
          }
        }).toList();
        _applyFilters();
      });
    } catch (e) {
      // Error ignored
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStaff = _allStaff.where((s) {
        final matchesSearch = s.name.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query);
        final matchesStatus = _statusFilter == 'All Status' ||
            (_statusFilter == 'Active' && s.isActive) ||
            (_statusFilter == 'Inactive' && !s.isActive);
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _toggleStaff(String id) async {
    try {
      await StaffService.toggleStaff(id);
      _loadStaff();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _deleteStaff(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _Palette.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _Palette.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: _Palette.danger,
            size: 26,
          ),
        ),
        title: Text(
          'Delete Staff Member',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _Palette.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this staff member? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // NOTE: the two buttons are wrapped in a single Row (instead of
        // being passed to `actions` as separate Expanded items) because
        // AlertDialog renders its `actions` list inside an internal
        // OverflowBar, which does not provide the FlexParentData that
        // Expanded needs — passing Expanded directly as an actions item
        // throws "Incorrect use of ParentDataWidget". Wrapping them in one
        // Row (itself a proper Flex) as the single actions item keeps the
        // exact same equal-width, 10px-gapped button layout without the
        // crash.
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    side: const BorderSide(color: _Palette.paleRose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.danger,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await StaffService.deleteStaff(id);
        _loadStaff();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  /// Computes a dialog content width that always fits the current screen.
  /// Desktop/tablet gets the original fixed 520px width; on narrow phones
  /// the width shrinks to (screen width − outer insets) so the dialog never
  /// overflows, and so the LayoutBuilder inside actually receives the real
  /// available width and can correctly switch to the stacked mobile layout.
  double _dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const outerInset = 48.0; // matches insetPadding horizontal (24 + 24)
    if (screenWidth < 560) {
      return (screenWidth - outerInset).clamp(240.0, 520.0);
    }
    return 520.0;
  }

  void _showAddDialog() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    _phoneCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _Palette.cardWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        icon: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: _Palette.dustyBlush,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: _Palette.milanoRed,
            size: 26,
          ),
        ),
        title: Text(
          'Add $_roleLabel',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRed,
          ),
        ),
        // Wider, rectangular layout on larger screens — fields are paired
        // side-by-side so the card reads as a broad rectangle instead of a
        // tall, narrow strip. On phones, the width is derived from the
        // actual screen size (see _dialogWidth) so it always fits, and the
        // LayoutBuilder below correctly detects the narrow width and stacks
        // the fields into a single column instead of overflowing.
        content: SizedBox(
          width: _dialogWidth(ctx),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _dialogField(
                            _nameCtrl,
                            'Full Name',
                            Icons.badge_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _emailCtrl,
                            'Email',
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _phoneCtrl,
                            'Phone Number',
                            Icons.phone_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _passCtrl,
                            'Password',
                            Icons.lock_outline,
                            obscure: true,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _dialogField(
                                _nameCtrl,
                                'Full Name',
                                Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dialogField(
                                _emailCtrl,
                                'Email',
                                Icons.email_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _dialogField(
                                _phoneCtrl,
                                'Phone Number',
                                Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dialogField(
                                _passCtrl,
                                'Password',
                                Icons.lock_outline,
                                obscure: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        // NOTE: the two buttons are wrapped in a single Row (instead of
        // being passed to `actions` as separate Expanded items) because
        // AlertDialog renders its `actions` list inside an internal
        // OverflowBar, which does not provide the FlexParentData that
        // Expanded needs — passing Expanded directly as an actions item
        // throws "Incorrect use of ParentDataWidget". Wrapping them in one
        // Row (itself a proper Flex) as the single actions item keeps the
        // exact same equal-width, 10px-gapped button layout without the
        // crash.
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    side: const BorderSide(color: _Palette.paleRose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.milanoRed,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await StaffService.createStaff({
                        'name': _nameCtrl.text,
                        'email': _emailCtrl.text,
                        'password': _passCtrl.text,
                        'phone': _phoneCtrl.text,
                        'role': widget.role == 'server'
                            ? 'SERVING_STAFF'
                            : 'BILLING_STAFF',
                      });
                      _loadStaff();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    }
                  },
                  child: Text(
                    'Add',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Edit dialog — mirrors `_showAddDialog` exactly in styling and layout
  /// (including the same responsive mobile-safe width/stacking behaviour),
  /// but pre-fills the existing staff member's details and saves via
  /// `StaffService.updateStaff` instead of `createStaff`. The password
  /// field is optional here — leaving it blank keeps the current password.
  ///
  /// NOTE: this assumes `StaffService` exposes an `updateStaff(id, data)`
  /// method mirroring the existing `createStaff(data)` method. That service
  /// file wasn't part of this screen, so if `updateStaff` doesn't exist yet
  /// it needs to be added there alongside `createStaff`/`deleteStaff`.
  void _showEditDialog(StaffMember s) {
    _nameCtrl.text = s.name;
    _emailCtrl.text = s.email;
    _phoneCtrl.text = s.phone ?? '';
    _passCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _Palette.cardWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        icon: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: _Palette.dustyBlush,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: _Palette.milanoRed,
            size: 26,
          ),
        ),
        title: Text(
          'Edit $_roleLabel',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRed,
          ),
        ),
        content: SizedBox(
          width: _dialogWidth(ctx),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _dialogField(
                            _nameCtrl,
                            'Full Name',
                            Icons.badge_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _emailCtrl,
                            'Email',
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _phoneCtrl,
                            'Phone Number',
                            Icons.phone_outlined,
                          ),
                          const SizedBox(height: 14),
                          _dialogField(
                            _passCtrl,
                            'New Password (optional)',
                            Icons.lock_outline,
                            obscure: true,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _dialogField(
                                _nameCtrl,
                                'Full Name',
                                Icons.badge_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dialogField(
                                _emailCtrl,
                                'Email',
                                Icons.email_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _dialogField(
                                _phoneCtrl,
                                'Phone Number',
                                Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dialogField(
                                _passCtrl,
                                'New Password (optional)',
                                Icons.lock_outline,
                                obscure: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
        // NOTE: the two buttons are wrapped in a single Row (instead of
        // being passed to `actions` as separate Expanded items) because
        // AlertDialog renders its `actions` list inside an internal
        // OverflowBar, which does not provide the FlexParentData that
        // Expanded needs — passing Expanded directly as an actions item
        // throws "Incorrect use of ParentDataWidget". Wrapping them in one
        // Row (itself a proper Flex) as the single actions item keeps the
        // exact same equal-width, 10px-gapped button layout without the
        // crash.
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    side: const BorderSide(color: _Palette.paleRose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.milanoRed,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final updateData = {
                        'name': _nameCtrl.text,
                        'email': _emailCtrl.text,
                        'phone': _phoneCtrl.text,
                        'role': widget.role == 'server'
                            ? 'SERVING_STAFF'
                            : 'BILLING_STAFF',
                      };
                      // Only send a password if the user actually typed a
                      // new one — leaving it blank keeps the existing
                      // password.
                      if (_passCtrl.text.trim().isNotEmpty) {
                        updateData['password'] = _passCtrl.text;
                      }
                      await StaffService.updateStaff(s.id, updateData);
                      _loadStaff();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    }
                  },
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.inter(color: _Palette.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: _Palette.milanoRed),
        labelStyle: GoogleFonts.inter(color: _Palette.textMuted),
        filled: true,
        fillColor: _Palette.canvasDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _Palette.milanoRed, width: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // PASS 5 — RESPONSIVE LAYOUT: three-tier breakpoint system (mobile /
    // tablet / laptop-desktop) replaces the old single isMobile flag, so
    // every section below can size itself correctly for tablets and
    // laptops instead of snapping straight from "mobile" to "desktop" at
    // one cutoff. Presentation only — no provider/service call, dialog,
    // filtering, toggle/delete logic, table rendering logic, or
    // navigation target was touched anywhere in this file.
    final width = size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;
    final isDesktop = width >= 1100;
    final mediaQuery = MediaQuery.of(context);

    // Extra bottom inset (home indicator / gesture bar) so the scrollable
    // content never sits flush under the device's safe-area edge — mirrors
    // the same treatment used on MenuScreen/AdminDashboardScreen.
    final double bottomSafePad = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Column(
        children: [
          // ── Header Section ───────────────────────────────────────────────
          // Fixed at the top, exactly like MenuScreen/AdminDashboardScreen —
          // it no longer scrolls away with the content beneath it.
          _buildHeader(isMobile, isTablet: isTablet),

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────
                // Purely decorative — soft gold/wine glows plus a faint
                // textured photograph, matching the rest of the admin app's
                // "foggy" backdrop so this screen feels like one cohesive
                // brand.
                Positioned.fill(
                  child: Container(
                    color: _Palette.canvas,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -70,
                          right: -60,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.lemonChiffon.withValues(
                                    alpha: 0.30,
                                  ),
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
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.milanoRed.withValues(alpha: 0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 240,
                          right: -120,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.lemonChiffonDeep.withValues(
                                    alpha: 0.10,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // UI-ENHANCEMENT PASS 2: extra low, wide glow
                        // further down the page — gives the staff table
                        // area a second soft focal point instead of all
                        // the ambient light sitting only near the header.
                        // Matches the Orders / Admin Dashboard screens'
                        // Pass-2 backdrop.
                        Positioned(
                          top: 620,
                          left: -100,
                          child: Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.milanoRedLight.withValues(
                                    alpha: 0.06,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // PASS 4: a soft blush glow low on the right, so
                        // the bottom of a long scroll carries the same
                        // warm brand tint as the top instead of fading to
                        // flat white. Purely decorative.
                        Positioned(
                          bottom: 40,
                          right: -70,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.dustyBlush.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.035,
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

                // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping
                // across the body — a subtle extra layer of depth so the
                // cream backdrop doesn't read as flat behind the header,
                // echoing the glass-highlight language used in the header
                // itself.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.26),
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
                // MenuScreen: a SingleChildScrollView centered with a max
                // width, instead of the header scrolling away inside a
                // CustomScrollView.
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _Palette.milanoRed,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 16 : (isTablet ? 28 : 40),
                          28,
                          isMobile ? 16 : (isTablet ? 28 : 40),
                          100 + bottomSafePad, // Extra bottom padding
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 1200 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsRow(isMobile, isTablet: isTablet),
                                const SizedBox(height: 24),
                                _buildFiltersBar(isMobile, isTablet: isTablet),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: _Palette.milanoRed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Showing ${_filteredStaff.length} members',
                                      style: GoogleFonts.inter(
                                        color: _Palette.textMuted,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildStaffList(isMobile, isTablet: isTablet),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PASS 3 rebuilt this into a flat, standard-mobile-app top bar.
  ///
  /// PASS 4: the same bar now carries the PUREDINE Deep Wine Maroon →
  /// Wine gradient (`#742A3C → #813244`) instead of flat white — a
  /// medium-depth maroon top bar spanning the full width of the screen,
  /// with a soft warm-gold corner glow, a large very faint watermark
  /// emblem behind the copy, a subtle diagonal glass sheen, and a
  /// warm-gold hairline along the bottom edge. Structurally identical to
  /// before: the same back-chevron control (still
  /// `context.go('/admin/staff')`), the same two-tone `ShaderMask` title,
  /// the same desktop-only date text, the same subtitle copy, the same
  /// thin gold underline accent, and the exact same circular "add staff"
  /// icon button (still `_showAddDialog`). Only the copy's colors changed
  /// so it reads clearly on the wine backdrop. No navigation, dialog, or
  /// any other logic was touched — presentation only.
  ///
  /// PASS 5: accepts an optional `isTablet` flag so title size and
  /// padding can step through mobile → tablet → desktop instead of
  /// jumping straight from phone sizing to desktop sizing. Same
  /// structure, same callbacks, same content — sizing only.
  Widget _buildHeader(bool isMobile, {bool isTablet = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _Palette.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: _Palette.lemonChiffon.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Ambient dressing for the wine backdrop — a soft warm-gold
          // corner glow, a large very faint watermark emblem behind the
          // copy, and a diagonal glass sheen. Purely decorative, clipped
          // to the header's own bounds.
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
                              _Palette.lemonChiffon.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: isMobile ? -22 : -14,
                      bottom: isMobile ? -20 : -16,
                      child: Icon(
                        Icons.groups_2_rounded,
                        size: isMobile ? 120 : (isTablet ? 138 : 160),
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
                isMobile ? 18 : (isTablet ? 26 : 32),
                isMobile ? 16 : (isTablet ? 20 : 22),
                isMobile ? 18 : (isTablet ? 26 : 32),
                isMobile ? 18 : (isTablet ? 22 : 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — back chevron, the two-tone title, the date
                  // (desktop only), and the "add staff" icon button, all
                  // on one line. No search bar of any kind here.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _backButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              _Palette.lemonChiffon,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            _roleLabel,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: isMobile ? 21 : (isTablet ? 24 : 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isMobile) ...[
                        Text(
                          _todayLabel(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: _Palette.softYellow,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      _addIconButton(),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    _roleSubtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: isMobile ? 12.5 : (isTablet ? 13 : 14),
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  // Thin gold gradient hairline — the same soft divider
                  // language used across the rest of the app's headers.
                  // Purely decorative.
                  Container(
                    width: 46,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.95),
                          _Palette.lemonChiffon.withValues(alpha: 0.15),
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
    );
  }

  Widget _backButton() => _BackChevronButton(
        onTap: () => context.go('/admin/staff'),
      );

  /// Compact circular icon-only "add staff" button, tucked into the top
  /// right corner of the navbar. Same `_showAddDialog` callback as before
  /// — only its look was ever touched. Its gold fill already read clearly
  /// on a white background and reads even more clearly against the new
  /// wine backdrop, so nothing inside it needed to change.
  Widget _addIconButton() {
    return Tooltip(
      message: 'Add $_roleLabel',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _showAddDialog,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Palette.lemonChiffon,
              boxShadow: [
                BoxShadow(
                  color: _Palette.milanoRedDarkest.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 22,
              color: _Palette.milanoRed,
            ),
          ),
        ),
      ),
    );
  }

  /// PASS 5: accepts an optional `isTablet` flag. Mobile keeps its
  /// horizontal-scroll row exactly as before; tablet and desktop share
  /// the same three-across `Row`, with tablet using a tighter 16px gutter
  /// (instead of desktop's 24px) so the cards keep comfortable internal
  /// padding without crowding a narrower tablet width. Same data, same
  /// colors, same icons as before.
  Widget _buildStatsRow(bool isMobile, {bool isTablet = false}) {
    final total = _allStaff.length;
    final active = _allStaff.where((s) => s.isActive).length;
    final inactive = total - active;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard(
              'Total',
              total.toString(),
              _Palette.milanoRed,
              isMobile,
              Icons.groups_2_outlined,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Active',
              active.toString(),
              _Palette.success,
              isMobile,
              Icons.check_circle_outline,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Inactive',
              inactive.toString(),
              _Palette.milanoRedDeep,
              isMobile,
              Icons.pause_circle_outline,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _buildStatCard(
          'Total $_roleLabel',
          total.toString(),
          _Palette.milanoRed,
          false,
          Icons.groups_2_outlined,
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 16 : 24),
        _buildStatCard(
          'Active',
          active.toString(),
          _Palette.success,
          false,
          Icons.check_circle_outline,
          isTablet: isTablet,
        ),
        SizedBox(width: isTablet ? 16 : 24),
        _buildStatCard(
          'Inactive',
          inactive.toString(),
          _Palette.milanoRedDeep,
          false,
          Icons.pause_circle_outline,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    bool isMobile,
    IconData icon, {
    bool isTablet = false,
  }) {
    // Wrapped in a clipped Column with a slim color-coded top cap,
    // matching the Orders screen's stat-card treatment, so each figure
    // carries its own subtle identity at a glance. Same
    // label/value/color/icon inputs as before — purely a frame around
    // the existing card content.
    //
    // PASS 4: the card body now sits on a white → Soft Cream wash with a
    // Pale Rose border, matching the PUREDINE card spec — decoration
    // only, no data changed.
    //
    // PASS 5: padding and value font size now step through mobile →
    // tablet → desktop, and the label gained maxLines/overflow
    // protection so it can never wrap awkwardly at in-between widths —
    // sizing/safety only, no data or callback changed.
    Widget cardContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: color.withValues(alpha: 0.7)),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _Palette.canvasDeep],
              ),
              border: Border.all(color: _Palette.paleRose),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: _Palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: isMobile ? 24 : (isTablet ? 28 : 32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.16),
                        color.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 18 : (isTablet ? 20 : 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return SizedBox(width: 160, child: cardContent);
    }

    return Expanded(child: cardContent);
  }

  /// PASS 5: accepts an optional `isTablet` flag purely to fine-tune the
  /// container's own padding and the gap before the status dropdown;
  /// the mobile stacked layout and the row layout (now shared by tablet
  /// and desktop) are structurally unchanged — same search field, same
  /// status dropdown, same `_applyFilters` wiring.
  Widget _buildFiltersBar(bool isMobile, {bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 14 : 16)),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: isMobile
          ? Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: _Palette.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.inter(color: _Palette.textMuted),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: _Palette.milanoRed,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
                const Divider(color: _Palette.paleRose),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _statusFilter,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: _Palette.milanoRed,
                    ),
                    style: GoogleFonts.inter(color: _Palette.textDark),
                    items: ['All Status', 'Active', 'Inactive']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _statusFilter = v!;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _Palette.dustyBlush,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: _Palette.milanoRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(color: _Palette.textDark),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: GoogleFonts.inter(color: _Palette.textMuted),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _Palette.canvasDeep,
                    border: Border.all(color: _Palette.paleRose),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: _Palette.milanoRed,
                      ),
                      style: GoogleFonts.inter(
                        color: _Palette.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      dropdownColor: _Palette.cardWhite,
                      items: ['All Status', 'Active', 'Inactive']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _statusFilter = v!;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// PASS 5: accepts an optional `isTablet` flag. Mobile keeps its single
  /// scrolling column of cards exactly as before. Tablet now also uses
  /// the same per-member card widget (instead of the six-column table,
  /// which is cramped below ~1100px) laid out as a two-column `Wrap`, so
  /// tablets get a proper grid instead of a squeezed table. Desktop keeps
  /// the exact same table as before. No filtering, toggle/delete, or
  /// navigation logic was touched — only which layout wraps the same
  /// `StaffMember` data.
  Widget _buildStaffList(bool isMobile, {bool isTablet = false}) {
    if (_filteredStaff.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: _Palette.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Palette.paleRose),
          boxShadow: _Palette.softShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: _Palette.dustyBlush,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_outlined,
                  size: 32,
                  color: _Palette.milanoRed.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No members found',
                style: GoogleFonts.inter(
                  color: _Palette.textMuted,
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
        itemCount: _filteredStaff.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _buildStaffMobileCard(_filteredStaff[i]),
      );
    }

    if (isTablet) {
      // Same per-member card as mobile (identical data + callbacks),
      // arranged as a two-column Wrap so tablets get a proper grid
      // instead of the six-column table squeezing to fit, and without
      // forcing a fixed card height (Wrap sizes each card by its own
      // natural content height, so nothing can overflow/clip).
      return LayoutBuilder(
        builder: (ctx, constraints) {
          final cardWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _filteredStaff
                .map(
                  (s) => SizedBox(
                    width: cardWidth,
                    child: _buildStaffMobileCard(s, isTablet: true),
                  ),
                )
                .toList(),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _Palette.lemonChiffon.withValues(alpha: 0.28),
                  _Palette.lemonChiffon.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _headerCell('NAME', 2),
                _headerCell('EMAIL', 3),
                _headerCell('ROLE', 2),
                _headerCell('PHONE', 2),
                _headerCell('STATUS', 1),
                _headerCell('ACTIONS', 1),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredStaff.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: _Palette.paleRose,
            ),
            itemBuilder: (ctx, i) => _buildStaffRow(_filteredStaff[i], i),
          ),
        ],
      ),
    );
  }

  /// PASS 5: accepts an optional `isTablet` flag purely to give the card
  /// slightly more breathing room (20px padding instead of 16px) when
  /// it's used inside the tablet two-column grid from `_buildStaffList`.
  /// Same avatar, same name/email, same phone row, same edit/delete
  /// buttons, same `_toggleStaff`/`_showEditDialog`/`_deleteStaff`
  /// callbacks as before.
  Widget _buildStaffMobileCard(StaffMember s, {bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, _Palette.canvasDeep],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _Palette.lemonChiffonDeep.withValues(alpha: 0.4),
                    width: 1.6,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: _Palette.dustyBlush,
                  child: Text(
                    s.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: _Palette.milanoRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _Palette.textDark,
                      ),
                    ),
                    Text(
                      s.email,
                      style: GoogleFonts.inter(
                        color: _Palette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.isActive,
                onChanged: (v) => _toggleStaff(s.id),
                activeColor: _Palette.milanoRed,
              ),
            ],
          ),
          const Divider(height: 24, color: _Palette.paleRose),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _Palette.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    s.phone ?? '—',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _Palette.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(s),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: _Palette.milanoRed,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteStaff(s.id),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: _Palette.milanoRedDeep,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: _Palette.milanoRedDeep.withValues(alpha: 0.70),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStaffRow(StaffMember s, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _Palette.dustyBlush,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: _Palette.milanoRed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: _Palette.textDark,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Email
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: _Palette.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.email,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _Palette.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Role
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _Palette.milanoRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  _roleLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _Palette.milanoRedDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Phone
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                s.phone ?? '—',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _Palette.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status
          Expanded(
            flex: 1,
            child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: s.isActive,
                  onChanged: (v) => _toggleStaff(s.id),
                  activeThumbColor: _Palette.milanoRed,
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: _Palette.milanoRed,
                    size: 18,
                  ),
                  onPressed: () => _showEditDialog(s),
                ),
                const SizedBox(width: 12),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: _Palette.milanoRedDeep,
                    size: 18,
                  ),
                  onPressed: () => _deleteStaff(s.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing only
/// a plain "‹" glyph. Matches the treatment used on MenuScreen's header for
/// a consistent brand feel across the admin app.
///
/// PASS 3 restyled this for the Pass-3 white header background (a soft
/// maroon-tinted circle with a maroon glyph).
///
/// PASS 4: the header is wine-colored again (see `_buildHeader`), so this
/// button is restyled back to a light "glass" treatment — a translucent
/// white circle with a white "‹" and a warm-gold ring — so it reads
/// clearly against the new dark backdrop, matching the same control used
/// on MenuScreen/OrdersScreen/TablesScreen. The `onTap` callback passed in
/// from `_backButton()` (`context.go('/admin/staff')`) is completely
/// unchanged — only the look changed.
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
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the same accent used on the dashboard, menu,
/// profile, and staff-landing screens so the title treatment matches
/// exactly across the admin app.
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _Palette.lemonChiffon.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
