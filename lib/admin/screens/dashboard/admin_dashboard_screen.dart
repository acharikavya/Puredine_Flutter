import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import 'package:restaurant_unified_app/admin/core/providers/restaurant_provider.dart';
import 'package:restaurant_unified_app/admin/core/providers/notification_provider.dart';
import 'package:restaurant_unified_app/admin/core/models/notification_model.dart';
import 'package:restaurant_unified_app/utils/session_manager.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette used ONLY
/// for this screen's restyle. Nothing here touches AppColors or any other
/// file — pure UI enhancement, no logic changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity — a richer four-stop diagonal
/// gradient, a large faint watermark emblem behind the brand block, and a
/// fine glass highlight line along the top edge — matching the staff-side
/// Dashboard / Orders / Tables screens' Pass-2 treatment, so the admin
/// console now reads as part of the exact same brand language. The
/// full-screen backdrop gained an extra diagonal sheen for more depth.
/// No provider, controller, route, notification, or session logic was
/// touched anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 3 (web-only card density): the dashboard grid
/// previously rendered a fixed 2-per-row layout on every breakpoint,
/// which meant desktop/laptop ("web") screens showed the exact same big
/// two-tile-per-row cards as mobile, just stretched wider. Mobile is left
/// completely untouched — same 2 columns, same card sizing, same
/// spacing, same aspect ratios as before. On tablet/wide (web) widths the
/// grid now scales up to 3–4 smaller, denser columns, and those cards get
/// a proportionally smaller icon/typography/padding treatment (via a new
/// purely-cosmetic `isCompact` sizing flag) so nothing overflows or looks
/// cramped. No navigation, provider, route, or animation logic changed —
/// only column count, card sizing, and spacing on non-mobile widths.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF320A0A); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with WidgetsBindingObserver {
  bool _isNavigating = false;
  Offset _navStartPos = Offset.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    SessionManager.updateLastActiveTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchRestaurant();
      final notifProv = context.read<NotificationProvider>();
      notifProv.startPolling();

      // Listen for new notifications to show custom top toast
      notifProv.addListener(() {
        if (notifProv.notifications.isNotEmpty &&
            !notifProv.notifications.first.isRead) {
          final latest = notifProv.notifications.first;
          if (mounted) {
            _showTopToast(latest);
          }
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // App returned from background

    if (state == AppLifecycleState.resumed) {
      bool isValid = await SessionManager.isSessionValid();

      if (!isValid && mounted) {
        await SessionManager.logout();

        if (!mounted) return;
        await context.read<AuthProvider>().logout();

        if (mounted) {
          context.go('/login');
        }
      } else {
        await SessionManager.updateLastActiveTime();
      }
    }

    // App moved to background
    if (state == AppLifecycleState.paused) {
      await SessionManager.updateLastActiveTime();
    }
  }

  void _showTopToast(NotificationModel notification) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        notification: notification,
        onDismiss: () => overlayEntry.remove(),
        onView: () {
          overlayEntry.remove();
          context.go('/admin/orders?highlightOrderId=${notification.orderId}');
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Note: We might want to keep polling if the admin stays in the app
    // but for now we stop when dashboard is disposed
    // context.read<NotificationProvider>().stopPolling();
    super.dispose();
  }

  void _triggerNavAnimation(Offset startPos, String route) async {
    setState(() {
      _navStartPos = startPos;
      _isNavigating = true;
    });

    // Wait for the animation to complete (approx 600ms)
    await Future.delayed(const Duration(milliseconds: 650));

    if (mounted) {
      setState(() => _isNavigating = false);
      context.go(route);
    }
  }

  final _dashboardOptions = [
    const _DashOption(
      title: 'Menu Management',
      description: 'Add, update, or remove menu items.',
      icon: Icons.restaurant_rounded,
      route: '/admin/menu',
    ),
    const _DashOption(
      title: 'Staff Management',
      description: 'Manage billing and serving staff credentials.',
      icon: Icons.people_outline_rounded,
      route: '/admin/staff',
    ),
    const _DashOption(
      title: 'Table Details',
      description: 'Configure layout, view status, and QR codes.',
      icon: Icons.grid_view_rounded,
      route: '/admin/tables',
    ),
    const _DashOption(
      title: 'Order Bill',
      description: 'View daily orders and billing history.',
      icon: Icons.receipt_long_rounded,
      route: '/admin/orders',
    ),
  ];

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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final restaurantProv = context.watch<RestaurantProvider>();
    final restaurant = restaurantProv.restaurant;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width <= 1024;
    final isWide = size.width > 1024;

    // Extra bottom inset (home indicator / gesture bar) so the scrollable
    // content never sits flush under the device's safe-area edge — this is
    // what makes the mobile layout "fit" the screen properly at the bottom.
    final double bottomSafePad = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Column(
        children: [
          // ── Header Section ──────────────────────────────────────────────────
          _buildHeader(context, auth, restaurant, isMobile, isWide),

          // ── Main Body Section ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Clean Elegant "Foggy" Background
                Positioned.fill(
                  child: Container(
                    color: _Palette.canvas,
                    child: Stack(
                      children: [
                        // Soft gold glow, top-right
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
                                  _Palette.lemonChiffon.withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Soft maroon glow, bottom-left
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
                        // Extra soft gold glow, center-right, for a richer
                        // full-screen ambience without affecting readability.
                        Positioned(
                          top: 260,
                          right: -120,
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
                        // Extra low, wide glow further down the page — gives
                        // the long grid a second soft focal point instead of
                        // all the ambient light sitting only near the top.
                        Positioned(
                          top: 620,
                          left: -70,
                          child: Container(
                            width: 250,
                            height: 250,
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
                          opacity: 0.05,
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
                // language used in the header itself. Matches the
                // staff-side Dashboard / Orders / Tables screens' Pass-2
                // backdrop treatment.
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

                // Dashboard Cards — centered with a max width on very wide /
                // full desktop screens so the layout stays balanced and
                // attractive instead of stretching edge-to-edge.
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 80 : (isTablet ? 40 : 20),
                    isMobile ? 28 : 60,
                    isWide ? 80 : (isTablet ? 40 : 20),
                    (isMobile ? 28 : 60) + bottomSafePad,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section label — small professional overline above the grid
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              bottom: 18,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _Palette.milanoRed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'MANAGEMENT CONSOLE',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.2,
                                    color: _Palette.textMuted,
                                  ),
                                ),
                                const Spacer(),
                                // Cosmetic date caption — purely decorative,
                                // no state or logic attached.
                                if (!isMobile)
                                  Text(
                                    _todayLabel(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      color: _Palette.textMuted.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          LayoutBuilder(
                            builder: (ctx, constraints) {
                              // ── Card density ─────────────────────────
                              // MOBILE (isMobile == true): completely
                              // unchanged from before — fixed 2 columns,
                              // same width-based aspect ratio steps, same
                              // spacing, same "isCompact: false" card
                              // sizing. Nothing here differs from the
                              // original behaviour on phones.
                              //
                              // WEB / TABLET (isMobile == false): instead
                              // of the old fixed 2-per-row layout, the
                              // grid now scales up to 3–4 smaller, denser
                              // columns depending on available width, and
                              // passes `isCompact: true` down to the card
                              // so its icon size, type scale, and padding
                              // shrink proportionally — keeping every
                              // card crisp and non-overflowing at the
                              // smaller footprint instead of just
                              // stretching the old large-card design.
                              final int cols;
                              final double aspect;
                              final bool isCompact;

                              if (isMobile) {
                                cols = 2;
                                isCompact = false;
                                if (constraints.maxWidth > 900) {
                                  aspect = 0.92;
                                } else if (constraints.maxWidth > 600) {
                                  aspect = 0.82;
                                } else {
                                  aspect = 0.72;
                                }
                              } else {
                                isCompact = true;
                                if (constraints.maxWidth > 1100) {
                                  cols = 4;
                                  aspect = 0.98;
                                } else if (constraints.maxWidth > 760) {
                                  cols = 3;
                                  aspect = 0.92;
                                } else {
                                  cols = 2;
                                  aspect = 0.88;
                                }
                              }

                              final double gridSpacing =
                                  isMobile ? 14 : (isCompact ? 16 : 22);

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: gridSpacing,
                                  mainAxisSpacing: gridSpacing,
                                  childAspectRatio: aspect,
                                ),
                                itemCount: _dashboardOptions.length,
                                itemBuilder: (ctx, i) => _HoverableDashCard(
                                  option: _dashboardOptions[i],
                                  index: i,
                                  isMobile: isMobile,
                                  isCompact: isCompact,
                                  onTap: (details) => _triggerNavAnimation(
                                    details.globalPosition,
                                    _dashboardOptions[i].route,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (restaurantProv.isLoading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: _Palette.milanoRed,
                      backgroundColor: _Palette.lemonChiffon,
                    ),
                  ),

                // Royal Navigation Pulse
                if (_isNavigating) _NavigationPulse(startPos: _navStartPos),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHeader(
    BuildContext context,
    AuthProvider auth,
    dynamic restaurant,
    bool isMobile,
    bool isWide,
  ) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the
          // staff-side Dashboard / Orders / Tables screens' Pass-2
          // "faceted" surface language.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
              _Palette.milanoRedDarkest,
            ],
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
          // Softly rounded bottom corners give the header a modern,
          // "floating navbar" feel instead of a flat hard-edged band.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRed.withValues(alpha: 0.34),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.10),
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle decorative diagonal ribbon accents (purely cosmetic)
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
            // Soft radial glow behind the brand block, adding depth without
            // affecting any layout or logic.
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Large faint watermark emblem — a unique signature touch
            // this header didn't previously have, sitting low-opacity and
            // large behind the brand block, never competing with the
            // restaurant name or controls. Matches the staff-side
            // Dashboard hero's Pass-2 watermark treatment.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -24 : -18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    Icons.storefront_rounded,
                    size: isMobile ? 140 : 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used on the login screen's header.
            Positioned(
              top: 10,
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
            // matches the staff-side Dashboard/Orders/Tables headers' top
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

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: isMobile ? 18 : 26,
              ),
              child: SafeArea(
                bottom: false,
                child: isMobile
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatusBadge(
                                isActive: restaurant?.isActive ?? true,
                              ),
                              // Compact right-hand cluster — both
                              // controls are now fixed-size circular
                              // buttons (notification bell + profile
                              // initial), so they sit tightly together
                              // on the right without ever needing to
                              // shrink or wrap.
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _NotificationButton(),
                                  const SizedBox(width: 12),
                                  _ProfileChip(
                                    email: auth.userEmail ??
                                        'admin@restaurant.com',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            restaurant?.name ?? 'PureDine Admin',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          _TitleDivider(),
                          const SizedBox(height: 10),
                          Text(
                            (restaurant?.restaurantType ?? 'CAFE')
                                .toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _Palette.lemonChiffon,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left spacer — keeps the brand block visually
                          // centered without ever competing for space
                          // with the right-hand controls.
                          const Expanded(child: SizedBox()),

                          // Center: Brand Info. FittedBox lets the
                          // title shrink gracefully on narrower
                          // desktop/tablet widths instead of
                          // overlapping the controls beside it.
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    restaurant?.name ?? 'PureDine Admin',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 46,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _TitleDivider(),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (restaurant?.restaurantType ?? 'CAFE')
                                          .toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: _Palette.lemonChiffon,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    _StatusBadge(
                                      isActive: restaurant?.isActive ?? true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Right: Notification + Profile — both fixed
                          // 40x40 circular buttons (bell icon, avatar
                          // initial), aligned to the right on wide
                          // screens exactly as on mobile.
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _NotificationButton(),
                                  const SizedBox(width: 16),
                                  _ProfileChip(
                                    email: auth.userEmail ??
                                        'admin@restaurant.com',
                                  ),
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
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.15, duration: 450.ms);
  }
}

/// Small decorative gradient divider placed beneath the restaurant title —
/// purely cosmetic, adds a refined, professional finishing touch.
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

/// ─────────────────────────────────────────────────────────────────────────
/// Portrait (tall × narrow) dashboard tile.
/// Restyled for the new 2-per-row grid: icon badge sits at the top, title
/// and description stack underneath it, and a small "Open" cue anchors the
/// bottom — a vertical layout language that reads naturally in a tall
/// rectangle. Hover/press states are richer: a gentle scale-up, deeper
/// shadow, a glowing/rotating icon badge, an animated top accent bar, and
/// a sliding "Open" pill that appears on hover.
///
/// UI-ENHANCEMENT PASS 3: added an `isCompact` sizing flag (web/tablet
/// only — always `false` on mobile, so phones render byte-for-byte the
/// same as before). When `isCompact` is true the icon badge, title/
/// description type scale, and internal padding shrink proportionally so
/// the smaller web grid tiles stay crisp and never overflow. Purely a
/// sizing adjustment — no hover/press/animation/navigation logic changed.
/// ─────────────────────────────────────────────────────────────────────────
class _HoverableDashCard extends StatefulWidget {
  final _DashOption option;
  final int index;
  final bool isMobile;
  final bool isCompact;
  final Function(TapDownDetails) onTap;

  const _HoverableDashCard({
    required this.option,
    required this.index,
    required this.isMobile,
    this.isCompact = false,
    required this.onTap,
  });

  @override
  State<_HoverableDashCard> createState() => _HoverableDashCardState();
}

class _HoverableDashCardState extends State<_HoverableDashCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tag = '0${widget.index + 1}';
    final double iconSize = widget.isMobile ? 58 : (widget.isCompact ? 54 : 76);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (d) {
          setState(() => _isPressed = true);
          widget.onTap(d);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: _isHovered
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.24),
                        _Palette.cardWhite,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_Palette.cardWhite, _Palette.cardWhite],
                    ),
              borderRadius: BorderRadius.circular(widget.isCompact ? 18 : 24),
              border: Border.all(
                color: _isHovered
                    ? _Palette.milanoRed.withValues(alpha: 0.55)
                    : Colors.black12,
                width: _isHovered ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? _Palette.milanoRed.withValues(alpha: 0.26)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _isHovered ? 32 : 16,
                  offset: Offset(0, _isHovered ? 18 : 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isCompact ? 18 : 24),
              child: Stack(
                children: [
                  // Top accent bar — a slim gradient strip reinforcing the
                  // brand palette along the top edge of every tall tile.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isHovered
                          ? (widget.isCompact ? 4 : 5)
                          : (widget.isCompact ? 2.5 : 3),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _Palette.milanoRed,
                            _Palette.lemonChiffon,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Soft corner glow behind the icon — purely decorative,
                  // adds depth without affecting layout.
                  Positioned(
                    top: -30,
                    right: -30,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 0.9 : 0.4,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _Palette.lemonChiffon.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Index tag — subtle professional numbering
                  Positioned(
                    top: widget.isMobile ? 12 : (widget.isCompact ? 10 : 16),
                    left: widget.isMobile ? 14 : (widget.isCompact ? 12 : 18),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: widget.isCompact ? 10 : 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: _isHovered
                            ? _Palette.milanoRed.withValues(alpha: 0.55)
                            : Colors.black.withValues(alpha: 0.16),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          widget.isMobile ? 14 : (widget.isCompact ? 14 : 20),
                      vertical:
                          widget.isMobile ? 18 : (widget.isCompact ? 16 : 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: widget.isCompact ? 4 : 6),

                        // Icon badge — the centerpiece at the top of the
                        // tall card, with a subtle rotation + glow on hover.
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          turns: _isHovered ? 0.028 : 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isHovered
                                  ? _Palette.milanoRed
                                  : _Palette.milanoRed.withValues(alpha: 0.08),
                              border: Border.all(
                                color: _isHovered
                                    ? _Palette.lemonChiffon.withValues(
                                        alpha: 0.6,
                                      )
                                    : _Palette.milanoRed.withValues(
                                        alpha: 0.10,
                                      ),
                                width: widget.isCompact ? 4.5 : 6,
                              ),
                              boxShadow: _isHovered
                                  ? [
                                      BoxShadow(
                                        color: _Palette.milanoRed
                                            .withValues(alpha: 0.34),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              widget.option.icon,
                              color: _isHovered
                                  ? _Palette.lemonChiffon
                                  : _Palette.milanoRed,
                              size: widget.isMobile
                                  ? 26
                                  : (widget.isCompact ? 24 : 32),
                            ),
                          ),
                        ),

                        // Title + description
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: widget.isMobile
                                    ? 15.5
                                    : (widget.isCompact ? 14.5 : 19),
                                fontWeight: FontWeight.bold,
                                color: _isHovered
                                    ? _Palette.milanoRed
                                    : _Palette.textDark,
                                letterSpacing: 0.2,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              child: Text(
                                widget.option.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: widget.isCompact ? 6 : 8),
                            Text(
                              widget.option.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: widget.isMobile
                                    ? 11.5
                                    : (widget.isCompact ? 10.5 : 13),
                                color: _Palette.textMuted,
                                height: 1.4,
                              ),
                              maxLines: widget.isCompact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        // "Open" cue — fades/slides in on hover, anchored
                        // at the bottom of the tall tile to hint at
                        // interactivity without cluttering the resting
                        // state of the card.
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 250),
                          offset:
                              _isHovered ? Offset.zero : const Offset(0, 0.4),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: _isHovered ? 1 : 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.isCompact ? 10 : 12,
                                vertical: widget.isCompact ? 5 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: _Palette.milanoRed.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'OPEN',
                                    style: GoogleFonts.inter(
                                      fontSize: widget.isCompact ? 9 : 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: _Palette.milanoRed,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_outward_rounded,
                                    size: widget.isCompact ? 11 : 13,
                                    color: _Palette.milanoRed,
                                  ),
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
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (widget.index * 100).ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCirc),
      ),
    );
  }
}

class _DashOption {
  final String title, description, route;
  final IconData icon;
  const _DashOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _Palette.lemonChiffon,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
            size: 14,
            color: _Palette.success,
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _Palette.milanoRedDeep,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile button — reduced to a compact 40×40 circular tap target that
/// shows only the admin's initial (e.g. "A"), matching the notification
/// button's footprint exactly. No email label, no logout control — this is
/// purely a small icon-style entry point into the profile page for both
/// the mobile and wide/desktop ("Chrome") layouts.
class _ProfileChip extends StatefulWidget {
  final String email;
  const _ProfileChip({required this.email});

  @override
  State<_ProfileChip> createState() => _ProfileChipState();
}

class _ProfileChipState extends State<_ProfileChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Derived purely from the email string for a small avatar initial —
    // presentation only, no new data source or logic path.
    final initial = widget.email.trim().isNotEmpty
        ? widget.email.trim()[0].toUpperCase()
        : 'A';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.email,
        child: GestureDetector(
          onTap: () => context.go('/admin/profile'),
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
                    : Colors.white.withValues(alpha: 0.15),
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isHovered
                    ? Colors.white
                    : _Palette.lemonChiffon.withValues(alpha: 0.9),
              ),
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationPulse extends StatelessWidget {
  final Offset startPos;
  const _NavigationPulse({required this.startPos});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Arrow
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              // Convert global to local (approximate since we're in a fill Stack)
              final x = startPos.dx;
              final y = startPos.dy - 100; // Account for header height approx

              return Stack(
                children: [
                  // Trail Particles
                  ...List.generate(5, (i) {
                    final particleProgress = (value - (i * 0.1)).clamp(
                      0.0,
                      1.0,
                    );
                    if (particleProgress <= 0 || particleProgress >= 0.8)
                      return const SizedBox();

                    return Positioned(
                      left: x + (particleProgress * 150),
                      top: y - (particleProgress * 50),
                      child: Opacity(
                        opacity: (1 - particleProgress) * 0.3,
                        child: Transform.scale(
                          scale: 0.5 + (particleProgress * 0.5),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: _Palette.milanoRed,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Main Moving Arrow
                  Positioned(
                    left: x + (value * 200),
                    top: y - (value * 80),
                    child: Opacity(
                      opacity: value < 0.8 ? 1.0 : (1.0 - (value - 0.8) * 5),
                      child: Transform.scale(
                        scale: 1.0 + (value * 0.4), // Scale up effect
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.milanoRed.withValues(
                                  alpha: 0.3 * (1 - value),
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: _Palette.milanoRed,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatefulWidget {
  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final unread = prov.unreadCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _showNotificationOverlay(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? _Palette.lemonChiffon.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _Palette.lemonChiffon,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _Palette.milanoRedDeep,
                          width: 1.5,
                        ),
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

  void _showNotificationOverlay(BuildContext context) {
    final prov = context.read<NotificationProvider>();

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Dialog(
          alignment: isMobile ? Alignment.center : Alignment.topRight,
          insetPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
              : const EdgeInsets.only(top: 80, right: 100),
          backgroundColor: Colors.transparent,
          child: Container(
            width: isMobile ? screenWidth - 32 : 400,
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _Palette.lemonChiffon.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: _Palette.milanoRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _Palette.milanoRedDeep,
                        ),
                      ),
                      const Spacer(),
                      if (prov.notifications.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            prov.markAllAsRead();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _Palette.milanoRed,
                          ),
                          child: Text(
                            'Mark all as read',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: _Palette.lemonChiffonDeep),
                if (prov.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: _Palette.lemonChiffon,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: _Palette.milanoRed.withValues(alpha: 0.4),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No new notifications',
                          style: GoogleFonts.inter(
                            color: _Palette.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: prov.notifications.length,
                      itemBuilder: (context, i) {
                        final n = prov.notifications[i];
                        return ListTile(
                          onTap: () {
                            prov.markAsRead(n.id);
                            Navigator.pop(context);
                            context.go(
                              '/admin/orders?highlightOrderId=${n.orderId}',
                            );
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? _Palette.lemonChiffon.withValues(alpha: 0.4)
                                  : _Palette.milanoRed.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: n.isRead
                                  ? _Palette.textMuted
                                  : _Palette.milanoRed,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            n.message,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight:
                                  n.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: _Palette.textDark,
                            ),
                          ),
                          subtitle: _LiveTimeAgo(dt: n.createdAt),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveTimeAgo extends StatefulWidget {
  final DateTime dt;
  const _LiveTimeAgo({required this.dt});

  @override
  State<_LiveTimeAgo> createState() => _LiveTimeAgoState();
}

class _LiveTimeAgoState extends State<_LiveTimeAgo> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Refresh every 30 seconds to keep the "time ago" accurate
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(widget.dt),
      style: GoogleFonts.inter(fontSize: 11, color: _Palette.textMuted),
    );
  }

  String _format(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _TopToastWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;
  final VoidCallback onView;

  const _TopToastWidget({
    required this.notification,
    required this.onDismiss,
    required this.onView,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _Palette.lemonChiffonDeep,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Left accent bar for a crisp, professional toast look
                        Container(
                          width: 4,
                          height: 34,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: _Palette.milanoRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _Palette.milanoRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _Palette.milanoRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.notification.message,
                            style: GoogleFonts.inter(
                              color: _Palette.milanoRedDeep,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: widget.onView,
                          style: TextButton.styleFrom(
                            foregroundColor: _Palette.milanoRed,
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          child: const Text('VIEW'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => _controller
                              .reverse()
                              .then((_) => widget.onDismiss()),
                        ),
                      ],
                    ),
                  ),
                  // Slim auto-dismiss progress indicator — cosmetic only,
                  // mirrors the existing 5-second auto-dismiss timer above.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 0.0),
                    duration: const Duration(seconds: 5),
                    curve: Curves.linear,
                    builder: (context, value, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value.clamp(0.0, 1.0),
                          child: Container(
                            height: 3,
                            color: _Palette.milanoRed.withValues(alpha: 0.55),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}