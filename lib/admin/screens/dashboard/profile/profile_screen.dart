import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import 'package:restaurant_unified_app/admin/core/providers/restaurant_provider.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "PUREDINE Maroon + Cream" palette — matches AdminDashboardScreen,
/// MenuScreen, OrdersScreen, TablesScreen, and StaffScreen exactly, so the
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
///
/// UI-ENHANCEMENT PASS 3: the Logout action was relocated from a bottom
/// full-width pill button to a compact circular icon button living inside
/// the top navbar/header (top-right corner), matching common "navbar
/// action" placement. The onPressed logic (logout + navigate) is byte-for-
/// byte identical to before — only its position/presentation changed.
///
/// UI-ENHANCEMENT PASS 4: a GPay-style light top bar + majority-white
/// "Milano Red/Wine × Golden Chiffon" re-tune.
///
/// UI-ENHANCEMENT PASS 5: PUREDINE re-skin + StaffScreen-style top bar —
/// zero changes to provider, form, save, contact-add/delete, or logout
/// logic anywhere in this file — palette and presentation only.
///
/// UI-ENHANCEMENT PASS 6 (this pass — full three-tier responsive layout):
/// zero changes to provider, form, save, contact-add/delete, or logout
/// logic anywhere in this file — layout, spacing and presentation only.
///   1. BREAKPOINTS: the old binary `isMobile` split (`< 800` / `>= 800`,
///      which silently treated tablets and laptops as the exact same
///      layout) is replaced by a proper three-tier `_ScreenSize` system —
///      `mobile` (< 700), `tablet` (700–1099), `desktop` (>= 1100) — so
///      phones, tablets and laptops/desktops each get spacing, type scale
///      and grouping tuned to their own width instead of tablets being
///      force-fit into either the phone or the laptop layout.
///   2. CONTENT WIDTH: on tablet and desktop the scrollable form content
///      (hero card, details grid, contacts, admin account) is now capped
///      to a comfortable reading width (860px tablet / 1080px desktop)
///      and centered, exactly like the rest of the admin app's dashboard
///      screens, instead of stretching every field edge-to-edge across a
///      wide tablet or laptop viewport. The header bar's inner content is
///      centered to the same width so the title/subtitle line up with the
///      form below it on larger screens. Mobile keeps the original
///      full-width layout untouched.
///   3. TYPE SCALE & SPACING: header title/subtitle sizes, header padding,
///      hero-card avatar/name/type sizes, and section padding now each
///      have a dedicated tablet value instead of jumping straight from the
///      phone size to the laptop size, so tablet no longer looks either
///      cramped (inheriting phone sizing) or oversized (inheriting laptop
///      sizing).
///   4. FIELD GROUPING: "Primary Phone" and "Primary Email" are now paired
///      side-by-side on tablet and desktop (mirroring the existing
///      State/Pincode pairing) instead of stacking as two full-width rows,
///      giving the details card a denser, more professional two-column
///      feel on larger screens while mobile keeps them stacked.
///   Every data binding (`r?.name`, `r?.restaurantType`, `r?.isActive`,
///   controller text, provider calls, dialog logic) and every
///   onPressed/onTap handler is completely untouched — only how things are
///   arranged and sized on screen changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  // PUREDINE Maroon + Cream — exact values supplied by the user.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color milanoRedDeep =
      Color(0xFF8A183F); // Burgundy (Primary accent)
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
  // Not part of the supplied palette by name — mapped onto the supplied
  // deeper gold so the "inactive" accent stays inside the given palette.
  static const Color warning = Color(0xFFD9A421);
  static const Color danger = Color(0xFFE0323F); // Clear alert red
  static const Color dangerDeep =
      Color(0xFFB8232E); // Deeper alert red (kept for parity; unused today)

  // Supporting PUREDINE tones.
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
  /// softShadow used on MenuScreen/StaffScreen/AdminDashboardScreen.
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

  /// Themed elevated/glow shadow — used on the hero header card.
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

/// UI-ENHANCEMENT PASS 6: three-tier responsive breakpoint used throughout
/// this screen instead of a single binary `isMobile` flag. Presentation
/// concern only — does not affect any provider/data logic.
enum _ScreenSize { mobile, tablet, desktop }

_ScreenSize _resolveScreenSize(double width) {
  if (width < 700) return _ScreenSize.mobile;
  if (width < 1100) return _ScreenSize.tablet;
  return _ScreenSize.desktop;
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

    // UI-ENHANCEMENT PASS 6: three-tier breakpoint (mobile / tablet /
    // desktop) replaces the old binary `isMobile` check so tablets and
    // laptops each get their own tuned layout instead of sharing one
    // "not mobile" layout.
    final _ScreenSize screenSize = _resolveScreenSize(size.width);
    final bool isMobile = screenSize == _ScreenSize.mobile;
    final bool isTablet = screenSize == _ScreenSize.tablet;
    final bool isDesktop = screenSize == _ScreenSize.desktop;

    // Desktop/tablet content is capped to a comfortable reading width and
    // centered, like the rest of the admin app's dashboard screens, so it
    // never stretches edge-to-edge on a wide tablet or laptop viewport.
    // Mobile keeps the original full-width behavior.
    final double maxContentWidth =
        isDesktop ? 1080 : (isTablet ? 860 : double.infinity);

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Column(
        children: [
          // ── Header Section ───────────────────────────────────────────────
          // Fixed at the top, exactly like StaffScreen/MenuScreen — it no
          // longer scrolls away with the content beneath it.
          _buildCustomHeader(screenSize),

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
                          right: -110,
                          child: Container(
                            width: 220,
                            height: 220,
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
                        // UI-ENHANCEMENT PASS 2: extra low, wide glow further
                        // down the page — gives the long scrollable form a
                        // second soft focal point instead of all the ambient
                        // light sitting only near the header/top. Matches
                        // the Orders / Admin Dashboard / Staff screens'
                        // Pass-2 backdrop.
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
                                  _Palette.milanoRedLight.withValues(
                                    alpha: 0.06,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // PASS 5: a soft blush glow low on the right, so the
                        // bottom of a long scroll carries the same warm
                        // brand tint as the top instead of fading to flat
                        // white — matches StaffScreen's Pass-4 treatment.
                        // Purely decorative.
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

                // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping across
                // the whole body — a subtle extra layer of depth so the
                // cream backdrop doesn't read as flat behind the header,
                // echoing the glass-highlight language used in the header
                // itself. Purely cosmetic, sits above the ambient blobs and
                // below all real content.
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

                restaurantProv.isLoading && r == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _Palette.milanoRed,
                        ),
                      )
                    : RefreshIndicator(
                        color: _Palette.milanoRed,
                        onRefresh: () => restaurantProv.fetchRestaurant(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                            vertical: isMobile ? 16 : 24,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxContentWidth,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderCard(r, screenSize),
                                    const SizedBox(height: 32),
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
                                    _buildDetailsGrid(r, screenSize),
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
                                              style:
                                                  GoogleFonts.playfairDisplay(
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
                                            icon: const Icon(Icons.close,
                                                size: 18),
                                            label: const Text('Done'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  _Palette.milanoRed,
                                            ),
                                          )
                                        else
                                          TextButton.icon(
                                            onPressed: () => setState(
                                                () => _isEditing = true),
                                            icon: const Icon(Icons.edit,
                                                size: 18),
                                            label: const Text('Edit'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  _Palette.milanoRed,
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
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  /// StaffScreen-style top bar — a flat, full-width bar (no rounded
  /// corners) carrying the PUREDINE Deep Wine Maroon → Wine diagonal
  /// gradient, with the exact same ambient dressing StaffScreen's header
  /// uses: a soft warm-gold corner glow, a large very faint watermark
  /// emblem, a subtle diagonal glass sheen, and a warm-gold hairline along
  /// the bottom edge. The title is a white → gold `ShaderMask`, the date
  /// text (tablet & desktop) sits in soft gold, the subtitle sits in
  /// reduced-opacity white, and a thin gold underline accent sits beneath
  /// it. In place of StaffScreen's back-chevron / add-icon controls, this
  /// header keeps this screen's own single action (Logout), restyled into
  /// the same circular gold icon-button shape. The `onPressed` logic —
  /// logout then navigate to `/admin/login` — is completely unchanged from
  /// Pass 3/4, only its look and position changed.
  ///
  /// UI-ENHANCEMENT PASS 6: the bar itself still spans the full device
  /// width (matching the rest of the app's headers), but its inner
  /// title/date/logout row and subtitle/divider are now centered inside
  /// the same max-width column used by the form below, with a dedicated
  /// tablet type scale, so the header lines up with the content beneath it
  /// instead of always hugging the far edges on wide screens.
  Widget _buildCustomHeader(_ScreenSize screenSize) {
    final bool isMobile = screenSize == _ScreenSize.mobile;
    final bool isTablet = screenSize == _ScreenSize.tablet;
    final bool isDesktop = screenSize == _ScreenSize.desktop;
    final double maxContentWidth =
        isDesktop ? 1080 : (isTablet ? 860 : double.infinity);

    final double horizontalPadding = isMobile ? 18 : (isTablet ? 26 : 32);
    final double topPadding = isMobile ? 16 : (isTablet ? 20 : 22);
    final double bottomPadding = isMobile ? 18 : (isTablet ? 22 : 24);
    final double titleSize = isMobile ? 21 : (isTablet ? 24 : 28);
    final double subtitleSize = isMobile ? 12.5 : (isTablet ? 13.5 : 14);

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
                        Icons.storefront_rounded,
                        size: isMobile ? 120 : (isTablet ? 140 : 160),
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row — the two-tone title, the date (tablet &
                      // desktop), and the Logout icon button, all on one
                      // line. No search bar or back control of any kind
                      // here — mirrors StaffScreen's top row shape with
                      // this screen's own single action swapped in.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  _Palette.lemonChiffon,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Restaurant Profile',
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: titleSize,
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
                          _logoutIconButton(),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Text(
                        'Manage your business identity',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: subtitleSize,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 14),
                      // Thin gold gradient hairline — the same soft divider
                      // language used across the rest of the app's
                      // headers. Purely decorative.
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
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }

  /// Compact circular icon-only "logout" button, tucked into the top right
  /// corner of the navbar — same visual language as StaffScreen's "add
  /// staff" icon button (a gold-filled circle with a dark glyph, reading
  /// clearly against the wine backdrop). The `onPressed` logic here is
  /// byte-for-byte identical to Pass 3/4: log out via `AuthProvider`, then
  /// navigate to `/admin/login` once the widget is still mounted — only
  /// its look/position was ever touched.
  Widget _logoutIconButton() {
    return Tooltip(
      message: 'Logout',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              context.go('/admin/login');
            }
          },
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
              Icons.logout_rounded,
              size: 22,
              color: _Palette.milanoRed,
            ),
          ),
        ),
      ),
    );
  }

  /// UI-ENHANCEMENT PASS 6: padding, avatar size and type scale now have a
  /// dedicated tablet value (between the phone and desktop sizes) instead
  /// of jumping straight from phone sizing to desktop sizing. Every data
  /// binding (`r?.name`, `r?.restaurantType`, the status badge) is
  /// completely unchanged.
  Widget _buildHeaderCard(RestaurantProfile? r, _ScreenSize screenSize) {
    final bool isMobile = screenSize == _ScreenSize.mobile;
    final bool isTablet = screenSize == _ScreenSize.tablet;

    final double cardPadding = isMobile ? 20 : (isTablet ? 24 : 28);
    final double avatarSize = isMobile ? 56 : (isTablet ? 64 : 72);
    final double avatarIconSize = isMobile ? 28 : (isTablet ? 32 : 36);
    final double nameSize = isMobile ? 20 : (isTablet ? 23 : 26);
    final double typeSize = isMobile ? 12 : (isTablet ? 13 : 14);

    // Wrapped in a clipped Column with a slim gold top cap, matching the
    // Orders/Staff screens' stat-card treatment. The card body sits on the
    // PUREDINE card spec — a white → Soft Cream wash with a Pale Rose
    // border — so it reads correctly against the (now light) page canvas.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.glowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 3,
            color: _Palette.lemonChiffon.withValues(alpha: 0.85),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _Palette.canvasDeep],
              ),
              border: Border.all(color: _Palette.paleRose, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: _Palette.dustyBlush,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _Palette.lemonChiffonDeep.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: _Palette.milanoRed,
                        size: avatarIconSize,
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
                              fontSize: nameSize,
                              fontWeight: FontWeight.w900,
                              color: _Palette.milanoRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r?.restaurantType ?? 'Restaurant Type',
                            style: GoogleFonts.inter(
                              fontSize: typeSize,
                              color: _Palette.lemonChiffonDeep,
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

  /// UI-ENHANCEMENT PASS 6: card padding now has a tablet value, and
  /// "Primary Phone" / "Primary Email" are paired side-by-side on tablet
  /// and desktop (mirroring the existing State/Pincode pairing) instead of
  /// always stacking as two separate full-width rows — a denser, more
  /// professional two-column feel on larger screens. Mobile is unchanged:
  /// every field still stacks full-width. No controller, field, or binding
  /// was touched — only grouping/spacing.
  Widget _buildDetailsGrid(RestaurantProfile? r, _ScreenSize screenSize) {
    final bool isMobile = screenSize == _ScreenSize.mobile;
    final bool isTablet = screenSize == _ScreenSize.tablet;
    final double gridPadding = isMobile ? 20 : (isTablet ? 24 : 28);

    return Container(
      padding: EdgeInsets.all(gridPadding),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.softShadow,
        border: Border.all(color: _Palette.paleRose),
      ),
      child: Column(
        children: [
          _buildEditableRow(
            icon: Icons.category_outlined,
            label: 'Restaurant Type',
            controller: _typeController,
            hint: 'e.g. Fine Dining, Cafe',
          ),
          Divider(height: 32, color: _Palette.paleRose),
          _buildEditableRow(
            icon: Icons.description_outlined,
            label: 'Description',
            controller: _descController,
            hint: 'Brief description of your restaurant',
            maxLines: 3,
          ),
          Divider(height: 32, color: _Palette.paleRose),
          _buildEditableRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            controller: _addrController,
            hint: 'Street address',
          ),
          Divider(height: 32, color: _Palette.paleRose),
          if (isMobile) ...[
            _buildEditableRow(
              icon: Icons.map_outlined,
              label: 'State',
              controller: _stateController,
              hint: 'State',
            ),
            Divider(height: 32, color: _Palette.paleRose),
            _buildEditableRow(
              icon: Icons.pin_drop_outlined,
              label: 'Pincode',
              controller: _pincodeController,
              hint: 'Pincode',
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          Divider(height: 32, color: _Palette.paleRose),
          if (isMobile) ...[
            _buildEditableRow(
              icon: Icons.phone_outlined,
              label: 'Primary Phone',
              controller: _phoneController,
              hint: 'Main contact number',
            ),
            Divider(height: 32, color: _Palette.paleRose),
            _buildEditableRow(
              icon: Icons.email_outlined,
              label: 'Primary Email',
              controller: _emailController,
              hint: 'Main contact email',
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildEditableRow(
                    icon: Icons.phone_outlined,
                    label: 'Primary Phone',
                    controller: _phoneController,
                    hint: 'Main contact number',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEditableRow(
                    icon: Icons.email_outlined,
                    label: 'Primary Email',
                    controller: _emailController,
                    hint: 'Main contact email',
                  ),
                ),
              ],
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
            color: _Palette.dustyBlush,
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
        border: Border.all(color: _Palette.paleRose),
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
                color: _Palette.paleRose,
              ),
              itemBuilder: (context, index) {
                final contact = prov.contacts[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _Palette.dustyBlush,
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
                backgroundColor: _Palette.milanoRed,
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
            decoration: const BoxDecoration(
              color: _Palette.dustyBlush,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.contact_phone_rounded,
              color: _Palette.milanoRed,
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
                    borderSide: const BorderSide(color: _Palette.paleRose),
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
                    borderSide: const BorderSide(color: _Palette.paleRose),
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
        border: Border.all(color: _Palette.paleRose),
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
                        color: _Palette.dustyBlush,
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
                Divider(height: 1, color: _Palette.paleRose),
            ],
          );
        }).toList(),
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
