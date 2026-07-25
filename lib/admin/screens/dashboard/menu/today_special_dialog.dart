import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// THEME 1 — Dark Maroon × Soft Cream × Gold Glow
/// Purely a UI palette used inside this file. No business logic depends on
/// these — they only drive colors/gradients/shadows for a premium,
/// restaurant-friendly look.
/// ─────────────────────────────────────────────────────────────────────────
class _SpecialTheme {
  static const Color maroon = Color(0xFF8B1D1D); // Primary
  static const Color maroonDark = Color(0xFF5E1212); // Deeper shade for depth
  static const Color maroonDeeper = Color(0xFF3E0B0B); // Gradient end
  static const Color cream = Color(0xFFFDF3E7); // Light / Soft Cream
  static const Color creamLighter = Color(0xFFFFFBF5); // Card background
  static const Color gold = Color(0xFFF4C430); // Gold Glow
  static const Color goldDark = Color(0xFFC9971F); // Gold shadow/border
  static const Color textOnMaroon = Color(0xFFFFF8ED);
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
            backgroundColor: AppColors.success,
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
            backgroundColor: AppColors.danger,
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

  // ── UI: "Navbar" style header — gradient maroon with a glowing gold rail ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SpecialTheme.maroon,
            _SpecialTheme.maroonDark,
            _SpecialTheme.maroonDeeper,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: _SpecialTheme.maroonDeeper.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _SpecialTheme.gold.withOpacity(0.16),
                  border: Border.all(
                    color: _SpecialTheme.gold.withOpacity(0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _SpecialTheme.gold.withOpacity(0.35),
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
                    Text(
                      "Today's Special",
                      style: GoogleFonts.playfairDisplay(
                        color: _SpecialTheme.textOnMaroon,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Curate the featured menu highlights',
                      style: GoogleFonts.inter(
                        color: _SpecialTheme.gold.withOpacity(0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withOpacity(0.08),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: _SpecialTheme.textOnMaroon),
                  splashRadius: 22,
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                ),
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
                  _SpecialTheme.gold.withOpacity(0.0),
                  _SpecialTheme.gold,
                  _SpecialTheme.gold.withOpacity(0.0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _SpecialTheme.gold.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _SpecialTheme.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _SpecialTheme.gold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _SpecialTheme.gold.withOpacity(0.2),
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
                color: _SpecialTheme.maroonDark,
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
              color: _SpecialTheme.maroon.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.inter(
              fontSize: 14, color: _SpecialTheme.maroonDeeper),
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
              borderSide:
                  BorderSide(color: _SpecialTheme.maroon.withOpacity(0.12)),
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
                  size: 40, color: _SpecialTheme.maroon.withOpacity(0.3)),
              const SizedBox(height: 10),
              Text(
                'No menu items available yet. Add items to your menu first.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textMuted),
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
                size: 36, color: _SpecialTheme.maroon.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              'No items found',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      color: _SpecialTheme.cream.withOpacity(0.35),
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
                  ? _SpecialTheme.maroon.withOpacity(0.06)
                  : _SpecialTheme.creamLighter,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _SpecialTheme.gold
                    : Colors.black.withOpacity(0.06),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _SpecialTheme.gold.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                      ? _SpecialTheme.maroonDeeper
                      : AppColors.textDark,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _SpecialTheme.gold.withOpacity(0.18),
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
                            color: _SpecialTheme.cream,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.broken_image_rounded,
                              size: 20,
                              color: _SpecialTheme.maroon.withOpacity(0.4)),
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _SpecialTheme.cream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _SpecialTheme.maroon.withOpacity(0.12)),
                      ),
                      child: Icon(Icons.fastfood_rounded,
                          size: 20,
                          color: _SpecialTheme.maroon.withOpacity(0.55)),
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
        border: Border(
            top: BorderSide(color: _SpecialTheme.maroon.withOpacity(0.1))),
        color: _SpecialTheme.creamLighter,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: _SpecialTheme.maroon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _SpecialTheme.maroon.withOpacity(0.2)),
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
                  foregroundColor: _SpecialTheme.maroonDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text('Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [_SpecialTheme.maroon, _SpecialTheme.maroonDeeper],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _SpecialTheme.gold.withOpacity(0.35),
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
                            color: _SpecialTheme.gold,
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
                          color: _SpecialTheme.gold.withOpacity(0.5), width: 1),
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
          border: Border.all(
              color: _SpecialTheme.gold.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _SpecialTheme.maroonDeeper.withOpacity(0.35),
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
