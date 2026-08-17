import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// MenuScreen / AdminDashboardScreen / CategoryFormDialog exactly. Used
/// ONLY for this dialog's restyle. Nothing here touches AppColors or any
/// other file — pure UI enhancement, no logic changed anywhere here. The
/// header mirrors the same decorative language (ribbon accents, dotted
/// texture line, radial glow, gold underline) used across the Menu screen
/// navbar and the Category dialog, so every surface in the admin flow
/// reads as one cohesive, professional brand.
///
/// UI-ENHANCEMENT PASS 2: brings this dialog's header up to the same
/// richer "command bar" identity used on the Orders/Menu screens — a
/// deeper four-stop diagonal gradient, a large faint watermark emblem
/// behind the title copy, and a fine glass highlight line along the very
/// top edge. No form fields, validation, save/submit, or image-cleaning
/// logic was touched anywhere in this pass — presentation only.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF2E0909); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFC62828);

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
                color: _Palette.lemonChiffon.withValues(alpha: 0.5),
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
              backgroundColor: _Palette.milanoRedDeep,
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
    final isMobile = size.width < 600;
    final isEditing = widget.item != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isMobile ? size.width * 0.94 : 540),
        child: Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.88),
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
              // Mirrors the Menu screen's header + CategoryFormDialog:
              // brand gradient, decorative diagonal ribbons, a soft radial
              // glow behind the icon block, a fine dotted accent line, and
              // a gold underline beneath the title.
              //
              // UI-ENHANCEMENT PASS 2: upgraded from a three-stop to a
              // richer four-stop diagonal gradient, a large faint
              // watermark emblem tucked behind the copy, and a fine glass
              // highlight line along the very top edge — matching the
              // Orders/Menu screens' Pass-2 "command bar" treatment.
              ClipRect(
                child: Container(
                  decoration: BoxDecoration(
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
                    border: const Border(
                      bottom: BorderSide(
                        color: _Palette.lemonChiffon,
                        width: 3.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.milanoRed.withValues(alpha: 0.34),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative diagonal ribbon accents (purely cosmetic)
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
                                  _Palette.lemonChiffon.withValues(alpha: 0.20),
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
                      // Soft radial glow behind the icon block, adding depth
                      // without affecting any layout or logic.
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
                      // UI-ENHANCEMENT PASS 2: large faint watermark
                      // emblem — a unique signature touch this header
                      // didn't previously have, sitting low-opacity and
                      // large behind the copy, never competing with the
                      // title or the close button. Icon swaps between
                      // "edit" and "add" to echo the header's own state,
                      // purely decorative.
                      Positioned(
                        right: -14,
                        bottom: -16,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.07,
                            child: Icon(
                              isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.restaurant_menu_rounded,
                              size: 108,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Fine dotted texture accent — matches the dashed dot
                      // row used on the Menu/Dashboard headers.
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
                      // UI-ENHANCEMENT PASS 2: fine glass highlight line
                      // along the very top edge of the header — purely
                      // cosmetic, gives the header a more polished,
                      // "premium panel" finish matching the Menu/Orders
                      // headers' top edge treatment.
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
                                Colors.white.withValues(alpha: 0.32),
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
                                    : Icons.add_box_rounded,
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
                                        ? 'Edit Menu Item'
                                        : 'Add Menu Item',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: isMobile ? 19 : 22,
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
                                        ? 'Update the details for this item'
                                        : 'Add a new dish to your menu',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
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

              // ── Scrollable form body ──────────────────────────────────
              // Given a faint cream tint (matching the app's canvas) so the
              // content area reads as a distinct "panel" beneath the header
              // instead of blending flatly into the white card.
              Flexible(
                child: Container(
                  color: _Palette.canvas.withValues(alpha: 0.5),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
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
                                color: _Palette.milanoRedDeep,
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
                          const SizedBox(height: 22),
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
                          const SizedBox(height: 22),
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
                          const SizedBox(height: 22),
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
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _Palette.canvasDeep,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.12,
                                ),
                              ),
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
                          const SizedBox(height: 22),
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
                              border: Border.all(
                                color: _Palette.milanoRedDeep.withValues(
                                  alpha: 0.12,
                                ),
                              ),
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
                                      isEditing ? 'Save Changes' : 'Add Item',
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
