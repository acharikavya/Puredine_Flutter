import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local palette for this dialog's restyle. Used ONLY for this dialog's
/// restyle. Nothing here touches AppColors or any other file — pure UI
/// enhancement, no logic changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: brought this dialog's header up to a richer
/// "command bar" identity — a deeper four-stop diagonal gradient, a large
/// faint watermark emblem behind the title copy, and a fine glass
/// highlight line along the very top edge. No form fields, validation,
/// save/submit, or image-cleaning logic was touched — presentation only.
///
/// UI-ENHANCEMENT PASS 3: re-balanced the header to a majority-white look
/// with maroon/gold used only as accents. No form fields, validation,
/// save/submit, image-cleaning logic, dialog structure, or spacing was
/// touched — presentation only.
///
/// UI-ENHANCEMENT PASS 4 (PUREDINE re-skin + StaffScreen-style header):
/// zero changes to form fields, validation, save/submit, image-cleaning
/// logic, category selection, availability toggle, or dialog-dismiss
/// behavior anywhere in this file — palette and header presentation only.
///
/// RESPONSIVE PASS 5 (mobile / tablet / laptop layout fix + narrower
/// submit button):
///   1. Introduced a lightweight `_Responsive` helper that reads the
///      current screen size and derives sizing tokens (dialog max
///      width/height, inset padding, header padding, icon sizes, font
///      sizes, form-body padding/gaps, action-row sizing) across three
///      breakpoints — mobile (<600), tablet (600–1024) and
///      desktop/laptop (≥1024). The dialog card, header type scale,
///      form-field spacing, and image-preview box all now scale with the
///      breakpoint instead of only branching on a single `isMobile`
///      flag, so tablet and laptop get their own intentionally larger,
///      better-proportioned spacing rather than reusing the desktop-ish
///      540px layout at every non-mobile size.
///   2. The action row's submit button ("Add Item" / "Save Changes") no
///      longer stretches to `Expanded(flex: 2)` — it is now a
///      breakpoint-scaled fixed width (visibly narrower than before),
///      right-aligned in the row, while the Cancel button expands to
///      fill the remaining space. On very narrow widths the two buttons
///      still automatically stack vertically (each full width) instead
///      of being squeezed, so nothing clips or overflows.
///   3. The existing `SingleChildScrollView` scrollable body and overall
///      max-height clamp against the viewport are preserved and now use
///      the same responsive padding tokens as the header/actions, so the
///      whole dialog reads as one consistent, professional surface at
///      every size.
///
/// ACTIONS-ROW PASS 6 (equal-size, smaller, right-aligned buttons): the
/// Cancel and Add Item/Save Changes buttons no longer use the Pass-5
/// `Expanded(cancel)` + fixed-width-submit split. Both buttons now share
/// ONE fixed `actionButtonWidth` sizing token (smaller than Pass 5's
/// `submitButtonWidth`, per breakpoint) and the row is right-aligned via
/// `MainAxisAlignment.end`. The same fixed width is reused in the narrow
/// "stacked" layout, right-aligned there too via
/// `CrossAxisAlignment.end`, instead of stretching to `double.infinity`.
/// Nothing else in the actions row — button styles, colors, icons, text,
/// loading spinner, `onPressed` callbacks, or the stacked/row breakpoint
/// logic — was changed.
///
/// ZERO changes were made to `_formKey`, `_submit`, `_cleanImageUrl`,
/// validators, `onSaved`/`onChanged` callbacks, `MenuService` calls,
/// `Navigator.of(context).pop(...)` calls, the availability switch logic,
/// the "No Category Found" fallback dialog's logic, or any other
/// business logic — this pass is layout/sizing only.
///
/// SAME-LINE PASS 9 (mobile buttons on one line): previously, below
/// `_Responsive.stackedActionsBreakpoint` (360px), the actions
/// `LayoutBuilder` dropped Cancel and Add Item/Save Changes into a
/// `Column` so they appeared on two separate lines on very narrow/mobile
/// widths. That stacking branch was removed — the two buttons now always
/// render side-by-side in one `Row`, right-aligned, on mobile as well as
/// tablet/desktop. The buttons' shared `actionButtonWidth` sizing,
/// `MainAxisAlignment.end` alignment, styles, icons, text, loading
/// spinner, and `onPressed` callbacks are all unchanged — only the
/// narrow-width stacking branch was removed.
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

  static const Color success = Color(0xFF44AF70); // Fresh Green
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
  /// language used across MenuScreen / StaffScreen / CategoryFormDialog.
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
/// RESPONSIVE PASS 5: small, self-contained sizing helper. Pure UI sizing
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
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 40);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
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
            ? 580.0
            : width * 0.94;
    return available < ideal ? available : ideal;
  }

  /// The dialog card's max height, so it never overflows short viewports
  /// — the form body scrolls internally instead.
  double get dialogMaxHeight => height * (isMobile ? 0.88 : 0.86);

  // ── Header ──────────────────────────────────────────────────────────
  double get headerHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get headerTopPad => isDesktop ? 30 : (isTablet ? 27 : 24);
  double get headerRightPad => isDesktop ? 22 : (isTablet ? 18 : 16);
  double get headerBottomPad => isDesktop ? 24 : (isTablet ? 22 : 20);

  double get iconBlockSize => isDesktop ? 56 : (isTablet ? 52 : 48);
  double get iconBlockRadius => isDesktop ? 16 : (isTablet ? 15 : 14);
  double get iconSize => isDesktop ? 26 : (isTablet ? 24 : 22);

  double get titleGap => isDesktop ? 18 : (isTablet ? 16 : 14);
  double get titleFontSize => isDesktop ? 24 : (isTablet ? 22 : 19);
  double get subtitleFontSize => isDesktop ? 13.5 : (isTablet ? 13 : 12.5);
  double get subtitleGap => isDesktop ? 7 : 6;

  double get closeButtonSize => isDesktop ? 40 : (isTablet ? 38 : 36);
  double get closeIconSize => isDesktop ? 20 : (isTablet ? 19 : 18);

  double get hairlineGap => isDesktop ? 18 : (isTablet ? 17 : 16);

  // ── Form body ───────────────────────────────────────────────────────
  double get bodyHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get bodyTopPad => isDesktop ? 30 : (isTablet ? 28 : 26);
  double get bodyBottomPad => isDesktop ? 12 : (isTablet ? 10 : 8);

  double get sectionGap => isDesktop ? 26 : (isTablet ? 24 : 22);
  double get imagePreviewHeight => isDesktop ? 160 : (isTablet ? 145 : 130);

  // ── Actions ─────────────────────────────────────────────────────────
  double get actionsHPad => isDesktop ? 32 : (isTablet ? 28 : 24);
  double get actionsTopPad => isDesktop ? 18 : (isTablet ? 17 : 16);
  double get actionsBottomPad => isDesktop ? 26 : (isTablet ? 25 : 24);
  double get actionGap => isDesktop ? 14 : (isTablet ? 13 : 12);
  double get actionVerticalPad => isDesktop ? 17 : (isTablet ? 15.5 : 14);
  double get actionFontSize => isDesktop ? 15.5 : (isTablet ? 15 : 14.5);

  /// ACTIONS-ROW PASS 6: fixed width shared by BOTH the Cancel and the
  /// Add Item/Save Changes buttons, per breakpoint. Smaller than Pass
  /// 5's `submitButtonWidth` so the pair reads as a compact,
  /// equally-sized button group instead of Cancel stretching to fill the
  /// row.
  double get actionButtonWidth => isDesktop ? 132 : (isTablet ? 122 : 110);

  /// Below this width the Cancel / Submit row is cramped, so the actions
  /// stack vertically instead (tiny phones only — normal mobile widths
  /// stay as a row).
  static const double stackedActionsBreakpoint = 360;
}

class ItemFormDialog extends StatefulWidget {
  final List<MenuCategory> categories;
  final MenuItem? item;
  final String? initialCategoryId;

  const ItemFormDialog({
    super.key,
    required this.categories,
    this.item,
    this.initialCategoryId,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late String _price;
  late String _imageUrl;
  final _imageController = TextEditingController();
  String _cleanedPreview = '';
  String? _selectedCategoryId;
  late bool _isAvailable;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.item?.name ?? '';
    _description = widget.item?.description ?? '';
    _price = widget.item != null ? widget.item!.price.toStringAsFixed(2) : '';
    _imageUrl = widget.item?.imageUrl ?? '';
    _imageController.text = _imageUrl;
    _cleanedPreview = _cleanImageUrl(_imageUrl);
    _isAvailable = widget.item?.isAvailable ?? true;

    if (widget.item != null) {
      _selectedCategoryId = widget.item!.categoryId;
    } else if (widget.initialCategoryId != null &&
        widget.initialCategoryId!.isNotEmpty) {
      _selectedCategoryId = widget.initialCategoryId;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  String _cleanImageUrl(String url) {
    if (url.isEmpty) return '';

    // Handle Google Search Redirects
    if (url.contains('google.com/imgres')) {
      try {
        final uri = Uri.parse(url);
        final imgUrl = uri.queryParameters['imgurl'];
        if (imgUrl != null && imgUrl.isNotEmpty) return imgUrl;
      } catch (_) {}
    }

    // Handle Bing Search Redirects
    if (url.contains('bing.com/images/search')) {
      try {
        final uri = Uri.parse(url);
        final imgUrl = uri.queryParameters['imgurl'];
        if (imgUrl != null && imgUrl.isNotEmpty) return imgUrl;
      } catch (_) {}
    }

    // Handle base64 or data urls (optional, but good to keep)
    if (url.startsWith('data:image')) return url;

    // Basic validation: if it doesn't start with http, it's likely invalid
    if (!url.startsWith('http')) return '';

    return url;
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: _Palette.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final body = {
        'name': _name,
        'description': _description.isEmpty ? null : _description,
        'price': double.tryParse(_price) ?? 0.0,
        'image_url': _imageUrl.isEmpty ? null : _imageUrl,
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
      };

      if (widget.item == null) {
        await MenuService.createItem(body);
      } else {
        await MenuService.updateItem(widget.item!.id, body);
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
    String? hint,
    String? helperText,
    TextStyle? helperStyle,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      helperMaxLines: 2,
      helperStyle: helperStyle ??
          GoogleFonts.inter(color: _Palette.textMuted, fontSize: 11),
      prefixText: prefixText,
      prefixStyle: GoogleFonts.inter(
        color: _Palette.milanoRedDeep,
        fontWeight: FontWeight.w700,
      ),
      suffixIcon: suffixIcon,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
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

  Widget _fieldLabel(String text, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
            text.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: _Palette.milanoRedDeep,
              letterSpacing: 0.6,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _Palette.softYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _Palette.milanoRedDeep,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _Palette.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: _Palette.danger,
            size: 26,
          ),
        ),
        title: Text(
          'No Category Found',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _Palette.textDark,
          ),
        ),
        content: Text(
          'You must create a category first before adding an item.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.milanoRed,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    final size = MediaQuery.of(context).size;
    final r = _Responsive(size.width, size.height);
    final isMobile = r.isMobile;
    final isEditing = widget.item != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: r.insetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.dialogMaxWidth),
        child: Container(
          constraints: BoxConstraints(maxHeight: r.dialogMaxHeight),
          decoration: BoxDecoration(
            color: _Palette.cardWhite,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _Palette.paleRose),
            boxShadow: _Palette.glowShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header (mini navbar) ─────────────────────────────────
              // PASS 4/5: PUREDINE Deep Wine Maroon → Wine diagonal
              // gradient band with a soft warm-gold corner glow, a large
              // very faint watermark emblem, a subtle diagonal glass
              // sheen, and a warm-gold hairline along the bottom edge.
              // Sizing now scales per breakpoint via `_Responsive`. No
              // form fields, validation, save/submit, image-cleaning
              // logic, or dialog-dismiss behavior was touched.
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
                    // warm-gold corner glow, a large very faint watermark
                    // emblem behind the copy, and a diagonal glass sheen.
                    // Purely decorative, clipped to the header's own
                    // bounds — mirrors StaffScreen's header exactly.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRect(
                          child: Stack(
                            children: [
                              Positioned(
                                top: -60,
                                right: -40,
                                child: Container(
                                  width: 190,
                                  height: 190,
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
                                      ? Icons.edit_note_rounded
                                      : Icons.restaurant_menu_rounded,
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
                          // purely decorative, recolored to sit on the
                          // wine backdrop.
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
                              // Icon block — translucent white fill with a
                              // gold ring, reading clearly on the wine
                              // backdrop. Icon still follows the same
                              // isEditing condition as before.
                              Container(
                                width: r.iconBlockSize,
                                height: r.iconBlockSize,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius:
                                      BorderRadius.circular(r.iconBlockRadius),
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
                                      : Icons.add_box_rounded,
                                  color: Colors.white,
                                  size: r.iconSize,
                                ),
                              ),
                              SizedBox(width: r.titleGap),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // White → gold ShaderMask title,
                                    // matching StaffScreen/CategoryForm-
                                    // Dialog's title treatment.
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
                                            ? 'Edit Menu Item'
                                            : 'Add Menu Item',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: r.titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: r.subtitleGap),
                                    Text(
                                      isEditing
                                          ? 'Update the details for this item'
                                          : 'Add a new dish to your menu',
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
                              // Close button — the same circular "glass"
                              // treatment StaffScreen/CategoryFormDialog
                              // use, so it reads clearly against the wine
                              // backdrop. The onPressed callback is
                              // completely unchanged.
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(false),
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
                          // Thin gold gradient hairline — same soft
                          // divider language used across the rest of the
                          // app's headers.
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

              // ── Scrollable form body ──────────────────────────────────
              // Uses the PUREDINE main-background tint so the content area
              // reads as a distinct "panel" beneath the wine header
              // instead of blending flatly into the white card.
              Flexible(
                child: Container(
                  color: _Palette.canvas,
                  child: SingleChildScrollView(
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
                          _fieldLabel('Category'),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategoryId,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _Palette.milanoRed,
                              ),
                              style: GoogleFonts.inter(
                                color: _Palette.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _fieldDecoration(
                                label: 'Select category',
                                icon: Icons.category_rounded,
                              ),
                              items: widget.categories.map((c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategoryId = val),
                              validator: (val) =>
                                  val == null ? 'Required' : null,
                            ),
                          ),
                          SizedBox(height: r.sectionGap),
                          _fieldLabel('Item Name'),
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
                              ),
                              decoration: _fieldDecoration(
                                label: 'e.g. Margherita Pizza',
                                icon: Icons.restaurant_menu_rounded,
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Required'
                                      : null,
                              onSaved: (val) => _name = val!.trim(),
                            ),
                          ),
                          SizedBox(height: r.sectionGap),
                          _fieldLabel('Price'),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: TextFormField(
                              initialValue: _price,
                              style: GoogleFonts.inter(
                                color: _Palette.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _fieldDecoration(
                                label: 'Price',
                                icon: Icons.payments_rounded,
                                prefixText: '₹ ',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (val) =>
                                  val == null || double.tryParse(val) == null
                                      ? 'Valid price required'
                                      : null,
                              onSaved: (val) => _price = val!.trim(),
                            ),
                          ),
                          SizedBox(height: r.sectionGap),
                          _fieldLabel('Image URL', badge: 'OPTIONAL'),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: TextFormField(
                              controller: _imageController,
                              style:
                                  GoogleFonts.inter(color: _Palette.textDark),
                              decoration: _fieldDecoration(
                                label: 'Image URL',
                                icon: Icons.link_rounded,
                                hint: 'https://example.com/image.jpg',
                                helperText:
                                    '💡 Tip: Right-click any image online and select "Copy Image Address"',
                                helperStyle: GoogleFonts.inter(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                                suffixIcon: _imageController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                          color: _Palette.textMuted,
                                        ),
                                        onPressed: () {
                                          _imageController.clear();
                                          setState(() => _cleanedPreview = '');
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _cleanedPreview = _cleanImageUrl(val.trim());
                                });
                              },
                              onSaved: (val) =>
                                  _imageUrl = _cleanImageUrl(val?.trim() ?? ''),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // --- Image Preview Section ---
                          Container(
                            height: r.imagePreviewHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _Palette.canvasDeep,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _Palette.paleRose),
                              boxShadow: [
                                BoxShadow(
                                  color: _Palette.milanoRedDeep.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _cleanedPreview.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: _Palette.textMuted.withValues(
                                          alpha: 0.6,
                                        ),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Image Preview',
                                        style: GoogleFonts.inter(
                                          color: _Palette.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.network(
                                      _cleanedPreview,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.broken_image_rounded,
                                            color: _Palette.danger,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Invalid Image URL',
                                            style: GoogleFonts.inter(
                                              color: _Palette.danger,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          if (_cleanedPreview.isNotEmpty &&
                              _cleanedPreview != _imageController.text)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: _Palette.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Direct link extracted successfully!',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: _Palette.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: r.sectionGap),
                          _fieldLabel('Description', badge: 'OPTIONAL'),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: TextFormField(
                              initialValue: _description,
                              style:
                                  GoogleFonts.inter(color: _Palette.textDark),
                              maxLines: 3,
                              decoration: _fieldDecoration(
                                label: 'Short description of this item',
                                icon: Icons.notes_rounded,
                              ),
                              onSaved: (val) =>
                                  _description = val?.trim() ?? '',
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _Palette.paleRose),
                              boxShadow: _Palette.softShadow,
                            ),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(
                                'Available',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _Palette.textDark,
                                ),
                              ),
                              subtitle: Text(
                                _isAvailable
                                    ? 'Visible to customers right now'
                                    : 'Hidden from customers',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: _Palette.textMuted,
                                ),
                              ),
                              activeThumbColor: _Palette.success,
                              value: _isAvailable,
                              onChanged: (val) =>
                                  setState(() => _isAvailable = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Actions ───────────────────────────────────────────────
              // ACTIONS-ROW PASS 6: Cancel and Add Item/Save Changes are
              // both wrapped to the SAME fixed `r.actionButtonWidth`
              // (smaller than Pass 5's `submitButtonWidth`), and the row
              // is right-aligned instead of Cancel stretching via
              // `Expanded`. Everything else here — styles, icons, text,
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
                                      isEditing ? 'Save Changes' : 'Add Item',
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
                    // Cancel stretching to fill the row.
                    final sizedCancelButton = SizedBox(
                      width: r.actionButtonWidth,
                      child: cancelButton,
                    );
                    final sizedSubmitButton = SizedBox(
                      width: r.actionButtonWidth,
                      child: submitButton,
                    );

                    // SAME-LINE PASS 9: previously, below
                    // `_Responsive.stackedActionsBreakpoint`, the two
                    // buttons dropped into a `Column` (two lines) on very
                    // narrow/mobile widths. Cancel and Add Item/Save
                    // Changes now always render side-by-side in one
                    // `Row`, on mobile as well as tablet/desktop — the
                    // fixed `actionButtonWidth` sizing, right alignment,
                    // button styles, icons, text, loading spinner, and
                    // `onPressed` callbacks are all unchanged.
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
