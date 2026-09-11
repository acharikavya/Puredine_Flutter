import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// MenuScreen / AdminDashboardScreen exactly. Used ONLY for this dialog's
/// restyle. Nothing here touches AppColors or any other file — pure UI
/// enhancement, no logic changed anywhere here. The header mirrors the same
/// decorative language (ribbon accents, dotted divider line, radial glow,
/// title underline) used on the Menu screen's navbar, so the dialog reads
/// as part of the same brand the moment it opens.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity (a richer four-stop diagonal
/// gradient, a faint watermark emblem behind the icon block, and a fine
/// glass highlight line along the top edge) matching the Orders / Admin
/// Dashboard / staff-side screens' Pass-2 treatment. No form validation,
/// submit logic, MenuService calls, or dialog-dismiss behavior was touched
/// anywhere in this pass — only presentation changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF2E0808); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color danger = Color(0xFFC62828);

  // UI-ENHANCEMENT PASS 2: promoted from a flat 3-stop wash to a richer
  // 4-stop diagonal gradient with explicit stops — matches the Orders
  // screen header's "faceted" surface language exactly.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRed, milanoRedDeep, milanoRedDarkest],
    stops: [0.0, 0.4, 0.75, 1.0],
  );

  /// Themed soft shadow for resting surfaces — mirrors the shared shadow
  /// language used across MenuScreen / AdminDashboardScreen.
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

  /// Themed elevated glow shadow — used for the whole dialog card and the
  /// primary action button so both read as "lifted" above the backdrop.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.28),
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
        child: Icon(icon, color: _Palette.milanoRedDeep, size: 20),
      ),
      filled: true,
      fillColor: _Palette.canvas,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.milanoRedDeep, width: 1.6),
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
            border: Border.all(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            ),
            boxShadow: _Palette.glowShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header (mini navbar) ─────────────────────────────────
              // Mirrors the Orders/Dashboard Pass-2 header treatment: a
              // richer four-stop brand gradient, decorative diagonal
              // ribbons, a soft radial glow behind the icon block, a large
              // faint watermark emblem, a fine glass highlight line along
              // the top edge, a dotted texture accent, and a gold underline
              // beneath the title — so the dialog feels like a natural
              // extension of the same "command bar" language used app-wide.
              ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _Palette.headerGradient,
                    border: const Border(
                      bottom: BorderSide(
                        color: _Palette.lemonChiffon,
                        width: 3.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.32),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Decorative diagonal ribbon accents (purely
                        // cosmetic)
                        Positioned(
                          top: -46,
                          right: -30,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Container(
                              width: 180,
                              height: 74,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _Palette.lemonChiffon
                                        .withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: -40,
                          child: Transform.rotate(
                            angle: 0.4,
                            child: Container(
                              width: 160,
                              height: 60,
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
                        // Soft radial glow behind the icon block, adding
                        // depth without affecting any layout or logic.
                        Positioned(
                          top: -30,
                          left: -20,
                          child: Container(
                            width: 140,
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

                        // ── Faint watermark emblem — a unique signature
                        // touch this header didn't previously have,
                        // sitting low-opacity behind the copy on the right
                        // edge, never competing with the title or close
                        // button. Matches the Orders / Admin Dashboard
                        // hero's Pass-2 watermark treatment, scaled down
                        // for the dialog's compact header.
                        Positioned(
                          right: -14,
                          bottom: -16,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.07,
                              child: Icon(
                                isEditing
                                    ? Icons.edit_rounded
                                    : Icons.create_new_folder_rounded,
                                size: 96,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Fine dotted texture accent — matches the dashed
                        // dot row used on the Menu/Dashboard headers.
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  width: 3.5,
                                  height: 3.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _Palette.lemonChiffon.withValues(
                                      alpha: i == 2 ? 0.85 : 0.28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Fine glass highlight line along the very top
                        // edge, giving the header a polished, "premium
                        // glass" finish — matches the Orders / Admin
                        // Dashboard headers' top edge treatment.
                        Positioned(
                          top: 0,
                          left: 20,
                          right: 20,
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
                          padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _Palette.lemonChiffon
                                        .withValues(alpha: 0.4),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _Palette.lemonChiffon
                                          .withValues(alpha: 0.18),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEditing
                                      ? Icons.edit_rounded
                                      : Icons.create_new_folder_rounded,
                                  color: _Palette.lemonChiffon,
                                  size: 23,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEditing
                                          ? 'Edit Category'
                                          : 'Create Category',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Container(
                                      width: 48,
                                      height: 2.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: LinearGradient(
                                          colors: [
                                            _Palette.lemonChiffon
                                                .withValues(alpha: 0.9),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isEditing
                                          ? 'Update the details for this category'
                                          : 'Add a new category to your menu',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(false),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  splashRadius: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form body ─────────────────────────────────────────────
              // Given a faint cream tint (matching the app's canvas) so the
              // content area reads as a distinct "panel" beneath the header
              // instead of blending flatly into the white card.
              Container(
                color: _Palette.canvas.withValues(alpha: 0.5),
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
                              color:
                                  _Palette.lemonChiffon.withValues(alpha: 0.5),
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
                color: _Palette.canvas.withValues(alpha: 0.5),
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
                          side: BorderSide(
                            color:
                                _Palette.milanoRedDeep.withValues(alpha: 0.14),
                          ),
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
                            backgroundColor: _Palette.milanoRedDeep,
                            disabledBackgroundColor:
                                _Palette.milanoRedDeep.withValues(alpha: 0.6),
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
