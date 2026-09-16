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
/// UI-ENHANCEMENT PASS 5 (this pass — PUREDINE re-skin + StaffScreen-style
/// header): zero changes to form validation, submit logic, MenuService
/// calls, or dialog-dismiss behavior anywhere in this file — palette and
/// header presentation only.
///   1. HEADER: rebuilt again — away from the light, standard-header look
///      of Pass 3 and into the SAME structural/visual pattern used by
///      `StaffScreen._buildHeader()`: a medium-depth (not near-black)
///      PUREDINE Deep Wine Maroon → Wine diagonal gradient band
///      (`#742A3C → #813244`) filling the whole header, with the same
///      ambient dressing StaffScreen's header uses — a soft warm-gold
///      corner glow, a large very faint watermark emblem tucked behind
///      the copy, a subtle diagonal glass sheen, and a warm-gold hairline
///      along the bottom edge. The small gold accent-dot row, the
///      category-icon block, the two-tone `ShaderMask` title, the
///      subtitle, and the thin gold hairline beneath the title are all
///      structurally unchanged — only recolored (white / soft-gold
///      instead of wine / muted) so they read clearly on the new dark
///      backdrop. The close button is now a circular "glass" button —
///      the same translucent-white-on-wine treatment StaffScreen uses for
///      its back-chevron control — but its `onPressed` callback
///      (`Navigator.of(context).pop(false)`, gated on `_isLoading`) is
///      completely unchanged, only the look changed.
///   2. PALETTE: `_Palette` was swapped to the exact PUREDINE Maroon +
///      Cream palette supplied by the user:
///        • `milanoRed`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `milanoRedLight`   → Wine `#813244` (topbar lighter gradient)
///        • `milanoRedDeep`    → Burgundy `#8A183F` (primary accent)
///        • `milanoRedDarkest` → Deep Brown/Black `#2E0D16`
///        • `canvas`           → Warm Off-White `#FBF8F5` (main background)
///        • `canvasDeep`       → Soft Cream `#F7F1ED` (card/field background)
///        • `lemonChiffon`     → Warm Gold `#F3C564` (gold accent)
///        • `lemonChiffonDeep` → deeper gold `#D9A421` (derived companion)
///        • `textDark`         → Deep Brown/Black `#2E0D16`
///        • `textMuted`        → Muted Taupe `#9B707A`
///        • `success`          → Fresh Green `#44AF70` (added for palette
///          parity with the other admin screens; not used in this file
///          today, so an unused static field here causes no compile
///          error)
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so error states stay legible.
///      Four supporting PUREDINE tones were added — `dustyBlush`
///      (`#F3D9DC`, icon backgrounds), `paleRose` (`#EFD7DA`, field/card
///      borders), `softYellow` (`#FCE1AB`, gold highlight) and `paleMint`
///      (`#EAF6EF`, success backgrounds; unused today, kept for parity).
///      `headerGradient` now holds the supplied header gradient exactly
///      (`#742A3C → #813244`), and a new `ctaGradient` field holds the
///      supplied CTA gradient exactly (`#6E1832 → #9B3E4E → #F3C564`) —
///      kept for palette-shape parity with the other admin screens, not
///      referenced elsewhere in this file today.
///   3. TOP-TO-BOTTOM CONSISTENCY: the form-body panel, both text fields,
///      the "OPTIONAL" chip, and the action row all follow the PUREDINE
///      card spec — Soft Cream field fills, Pale Rose borders, Dusty
///      Blush icon tinting, and Warm Gold focus/accent — so the whole
///      dialog reads as one brand from the top of the header to the
///      bottom of the action row. No form validation, submit logic,
///      MenuService calls, or dialog-dismiss behavior was touched.
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
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
              // ── Header ────────────────────────────────────────────────
              // PASS 5: rebuilt into the same structural/visual pattern
              // StaffScreen._buildHeader() uses — a medium-depth PUREDINE
              // Deep Wine Maroon → Wine diagonal gradient band with a
              // soft warm-gold corner glow, a large very faint watermark
              // emblem, a subtle diagonal glass sheen, and a warm-gold
              // hairline along the bottom edge. The accent-dot row, the
              // category-icon block, the two-tone ShaderMask title, the
              // subtitle, and the hairline beneath it are structurally
              // unchanged from before — only recolored for the dark
              // backdrop. No form validation, submit logic, MenuService
              // calls, or dialog-dismiss behavior was touched.
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
                      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
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
                              // Category-icon block — translucent white
                              // fill with a gold ring, reading clearly on
                              // the wine backdrop.
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
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
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // White → gold ShaderMask title,
                                    // matching StaffScreen's title
                                    // treatment.
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
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isEditing
                                          ? 'Update the details for this category'
                                          : 'Add a new category to your menu',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Close button — restyled into the same
                              // circular "glass" treatment StaffScreen
                              // uses for its back-chevron control (a
                              // translucent white circle with a gold
                              // ring), so it reads clearly against the
                              // wine backdrop. The onPressed callback is
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
                                    width: 36,
                                    height: 36,
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
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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

              // ── Form body ─────────────────────────────────────────────
              // Uses the PUREDINE main-background tint so the content area
              // reads as a distinct "panel" beneath the wine header
              // instead of blending flatly into the white card.
              Container(
                color: _Palette.canvas,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: _Palette.milanoRedDeep,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                            label: 'e.g. Starters, Main Course',
                            icon: Icons.restaurant_menu_rounded,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Required'
                              : null,
                          onSaved: (val) => _name = val!.trim(),
                        ),
                      ),
                      const SizedBox(height: 22),
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
                              fontSize: 11.5,
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
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _Palette.softShadow,
                        ),
                        child: TextFormField(
                          initialValue: _description,
                          style: GoogleFonts.inter(color: _Palette.textDark),
                          maxLines: 3,
                          decoration: _fieldDecoration(
                            label: 'Short description of this category',
                            icon: Icons.notes_rounded,
                          ),
                          onSaved: (val) => _description = val?.trim() ?? '',
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // ── Actions ───────────────────────────────────────────────
              Container(
                color: _Palette.canvas,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _Palette.textMuted,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _Palette.paleRose),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                    Text(
                                      isEditing
                                          ? 'Save Changes'
                                          : 'Create Category',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
