import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import 'package:restaurant_unified_app/core/theme.dart';
import 'package:restaurant_unified_app/admin/core/providers/restaurant_provider.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// AdminDashboardScreen, MenuScreen, and the admin dialogs exactly, so the
/// Profile screen reads as part of the same consistent brand instead of its
/// own one-off theme. Used ONLY for this screen's restyle. Nothing here
/// touches AppColors or any other file — pure UI enhancement, no logic
/// changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a large faint watermark emblem, and a fine glass highlight
/// line along the top edge) matching the Orders / Admin Dashboard /
/// staff-side screens' Pass-2 treatment, and the full-screen backdrop
/// gained an extra diagonal sheen plus a secondary ambient glow for more
/// depth. No provider, form, save, contact, or logout logic was touched
/// anywhere in this pass — only presentation changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest = Color(0xFF2E0808); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFB8860B);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerDeep = Color(0xFF8E1D1D);

  // UI-ENHANCEMENT PASS 2: promoted from a flat 3-stop wash to a richer
  // 4-stop diagonal gradient with explicit stops — matches the Orders
  // screen header's "faceted" surface language exactly.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRed, milanoRedDeep, milanoRedDarkest],
    stops: [0.0, 0.38, 0.72, 1.0],
  );

  /// Themed soft shadow for resting cards/panels — matches MenuScreen's
  /// softShadow exactly, so every surface across the admin app shares the
  /// same warm, branded tint.
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

  /// Themed elevated/glow shadow — used on the hero header card.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.28),
          blurRadius: 32,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _typeController;
  late TextEditingController _descController;
  late TextEditingController _addrController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

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

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController();
    _descController = TextEditingController();
    _addrController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchRestaurant().then((_) {
        _populateFields();
      });
    });
  }

  void _populateFields() {
    final r = context.read<RestaurantProvider>().restaurant;
    if (r != null) {
      _typeController.text = r.restaurantType;
      _descController.text = r.description ?? '';
      _addrController.text = r.address ?? '';
      _stateController.text = r.state ?? '';
      _pincodeController.text = r.pincode ?? '';
      _phoneController.text = r.phone ?? '';
      _emailController.text = r.email ?? '';
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descController.dispose();
    _addrController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final restaurantProv = context.watch<RestaurantProvider>();
    final r = restaurantProv.restaurant;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/maroon glows plus a faint textured
          // photograph, matching MenuScreen's and the dashboard's "foggy"
          // backdrop so the whole admin experience feels like one brand.
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
                            _Palette.lemonChiffon.withValues(alpha: 0.32),
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
                  // UI-ENHANCEMENT PASS 2: extra low, wide glow further down
                  // the page — gives the long scrollable form a second soft
                  // focal point instead of all the ambient light sitting
                  // only near the header/top. Matches the Orders / Admin
                  // Dashboard screens' Pass-2 backdrop.
                  Positioned(
                    top: 720,
                    left: -100,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRedLight.withValues(alpha: 0.06),
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

          // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping across the
          // whole body — a subtle extra layer of depth so the cream backdrop
          // doesn't read as flat behind the header, echoing the glass-
          // highlight language used in the header itself. Purely cosmetic,
          // sits above the ambient blobs and below all real content.
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

          Column(
            children: [
              _buildCustomHeader(isMobile),
              Expanded(
                child: restaurantProv.isLoading && r == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _Palette.milanoRed,
                        ),
                      )
                    : RefreshIndicator(
                        color: _Palette.milanoRed,
                        onRefresh: () => restaurantProv.fetchRestaurant(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderCard(r, isMobile),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _Palette.milanoRed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Restaurant Details',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _Palette.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailsGrid(r, isMobile),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _Palette.milanoRed,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Additional Contacts',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _Palette.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_isEditing)
                                      TextButton.icon(
                                        onPressed: () => setState(() {
                                          _isEditing = false;
                                          _populateFields();
                                        }),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Done'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: _Palette.milanoRed,
                                        ),
                                      )
                                    else
                                      TextButton.icon(
                                        onPressed: () =>
                                            setState(() => _isEditing = true),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: _Palette.milanoRed,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildContactsSection(restaurantProv),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _Palette.milanoRed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Admin Account',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: _Palette.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _infoCard([
                                  _InfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Account Email',
                                    value: auth.userEmail ??
                                        'admin@restaurant.com',
                                  ),
                                  const _InfoRow(
                                    icon: Icons.badge_outlined,
                                    label: 'Role',
                                    value: 'Administrator',
                                  ),
                                ]),
                                const SizedBox(height: 40),
                                // Medium-big, more prominent pill-style
                                // logout button — same filled danger-red
                                // background and centered layout as before,
                                // just sized up (padding, icon, and label
                                // all increased) so it reads as a proper
                                // medium-sized call-to-action instead of a
                                // compact/small button. The onPressed logic
                                // (logout + navigate) is completely
                                // unchanged, only the visual sizing.
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await context
                                          .read<AuthProvider>()
                                          .logout();
                                      if (context.mounted) {
                                        context.go('/admin/login');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _Palette.danger,
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                      shadowColor: _Palette.danger.withValues(
                                        alpha: 0.35,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        side: BorderSide(
                                          color: _Palette.dangerDeep
                                              .withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      size: 22,
                                    ),
                                    label: Text(
                                      'Logout',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  /// Branded "floating navbar" header — mirrors the exact Pass-2 treatment
  /// used on the Orders / AdminDashboardScreen / MenuScreen headers: a
  /// richer four-stop diagonal gradient, rounded bottom corners, decorative
  /// diagonal ribbon accents, a soft radial glow behind the title block, a
  /// large faint watermark emblem, a fine glass highlight line along the
  /// very top edge, and a fine dotted texture strip. The back control has
  /// been removed per request — the header now opens directly with the
  /// date (desktop) and the title block, no left-side back button.
  Widget _buildCustomHeader(bool isMobile) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _Palette.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.35),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.12),
              blurRadius: 18,
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
              // matches the dashboard/menu/orders headers for a consistent
              // brand feel)
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
                          _Palette.lemonChiffon.withValues(alpha: 0.18),
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
              // Soft radial glow behind the title block, adding depth
              // without affecting any layout or logic.
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 260,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Palette.lemonChiffon.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Large faint watermark emblem — a unique signature touch
              // this header didn't previously have, sitting low-opacity and
              // large behind the copy, never competing with the title.
              // Matches the Orders / Admin Dashboard hero's Pass-2
              // watermark treatment.
              Positioned(
                right: isMobile ? -22 : -12,
                bottom: isMobile ? -20 : -16,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Icon(
                      Icons.storefront_rounded,
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
                  isMobile ? 16 : 32,
                  20,
                  isMobile ? 16 : 32,
                  isMobile ? 20 : 28,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _todayLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      SizedBox(height: isMobile ? 0 : 18),
                      Text(
                        'Restaurant Profile',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: isMobile ? 26 : 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _TitleDivider(),
                      const SizedBox(height: 10),
                      Text(
                        'Manage your business identity',
                        style: GoogleFonts.inter(
                          color: _Palette.lemonChiffon,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w600,
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
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }

  Widget _buildHeaderCard(RestaurantProfile? r, bool isMobile) {
    // UI-ENHANCEMENT PASS 2: wrapped in a clipped Column with a slim gold
    // top cap, matching the Orders screen's stat-card treatment, so the
    // hero card carries the same subtle color-coded identity language used
    // elsewhere in the app. Same inputs/content as before — purely a frame
    // around the existing card.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.glowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: _Palette.lemonChiffon.withValues(alpha: 0.85)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              gradient: _Palette.headerGradient,
              border: Border.all(
                color: _Palette.lemonChiffon.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isMobile ? 56 : 72,
                      height: isMobile ? 56 : 72,
                      decoration: BoxDecoration(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _Palette.lemonChiffon.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: _Palette.lemonChiffon,
                        size: isMobile ? 28 : 36,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r?.name ?? 'Restaurant Name',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r?.restaurantType ?? 'Restaurant Type',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 12 : 14,
                              color: _Palette.lemonChiffon.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) _buildStatusBadge(r),
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: 16),
                  _buildStatusBadge(r),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05);
  }

  Widget _buildStatusBadge(RestaurantProfile? r) {
    final isActive = r != null && r.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? _Palette.success.withValues(alpha: 0.18)
            : _Palette.warning.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isActive
              ? _Palette.success.withValues(alpha: 0.5)
              : _Palette.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? _Palette.success : _Palette.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            (r?.isActive ?? false) ? 'ACTIVE' : 'INACTIVE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isActive ? _Palette.success : _Palette.warning,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(RestaurantProfile? r, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.softShadow,
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          _buildEditableRow(
            icon: Icons.category_outlined,
            label: 'Restaurant Type',
            controller: _typeController,
            hint: 'e.g. Fine Dining, Cafe',
          ),
          Divider(
            height: 32,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          _buildEditableRow(
            icon: Icons.description_outlined,
            label: 'Description',
            controller: _descController,
            hint: 'Brief description of your restaurant',
            maxLines: 3,
          ),
          Divider(
            height: 32,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          _buildEditableRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            controller: _addrController,
            hint: 'Street address',
          ),
          Divider(
            height: 32,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          if (isMobile) ...[
            _buildEditableRow(
              icon: Icons.map_outlined,
              label: 'State',
              controller: _stateController,
              hint: 'State',
            ),
            Divider(
              height: 32,
              color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            _buildEditableRow(
              icon: Icons.pin_drop_outlined,
              label: 'Pincode',
              controller: _pincodeController,
              hint: 'Pincode',
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _buildEditableRow(
                    icon: Icons.map_outlined,
                    label: 'State',
                    controller: _stateController,
                    hint: 'State',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEditableRow(
                    icon: Icons.pin_drop_outlined,
                    label: 'Pincode',
                    controller: _pincodeController,
                    hint: 'Pincode',
                  ),
                ),
              ],
            ),
          Divider(
            height: 32,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          _buildEditableRow(
            icon: Icons.phone_outlined,
            label: 'Primary Phone',
            controller: _phoneController,
            hint: 'Main contact number',
          ),
          Divider(
            height: 32,
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
          ),
          _buildEditableRow(
            icon: Icons.email_outlined,
            label: 'Primary Email',
            controller: _emailController,
            hint: 'Main contact email',
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _Palette.lemonChiffon.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _Palette.milanoRed, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _Palette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.text.isEmpty ? 'Not set' : controller.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: controller.text.isEmpty
                      ? _Palette.textMuted
                      : _Palette.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection(RestaurantProvider prov) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.softShadow,
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          if (prov.contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No additional contacts added.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _Palette.textMuted,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prov.contacts.length,
              separatorBuilder: (_, __) => Divider(
                height: 24,
                color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final contact = prov.contacts[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        contact.type == 'PHONE' ? Icons.phone : Icons.email,
                        size: 16,
                        color: _Palette.milanoRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contact.value,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _Palette.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: _Palette.danger,
                          size: 20,
                        ),
                        onPressed: () =>
                            prov.deleteRestaurantContact(contact.id),
                      ),
                  ],
                );
              },
            ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddContactDialog(prov),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.milanoRedDeep,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: _Palette.milanoRed.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddContactDialog(RestaurantProvider prov) {
    String type = 'PHONE';
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: _Palette.cardWhite,
          icon: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.contact_phone_rounded,
              color: _Palette.milanoRedDeep,
              size: 26,
            ),
          ),
          title: Text(
            'Add New Contact',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _Palette.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'PHONE', child: Text('Phone')),
                  DropdownMenuItem(value: 'EMAIL', child: Text('Email')),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
                decoration: InputDecoration(
                  labelText: 'Type',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _Palette.milanoRed,
                      width: 1.6,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: type == 'PHONE' ? 'Phone Number' : 'Email Address',
                  hintText: type == 'PHONE' ? '9876543210' : 'example@mail.com',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _Palette.milanoRed,
                      width: 1.6,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
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
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    prov.addRestaurantContact(type, controller.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.milanoRed,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _Palette.softShadow,
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        row.icon,
                        color: _Palette.milanoRed,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _Palette.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _Palette.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the same accent used on the dashboard and menu
/// screens so the title treatment matches exactly across the admin app.
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

class _InfoRow {
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}