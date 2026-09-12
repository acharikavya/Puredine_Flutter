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
/// Theme 2 — "Fresh Greens × Warm Gold × Soft Ivory"
/// Primary:  #1E4A34 (Deep Green)
/// Accent:   #C99A3D (Warm Gold)
/// Kept local to this file so no other screen/theme file needs to change.
///
/// UI PASS: keeps the exact same green/gold/ivory color identity, ring
/// logo badge, two-tone brand title, tagline, script-style corner mark,
/// and three feature-highlight chips from the previous pass. Per this
/// request: (1) the three feature chips are now laid out in three equal
/// width columns so the spacing between them reads as evenly and
/// symmetrically aligned instead of being squeezed toward the middle,
/// and (2) every decorative background illustration (the corner leaf
/// glyphs, the soft gold circle glow behind the script mark, the plate
/// illustration, and the painted bottom wave) has been removed, leaving
/// a plain, flat ivory background behind the header/card. The card
/// itself (Welcome back, fields, button, secured sign-in note) keeps its
/// exact original structure and copy layout. No auth logic, controllers,
/// focus handling, validation, navigation, or callback code was touched
/// anywhere in this pass — presentation only. No "OR" divider and no
/// "Continue with Google/Apple" row were added, and the Login button
/// still has no arrow icon (it only ever renders its label).
///
/// LATEST PASS: added a manually-supplied background image asset behind
/// the entire screen (placed at assets/images/login_bg.png — update the
/// path/const below if your file is named or located differently, and
/// remember to register it under `flutter: assets:` in pubspec.yaml).
/// It sits underneath all existing content via a Stack + Positioned.fill,
/// with the original ivory color kept as the Scaffold's fallback
/// background so nothing shifts if the asset fails to load. No other
/// widget, spacing, logic, or copy was changed.
/// -----------------------------------------------------------------------
class _LoginPalette {
  // Core brand colors from the requested Theme 2 palette
  static const Color milanoRed = Color(0xFF1E4A34); // Deep Green (Primary)
  static const Color milanoRedDark = Color(0xFF163A29); // Deeper green
  static const Color milanoRedDeep = Color(0xFF0F2A1C); // Deepest green
  static const Color lemonChiffon = Color(0xFFC99A3D); // Warm Gold (Accent)
  static const Color lemonChiffonSoft = Color(0xFFF3E7CC); // Soft gold tint

  // Supporting neutrals
  static const Color ivory = Color(0xFFFAF7EF); // Soft Ivory background
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF20301F); // Deep green-charcoal text
  static const Color textMuted = Color(0xFF708070); // Muted sage gray
  static const Color fieldBorder = Color(0xFFE7E3D8);
  static const Color featurePillBg = Color(0xFFE7F0E4); // Soft green tint

  // Feedback colors
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerBg = Color(0xFFFBE3DC);

  // Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [milanoRed, milanoRedDark],
  );

  static const LinearGradient titleShaderGradient = LinearGradient(
    colors: [milanoRed, lemonChiffon],
  );

  // Two-tone sweep gradient used to build the ring around the logo
  // badge — mostly deep green with a warm gold accent arc, echoing the
  // reference design's circular fork/spoon + leaf mark.
  static const SweepGradient logoRingGradient = SweepGradient(
    colors: [
      milanoRed,
      milanoRed,
      milanoRed,
      lemonChiffon,
      lemonChiffon,
      milanoRed,
    ],
    stops: [0.0, 0.55, 0.72, 0.82, 0.92, 1.0],
  );

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.12),
      blurRadius: 34,
      offset: const Offset(0, 20),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: milanoRed.withValues(alpha: 0.32),
      blurRadius: 20,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> badgeShadow = [
    BoxShadow(
      color: lemonChiffon.withValues(alpha: 0.22),
      blurRadius: 18,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> fieldShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

// -----------------------------------------------------------------------
// Manually-added background image asset path. Update this single
// constant if your image file has a different name or location — it is
// the only thing you need to change to point at your own asset.
// -----------------------------------------------------------------------
const String _kBackgroundImageAsset = 'assets/images/login_background.png';

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
    final double horizontalPad = isTinyScreen ? 16 : (isCompact ? 18 : 24);
    final double headerTopPad = isTinyScreen ? 30 : (isCompact ? 36 : 46);
    final double headerBottomPad = isTinyScreen ? 46 : (isCompact ? 54 : 70);
    final double badgeSize = isTinyScreen ? 52 : (isCompact ? 58 : 64);
    final double badgeIconSize = isTinyScreen ? 24 : (isCompact ? 26 : 29);
    final double titleSize = isTinyScreen ? 23 : (isCompact ? 26 : 31);
    // Card now overlaps the header more aggressively, so it sits higher
    // up the screen and the whole layout feels tighter and more compact.
    final double cardOverlap = isTinyScreen ? -34 : (isCompact ? -40 : -58);
    final double cardHorizontalPad = isTinyScreen ? 20 : (isCompact ? 24 : 30);
    final double cardTopPad = isTinyScreen ? 22 : (isCompact ? 26 : 30);
    final double buttonHeight = isTinyScreen ? 48 : (isCompact ? 50 : 54);
    final double cardMaxWidth = isMobile ? double.infinity : 420;

    // Sizing for the feature-highlights row beneath the title, scaled
    // the same way the rest of the header already does.
    final double featureLabelSize = isTinyScreen ? 10.5 : (isCompact ? 11 : 12);
    final double featureIconSize = isTinyScreen ? 18 : (isCompact ? 19 : 21);
    final double featureCircleSize = isTinyScreen ? 38 : (isCompact ? 42 : 46);

    return Scaffold(
      backgroundColor: _LoginPalette.ivory,
      // Ensures the layout resizes cleanly (not obscured/overflowing)
      // when the on-screen keyboard opens on small devices.
      resizeToAvoidBottomInset: true,
      // ---------------------------------------------------------------
      // Manually-added background image: sits behind everything via a
      // Stack. Positioned.fill + BoxFit.cover makes it span the whole
      // screen regardless of device size. The SafeArea/ScrollView with
      // all existing content is layered on top, completely unchanged.
      // ---------------------------------------------------------------
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              _kBackgroundImageAsset,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
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
                    // ---------------------------------------------------
                    // Header banner — a flat, plain ivory surface (no
                    // decorative leaf/glow backdrop) with a centered
                    // two-tone ring logo badge, two-tone brand title, a
                    // small-caps tagline, a script-style corner mark, and
                    // a row of three evenly aligned feature highlights.
                    // ---------------------------------------------------
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        headerTopPad,
                        horizontalPad,
                        headerBottomPad,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: const Alignment(0, -0.34),
                        children: [
                          // Small script-style corner mark — "Good Food,
                          // Brighter Days" — sitting top-right of the
                          // header, with no background glow/circle behind
                          // it. Hidden on very narrow screens so it never
                          // crowds the title.
                          if (!isCompact)
                            Positioned(
                              top: 0,
                              right: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Good Food',
                                    textAlign: TextAlign.right,
                                    style: AppTheme.serif(
                                      size: 12.5,
                                      weight: FontWeight.w500,
                                      color: _LoginPalette.textMuted,
                                    ).copyWith(fontStyle: FontStyle.italic),
                                  ),
                                  Text(
                                    'Brighter Days',
                                    textAlign: TextAlign.right,
                                    style: AppTheme.serif(
                                      size: 12.5,
                                      weight: FontWeight.w500,
                                      color: _LoginPalette.textMuted,
                                    ).copyWith(fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 28,
                                    height: 2,
                                    color: _LoginPalette.lemonChiffon,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 60.ms),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Logo badge: two-tone ring (green +
                              // gold) with a fork/knife glyph in the
                              // centre and a small leaf accent
                              // overlapping the ring.
                              _buildLogoBadge(badgeSize, badgeIconSize)
                                  .animate()
                                  .scale(
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
                                  shaderCallback: (bounds) => _LoginPalette
                                      .titleShaderGradient
                                      .createShader(bounds),
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
                              const SizedBox(height: 6),
                              // Small-caps tagline flanked by thin
                              // dashes, matching the reference design's
                              // subtitle treatment beneath the brand
                              // name.
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 1,
                                    color: _LoginPalette.textMuted.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GOOD FOOD. BETTER YOU.',
                                    style: AppTheme.sans(
                                      size: isTinyScreen ? 9.5 : 10.5,
                                      weight: FontWeight.w600,
                                      color: _LoginPalette.textMuted,
                                    ).copyWith(letterSpacing: 1.4),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 14,
                                    height: 1,
                                    color: _LoginPalette.textMuted.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(
                                    duration: 400.ms,
                                    delay: 140.ms,
                                  ),
                              SizedBox(height: isTinyScreen ? 16 : 20),
                              // ─────────────────────────────────────────
                              // Feature highlights — three items laid out
                              // in three EQUAL WIDTH columns (via
                              // Expanded), each one centered within its
                              // own column. This keeps the gap between
                              // items — including the middle one — even
                              // and properly aligned across every screen
                              // width, instead of drifting together.
                              // ─────────────────────────────────────────
                              SizedBox(
                                width: (screenWidth - (horizontalPad * 2))
                                    .clamp(0.0, double.infinity),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        icon: Icons.eco_rounded,
                                        label: 'Fresh Choices',
                                        circleSize: featureCircleSize,
                                        iconSize: featureIconSize,
                                        labelSize: featureLabelSize,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        icon: Icons.verified_user_rounded,
                                        label: 'Safe & Secure',
                                        circleSize: featureCircleSize,
                                        iconSize: featureIconSize,
                                        labelSize: featureLabelSize,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        icon: Icons.bolt_rounded,
                                        label: 'Fast & Easy',
                                        circleSize: featureCircleSize,
                                        iconSize: featureIconSize,
                                        labelSize: featureLabelSize,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 400.ms,
                                    delay: 180.ms,
                                  )
                                  .slideY(
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

                    // ---------------------------------------------------
                    // Card, overlapping the header (raised higher for a
                    // tighter, more compact full-screen composition)
                    // ---------------------------------------------------
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
                                alpha: 0.45,
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
                              // "Welcome back" + a small animated
                              // waving-hand icon (replaces the plain
                              // emoji character so it renders crisply
                              // and consistently on every device/font).
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: AppTheme.serif(
                                      size: isTinyScreen ? 19 : 22,
                                      weight: FontWeight.w700,
                                      color: _LoginPalette.milanoRed,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.waving_hand_rounded,
                                    size: isTinyScreen ? 20 : 24,
                                    color: _LoginPalette.lemonChiffon,
                                  )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .rotate(
                                        begin: -0.04,
                                        end: 0.06,
                                        duration: 480.ms,
                                        curve: Curves.easeInOut,
                                      ),
                                ],
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
                              )
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 80.ms)
                                  .slideX(
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
                              )
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 140.ms)
                                  .slideX(
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
                                  onPressed: () =>
                                      context.push('/forgot-password'),
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
                              // Login button — solid brand-gradient pill
                              // with only its label, no arrow icon
                              // (nothing was removed here since none was
                              // ever rendered).
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
                                                child:
                                                    CircularProgressIndicator(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: isTinyScreen
                                                          ? 15
                                                          : 16,
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
                                    'Your data is encrypted and secure',
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

                    // ---------------------------------------------------
                    // Footer mark — "EAT WELL • LIVE BETTER" with a
                    // small gold underline beneath the card, sitting on
                    // the plain ivory background (no wave/leaf backdrop).
                    // ---------------------------------------------------
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isTinyScreen ? 18 : 26,
                        top: 2,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'EAT WELL  •  LIVE BETTER',
                            style: AppTheme.sans(
                              size: 10.5,
                              weight: FontWeight.w600,
                              color: _LoginPalette.textMuted.withValues(
                                alpha: 0.7,
                              ),
                            ).copyWith(letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 26,
                            height: 2,
                            decoration: BoxDecoration(
                              color: _LoginPalette.lemonChiffon,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 320.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The circular logo mark shown at the top of the header — a two-tone
  /// (green + gold) ring drawn with a sweep gradient, an ivory "hole" in
  /// the middle so it reads as a donut/ring rather than a solid disc, a
  /// fork/knife glyph centred inside it, and a small gold leaf accent
  /// overlapping the ring at the top-right — mirroring the reference
  /// design's circular cutlery + leaf mark without needing any new
  /// image assets or packages.
  Widget _buildLogoBadge(double size, double iconSize) {
    final double outerSize = size + 20;
    final double innerSize = size - 6;
    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outerSize,
            height: outerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: _LoginPalette.logoRingGradient,
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _LoginPalette.ivory,
              boxShadow: _LoginPalette.badgeShadow,
            ),
          ),
          Icon(
            Icons.restaurant_rounded,
            color: _LoginPalette.milanoRed,
            size: iconSize,
          ),
          Positioned(
            top: 2,
            right: 4,
            child: Icon(
              Icons.eco_rounded,
              size: size * 0.26,
              color: _LoginPalette.lemonChiffon,
            ),
          ),
        ],
      ),
    );
  }

  /// Small uppercase label rendered above each input field.
  Widget _buildFieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _LoginPalette.textMuted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  /// A single feature-highlight item used in the header row — an icon in
  /// a soft green circle with a short two-line label beneath it. Always
  /// wrapped in an `Expanded` by the caller so all three items occupy
  /// equal-width columns and the middle one stays evenly centered
  /// between the other two, regardless of screen width.
  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required double circleSize,
    required double iconSize,
    required double labelSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _LoginPalette.featurePillBg,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: _LoginPalette.milanoRed,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.sans(
            size: labelSize,
            weight: FontWeight.w600,
            color: _LoginPalette.textDark,
          ).copyWith(height: 1.2),
        ),
      ],
    );
  }

  /// Reusable styled text field. Wrapped in its own elevated white card so
  /// the input is clearly visible against the form card behind it, with a
  /// crisp border that strengthens and glows in the brand green on focus.
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
        color: _LoginPalette.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFocus ? _LoginPalette.milanoRed : _LoginPalette.fieldBorder,
          width: hasFocus ? 1.8 : 1.4,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: _LoginPalette.milanoRed.withValues(alpha: 0.12),
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
                    : _LoginPalette.white,
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
