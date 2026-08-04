import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/core/theme.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/staff_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Dark Maroon / Soft Cream / Gold Glow" palette — matches
/// AdminDashboardScreen, MenuScreen, ProfileScreen, and StaffLandingScreen
/// exactly, so this screen reads as part of the same consistent brand
/// instead of its own one-off theme. Used ONLY for this screen's restyle.
/// Nothing here touches AppColors or any other file — pure UI enhancement,
/// no logic changed anywhere here.
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
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  // Dark Maroon — primary brand color
  static const Color milanoRed = Color(0xFF8B1D1D);
  static const Color milanoRedDeep = Color(0xFF5C1212);
  static const Color milanoRedLight = Color(0xFFA6302B);
  static const Color milanoRedDarkest =
      Color(0xFF350B0B); // Fourth gradient stop

  // Gold Glow — accent color
  static const Color lemonChiffon = Color(0xFFF4C430);
  static const Color lemonChiffonDeep = Color(0xFFD4A017);

  // Soft Cream — canvas / background
  static const Color canvas = Color(0xFFFDF6EC);
  static const Color canvasDeep = Color(0xFFF7ECD9);
  static const Color cardWhite = Colors.white;

  static const Color textDark = Color(0xFF2A1512);
  static const Color textMuted = Color(0xFF8B7F72);
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFC62828);

  // UI-ENHANCEMENT PASS 2: promoted from a flat 2-stop wash to a richer
  // 4-stop diagonal gradient with explicit stops — matches the Orders
  // screen header's "faceted" surface language exactly.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRed, milanoRedDeep, milanoRedDarkest],
    stops: [0.0, 0.38, 0.72, 1.0],
  );

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on MenuScreen/ProfileScreen/StaffLandingScreen.
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
                    side: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                    ),
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
          decoration: BoxDecoration(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: _Palette.milanoRedDeep,
            size: 26,
          ),
        ),
        title: Text(
          'Add $_roleLabel',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRedDeep,
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
                    side: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                    ),
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
          decoration: BoxDecoration(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: _Palette.milanoRedDeep,
            size: 26,
          ),
        ),
        title: Text(
          'Edit $_roleLabel',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRedDeep,
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
                    side: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                    ),
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
        fillColor: _Palette.lemonChiffon.withValues(alpha: 0.18),
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
    final isMobile = size.width < 800;
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
          _buildHeader(isMobile),

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────
                // Purely decorative — soft gold/maroon glows plus a faint
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
                          isMobile ? 16 : 40,
                          28,
                          isMobile ? 16 : 40,
                          100 + bottomSafePad, // Extra bottom padding
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsRow(isMobile),
                                const SizedBox(height: 24),
                                _buildFiltersBar(isMobile),
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
                                _buildStaffList(isMobile),
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

  /// Branded "floating navbar" header — mirrors the exact Pass-2 treatment
  /// used on the Orders / AdminDashboardScreen / MenuScreen headers: a
  /// richer four-stop diagonal gradient, rounded bottom corners, decorative
  /// diagonal ribbon accents, a large faint watermark emblem, a fine glass
  /// highlight line along the very top edge, and a fine dotted texture
  /// strip, plus a matching gold-bordered pill "Back" button and a compact
  /// circular "add staff" icon button tucked in the top right corner.
  /// Purely visual; the navigation and add-staff actions underneath are
  /// unchanged.
  Widget _buildHeader(bool isMobile) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _Palette.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 36),
            bottomRight: Radius.circular(isMobile ? 28 : 36),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.34),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
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
              // matches the dashboard/menu/profile/staff-landing headers
              // for a consistent brand feel).
              Positioned(
                top: -60,
                right: -40,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 260,
                    height: 100,
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
                    width: 230,
                    height: 80,
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
              // Soft gold glow anchored behind the add-staff icon button.
              Positioned(
                top: -30,
                right: 20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Large faint watermark emblem — a unique signature touch
              // this header didn't previously have, sitting low-opacity
              // and large behind the copy, never competing with the
              // title. Matches the Orders / Admin Dashboard hero's Pass-2
              // watermark treatment.
              Positioned(
                right: isMobile ? -22 : -12,
                bottom: isMobile ? -20 : -16,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.groups_2_rounded,
                      size: isMobile ? 120 : 170,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Fine dotted texture accent, matching the app's refined
              // decorative language used across the other admin headers.
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
              // matches the Orders / Admin Dashboard headers' top edge
              // treatment.
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

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 40,
                  isMobile ? 16 : 24,
                  isMobile ? 20 : 40,
                  isMobile ? 20 : 28,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _backButton(),
                              const Spacer(),
                              if (!isMobile) ...[
                                Text(
                                  _todayLabel(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: Colors.white.withValues(
                                      alpha: 0.68,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                                const SizedBox(width: 18),
                              ],
                              _addIconButton(),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _titleBlock(fontSize: isMobile ? 26 : 34),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() => _BackChevronButton(
        onTap: () => context.go('/admin/staff'),
      );

  Widget _titleBlock({required double fontSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _roleLabel,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const _TitleDivider(),
        const SizedBox(height: 10),
        Text(
          _roleSubtitle,
          style: GoogleFonts.inter(
            color: _Palette.lemonChiffon,
            fontSize: fontSize > 30 ? 14 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Compact circular icon-only "add staff" button, tucked into the top
  /// right corner of the navbar — replaces the old full-width pill button.
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
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.4,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 22,
              color: _Palette.milanoRedDeep,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile) {
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
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          'Active',
          active.toString(),
          _Palette.success,
          false,
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          'Inactive',
          inactive.toString(),
          _Palette.milanoRedDeep,
          false,
          Icons.pause_circle_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    bool isMobile,
    IconData icon,
  ) {
    // UI-ENHANCEMENT PASS 2: wrapped in a clipped Column with a slim
    // color-coded top cap, matching the Orders screen's stat-card
    // treatment, so each figure carries its own subtle identity at a
    // glance. Same label/value/color/icon inputs as before — purely a
    // frame around the existing card content.
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
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _Palette.cardWhite,
                  _Palette.canvasDeep.withValues(alpha: 0.4)
                ],
              ),
              border: Border.all(
                color: color.withValues(alpha: 0.16),
              ),
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
                          fontSize: isMobile ? 24 : 32,
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
                  child: Icon(icon, color: color, size: isMobile ? 18 : 22),
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

  Widget _buildFiltersBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
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
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: _Palette.milanoRedDeep,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
                Divider(color: _Palette.milanoRedDeep.withValues(alpha: 0.08)),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _statusFilter,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: _Palette.milanoRedDeep,
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
                    color: _Palette.milanoRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: _Palette.milanoRedDeep,
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
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _Palette.lemonChiffon.withValues(alpha: 0.22),
                    border: Border.all(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: _Palette.milanoRedDeep,
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

  Widget _buildStaffList(bool isMobile) {
    if (_filteredStaff.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: _Palette.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
          ),
          boxShadow: _Palette.softShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_outlined,
                  size: 32,
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.5),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
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
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            itemBuilder: (ctx, i) => _buildStaffRow(_filteredStaff[i], i),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffMobileCard(StaffMember s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.cardWhite,
            _Palette.canvasDeep.withValues(alpha: 0.35)
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
        ),
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
                  backgroundColor: _Palette.milanoRed.withValues(alpha: 0.1),
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
          Divider(
            height: 24,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
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
          color: _Palette.milanoRedDeep.withValues(alpha: 0.60),
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
                    color: _Palette.lemonChiffon.withValues(alpha: 0.3),
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
                Icon(
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
                  color: _Palette.milanoRed.withValues(alpha: 0.08),
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
/// a plain "‹" glyph. Replaces the previous arrow-icon + "Back" label combo
/// with a minimal, professional control, matching the treatment used on
/// MenuScreen's header for a consistent brand feel across the admin app.
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
