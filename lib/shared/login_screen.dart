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
///
/// COLOR-THEME PASS ("Kumo Ramen" palette): swaps the underlying color
/// values in `_LoginPalette` for the requested 5-color reference palette
/// — Spicy Ember (#EE3F24), Noodle Cream (#FFEFCB), Matcha Leaf
/// (#023820), Yolk Blaze (#F9A11B), and Tofu Silklaze (#FFF4E6) — for a
/// more vivid, professional, restaurant-brand feel. Every field name
/// below (`milanoRed`, `lemonChiffon`, `ivory`, `danger`, etc.) is
/// unchanged on purpose, since every other widget in this file already
/// reads from these exact names — only the `Color` values themselves,
/// plus a couple of shadow/tint values derived from them, were updated:
///   • milanoRed / milanoRedDark / milanoRedDeep → Matcha Leaf (#023820)
///     and two darker shades derived from it, used as the primary brand
///     green (logo ring, title gradient, button, focus states).
///   • lemonChiffon / lemonChiffonSoft → Yolk Blaze (#F9A11B) and Noodle
///     Cream (#FFEFCB), used as the warm gold/amber accent (logo ring
///     sweep, card border, feature icon accents, divider marks).
///   • ivory → Tofu Silklaze (#FFF4E6), the soft warm background behind
///     the header/card.
///   • featurePillBg → a soft Noodle Cream tint behind each feature
///     icon circle, replacing the old flat green tint.
///   • danger / dangerBg → Spicy Ember (#EE3F24) and a soft tint of it,
///     since it already reads naturally as an alert/error red.
/// No auth logic, controllers, focus handling, validation, navigation,
/// spacing, or callback code was touched anywhere in this pass —
/// presentation only.
///
/// POLISH PASS: the "Kumo Ramen" palette from the pass above was kept —
/// no widget, layout, spacing, logic, controller, focus, validation,
/// navigation, or callback code was touched — only the gradient stops,
/// shadow depth/tint, border tones, and a couple of opacity/elevation
/// values inside `_LoginPalette` were refined so the same five colors
/// read as richer and more premium (smoother title/button gradient,
/// a narrower feathered gold arc on the logo ring, a "lit from within"
/// card edge, and a deeper, gold-tinted button shadow).
///
/// COLOR-THEME PASS ("Pure Slurp" palette): swapped the underlying color
/// values in `_LoginPalette` for a Warm Gold / Deep Plum Brown / Soft
/// Sage Cream / White / Muted Red reference palette — a warm, cozy
/// noodle-house look with a deeper, less typical accent red.
///
/// COLOR-THEME PASS ("2024 Food Colors" palette): swapped the underlying
/// color values in `_LoginPalette` for a Snow / Beer / Old Moss Green /
/// Pullman Brown reference palette — a warm, appetizing yellow/green/
/// brown food-branding look.
///
/// COLOR-THEME PASS ("Kumo Ramen — Refined"): restored and refined the
/// original 5-color "Kumo Ramen" reference palette — Spicy Ember
/// (#EE3F24), Noodle Cream (#FFEFCB), Matcha Leaf (#023820), Yolk Blaze
/// (#F9A11B), and Tofu Silklaze (#FFF4E6) — putting all five colors to
/// deliberate, professional use across the screen.
///
/// COLOR-THEME PASS ("Milano Red/Wine × Golden Chiffon × White") — this
/// pass: swapped the underlying color values in `_LoginPalette` for a
/// deep Milano red/wine primary, a golden/yellow-chiffon accent, and a
/// background/surface palette that leans **majorly white** rather than
/// warm cream, per this request. Every field name below (`milanoRed`,
/// `lemonChiffon`, `ivory`, `danger`, etc.) is unchanged on purpose,
/// since every other widget in this file already reads from these exact
/// names — only the `Color` values themselves, plus the shadow/tint/
/// gradient values derived from them, were updated:
///   • milanoRed / milanoRedDark / milanoRedDeep → a deep Milano red/
///     wine (#7A1330) and two darker wine shades derived from it — the
///     primary brand tone used for the logo ring, title gradient,
///     "Welcome back" heading, button, and focus states.
///   • lemonChiffon / lemonChiffonSoft → a rich golden/yellow chiffon
///     (#F0B429) and a very pale chiffon tint (#FDF3D7) — the accent
///     used for the logo ring sweep, card border glow, feature-icon
///     ring accents, divider marks, and the waving-hand icon.
///   • ivory → nudged to sit almost flush with pure white (#FEFDFB) so
///     the header, field fill, and page backdrop all read as clean,
///     majorly-white surfaces, with the wine/gold only appearing as
///     accents rather than a colored backdrop — the white `Colors.white`
///     card itself, the fields, and the header now dominate the screen.
///   • featurePillBg → a very pale chiffon-white tint behind each
///     feature icon circle, so the icons sit on a barely-there gold
///     wash rather than a strong color block.
///   • danger / dangerBg → a clear, distinct crimson (#D7263D) and a
///     soft pink-white tint of it, kept visually separate from the
///     deep wine primary so an error banner never gets mistaken for
///     the brand color.
///   • the internal gradient "bridge" tone (used only to smooth the
///     title/button gradients between the wine and the gold) was
///     re-derived as a warm antique-gold midtone so the sweep reads as
///     a deliberate, three-stop, professional gradient rather than a
///     flat 2-stop blend.
/// No auth logic, controllers, focus handling, validation, navigation,
/// spacing, or callback code was touched anywhere in this pass —
/// presentation only.
///
/// COLOR-THEME PASS ("PUREDINE Maroon + Cream" palette) — this pass:
/// swapped the underlying color values in `_LoginPalette` for the
/// requested reference palette — Deep Wine Maroon (#742A3C), Wine
/// (#813244), Burgundy (#8A183F), Deep Brown/Black (#2E0D16), Warm
/// Off-White (#FBF8F5), Soft Cream (#F7F1ED), Dusty Blush (#F3D9DC),
/// Pale Rose (#EFD7DA), Warm Gold (#F3C564), Soft Yellow (#FCE1AB), and
/// Muted Taupe (#9B707A) — a warmer, more upscale maroon-and-cream
/// restaurant identity. Every field name below (`milanoRed`,
/// `milanoRedDark`, `lemonChiffon`, `ivory`, `white`, `danger`, etc.) is
/// unchanged on purpose, since every other widget in this file already
/// reads from these exact names — only the `Color` values themselves,
/// plus the gradient/shadow values derived from them, were updated:
///   • milanoRed → Deep Wine Maroon (#742A3C), the primary brand tone
///     used for the logo ring, title gradient, "Welcome back" heading,
///     forgot-password link, field icons/cursor, and focus states.
///   • milanoRedDark → Burgundy (#8A183F), the palette's own "primary
///     accent", used as the deeper step in the logo ring and button
///     gradients.
///   • milanoRedDeep → Deep Brown/Black (#2E0D16), used as the deepest
///     shadow tint (card shadow, field shadow) for a rich, grounded lift
///     instead of a plain grey/black shadow.
///   • wine (new field, additive only — see note below) → Wine
///     (#813244), the requested lighter header-gradient tone, woven into
///     the logo ring alongside the Maroon/Burgundy/Gold sweep.
///   • lemonChiffon / lemonChiffonSoft → Warm Gold (#F3C564) and Soft
///     Yellow (#FCE1AB), the accent used for the logo ring sweep, card
///     border glow, feature-icon ring accents, divider marks, and the
///     waving-hand icon.
///   • ivory → Warm Off-White (#FBF8F5), the requested main background,
///     also used for the input-field fill and the logo badge's inner
///     "hole".
///   • white → repurposed (per the same pattern as the pass above) to
///     Soft Cream (#F7F1ED), the requested card background — the login
///     card, and the unfocused field-icon chip background, now read as
///     a warm soft cream rather than stark white. (The "Login" button
///     label itself still renders as literal `Colors.white`, unaffected
///     by this field, since it was never wired to this token.)
///   • textDark → Deep Brown/Black (#2E0D16), used for input text and
///     feature-item labels.
///   • textMuted → Muted Taupe (#9B707A), used for the tagline,
///     subtitle, hints, and other secondary text.
///   • fieldBorder → Pale Rose (#EFD7DA), the requested card/element
///     border tone, used for the unfocused input-field border.
///   • featurePillBg → Dusty Blush (#F3D9DC), the requested icon-chip
///     background, used behind each feature-highlight icon circle.
///   • danger / dangerBg → kept as a clear, distinct crimson (#D7263D)
///     and a soft tint of it, since the requested palette only defines
///     a "Live/Success" green (not an error/alert color) and this stays
///     visually distinct from the Maroon/Burgundy primary so an error
///     banner is never mistaken for the brand color.
///   • the internal gradient "bridge" tone previously named
///     `_matchaGoldBridge` was re-derived as the requested CTA
///     mid-gradient tone (#9B3E4E) so the title/button sweep reads as a
///     deliberate, professional blend from Maroon through Burgundy-red
///     into Gold. The button gradient's very first stop was also set to
///     the requested CTA start tone (#6E1832) via a new, purely-internal
///     private constant (`_ctaDeepStart`), so the Login button follows
///     the exact "#6E1832 → #9B3E4E → #F3C564" sweep supplied in this
///     request.
/// No auth logic, controllers, focus handling, validation, navigation,
/// spacing, or callback code was touched anywhere in this pass —
/// presentation only. No header container, card, or field was added,
/// removed, resized, or repositioned — only `Color` values (and the two
/// small private/additive constants noted above, needed only to carry
/// the extra requested gradient tones) changed.
///
/// RESPONSIVE + TABLET/LAPTOP POLISH PASS (this pass): no auth logic,
/// controllers, focus handling, validation, navigation, or callback
/// code was touched — layout/presentation only, exactly as requested.
/// What changed:
///   • Added proper `isTablet` (600–1023px) and `isDesktop` (≥1024px)
///     breakpoints alongside the existing `isTinyScreen` / `isCompact` /
///     `isMobile` ones, so every sizing value (paddings, badge, title,
///     card width, button height, feature icons, etc.) now has a
///     dedicated, larger step for tablets and laptops instead of simply
///     reusing the largest phone value.
///   • The whole header + card + footer column is now centered and
///     capped with a `contentMaxWidth` on tablet/laptop screens (via
///     `Align(topCenter)` + `ConstrainedBox`), so the screen reads as a
///     deliberate, centered panel on wide viewports instead of stretching
///     full-bleed edge-to-edge — this is what was actually breaking the
///     layout on tablets/laptops before.
///   • The feature-highlights row's width calculation now derives from
///     the same capped content width (`effectiveContentWidth`) instead
///     of the raw device `screenWidth`, which previously could make that
///     row wider than its centered parent on large screens and misalign
///     it.
///   • Introduced a small `sp()` spacing helper (mobile spacing is
///     completely untouched; tablet/laptop spacing is scaled up ~12–22%)
///     applied only to a handful of internal vertical gaps inside the
///     card, so larger screens get a little extra breathing room instead
///     of a cramped phone layout stretched onto a bigger canvas.
///   • The login card's corner radius now has a slightly larger, more
///     premium step on tablet/laptop, and its max width is capped
///     (460px tablet / 440px laptop+) so the form never becomes an
///     awkward, overly wide input field on large screens.
/// No colors, gradients, copy, icons, or structural widgets were added
/// or removed — only sizing math and the new centering wrapper.
/// -----------------------------------------------------------------------
class _LoginPalette {
  // Core brand colors — "PUREDINE Maroon + Cream" reference palette.
  // Field names are unchanged from the previous themes on purpose (see
  // the COLOR-THEME PASS notes above) — every other widget in this file
  // reads from these exact names, so only the underlying Color values
  // change.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary)
  static const Color milanoRedDark =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedDeep =
      Color(0xFF2E0D16); // Deep Brown/Black (deepest shade)

  // Additive field: the palette's requested lighter "Wine" tone, woven
  // into the logo ring gradient alongside Maroon/Burgundy/Gold. This is
  // a new field (not a repurposed one) since nothing in the previous
  // palette carried this specific tone.
  static const Color wine = Color(0xFF813244); // Wine

  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color lemonChiffonSoft =
      Color(0xFFFCE1AB); // Soft Yellow highlight

  // Supporting neutrals — warm cream/off-white per this pass, so the
  // page backdrop reads as Warm Off-White and the card/field-icon chips
  // read as Soft Cream, with the maroon/gold reserved for accents.
  static const Color ivory =
      Color(0xFFFBF8F5); // Warm Off-White (main background)
  static const Color white = Color(0xFFF7F1ED); // Soft Cream (card background)
  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black text
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color fieldBorder = Color(0xFFEFD7DA); // Pale Rose
  static const Color featurePillBg = Color(0xFFF3D9DC); // Dusty Blush

  // Feedback colors — kept visually distinct from the maroon/burgundy
  // primary so an error state never reads as "brand color". The
  // requested palette only defines a Live/Success green, not an error
  // tone, so this crimson is retained from the previous pass for clear,
  // unambiguous alert styling.
  static const Color danger = Color(0xFFD7263D); // Clear crimson
  static const Color dangerBg = Color(0xFFFBE4E7); // Soft crimson tint

  // Two small, purely-internal gradient tones — needed only to carry the
  // exact CTA gradient requested ("#6E1832 → #9B3E4E → #F3C564") without
  // overloading the core named fields above with a value that's only
  // ever used inside a gradient stop.
  static const Color _ctaDeepStart = Color(0xFF6E1832);
  static const Color _matchaGoldBridge = Color(0xFF9B3E4E);

  // Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [_ctaDeepStart, _matchaGoldBridge, lemonChiffon],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient titleShaderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [milanoRed, _matchaGoldBridge, lemonChiffon],
    stops: [0.0, 0.55, 1.0],
  );

  // Two-tone sweep gradient used to build the ring around the logo
  // badge — mostly Maroon with a Wine mid-step and a narrow, feathered
  // Warm Gold accent arc, echoing the reference design's circular
  // fork/spoon + leaf mark. The gold arc is narrow and feathered in/out
  // for a clean, premium sweep rather than a hard-edged split.
  static const SweepGradient logoRingGradient = SweepGradient(
    colors: [
      milanoRed,
      milanoRed,
      wine,
      lemonChiffon,
      wine,
      milanoRed,
    ],
    stops: [0.0, 0.58, 0.74, 0.83, 0.90, 1.0],
  );

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.14),
      blurRadius: 38,
      offset: const Offset(0, 22),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: lemonChiffon.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: milanoRed.withValues(alpha: 0.34),
      blurRadius: 24,
      offset: const Offset(0, 14),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: lemonChiffon.withValues(alpha: 0.22),
      blurRadius: 14,
      offset: const Offset(0, 4),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> badgeShadow = [
    BoxShadow(
      color: lemonChiffon.withValues(alpha: 0.30),
      blurRadius: 22,
      spreadRadius: 1.5,
    ),
  ];

  static List<BoxShadow> fieldShadow = [
    BoxShadow(
      color: milanoRedDeep.withValues(alpha: 0.05),
      blurRadius: 12,
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
    // Androids ~360px wide), regular phones, tablets (portrait/landscape,
    // e.g. iPad ~768–1024px), and laptops/desktops (≥1024px). Adding the
    // `isTablet` / `isDesktop` steps below is what actually fixes the
    // layout on tablets and laptops — every size that used to jump
    // straight from "phone" to "whatever's left" now has its own step.
    final bool isTinyScreen = screenWidth < 340;
    final bool isCompact = screenWidth < 380;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    // `isDesktop` doubles as a readability flag for anyone scanning the
    // sizing block below (every "isTablet ? tabletValue : desktopValue"
    // ternary's else-branch is exactly the isDesktop case, since isMobile,
    // isTablet and isDesktop are mutually exclusive and exhaustive).
    assert(isMobile || isTablet || isDesktop);

    // Overall header/card/footer column width. On phones this stays
    // `double.infinity` (unchanged full-bleed behaviour). On tablets and
    // laptops the whole column is capped and centered so the screen reads
    // as a deliberate, centered panel instead of stretching edge-to-edge.
    final double contentMaxWidth =
        isMobile ? double.infinity : (isTablet ? 640 : 600);
    // The actual width available to content inside that column — used
    // instead of the raw `screenWidth` for any width math done further
    // down (e.g. the feature-highlights row), so nothing overflows or
    // misaligns once the column itself is capped on larger screens.
    final double effectiveContentWidth =
        isMobile ? screenWidth : contentMaxWidth;

    // Small multiplier used only to open up a little extra breathing
    // room between elements on tablets/laptops. Mobile spacing (where
    // `spacingScale == 1.0`) is completely unchanged.
    final double spacingScale = isMobile ? 1.0 : (isTablet ? 1.12 : 1.22);
    double sp(double value) => value * spacingScale;

    // ── Header ("navbar") sizing ──────────────────────────────────────
    final double horizontalPad = isTinyScreen
        ? 16
        : (isCompact ? 18 : (isMobile ? 24 : (isTablet ? 32 : 40)));
    final double headerTopPad = isTinyScreen
        ? 30
        : (isCompact ? 36 : (isMobile ? 46 : (isTablet ? 56 : 64)));
    final double headerBottomPad = isTinyScreen
        ? 46
        : (isCompact ? 54 : (isMobile ? 70 : (isTablet ? 80 : 88)));
    final double badgeSize = isTinyScreen
        ? 52
        : (isCompact ? 58 : (isMobile ? 64 : (isTablet ? 72 : 78)));
    final double badgeIconSize = isTinyScreen
        ? 24
        : (isCompact ? 26 : (isMobile ? 29 : (isTablet ? 32 : 34)));
    final double titleSize = isTinyScreen
        ? 23
        : (isCompact ? 26 : (isMobile ? 31 : (isTablet ? 34 : 37)));
    // Card now overlaps the header more aggressively, so it sits higher
    // up the screen and the whole layout feels tighter and more compact.
    final double cardOverlap = isTinyScreen
        ? -34
        : (isCompact ? -40 : (isMobile ? -58 : (isTablet ? -66 : -74)));
    final double cardHorizontalPad = isTinyScreen
        ? 20
        : (isCompact ? 24 : (isMobile ? 30 : (isTablet ? 38 : 44)));
    final double cardTopPad = isTinyScreen
        ? 22
        : (isCompact ? 26 : (isMobile ? 30 : (isTablet ? 36 : 40)));
    final double cardRadius = isTinyScreen
        ? 22
        : (isCompact ? 24 : (isMobile ? 28 : (isTablet ? 30 : 32)));
    final double buttonHeight = isTinyScreen
        ? 48
        : (isCompact ? 50 : (isMobile ? 54 : (isTablet ? 56 : 58)));
    // The card itself is capped well below the full column width on
    // tablets/laptops so the form never turns into one long, awkward
    // input field — it stays a natural, professional login-card width.
    final double cardMaxWidth =
        isMobile ? double.infinity : (isTablet ? 460 : 440);

    // Sizing for the feature-highlights row beneath the title, scaled
    // the same way the rest of the header already does.
    final double featureLabelSize = isTinyScreen
        ? 10.5
        : (isCompact ? 11 : (isMobile ? 12 : (isTablet ? 12.5 : 13)));
    final double featureIconSize = isTinyScreen
        ? 18
        : (isCompact ? 19 : (isMobile ? 21 : (isTablet ? 22 : 23)));
    final double featureCircleSize = isTinyScreen
        ? 38
        : (isCompact ? 42 : (isMobile ? 46 : (isTablet ? 50 : 54)));

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
                // On tablets/laptops the whole header + card + footer
                // column is centered and capped at `contentMaxWidth` so
                // the screen reads as a deliberate, centered panel
                // instead of stretching full-bleed edge-to-edge. On
                // phones `contentMaxWidth` is `double.infinity`, so this
                // wrapper is a no-op and behaviour is unchanged.
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 60.ms),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ── Logo badge: two-tone ring (wine +
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
                                  SizedBox(height: sp(isTinyScreen ? 10 : 14)),
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
                                        color:
                                            _LoginPalette.textMuted.withValues(
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
                                        color:
                                            _LoginPalette.textMuted.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(
                                        duration: 400.ms,
                                        delay: 140.ms,
                                      ),
                                  SizedBox(height: sp(isTinyScreen ? 16 : 20)),
                                  // ─────────────────────────────────────────
                                  // Feature highlights — three items laid out
                                  // in three EQUAL WIDTH columns (via
                                  // Expanded), each one centered within its
                                  // own column. This keeps the gap between
                                  // items — including the middle one — even
                                  // and properly aligned across every screen
                                  // width, instead of drifting together. The
                                  // width now derives from the same capped
                                  // `effectiveContentWidth` used for the rest
                                  // of the column, so it can never overflow
                                  // its centered parent on tablets/laptops.
                                  // ─────────────────────────────────────────
                                  SizedBox(
                                    width: (effectiveContentWidth -
                                            (horizontalPad * 2))
                                        .clamp(0.0, double.infinity),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              constraints:
                                  BoxConstraints(maxWidth: cardMaxWidth),
                              padding: EdgeInsets.fromLTRB(
                                cardHorizontalPad,
                                cardTopPad,
                                cardHorizontalPad,
                                cardTopPad - 2,
                              ),
                              decoration: BoxDecoration(
                                color: _LoginPalette.white,
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: _LoginPalette.cardShadow,
                                border: Border.all(
                                  color: _LoginPalette.lemonChiffon.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.3,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 10,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: _LoginPalette.lemonChiffon
                                              .withValues(alpha: 0.4),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: sp(isTinyScreen ? 12 : 16)),
                                  // "Welcome back" + a small animated
                                  // waving-hand icon (replaces the plain
                                  // emoji character so it renders crisply
                                  // and consistently on every device/font).
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            onPlay: (c) =>
                                                c.repeat(reverse: true),
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
                                  SizedBox(height: sp(isTinyScreen ? 18 : 24)),
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
                                          color:
                                              _LoginPalette.danger.withValues(
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
                                    SizedBox(
                                        height: sp(isTinyScreen ? 12 : 16)),
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
                                  SizedBox(height: sp(isTinyScreen ? 14 : 18)),
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
                                        () => _obscurePassword =
                                            !_obscurePassword,
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
                                        foregroundColor:
                                            _LoginPalette.milanoRed,
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
                                  SizedBox(height: sp(isTinyScreen ? 14 : 18)),
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
                                        onTap: auth.isLoading
                                            ? null
                                            : _handleLogin,
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 250),
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
                                                    key:
                                                        const ValueKey('label'),
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                  SizedBox(height: sp(isTinyScreen ? 16 : 20)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 13,
                                        color:
                                            _LoginPalette.textMuted.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Your data is encrypted and secure',
                                        style: AppTheme.sans(
                                          size: 11.5,
                                          color: _LoginPalette.textMuted
                                              .withValues(
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
                            bottom: sp(isTinyScreen ? 18 : 26),
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
            ),
          ),
        ],
      ),
    );
  }

  /// The circular logo mark shown at the top of the header — a two-tone
  /// (wine + gold) ring drawn with a sweep gradient, an ivory "hole" in
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
            border: Border.all(
              color: _LoginPalette.lemonChiffon.withValues(alpha: 0.35),
              width: 1,
            ),
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
  /// crisp border that strengthens and glows in the brand tone on focus.
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
                  color: _LoginPalette.milanoRed.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: _LoginPalette.lemonChiffon.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
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
