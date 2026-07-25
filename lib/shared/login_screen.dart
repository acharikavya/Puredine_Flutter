import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import 'package:restaurant_unified_app/staff/contexts/auth_provider.dart';
import 'package:restaurant_unified_app/staff/models/models.dart'
    as staff_models;
import 'package:restaurant_unified_app/core/models/user.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

/// -----------------------------------------------------------------------
/// Local color palette for this screen only.
/// Theme 1 — "Dark Maroon × Soft Cream × Gold Glow"
/// Primary:  #8B1D1D (Dark Maroon)
/// Accent:   #F4C430 (Gold Glow)
/// Kept local to this file so no other screen/theme file needs to change.
/// -----------------------------------------------------------------------
class _LoginPalette {
  // Core brand colors from the requested Theme 1 palette
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDark = Color(0xFF6B1616); // Deeper maroon
  static const Color milanoRedDeep = Color(0xFF3D0D0D); // Deepest maroon
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonSoft = Color(0xFFFFF3D6); // Soft gold tint

  // Supporting neutrals
  static const Color ivory = Color(0xFFFFF8F0); // Soft Cream background
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color fieldBorder = Color(0xFFEFDFB8);

  // Feedback colors
  static const Color danger = Color(0xFF8B1D1D);
  static const Color dangerBg = Color(0xFFFBE3DC);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRed, milanoRedDark, milanoRedDeep],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [milanoRed, milanoRedDark],
  );

  // Subtle gradient used behind the feature/status strip so it
  // reads as a distinct "chip" rather than a flat outline.
  static const LinearGradient stripGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x33F4C430), // lemonChiffon (gold) @ ~20%
      Color(0x1AF4C430), // lemonChiffon (gold) @ ~10%
    ],
  );

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.20),
      blurRadius: 34,
      offset: const Offset(0, 20),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: milanoRed.withValues(alpha: 0.38),
      blurRadius: 20,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> badgeShadow = [
    BoxShadow(
      color: lemonChiffon.withValues(alpha: 0.18),
      blurRadius: 18,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> fieldShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Soft glow used behind the badge icon for extra depth.
  static List<BoxShadow> stripShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.18),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];
}

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;
  String? _error;
  String _restaurantName = 'PUREDINE';

  @override
  void initState() {
    super.initState();
    _loadRestaurantName();
    _emailFocus.addListener(() {
      setState(() => _emailHasFocus = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocus.hasFocus);
    });
  }

  Future<void> _loadRestaurantName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_restaurant_name');
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _restaurantName = cached;
        });
      }
    } catch (e) {
      debugPrint("Error loading cached restaurant name: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _error = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    final auth = context.read<AuthProvider>();
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // 1. Try existing Admin login first
      await auth.login(email, password);
      // Success -> AuthProvider is authenticated with role = admin
      // Router redirect logic sends the user to /admin/dashboard
    } catch (adminError) {
      // 2. Admin login failed -> automatically try existing Staff login
      if (!mounted) return;
      final staffAuth = context.read<StaffAuthProvider>();

      try {
        await staffAuth.login(email, password);
        debugPrint("Role from StaffAuthProvider: ${staffAuth.user?.role}");
        debugPrint("========== STAFF LOGIN ==========");
        debugPrint("Token: ${staffAuth.token}");
        debugPrint("User: ${staffAuth.user?.name}");
        debugPrint("Role: ${staffAuth.user?.role}");

        final staffUser = staffAuth.user;
        if (staffUser == null || staffAuth.token == null) {
          throw Exception('Invalid email or password');
        }

        // Backend already returned the role inside StaffUser.fromJson().
        // Mirror it into AuthProvider so the router (which only listens
        // to AuthProvider) redirects to the correct dashboard.
        final mappedRole = staffUser.role == staff_models.StaffRole.servingStaff
            ? UserRole.servingStaff
            : UserRole.billingStaff;

        await auth.setAuth(
          staffAuth.token!,
          UserProfile(
            id: staffUser.id,
            name: staffUser.name,
            email: staffUser.email,
            role: mappedRole,
            phone: staffUser.phone,
            restaurantName: staffUser.restaurantName,
            createdAt: staffUser.createdAt,
          ),
        );
        // Navigation will be handled by the router/main redirect logic
      } catch (staffError) {
        setState(() => _error = 'Invalid email or password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // ── Responsive breakpoints ────────────────────────────────────────
    // Tuned for phones in portrait, small phones (e.g. iPhone SE / older
    // Androids ~360px wide), and slightly larger phones/small tablets.
    final bool isTinyScreen = screenWidth < 340;
    final bool isCompact = screenWidth < 380;
    final bool isMobile = screenWidth < 600;

    // ── Header ("navbar") sizing ──────────────────────────────────────
    // Trimmed down from the previous version so the banner reads as a
    // slim, modern header rather than a tall hero block — frees up
    // vertical space for the form and keeps everything comfortably
    // inside a single mobile viewport without scrolling on most phones.
    final double horizontalPad = isTinyScreen ? 16 : (isCompact ? 18 : 24);
    final double headerTopPad = isTinyScreen ? 36 : (isCompact ? 42 : 54);
    final double headerBottomPad = isTinyScreen ? 46 : (isCompact ? 54 : 70);
    final double badgeSize = isTinyScreen ? 52 : (isCompact ? 58 : 64);
    final double badgeIconSize = isTinyScreen ? 24 : (isCompact ? 26 : 29);
    final double titleSize = isTinyScreen ? 21 : (isCompact ? 24 : 29);
    // Card now overlaps the header more aggressively, so it sits higher
    // up the screen and the whole layout feels tighter and more compact.
    final double cardOverlap = isTinyScreen ? -34 : (isCompact ? -40 : -58);
    final double cardHorizontalPad = isTinyScreen ? 20 : (isCompact ? 24 : 30);
    final double cardTopPad = isTinyScreen ? 22 : (isCompact ? 26 : 30);
    final double buttonHeight = isTinyScreen ? 48 : (isCompact ? 50 : 54);
    final double cardMaxWidth = isMobile ? double.infinity : 420;
    final double headerRadius = isTinyScreen ? 32 : (isCompact ? 40 : 48);

    // Sizing for the feature/status strip beneath the title, scaled the
    // same way the rest of the header already does.
    final double stripFontSize = isTinyScreen ? 10.5 : (isCompact ? 11 : 12);
    final double stripIconSize = isTinyScreen ? 12 : (isCompact ? 13 : 14);
    final double stripHPad = isTinyScreen ? 10 : (isCompact ? 12 : 16);
    final double stripVPad = isTinyScreen ? 6 : 7;
    final double stripGap = isTinyScreen ? 6 : (isCompact ? 8 : 10);
    final double stripDotSize = isTinyScreen ? 3 : 3.5;

    return Scaffold(
      backgroundColor: _LoginPalette.ivory,
      // Ensures the layout resizes cleanly (not obscured/overflowing)
      // when the on-screen keyboard opens on small devices.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  mediaQuery.padding.top -
                  mediaQuery.padding.bottom,
            ),
            child: Column(
              children: [
                // ---------------------------------------------------------
                // Header banner ("navbar") — now more compact
                // ---------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    headerTopPad,
                    horizontalPad,
                    headerBottomPad,
                  ),
                  decoration: BoxDecoration(
                    gradient: _LoginPalette.headerGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(headerRadius),
                      bottomRight: Radius.circular(headerRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _LoginPalette.milanoRedDeep.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: const Alignment(0, -0.34),
                    children: [
                      // Layered decorative glows for extra depth
                      Positioned(
                        top: -40,
                        right: -50,
                        child: Container(
                          width: isCompact ? 130 : 180,
                          height: isCompact ? 130 : 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _LoginPalette.lemonChiffon.withValues(
                              alpha: 0.09,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -14,
                        right: -24,
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: isCompact ? 104 : 144,
                          color: _LoginPalette.lemonChiffon.withValues(
                            alpha: 0.09,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -48,
                        left: -40,
                        child: Container(
                          width: isCompact ? 104 : 148,
                          height: isCompact ? 104 : 148,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Fine dotted texture accent near the top
                      Positioned(
                        top: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _LoginPalette.lemonChiffon.withValues(
                                  alpha: i == 2 ? 0.9 : 0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Enhanced badge: soft outer ring + glass tile ──
                          SizedBox(
                            width: badgeSize + 18,
                            height: badgeSize + 18,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: badgeSize + 18,
                                  height: badgeSize + 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _LoginPalette.lemonChiffon
                                          .withValues(alpha: 0.22),
                                      width: 1,
                                    ),
                                  ),
                                ).animate(
                                  onPlay: (c) => c.repeat(reverse: true),
                                ).scale(
                                      duration: 1800.ms,
                                      begin: const Offset(0.92, 0.92),
                                      end: const Offset(1.04, 1.04),
                                      curve: Curves.easeInOut,
                                    ),
                                Container(
                                  width: badgeSize,
                                  height: badgeSize,
                                  decoration: BoxDecoration(
                                    color: _LoginPalette.white.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      isTinyScreen ? 18 : 22,
                                    ),
                                    border: Border.all(
                                      color: _LoginPalette.lemonChiffon
                                          .withValues(alpha: 0.65),
                                      width: 1.4,
                                    ),
                                    boxShadow: _LoginPalette.badgeShadow,
                                  ),
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    color: _LoginPalette.lemonChiffon,
                                    size: badgeIconSize,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().scale(
                                duration: 480.ms,
                                curve: Curves.easeOutBack,
                                begin: const Offset(0.7, 0.7),
                                end: const Offset(1, 1),
                              ),
                          SizedBox(height: isTinyScreen ? 10 : 14),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTinyScreen ? 8 : 0,
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  _LoginPalette.white,
                                  _LoginPalette.lemonChiffon,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                _restaurantName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.serif(
                                  size: titleSize,
                                  weight: FontWeight.bold,
                                  color: _LoginPalette.white,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: 100.ms,
                              ),
                          const SizedBox(height: 5),
                          Container(
                            width: 32,
                            height: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: _LoginPalette.lemonChiffon.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          // ─────────────────────────────────────────────
                          // Feature strip — compact, attractive pill that
                          // fits any screen width (auto-shrinks text/gaps
                          // instead of wrapping or overflowing).
                          // ─────────────────────────────────────────────
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth - (horizontalPad * 2) - 8,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: stripHPad,
                                  vertical: stripVPad,
                                ),
                                decoration: BoxDecoration(
                                  gradient: _LoginPalette.stripGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _LoginPalette.lemonChiffon
                                        .withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                  boxShadow: _LoginPalette.stripShadow,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _LoginPalette.lemonChiffon
                                            .withValues(alpha: 0.16),
                                      ),
                                      child: Icon(
                                        Icons.verified_user_rounded,
                                        size: stripIconSize,
                                        color: _LoginPalette.lemonChiffon
                                            .withValues(alpha: 0.95),
                                      ),
                                    ),
                                    SizedBox(width: stripGap),
                                    Text(
                                      'Access your dashboard',
                                      style: AppTheme.sans(
                                        size: stripFontSize,
                                        weight: FontWeight.w600,
                                        color: _LoginPalette.lemonChiffon
                                            .withValues(alpha: 0.95),
                                      ),
                                    ),
                                    SizedBox(width: stripGap),
                                    Container(
                                      width: stripDotSize,
                                      height: stripDotSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _LoginPalette.lemonChiffon
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    SizedBox(width: stripGap),
                                    Icon(
                                      Icons.bolt_rounded,
                                      size: stripIconSize,
                                      color: _LoginPalette.lemonChiffon
                                          .withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: stripGap * 0.6),
                                    Text(
                                      'Fast & secure',
                                      style: AppTheme.sans(
                                        size: stripFontSize,
                                        weight: FontWeight.w500,
                                        color: _LoginPalette.lemonChiffon
                                            .withValues(alpha: 0.82),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(
                                duration: 400.ms,
                                delay: 180.ms,
                              ).slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 400.ms,
                                delay: 180.ms,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // Card, overlapping the header (raised higher for a
                // tighter, more compact full-screen composition)
                // ---------------------------------------------------------
                Transform.translate(
                  offset: Offset(0, cardOverlap),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      isTinyScreen ? 14 : 20,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: cardMaxWidth),
                      padding: EdgeInsets.fromLTRB(
                        cardHorizontalPad,
                        cardTopPad,
                        cardHorizontalPad,
                        cardTopPad - 2,
                      ),
                      decoration: BoxDecoration(
                        color: _LoginPalette.white,
                        borderRadius: BorderRadius.circular(
                          isTinyScreen ? 22 : 28,
                        ),
                        boxShadow: _LoginPalette.cardShadow,
                        border: Border.all(
                          color: _LoginPalette.lemonChiffon.withValues(
                            alpha: 0.7,
                          ),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _LoginPalette.lemonChiffon,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _LoginPalette.lemonChiffon
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTinyScreen ? 12 : 16),
                          Text(
                            'Welcome back',
                            style: AppTheme.serif(
                              size: isTinyScreen ? 19 : 22,
                              weight: FontWeight.w700,
                              color: _LoginPalette.milanoRed,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Sign in to continue to your dashboard',
                            style: AppTheme.sans(
                              size: isTinyScreen ? 12 : 13,
                              color: _LoginPalette.textMuted,
                            ),
                          ),
                          SizedBox(height: isTinyScreen ? 18 : 24),
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _LoginPalette.dangerBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _LoginPalette.danger.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: _LoginPalette.danger,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: _LoginPalette.danger,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().shake(duration: 400.ms, hz: 4),
                            SizedBox(height: isTinyScreen ? 12 : 16),
                          ],
                          _buildFieldLabel('Email'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            hasFocus: _emailHasFocus,
                            hint: 'Enter your email',
                            icon: Icons.mail_outline_rounded,
                            isCompact: isTinyScreen,
                          ).animate().fadeIn(duration: 350.ms, delay: 80.ms).slideX(
                                begin: -0.03,
                                end: 0,
                                duration: 350.ms,
                              ),
                          SizedBox(height: isTinyScreen ? 14 : 18),
                          _buildFieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            hasFocus: _passwordHasFocus,
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            isCompact: isTinyScreen,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: _LoginPalette.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ).animate().fadeIn(duration: 350.ms, delay: 140.ms).slideX(
                                begin: -0.03,
                                end: 0,
                                duration: 350.ms,
                              ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: _LoginPalette.milanoRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                'Forgot Password?',
                                style: AppTheme.sans(
                                  color: _LoginPalette.milanoRed,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTinyScreen ? 14 : 18),
                          Container(
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              gradient: auth.isLoading
                                  ? null
                                  : _LoginPalette.buttonGradient,
                              color: auth.isLoading
                                  ? _LoginPalette.milanoRed.withValues(
                                      alpha: 0.6,
                                    )
                                  : null,
                              boxShadow: auth.isLoading
                                  ? []
                                  : _LoginPalette.buttonShadow,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(17),
                                splashColor: _LoginPalette.lemonChiffon
                                    .withValues(alpha: 0.25),
                                highlightColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                                onTap: auth.isLoading ? null : _handleLogin,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            key: const ValueKey('label'),
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Login',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      isTinyScreen ? 15 : 16,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTinyScreen ? 16 : 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 13,
                                color: _LoginPalette.textMuted.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Secured sign-in',
                                style: AppTheme.sans(
                                  size: 11.5,
                                  color: _LoginPalette.textMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 500.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOut,
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

  /// Small uppercase label rendered above each input field.
  Widget _buildFieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _LoginPalette.textMuted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Reusable styled text field. Wrapped in its own elevated white card so
  /// the input is clearly visible against the form card behind it, with a
  /// crisp border that strengthens and glows in the brand red on focus.
  /// `isCompact` slightly tightens padding/icon sizing on very small
  /// screens so fields never feel oversized relative to the viewport.
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool hasFocus,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    bool isCompact = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _LoginPalette.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFocus
              ? _LoginPalette.milanoRed
              : _LoginPalette.fieldBorder,
          width: hasFocus ? 1.8 : 1.4,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: _LoginPalette.milanoRed.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : _LoginPalette.fieldShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: TextStyle(
          color: _LoginPalette.textDark,
          fontSize: isCompact ? 14 : 15,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: _LoginPalette.milanoRed,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _LoginPalette.textMuted.withValues(alpha: 0.65),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: Padding(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            child: Container(
              padding: EdgeInsets.all(isCompact ? 7 : 8),
              decoration: BoxDecoration(
                color: hasFocus
                    ? _LoginPalette.milanoRed.withValues(alpha: 0.10)
                    : _LoginPalette.lemonChiffonSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: _LoginPalette.milanoRed,
                size: isCompact ? 16 : 18,
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: isCompact ? 40 : 44,
            minHeight: isCompact ? 40 : 44,
          ),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            vertical: isCompact ? 13 : 16,
            horizontal: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}