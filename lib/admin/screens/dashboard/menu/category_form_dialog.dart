import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local palette for this dialog's restyle. Nothing here touches AppColors
/// or any other file — pure UI enhancement, no logic changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a faint watermark emblem behind the icon block, and a fine
/// glass highlight line along the top edge) matching the Orders / Admin
/// Dashboard / staff-side screens' Pass-2 treatment. No form validation,
/// submit logic, MenuService calls, or dialog-dismiss behavior was touched
/// anywhere in this pass — only presentation changed.
///
/// UI-ENHANCEMENT PASS 3: brought the dialog's header into a lighter,
/// standard header style. No form validation, submit logic, MenuService
/// calls, or dialog-dismiss behavior was touched — presentation only.
///
/// COLOR-THEME PASS ("Milano Red/Wine × Golden Chiffon × White"): swapped
/// the underlying color values for a deep Milano red/wine primary and a
/// majority-white surface palette. Presentation only.
///
/// UI-ENHANCEMENT PASS 5 (PUREDINE re-skin + StaffScreen-style header):
/// zero changes to form validation, submit logic, MenuService calls, or
/// dialog-dismiss behavior anywhere in this file — palette and header
/// presentation only.
///
/// RESPONSIVE PASS 6 (mobile / tablet / laptop layout fix): introduced a
/// lightweight `_Responsive` helper that reads the current screen size and
/// derives sizing tokens (dialog max width, inset padding, header padding,
/// icon sizes, font sizes, field sizing, action-row sizing) across three
/// breakpoints — mobile (<600), tablet (600–1024) and desktop/laptop
/// (≥1024). The dialog card clamps its own max width AND max height
/// against the viewport and scrolls its body when content would otherwise
/// overflow, instead of relying on a single fixed 460px width. On very
/// narrow widths the Cancel / Submit action row automatically stacks
/// vertically instead of being forced into a cramped row. Header and body
/// paddings, icon-block size, title/subtitle font sizes, and the action
/// buttons' padding/font size all scale up slightly for tablet and
/// desktop so the dialog reads as an intentional, well-proportioned
/// surface at every size instead of a stretched mobile dialog.
///
/// PASS 6 FIX: the `stacked` breakpoint comparison in the actions
/// LayoutBuilder was missing its `<` operator (a copy/paste artifact),
/// which caused a compile error. That is the only change in this pass —
/// the comparison now reads `constraints.maxWidth <
/// _Responsive.stackedActionsBreakpoint`.
///
/// ACTIONS-ROW PASS 7 (equal-size, smaller, left-aligned buttons): the
/// Cancel and Create/Save buttons no longer stretch via `Expanded` to
/// fill the full row width. Both buttons now share one fixed
/// `actionButtonWidth` sizing token (smaller than before, per
/// breakpoint) and the row is left-aligned via
/// `MainAxisAlignment.start`. The same fixed width is reused in the
/// narrow "stacked" layout so both buttons stay equally sized and
/// left-aligned there too, instead of stretching to
/// `double.infinity`. Nothing else in the actions row — button styles,
/// colors, icons, text, loading spinner, `onPressed` callbacks, or the
/// stacked/row breakpoint logic — was changed.
///
/// ACTIONS-ROW PASS 8 (right-aligned, further-reduced button width,
/// shorter Create label): the Cancel and Create/Save buttons now sit on
/// the RIGHT side of the actions area — `MainAxisAlignment.end` for the
/// row, `CrossAxisAlignment.end` for the stacked/narrow column — instead
/// of the left. `actionButtonWidth` was reduced again (per breakpoint)
/// so both equally-sized buttons read as compact. The non-editing
/// submit label was shortened from "Create Category" to just "Create"
/// (the "Save Changes" edit-mode label is unchanged). Nothing else —
/// button styles, colors, icons, loading spinner, `onPressed`
/// callbacks, or the stacked/row breakpoint logic — was changed.
///
/// ZERO changes were made to `_submit`, `_formKey`, validators,
/// `onSaved`, `MenuService` calls, `Navigator.of(context).pop(...)`
/// calls, or any other business logic — this pass is layout/sizing only.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // NOTE: field names are unchanged from the previous themes on purpose —
  // every other widget in this file reads from these exact names, so only
  // the underlying Color values change. Re-themed to the exact PUREDINE
  // Maroon + Cream palette.
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

  static const Color success = Color(0xFF44AF70); // Fresh Green (parity)
  static const Color danger = Color(0xFFE0323F); // Clear alert red

  // Supporting PUREDINE tones.
  static const Color dustyBlush =
      Color(0xFFF3D9DC); // Dusty Blush — icon backgrounds
  static const Color paleRose =
      Color(0xFFEFD7DA); // Pale Rose — field/card borders
  static const Color softYellow = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color paleMint = Color(0xFFEAF6EF); // Pale Mint (parity)

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

  /// Themed soft shadow for resting surfaces — mirrors the shared shadow
  /// language used across MenuScreen / StaffScreen / AdminDashboardScreen.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Themed elevated glow shadow — used for the whole dialog card and the
  /// primary action button so both read as "lifted" above the backdrop.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.22),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}

/// ─────────────────────────────────────────────────────────────────────────
/// RESPONSIVE PASS 6: small, self-contained sizing helper. Pure UI sizing
/// math derived from the current viewport — touches no business logic.
/// Breakpoints: mobile < 600, tablet 600–1024, desktop/laptop ≥ 1024.
/// ─────────────────────────────────────────────────────────────────────────
class _Responsive {
  final double width;
  final double height;

  _Responsive(this.width, this.height);

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  /// Outer margin between the dialog card and the screen edges.
  EdgeInsets get insetPadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 48);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 36);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
  }

  /// The dialog card's max width, capped by both an ideal per-breakpoint
  /// width AND whatever space is actually left after [insetPadding].
  double get dialogMaxWidth {
    final available = width - insetPadding.horizontal;
    final ideal = isDesktop
        ? 640.0
        : isTablet
            ? 560.0
            : 460.0;
    return available < ideal ? available : ideal;
  }

  /// The dialog card's max height, so it never overflows short viewports
  /// (small phones, landscape, or with the keyboard open) — the body
  /// scrolls internally instead.
  double get dialogMaxHeight => height * 0.9;

  // ── Header ──────────────────────────────────────────────────────────
  double get headerHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get headerTopPad => isDesktop ? 30 : (isTablet ? 27 : 24);
  double get headerRightPad => isDesktop ? 22 : (isTablet ? 18 : 16);
  double get headerBottomPad => isDesktop ? 24 : (isTablet ? 22 : 20);

  double get iconBlockSize => isDesktop ? 56 : (isTablet ? 52 : 48);
  double get iconBlockRadius => isDesktop ? 16 : (isTablet ? 15 : 14);
  double get iconSize => isDesktop ? 26 : (isTablet ? 24 : 22);

  double get titleGap => isDesktop ? 18 : (isTablet ? 16 : 14);
  double get titleFontSize => isDesktop ? 24 : (isTablet ? 22.5 : 21);
  double get subtitleFontSize => isDesktop ? 13.5 : (isTablet ? 13 : 12.5);
  double get subtitleGap => isDesktop ? 7 : 6;

  double get closeButtonSize => isDesktop ? 40 : (isTablet ? 38 : 36);
  double get closeIconSize => isDesktop ? 20 : (isTablet ? 19 : 18);

  double get hairlineGap => isDesktop ? 18 : (isTablet ? 17 : 16);

  // ── Form body ───────────────────────────────────────────────────────
  double get bodyHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get bodyTopPad => isDesktop ? 30 : (isTablet ? 28 : 26);
  double get bodyBottomPad => isDesktop ? 12 : (isTablet ? 10 : 8);

  double get sectionLabelFontSize => isDesktop ? 12.5 : (isTablet ? 12 : 11.5);
  double get labelGap => isDesktop ? 12 : (isTablet ? 11 : 10);
  double get sectionGap => isDesktop ? 26 : (isTablet ? 24 : 22);
  double get lastFieldGap => isDesktop ? 22 : (isTablet ? 20 : 18);

  double get fieldFontSize => isDesktop ? 15.5 : (isTablet ? 15 : 14.5);
  double get fieldVerticalPad => isDesktop ? 18 : (isTablet ? 17 : 16);
  double get fieldHorizontalPad => isDesktop ? 18 : (isTablet ? 17 : 16);

  // ── Actions ─────────────────────────────────────────────────────────
  double get actionsHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get actionsTopPad => isDesktop ? 18 : (isTablet ? 17 : 16);
  double get actionsBottomPad => isDesktop ? 26 : (isTablet ? 25 : 24);
  double get actionGap => isDesktop ? 14 : (isTablet ? 13 : 12);
  double get actionVerticalPad => isDesktop ? 17 : (isTablet ? 15.5 : 14);
  double get actionFontSize => isDesktop ? 15.5 : (isTablet ? 15 : 14.5);

  /// ACTIONS-ROW PASS 7/8: fixed width shared by BOTH the Cancel and the
  /// Create/Save buttons, per breakpoint. Deliberately smaller than the
  /// old flex-based widths so the pair reads as a compact, equally-sized
  /// button group instead of two buttons stretched across the dialog.
  /// PASS 8: narrowed a little further at every breakpoint.
  double get actionButtonWidth => isDesktop ? 118 : (isTablet ? 108 : 98);

  /// Below this width the Cancel / Submit row is cramped, so the actions
  /// stack vertically instead (tiny phones only — normal mobile widths
  /// stay as a row).
  static const double stackedActionsBreakpoint = 340;
}

class CategoryFormDialog extends StatefulWidget {
  final MenuCategory? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _description = widget.category?.description ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final body = {'name': _name, 'description': _description};

      if (widget.category == null) {
        await MenuService.createCategory(body);
      } else {
        await MenuService.updateCategory(widget.category!.id, body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: _Palette.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    required _Responsive r,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        color: _Palette.textMuted,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 4, right: 4),
        alignment: Alignment.center,
        width: 20,
        child: Icon(icon, color: _Palette.milanoRed, size: 20),
      ),
      filled: true,
      fillColor: _Palette.canvasDeep,
      contentPadding: EdgeInsets.symmetric(
        horizontal: r.fieldHorizontalPad,
        vertical: r.fieldVerticalPad,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.paleRose),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.paleRose),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.milanoRed, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.danger, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.danger, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final screenSize = MediaQuery.sizeOf(context);
    final r = _Responsive(screenSize.width, screenSize.height);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: r.insetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: r.dialogMaxWidth,
          maxHeight: r.dialogMaxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _Palette.cardWhite,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _Palette.paleRose),
            boxShadow: _Palette.glowShadow,
          ),
          clipBehavior: Clip.antiAlias,
          // RESPONSIVE PASS 6: scroll the whole card body so short
          // viewports (small phones, landscape, keyboard open) never
          // overflow instead of clipping/erroring.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────
                // PUREDINE Deep Wine Maroon → Wine diagonal gradient
                // header, StaffScreen-style. Structure/behavior
                // unchanged from Pass 5 — only sizing is now responsive.
                Container(
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
                      // Ambient dressing for the wine backdrop — a soft
                      // warm-gold corner glow, a large very faint
                      // watermark emblem behind the copy, and a diagonal
                      // glass sheen. Purely decorative.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRect(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -60,
                                  right: -40,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _Palette.lemonChiffon.withValues(
                                            alpha: 0.16,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -14,
                                  bottom: -16,
                                  child: Icon(
                                    isEditing
                                        ? Icons.edit_rounded
                                        : Icons.create_new_folder_rounded,
                                    size: 110,
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
                        padding: EdgeInsets.fromLTRB(
                          r.headerHPad,
                          r.headerTopPad,
                          r.headerRightPad,
                          r.headerBottomPad,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Small gold accent-dot row above the title —
                            // purely decorative.
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
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
                                      color: _Palette.lemonChiffon.withValues(
                                        alpha: i == 2 ? 0.95 : 0.40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category-icon block — translucent white
                                // fill with a gold ring.
                                Container(
                                  width: r.iconBlockSize,
                                  height: r.iconBlockSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(
                                        r.iconBlockRadius),
                                    border: Border.all(
                                      color: _Palette.lemonChiffon.withValues(
                                        alpha: 0.55,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    isEditing
                                        ? Icons.edit_rounded
                                        : Icons.create_new_folder_rounded,
                                    color: Colors.white,
                                    size: r.iconSize,
                                  ),
                                ),
                                SizedBox(width: r.titleGap),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // White → gold ShaderMask title.
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            _Palette.lemonChiffon,
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          isEditing
                                              ? 'Edit Category'
                                              : 'Create Category',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: r.titleFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: r.subtitleGap),
                                      Text(
                                        isEditing
                                            ? 'Update the details for this category'
                                            : 'Add a new category to your menu',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: r.subtitleFontSize,
                                          color: Colors.white.withValues(
                                            alpha: 0.75,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Close button — circular "glass" control.
                                // onPressed callback is unchanged.
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _isLoading
                                        ? null
                                        : () =>
                                            Navigator.of(context).pop(false),
                                    child: Container(
                                      width: r.closeButtonSize,
                                      height: r.closeButtonSize,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        border: Border.all(
                                          color: _Palette.lemonChiffon
                                              .withValues(alpha: 0.45),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: r.closeIconSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: r.hairlineGap),
                            // Thin gold gradient hairline.
                            Container(
                              width: 46,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    _Palette.lemonChiffon.withValues(
                                      alpha: 0.95,
                                    ),
                                    _Palette.lemonChiffon.withValues(
                                      alpha: 0.15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form body ───────────────────────────────────────────
                Container(
                  color: _Palette.canvas,
                  padding: EdgeInsets.fromLTRB(
                    r.bodyHPad,
                    r.bodyTopPad,
                    r.bodyHPad,
                    r.bodyBottomPad,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _Palette.milanoRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CATEGORY NAME',
                              style: GoogleFonts.inter(
                                fontSize: r.sectionLabelFontSize,
                                fontWeight: FontWeight.w800,
                                color: _Palette.milanoRedDeep,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.labelGap),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _Palette.softShadow,
                          ),
                          child: TextFormField(
                            initialValue: _name,
                            style: GoogleFonts.inter(
                              color: _Palette.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: r.fieldFontSize,
                            ),
                            decoration: _fieldDecoration(
                              label: 'e.g. Starters, Main Course',
                              icon: Icons.restaurant_menu_rounded,
                              r: r,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                            onSaved: (val) => _name = val!.trim(),
                          ),
                        ),
                        SizedBox(height: r.sectionGap),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _Palette.milanoRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DESCRIPTION',
                              style: GoogleFonts.inter(
                                fontSize: r.sectionLabelFontSize,
                                fontWeight: FontWeight.w800,
                                color: _Palette.milanoRedDeep,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _Palette.softYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'OPTIONAL',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: _Palette.milanoRedDeep,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.labelGap),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _Palette.softShadow,
                          ),
                          child: TextFormField(
                            initialValue: _description,
                            style: GoogleFonts.inter(
                              color: _Palette.textDark,
                              fontSize: r.fieldFontSize,
                            ),
                            maxLines: 3,
                            decoration: _fieldDecoration(
                              label: 'Short description of this category',
                              icon: Icons.notes_rounded,
                              r: r,
                            ),
                            onSaved: (val) => _description = val?.trim() ?? '',
                          ),
                        ),
                        SizedBox(height: r.lastFieldGap),
                      ],
                    ),
                  ),
                ),

                // ── Actions ─────────────────────────────────────────────
                // ACTIONS-ROW PASS 7: Cancel and Create/Save are both
                // wrapped to the SAME fixed `r.actionButtonWidth` (smaller
                // than the previous flex-based sizing) and the row/column
                // is left-aligned instead of stretching across the
                // dialog. Everything else here — styles, icons, text,
                // loading spinner, onPressed callbacks, and the
                // stacked/row breakpoint logic — is unchanged.
                Container(
                  color: _Palette.canvas,
                  padding: EdgeInsets.fromLTRB(
                    r.actionsHPad,
                    r.actionsTopPad,
                    r.actionsHPad,
                    r.actionsBottomPad,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cancelButton = OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _Palette.textMuted,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _Palette.paleRose),
                          padding: EdgeInsets.symmetric(
                            vertical: r.actionVerticalPad,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: r.actionFontSize,
                          ),
                        ),
                      );

                      final submitButton = DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isLoading
                              ? const []
                              : [
                                  BoxShadow(
                                    color: _Palette.milanoRed
                                        .withValues(alpha: 0.32),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: _Palette.lemonChiffon
                                        .withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _Palette.milanoRed,
                            disabledBackgroundColor:
                                _Palette.milanoRed.withValues(alpha: 0.6),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: r.actionVerticalPad,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing
                                          ? Icons.save_rounded
                                          : Icons.add_rounded,
                                      size: 18,
                                      color: _Palette.lemonChiffon,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        isEditing ? 'Save Changes' : 'Create',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: r.actionFontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );

                      // Both buttons now share one fixed, smaller width so
                      // they render as an equally-sized pair instead of
                      // stretching to fill the row.
                      final sizedCancelButton = SizedBox(
                        width: r.actionButtonWidth,
                        child: cancelButton,
                      );
                      final sizedSubmitButton = SizedBox(
                        width: r.actionButtonWidth,
                        child: submitButton,
                      );

                      // RESPONSIVE PASS 6: on very narrow widths, stack
                      // the two actions instead of squeezing them into a
                      // Row, so labels never wrap or clip.
                      // FIX: the `<` operator is required here — without
                      // it this line does not compile.
                      final stacked = constraints.maxWidth <
                          _Responsive.stackedActionsBreakpoint;

                      if (stacked) {
                        // ACTIONS-ROW PASS 8: even when stacked, both
                        // buttons keep the same fixed, smaller width and
                        // are right-aligned rather than stretched full
                        // width.
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            sizedSubmitButton,
                            SizedBox(height: r.actionGap),
                            sizedCancelButton,
                          ],
                        );
                      }

                      // ACTIONS-ROW PASS 8: right-aligned row of two
                      // equally, smaller-sized buttons (no more
                      // Expanded/flex stretching across the dialog).
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          sizedCancelButton,
                          SizedBox(width: r.actionGap),
                          sizedSubmitButton,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOut).scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1, 1),
              duration: 220.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}
