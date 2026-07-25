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
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
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
                              int cols = 1;
                              double aspect = 1.4;

                              if (constraints.maxWidth > 900) {
                                cols = 4;
                                aspect = 1.0;
                              } else if (constraints.maxWidth > 600) {
                                cols = 2;
                                aspect = 1.1;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: isMobile ? 16 : 24,
                                  mainAxisSpacing: isMobile ? 16 : 24,
                                  childAspectRatio: aspect,
                                ),
                                itemCount: _dashboardOptions.length,
                                itemBuilder: (ctx, i) => _HoverableDashCard(
                                  option: _dashboardOptions[i],
                                  index: i,
                                  isMobile: isMobile,
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.milanoRedLight,
              _Palette.milanoRed,
              _Palette.milanoRedDeep,
            ],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          (restaurant?.restaurantType ??
                                                  'CAFE')
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
                                          isActive:
                                              restaurant?.isActive ?? true,
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
    );
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

class _HoverableDashCard extends StatefulWidget {
  final _DashOption option;
  final int index;
  final bool isMobile;
  final Function(TapDownDetails) onTap;

  const _HoverableDashCard({
    required this.option,
    required this.index,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_HoverableDashCard> createState() => _HoverableDashCardState();
}

class _HoverableDashCardState extends State<_HoverableDashCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tag = '0${widget.index + 1}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isHovered
                ? _Palette.lemonChiffon.withValues(alpha: 0.30)
                : _Palette.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? _Palette.milanoRed : Colors.black12,
              width: _isHovered ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _Palette.milanoRed.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 32 : 16,
                offset: Offset(0, _isHovered ? 16 : 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top accent strip — a slim gradient bar that reinforces the
              // brand palette at the top edge of every card. Purely
              // decorative, sits above the content.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isHovered ? 5 : 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _Palette.milanoRed,
                          _Palette.lemonChiffon,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Index tag — subtle professional numbering
              Positioned(
                top: widget.isMobile ? 14 : 18,
                left: widget.isMobile ? 14 : 18,
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: _isHovered
                        ? _Palette.milanoRed.withValues(alpha: 0.55)
                        : Colors.black.withValues(alpha: 0.16),
                  ),
                ),
              ),

              // Arrow indicator — nudges in on hover to hint interactivity
              Positioned(
                top: widget.isMobile ? 14 : 18,
                right: widget.isMobile ? 14 : 18,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: _isHovered ? Offset.zero : const Offset(0.3, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isHovered ? 1 : 0,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: _Palette.milanoRed,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 16 : 24,
                  vertical: widget.isMobile ? 26 : 34,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: widget.isMobile ? 64 : 84,
                      height: widget.isMobile ? 64 : 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isHovered
                            ? _Palette.milanoRed
                            : _Palette.milanoRed.withValues(alpha: 0.07),
                        border: Border.all(
                          color: _isHovered
                              ? _Palette.milanoRed.withValues(alpha: 0.35)
                              : _Palette.milanoRed.withValues(alpha: 0.10),
                          width: 6,
                        ),
                        boxShadow: _isHovered
                            ? [
                                BoxShadow(
                                  color: _Palette.milanoRed
                                      .withValues(alpha: 0.30),
                                  blurRadius: 16,
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
                        size: widget.isMobile ? 30 : 36,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: widget.isMobile ? 18 : 21,
                        fontWeight: FontWeight.bold,
                        color:
                            _isHovered ? _Palette.milanoRed : _Palette.textDark,
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                      child: Text(
                        widget.option.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.option.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: widget.isMobile ? 12 : 13,
                        color: _Palette.textMuted,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
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
                            color:
                                _Palette.milanoRed.withValues(alpha: 0.55),
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