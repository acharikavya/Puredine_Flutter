import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// THEME — PUREDINE Maroon + Cream
/// Purely a UI palette used inside this file. No business logic depends on
/// these — they only drive colors/gradients/shadows for a premium,
/// restaurant-friendly look.
///
/// These values are intentionally identical to the `_Palette` class used in
/// StaffScreen (staff_screen.dart) / MenuScreen, so this dialog reads as
/// part of the exact same brand instead of a separately-themed surface:
///   maroonLight  == StaffScreen's _Palette.milanoRedLight
///   maroon       == StaffScreen's _Palette.milanoRed
///   maroonDeep   == StaffScreen's _Palette.milanoRedDeep
///   maroonDarkest== StaffScreen's _Palette.milanoRedDarkest
///   cream        == StaffScreen's _Palette.canvas
///   creamLighter == StaffScreen's _Palette.cardWhite
///   gold         == StaffScreen's _Palette.lemonChiffon
///   goldDark     == StaffScreen's _Palette.lemonChiffonDeep
///   textDark     == StaffScreen's _Palette.textDark
///   textMuted    == StaffScreen's _Palette.textMuted
///   success      == StaffScreen's _Palette.success
///   danger is kept as a clear alert red (not part of the supplied
///   palette) so error states stay legible.
///
/// UI-ENHANCEMENT PASS 2: the header was pushed further into its own
/// distinctive "command bar" identity — a richer four-stop diagonal
/// gradient, a large faint watermark emblem behind the title, a fine
/// glass highlight line along the top edge, and a dotted texture accent
/// — matching the Admin Orders / Dashboard / staff-side screens' Pass-2
/// treatment. No selection logic, save/API calls, search filtering, or
/// item-payload logic was touched anywhere in this pass — only the
/// header's presentation changed.
///
/// UI-ENHANCEMENT PASS 3: re-balanced the same Milano Red/Wine + Gold
/// Chiffon identity so the dialog read as "majorly white" overall, with
/// maroon and gold used only as accents rather than a solid header fill.
///
/// UI-ENHANCEMENT PASS 4 (this pass): presentation-only, exactly like
/// every pass above — no selection logic, save/API calls, search
/// filtering, or item-payload logic was touched anywhere in this file,
/// and no field, callback, or keyword was renamed.
///   1. PALETTE — full PUREDINE mapping, mirroring the exact swap already
///      done on StaffScreen/ManualOrderDialog. Every field name inside
///      `_SpecialTheme` is unchanged on purpose (every widget in this
///      file already reads from these exact names, so swapping only the
///      underlying `Color` values re-skins the whole dialog with no
///      other code touched):
///        • `maroon`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `maroonLight`   → Wine `#813244` (topbar lighter gradient)
///        • `maroonDeep`    → Burgundy `#8A183F` (primary accent)
///        • `maroonDarkest` → Deep Brown/Black `#2E0D16`
///        • `cream`         → Warm Off-White `#FBF8F5` (main background)
///        • `creamLighter`  → kept as pure white (card surface)
///        • `gold`          → Warm Gold `#F3C564` (gold accent)
///        • `goldDark`      → deeper gold `#D9A421` (derived companion)
///        • `textDark`      → Deep Brown/Black `#2E0D16`
///        • `textMuted`     → Muted Taupe `#9B707A`
///        • `success`       → Fresh Green `#44AF70`
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so error states stay legible.
///      Four supporting PUREDINE tones were ADDED as new fields — nothing
///      existing was removed — `dustyBlush` (`#F3D9DC`, icon backgrounds),
///      `paleRose` (`#EFD7DA`, card borders), `softYellow` (`#FCE1AB`,
///      gold highlight) and `paleMint` (`#EAF6EF`, success backgrounds).
///      `headerGradient` now holds the supplied header gradient exactly
///      (`#742A3C → #813244`), and `ctaGradient` holds the supplied CTA
///      gradient exactly (`#6E1832 → #9B3E4E → #F3C564`).
///   2. HEADER: rebuilt to match StaffScreen's header treatment exactly —
///      the flat white Pass-3 bar is replaced with the PUREDINE Deep Wine
///      Maroon → Wine diagonal gradient (a medium-depth, not near-black,
///      maroon band). It carries the same ambient dressing used on the
///      other admin headers: a soft warm-gold corner glow, a large very
///      faint watermark emblem (the same star glyph already used in this
///      dialog's icon chip) sitting low-opacity behind the copy, a
///      subtle diagonal glass sheen, and a warm-gold hairline along the
///      bottom edge. Structurally nothing changed: the same star icon
///      chip, the same title copy ("Today's Special"), the same subtitle
///      copy ("Curate the featured menu highlights"), the same gold glow
///      "navbar" rail underneath, the same dotted texture row, and the
///      exact same `_isSubmitting ? null : () => Navigator.pop(context)`
///      close callback (still correctly disabled while saving). Only the
///      copy's colors changed (white / soft-gold instead of maroon /
///      taupe) and the icon chip + close button were restyled from
///      Pass-3's maroon-on-white / cream-on-white "glass" look to a light
///      glass-on-wine treatment so both read clearly against the new
///      dark backdrop — their callbacks/behavior are unchanged.
///   3. TOP-TO-BOTTOM CONSISTENCY: so the whole dialog reads as one brand
///      rather than just a re-colored header, the outer dialog frame,
///      search bar, and item-card borders now use Pale Rose, the no-image
///      / broken-image item placeholders use the Dusty Blush icon-BG, and
///      the "Save Specials" CTA button now carries the supplied CTA
///      gradient (`#6E1832 → #9B3E4E → #F3C564`) instead of a flat
///      maroon fill — matching the "Login / CTA buttons" spec exactly.
///      No button's `onPressed` callback was touched.
/// ─────────────────────────────────────────────────────────────────────────
class _SpecialTheme {
  // PUREDINE Maroon + Cream — field names unchanged on purpose (see the
  // PASS 4 note above); only the underlying Color values changed.
  static const Color maroonLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color maroon =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color maroonDeep = Color(0xFF8A183F); // Burgundy (accent)
  static const Color maroonDarkest = Color(0xFF2E0D16); // Deep Brown/Black
  static const Color cream =
      Color(0xFFFBF8F5); // Warm Off-White (Main background)
  static const Color creamLighter = Colors.white; // Card white
  static const Color gold = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color goldDark = Color(0xFFD9A421); // Deeper Warm Gold
  static const Color textOnMaroon = Colors.white;
  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black text
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color success = Color(0xFF44AF70); // Fresh Green
  static const Color danger = Color(0xFFE0323F); // Clear alert red

  // PASS 4: four supporting PUREDINE tones added — nothing above this
  // line was removed; these are new fields only.
  static const Color dustyBlush =
      Color(0xFFF3D9DC); // Dusty Blush — icon backgrounds
  static const Color paleRose = Color(0xFFEFD7DA); // Pale Rose — card borders
  static const Color softYellow = Color(0xFFFCE1AB); // Soft Yellow highlight
  static const Color paleMint = Color(0xFFEAF6EF); // Pale Mint background

  /// The supplied top-header gradient, exactly: `#742A3C → #813244`.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [maroon, maroonLight],
  );

  /// The supplied CTA gradient, exactly: `#6E1832 → #9B3E4E → #F3C564`.
  /// Used for the primary "Save Specials" action button below.
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), gold],
  );
}

/// Dialog that lets the admin pick any existing menu items and
/// reassign them to the "Today's Special" category (creating that
/// category on-the-fly if it doesn't exist yet).
class TodaySpecialDialog extends StatefulWidget {
  final List<MenuCategory> categories;
  final List<MenuItem> allItems;

  const TodaySpecialDialog({
    super.key,
    required this.categories,
    required this.allItems,
  });

  @override
  State<TodaySpecialDialog> createState() => _TodaySpecialDialogState();
}

class _TodaySpecialDialogState extends State<TodaySpecialDialog> {
  Set<String> _specialItemIds = {};
  bool _isSubmitting = false;
  String _searchQuery = '';

  // The ID of the "Today's Special" category (null if not yet created)
  String? _specialCategoryId;

  @override
  void initState() {
    super.initState();
    _computeSpecialSelection();
  }

  void _computeSpecialSelection() {
    // Find the "Today's Special" category, if one already exists.
    MenuCategory? specialCat;
    for (final c in widget.categories) {
      final name = c.name.toLowerCase();
      if (name.contains('today') || name.contains('special')) {
        specialCat = c;
        break;
      }
    }
    _specialCategoryId =
        (specialCat == null || specialCat.id.isEmpty) ? null : specialCat.id;

    // Pre-select items already in Today's Special.
    _specialItemIds = widget.allItems
        .where((i) =>
            _specialCategoryId != null && i.categoryId == _specialCategoryId)
        .map((i) => i.id)
        .toSet();
  }

  List<MenuItem> get _filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return widget.allItems;
    return widget.allItems
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
  }

  Map<String, dynamic> _itemPayload(MenuItem item,
      {required String categoryId}) {
    return {
      'name': item.name,
      'description': item.description ?? '',
      'price': item.price,
      'is_available': item.isAvailable,
      'image_url': item.imageUrl ?? '',
      'category_id': categoryId,
      'preparation_time': item.preparationTime ?? '',
    };
  }

  Future<void> _save() async {
    setState(() => _isSubmitting = true);
    try {
      String catId = _specialCategoryId ?? '';

      // Create the category if it doesn't exist yet.
      if (catId.isEmpty) {
        final newCat = await MenuService.createCategory({
          'name': "Today's Special",
          'description': 'Daily specials curated by the chef',
        });
        if (newCat.id.isEmpty) {
          throw Exception('Category was created but returned no valid id');
        }
        catId = newCat.id;
      }

      // For each item, update its categoryId if it changed.
      final futures = <Future>[];
      for (final item in widget.allItems) {
        final shouldBeSpecial = _specialItemIds.contains(item.id);
        final isCurrentlySpecial = item.categoryId == _specialCategoryId;

        if (shouldBeSpecial && !isCurrentlySpecial) {
          // Move to Today's Special.
          futures.add(
            MenuService.updateItem(
                item.id, _itemPayload(item, categoryId: catId)),
          );
        } else if (!shouldBeSpecial && isCurrentlySpecial) {
          // Remove from Today's Special — move to first non-special category.
          final fallback = widget.categories
              .where((c) => c.id != _specialCategoryId && c.id.isNotEmpty)
              .map((c) => c.id)
              .firstOrNull;

          if (fallback != null && fallback.isNotEmpty) {
            futures.add(
              MenuService.updateItem(
                item.id,
                _itemPayload(item, categoryId: fallback),
              ),
            );
          }
          // If there's no fallback category available, we intentionally
          // leave the item where it is rather than sending an empty
          // category_id.
        }
      }

      await Future.wait(futures);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Today's Special updated!"),
            backgroundColor: _SpecialTheme.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: _SpecialTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── UI: header — UI-ENHANCEMENT PASS 4 rebuilds this to match
  // StaffScreen's header treatment: the PUREDINE Deep Wine Maroon → Wine
  // diagonal gradient, dressed with the same ambient touches (corner
  // glow, watermark emblem, glass sheen, gold hairline). The star icon
  // chip, gold glow rail, dotted texture row, title/subtitle copy, and
  // the close button's `_isSubmitting ? null : () => Navigator.pop(...)`
  // behavior are all unchanged — presentation only. ─────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        decoration: BoxDecoration(
          // PUREDINE Deep Wine Maroon → Wine diagonal gradient — a
          // medium-depth maroon band, not near-black and not white.
          gradient: _SpecialTheme.headerGradient,
          border: Border(
            bottom: BorderSide(
              color: _SpecialTheme.gold.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: _SpecialTheme.maroonDarkest.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Large faint watermark emblem — a unique signature touch
            // sitting low-opacity and large behind the copy, never
            // competing with the title or controls. Rendered in white so
            // it reads on the new dark wine backdrop.
            Positioned(
              right: -14,
              bottom: -18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    Icons.star_rounded,
                    size: 108,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Soft warm-gold corner glow — purely decorative.
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _SpecialTheme.gold.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // A subtle secondary highlight low-left, echoing the ambient
            // dressing used on the other admin headers — a soft
            // warm-white tint so it still reads on the dark backdrop.
            Positioned(
              bottom: -40,
              left: -36,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the refined decorative
            // language used on the Admin Orders / Dashboard / Staff
            // headers.
            Positioned(
              top: 4,
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
                        color: i == 2
                            ? Colors.white.withValues(alpha: 0.85)
                            : _SpecialTheme.gold.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Subtle diagonal glass sheen — a fine extra layer of depth
            // across the whole header.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.07),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Fine glass highlight line along the very top edge, kept as
            // a subtle accent.
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _SpecialTheme.gold.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon chip — a light glass-on-wine treatment so it
                    // reads clearly against the new dark backdrop.
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: _SpecialTheme.gold.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _SpecialTheme.maroonDarkest
                                .withValues(alpha: 0.25),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text('⭐', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                _SpecialTheme.gold,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              "Today's Special",
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Curate the featured menu highlights',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _HeaderCloseButton(
                      onTap:
                          _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Gold glow rail — the "navbar" accent line
                Container(
                  height: 3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        _SpecialTheme.gold.withValues(alpha: 0.0),
                        _SpecialTheme.gold,
                        _SpecialTheme.gold.withValues(alpha: 0.0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _SpecialTheme.gold.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _SpecialTheme.softYellow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _SpecialTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _SpecialTheme.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                size: 14, color: _SpecialTheme.goldDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Select items to feature as Today's Special. Unselected items are removed.",
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: _SpecialTheme.maroonDeep,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: _SpecialTheme.creamLighter,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _SpecialTheme.maroon.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style:
              GoogleFonts.inter(fontSize: 14, color: _SpecialTheme.maroonDeep),
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle:
                GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13.5),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 20, color: _SpecialTheme.maroon),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _SpecialTheme.paleRose),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _SpecialTheme.gold, width: 1.6),
            ),
            filled: true,
            fillColor: _SpecialTheme.creamLighter,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu_rounded,
                  size: 40, color: _SpecialTheme.maroon.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              Text(
                'No menu items available yet. Add items to your menu first.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: _SpecialTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredItems;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 36, color: _SpecialTheme.maroon.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'No items found',
              style: GoogleFonts.inter(color: _SpecialTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      color: _SpecialTheme.cream.withValues(alpha: 0.35),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final item = filtered[i];
          final isSelected = _specialItemIds.contains(item.id);
          final displayName =
              item.name.trim().isEmpty ? 'Unnamed item' : item.name;
          final price = item.price;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? _SpecialTheme.maroon.withValues(alpha: 0.06)
                  : _SpecialTheme.creamLighter,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _SpecialTheme.gold : _SpecialTheme.paleRose,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _SpecialTheme.gold.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _specialItemIds.add(item.id);
                  } else {
                    _specialItemIds.remove(item.id);
                  }
                });
              },
              activeColor: _SpecialTheme.maroon,
              checkColor: _SpecialTheme.gold,
              title: Text(
                displayName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: isSelected
                      ? _SpecialTheme.maroonDeep
                      : _SpecialTheme.textDark,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _SpecialTheme.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _SpecialTheme.goldDark,
                    ),
                  ),
                ),
              ),
              secondary: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _SpecialTheme.dustyBlush,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.broken_image_rounded,
                              size: 20,
                              color:
                                  _SpecialTheme.maroon.withValues(alpha: 0.4)),
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _SpecialTheme.dustyBlush,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _SpecialTheme.paleRose),
                      ),
                      child: Icon(Icons.fastfood_rounded,
                          size: 20,
                          color: _SpecialTheme.maroon.withValues(alpha: 0.55)),
                    ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _SpecialTheme.paleRose)),
        color: _SpecialTheme.creamLighter,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _SpecialTheme.maroon.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _SpecialTheme.maroon.withValues(alpha: 0.2)),
            ),
            child: Text(
              '${_specialItemIds.length} item(s) selected',
              style: GoogleFonts.inter(
                color: _SpecialTheme.maroon,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          OverflowBar(
            spacing: 12,
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (!_isSubmitting) Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: _SpecialTheme.maroonDeep,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text('Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: _SpecialTheme.ctaGradient,
                  boxShadow: [
                    BoxShadow(
                      color: _SpecialTheme.gold.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed:
                      (_isSubmitting || widget.allItems.isEmpty) ? null : _save,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('⭐', style: TextStyle(fontSize: 14)),
                  label: Text(
                    'Save Specials',
                    style: GoogleFonts.inter(
                      color: _SpecialTheme.textOnMaroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: _SpecialTheme.gold.withValues(alpha: 0.5),
                          width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Near-fullscreen, more immersive dialog footprint.
    final dialogWidth = size.width < 700 ? size.width * 0.96 : size.width * 0.6;
    final dialogHeight = size.height * 0.9;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 24,
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 320),
        decoration: BoxDecoration(
          color: _SpecialTheme.cream,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _SpecialTheme.paleRose, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _SpecialTheme.maroonDarkest.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(),
            _buildSubtitle(),
            _buildSearch(),
            Expanded(child: _buildBody()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}

/// Compact icon-only "close" control for the header — a circular glass
/// button showing only an "×" glyph. Mirrors the `_BackChevronButton` /
/// `_HeaderCloseButton` treatment used on StaffScreen/ManualOrderDialog's
/// headers for a consistent brand feel across the admin app: a
/// translucent white circle with a white "×" and a warm-gold ring, so it
/// reads clearly against the wine header backdrop.
///
/// `onTap` is nullable so it can carry through the exact same disabled
/// behavior the old `IconButton(onPressed: ...)` had — passing `null`
/// (while `_isSubmitting` is true) renders the button visibly dimmed and
/// ignores taps, exactly like a disabled `IconButton` did before.
class _HeaderCloseButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _HeaderCloseButton({required this.onTap});

  @override
  State<_HeaderCloseButton> createState() => _HeaderCloseButtonState();
}

class _HeaderCloseButtonState extends State<_HeaderCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (enabled && _isHovered)
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: (enabled && _isHovered)
                    ? _SpecialTheme.gold.withValues(alpha: 0.7)
                    : _SpecialTheme.gold.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: (enabled && _isHovered)
                  ? [
                      BoxShadow(
                        color: _SpecialTheme.gold.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
