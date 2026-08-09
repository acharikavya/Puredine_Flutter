import 'package:restaurant_unified_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/menu_service.dart';
import 'category_form_dialog.dart';
import 'item_form_dialog.dart';
import 'manual_order_dialog.dart';
import 'today_special_dialog.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// AdminDashboardScreen and CategoryFormDialog. Used ONLY for this screen's
/// restyle. Nothing here touches AppColors or any other file — pure UI
/// enhancement, no logic changed anywhere here. Every section of the screen
/// (header, sidebar, search bar, bottom sheet, dialogs, cards) now pulls
/// from this single source so the whole screen reads as one consistent
/// brand, matching the navbar/header treatment used on the dashboard.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header/backdrop up to the
/// same richer "command bar" identity used on the Orders screen — a
/// deeper four-stop diagonal gradient, a large faint watermark emblem
/// behind the header copy, and an extra diagonal glass sheen sweeping
/// across the body backdrop. No data loading, filtering, mutation, or
/// navigation logic was touched anywhere in this pass — presentation only.
///
/// UI-ENHANCEMENT PASS 3: "Read more" on a card no longer opens a popup
/// dialog. Tapping it expands the description in place instead of
/// showing a dialog.
///
/// UI-ENHANCEMENT PASS 4: two purely visual refinements —
///   1. The description under each item name is now a single, clamped
///      line (instead of two) when collapsed, matching the reference
///      design's compact card copy.
///   2. All menu item cards are now uniform in size again. The grid
///      switched from the Pass‑3 "masonry" (free-height) column layout
///      back to a standard `GridView` with a fixed aspect ratio, so
///      every card — across every row, every screen size — occupies the
///      exact same footprint. To keep "Read more" fully functional
///      without breaking that uniform sizing, the description now lives
///      in a small fixed-height box: collapsed it clips to one line,
///      and expanded ("Read more" tapped) that same box reveals the
///      complete description text via an internal scroll — the box's
///      height never changes, so the card itself never changes size and
///      neighbouring cards never shift. No data loading, mutation, or
///      callback logic was touched in this pass — presentation only.
///
/// UI-ENHANCEMENT PASS 5: the Pass‑4 grid's `childAspectRatio` values were
/// taller than the card's actual content needed, leaving a visible empty
/// gap under the "Edit Item" button. The ratios in `_buildItemsGrid` were
/// tuned to closely match the card's real content height so every card
/// sat snug with no wasted space at the bottom.
///
/// UI-ENHANCEMENT PASS 6: fixes a problem the Pass‑4/5 fixed-
/// aspect-ratio `GridView` introduced — because every card was locked to
/// the exact same cell height, tapping "Read more" couldn't actually grow
/// the card; the extra description text was confined to a small internal
/// scroll box, which pushed the "Edit Item" button out of easy view.
///
/// The grid is back to the same lightweight, dependency-free "masonry"
/// column layout used in Pass 3 (see `_buildItemsGrid`): items are split
/// left-to-right, top-to-bottom into `cols` column buckets, each laid out
/// as an ordinary `Column`, so a card is free to grow when its own
/// description expands without affecting its neighbours. Crucially, the
/// description is now a single collapsed line everywhere (from Pass 4),
/// so every card's *collapsed* content is effectively identical in size —
/// meaning the masonry layout naturally renders every collapsed card at
/// the same height, with zero wasted space, exactly like a uniform grid.
/// Tapping "Read more" then grows only that one card via `AnimatedSize`
/// to fit the full description, pushing its own "Edit Item" button down
/// with it — the button stays fully visible, never clipped or scrolled
/// out of view. Tapping "Show less" shrinks it back. This applies
/// identically on mobile and desktop; the same masonry logic just uses a
/// different column count depending on screen width. No data loading,
/// mutation, or callback logic was touched — only how cards size and grow.
///
/// UI-ENHANCEMENT PASS 7 (this pass): "Read more" now sits inline at the
/// end of the same truncated description line (matching the reference
/// design's "Tender, boneless murgh ... Read More" style) instead of on
/// its own line underneath. Since Flutter's automatic `TextOverflow.
/// ellipsis` would just as happily cut the appended "Read more" text off
/// along with the rest of the sentence, the collapsed description is now
/// measured with a `TextPainter` to find exactly how much of the
/// description fits alongside "… Read more" on one line, so the link is
/// always fully visible right after the truncated text. Expanding still
/// works exactly the same way as Pass 6 (`AnimatedSize` grows the card,
/// "Show less" appended inline at the end once expanded) — only where
/// "Read more"/"Show less" sits relative to the text changed. No data,
/// callback, or navigation logic was touched.
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

  /// Themed soft shadow for resting cards/panels — replaces the generic
  /// AppShadows.card so every surface shares the same warm, branded tint.
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

  /// Themed elevated/hover shadow — replaces AppShadows.glow.
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.20),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
}

IconData categoryIconFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('breakfast')) return Icons.free_breakfast_rounded;
  if (n.contains('soup')) return Icons.soup_kitchen_rounded;
  if (n.contains('pasta') || n.contains('noodle')) {
    return Icons.ramen_dining_rounded;
  }
  if (n.contains('main') || n.contains('curry') || n.contains('thali')) {
    return Icons.dinner_dining_rounded;
  }
  if (n.contains('burger')) return Icons.lunch_dining_rounded;
  if (n.contains('pizza')) return Icons.local_pizza_rounded;
  if (n.contains('drink') || n.contains('beverage') || n.contains('juice')) {
    return Icons.local_bar_rounded;
  }
  if (n.contains('dessert') || n.contains('sweet') || n.contains('ice')) {
    return Icons.icecream_rounded;
  }
  if (n.contains('starter') || n.contains('appetizer') || n.contains('snack')) {
    return Icons.tapas_rounded;
  }
  if (n.contains('salad')) return Icons.eco_rounded;
  if (n.contains('bread') || n.contains('bakery')) {
    return Icons.bakery_dining_rounded;
  }
  return Icons.restaurant_menu_rounded;
}

/// Purely decorative, deterministic "rating" derived from the item's own id
/// so every card shows a consistent star rating (e.g. 4.6) across rebuilds
/// without needing any new field on the MenuItem model or any service call.
/// This mirrors the rating badges shown on the reference food-app design —
/// display only, never read or written anywhere else in the app.
double _displayRatingFor(String id) {
  final h = id.hashCode.abs();
  return 4.0 + (h % 10) / 10.0; // spans 4.0 – 4.9
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuCategory> _categories = [];
  List<MenuItem> _items = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategoryId = '';
  String _searchQuery = '';

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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final cats = await MenuService.getCategories();
      final items = await MenuService.getItems();
      setState(() {
        _categories = cats;
        _items = items;
        if (!cats.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = '';
        }
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<MenuItem> get _filteredItems {
    List<MenuItem> filtered = _items;
    if (_selectedCategoryId == 'SPECIALS') {
      filtered = filtered.where((i) => i.isSpecial).toList();
    } else if (_selectedCategoryId.isNotEmpty) {
      filtered =
          filtered.where((i) => i.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
              (i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  Future<void> _toggleItem(String id) async {
    try {
      await MenuService.toggleItem(id);
      setState(() {
        final idx = _items.indexWhere((i) => i.id == id);
        if (idx != -1) {
          final item = _items[idx];
          _items[idx] = MenuItem(
            id: item.id,
            name: item.name,
            description: item.description,
            price: item.price,
            isAvailable: !item.isAvailable,
            imageUrl: item.imageUrl,
            categoryId: item.categoryId,
            preparationTime: item.preparationTime,
            isSpecial: item.isSpecial,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
      }
    }
  }

  /// Toggles whether [id] is featured as one of "Today's Special" items.
  ///
  /// This still flips the same `isSpecial` flag as before (via
  /// `MenuService.updateSpecialStatus`, unchanged) so the heart badge /
  /// "TODAY'S SPECIAL" tag on the card keeps working exactly as it did.
  ///
  /// On top of that, it now also keeps the item's *category* in sync with
  /// a "Today's Special" category — finding it if it exists, or creating
  /// it on-the-fly if it doesn't — using the exact same approach
  /// TodaySpecialDialog uses to decide which items are pre-selected
  /// (category-based, not flag-based). Without this, pressing the star
  /// here and opening the Today's Special dialog could disagree about
  /// which items are actually featured; now tapping the star here adds
  /// (or removes) the item from that same Today's Special list.
  Future<void> _toggleSpecial(String id) async {
    final item = _items.firstWhere((i) => i.id == id);
    final bool makeSpecial = !item.isSpecial;

    try {
      // Same call as before — flips the isSpecial flag used for the
      // heart badge / "TODAY'S SPECIAL" tag on the card.
      await MenuService.updateSpecialStatus(id, makeSpecial);

      // Find the "Today's Special" category the same way
      // TodaySpecialDialog does, so both stay in sync.
      MenuCategory? specialCat;
      for (final c in _categories) {
        final name = c.name.toLowerCase();
        if (name.contains('today') || name.contains('special')) {
          specialCat = c;
          break;
        }
      }
      String? specialCategoryId =
          (specialCat == null || specialCat.id.isEmpty) ? null : specialCat.id;

      Map<String, dynamic> payloadFor(MenuItem i, String categoryId) => {
            'name': i.name,
            'description': i.description ?? '',
            'price': i.price,
            'is_available': i.isAvailable,
            'image_url': i.imageUrl ?? '',
            'category_id': categoryId,
            'preparation_time': i.preparationTime ?? '',
          };

      if (makeSpecial) {
        // Create the "Today's Special" category if it doesn't exist yet.
        specialCategoryId ??= (await MenuService.createCategory({
          'name': "Today's Special",
          'description': 'Daily specials curated by the chef',
        }))
            .id;

        if (specialCategoryId.isNotEmpty &&
            item.categoryId != specialCategoryId) {
          await MenuService.updateItem(
            id,
            payloadFor(item, specialCategoryId),
          );
        }
      } else if (specialCategoryId != null &&
          item.categoryId == specialCategoryId) {
        // Removing from Today's Special — move back to a fallback
        // category, same behaviour as inside TodaySpecialDialog.
        final fallback = _categories
            .where((c) => c.id != specialCategoryId && c.id.isNotEmpty)
            .map((c) => c.id)
            .firstOrNull;

        if (fallback != null && fallback.isNotEmpty) {
          await MenuService.updateItem(id, payloadFor(item, fallback));
        }
      }

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              makeSpecial
                  ? 'Added to Today\'s Special'
                  : 'Removed from Specials',
            ),
            backgroundColor: _Palette.milanoRedDeep,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _showCategoryActions(MenuCategory cat) {
    final hasItems = _items.any((it) => it.categoryId == cat.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        categoryIconFor(cat.name),
                        size: 17,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _Palette.milanoRedDeep,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 24, color: Color(0x14000000)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: _Palette.milanoRedDeep,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Edit Category',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: _Palette.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCategoryForm(cat);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasItems
                        ? Colors.grey.shade100
                        : _Palette.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: hasItems ? Colors.grey.shade400 : _Palette.danger,
                    size: 18,
                  ),
                ),
                title: Text(
                  hasItems
                      ? 'Delete Category (remove its items first)'
                      : 'Delete Category',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: hasItems ? Colors.grey.shade400 : _Palette.danger,
                  ),
                ),
                onTap: hasItems
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _deleteCategory(cat.id);
                      },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteCategory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _Palette.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: _Palette.danger,
            size: 26,
          ),
        ),
        title: Text(
          'Delete Category',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _Palette.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: _Palette.textMuted,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Cancel',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.danger,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await MenuService.deleteCategory(id);
      if (_selectedCategoryId == id) {
        setState(() => _selectedCategoryId = '');
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
      }
    }
  }

  /// Deletes a menu item after confirmation — mirrors `_deleteCategory`'s
  /// flow exactly (same confirm dialog styling, same success/error
  /// handling), just targeting `MenuService.deleteItem` for a menu item
  /// instead of a category. Kept available for programmatic/other use;
  /// the on-card delete button has been removed per request, but this
  /// method itself is untouched so no delete logic elsewhere is affected.
  Future<void> _deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _Palette.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: _Palette.danger,
            size: 26,
          ),
        ),
        title: Text(
          'Delete Item',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _Palette.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this menu item? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: _Palette.textMuted,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Cancel',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.danger,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await MenuService.deleteItem(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item deleted'),
            backgroundColor: _Palette.milanoRedDeep,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
      }
    }
  }

  void _showCategoryForm([MenuCategory? cat]) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => CategoryFormDialog(category: cat),
    );
    if (result == true) _loadData();
  }

  void _showItemForm([MenuItem? item]) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => ItemFormDialog(
        categories: _categories,
        item: item,
        initialCategoryId:
            _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
      ),
    );
    if (result == true) _loadData();
  }

  void _showManualOrderForm() async {
    await showDialog(
      context: context,
      builder: (ctx) =>
          ManualOrderDialog(menuItems: _items, categories: _categories),
    );
  }

  void _showTodaySpecialDialog() async {
    final result = await showDialog(
      context: context,
      builder: (ctx) =>
          TodaySpecialDialog(categories: _categories, allItems: _items),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final mediaQuery = MediaQuery.of(context);

    // Extra bottom inset (home indicator / gesture bar) so the scrollable
    // content never sits flush under the device's safe-area edge — mirrors
    // the same treatment used on AdminDashboardScreen.
    final double bottomSafePad = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Column(
        children: [
          // ── Header Section ───────────────────────────────────────────────
          // Fixed at the top, exactly like AdminDashboardScreen — it no
          // longer scrolls away with the content beneath it.
          _buildCustomHeader(),

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────
                // Purely decorative — soft gold/maroon glows plus a faint
                // textured photograph, matching the dashboard's "foggy"
                // backdrop so the whole admin experience feels like one
                // cohesive brand. A couple of extra glows/vignette layers
                // were added for a richer, more "premium full screen" feel.
                Positioned.fill(
                  child: Container(
                    color: _Palette.canvas,
                    child: Stack(
                      children: [
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
                                  _Palette.lemonChiffon.withValues(
                                    alpha: 0.32,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
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
                        Positioned(
                          top: 240,
                          right: -110,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _Palette.lemonChiffonDeep.withValues(
                                    alpha: 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Extra soft maroon glow, lower-center — adds a
                        // touch more richness to the full-screen backdrop.
                        Positioned(
                          bottom: 120,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 340,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _Palette.milanoRed.withValues(
                                      alpha: 0.05,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // UI-ENHANCEMENT PASS 2: extra low, wide glow
                        // further down the page — gives a long items grid
                        // a second soft focal point instead of all the
                        // ambient light sitting only near the header,
                        // matching the Orders screen's Pass-2 backdrop.
                        Positioned(
                          top: 700,
                          left: -110,
                          child: Container(
                            width: 240,
                            height: 240,
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
                          opacity: 0.04,
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

                // UI-ENHANCEMENT PASS 2: faint diagonal sheen sweeping
                // across the body — a subtle extra layer of depth so the
                // cream backdrop doesn't read as flat behind the header,
                // echoing the glass-highlight language used in the header
                // itself. Matches the Orders screen's Pass-2 treatment.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content — same fixed-header / scrollable-body pattern as
                // AdminDashboardScreen: a SingleChildScrollView centered
                // with a max width, instead of the header scrolling away
                // inside a CustomScrollView.
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _Palette.milanoRed,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          28,
                          24,
                          100 + bottomSafePad, // Extra bottom padding
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1360),
                            child: _error != null
                                ? _buildError()
                                : isDesktop
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 300,
                                            child: _buildSidebar(),
                                          ),
                                          const SizedBox(width: 32),
                                          Expanded(child: _buildMainContent()),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _buildSidebar(),
                                          const SizedBox(height: 32),
                                          _buildMainContent(),
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
    ).animate().fadeIn();
  }

  Widget _buildCustomHeader() {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          // UI-ENHANCEMENT PASS 2: richer four-stop diagonal maroon
          // gradient — deeper and more dimensional than the previous
          // three-stop wash, matching the Orders screen's Pass-2
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
          // "floating navbar" feel that matches the dashboard exactly,
          // instead of a flat hard-edged band.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRed.withValues(alpha: 0.36),
              blurRadius: 38,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.12),
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
            // Subtle decorative diagonal ribbon accents (purely cosmetic,
            // matches the dashboard header for a consistent brand feel)
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
            // Soft radial glow behind the title block, adding depth without
            // affecting any layout or logic.
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // UI-ENHANCEMENT PASS 2: large faint watermark emblem — a
            // unique signature touch this header didn't previously have,
            // sitting low-opacity and large behind the copy, never
            // competing with the title or controls. Matches the Orders
            // screen header's Pass-2 watermark treatment.
            Positioned(
              right: isMobile ? -18 : -8,
              bottom: isMobile ? -16 : -12,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: isMobile ? 110 : 160,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Fine dotted texture accent, matching the app's refined
            // decorative language used on the dashboard/login headers.
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

            // Fine glass highlight line along the very top edge of the
            // header — purely cosmetic, gives the full-width bar a more
            // polished, "premium panel" finish (matches the dashboard).
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

            // Extra soft corner glows tucked behind each top corner,
            // framing the header's full width with a touch more depth.
            Positioned(
              top: -20,
              left: -20,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 20,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Compact icon-only back control — no arrow icon,
                        // no "Back" label, just a clean "<" glyph in a
                        // circular glass button matching the app's other
                        // header controls.
                        _BackChevronButton(
                          onTap: () => context.go('/admin/dashboard'),
                        ),
                        const Spacer(),
                        if (!isMobile)
                          Text(
                            _todayLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu Management',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _TitleDivider(),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _HeaderButton(
                                  onTap: _showManualOrderForm,
                                  icon: Icons.receipt_long,
                                  label: 'Order',
                                  isPrimary: false,
                                ),
                                const SizedBox(width: 8),
                                _HeaderButton(
                                  onTap: _showTodaySpecialDialog,
                                  icon: Icons.star_border_rounded,
                                  label: 'Specials',
                                  isPrimary: false,
                                ),
                                const SizedBox(width: 8),
                                _HeaderButton(
                                  onTap: () => _showItemForm(),
                                  icon: Icons.add,
                                  label: 'Add Item',
                                  isPrimary: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menu Management',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _TitleDivider(),
                                const SizedBox(height: 10),
                                Text(
                                  'Manage your restaurant menu items and categories',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showManualOrderForm(),
                                icon: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Create Order',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _Palette.lemonChiffon,
                                    width: 2,
                                  ),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.06),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () => _showTodaySpecialDialog(),
                                icon: const Text('⭐',
                                    style: TextStyle(fontSize: 16)),
                                label: Text(
                                  "Today's Special",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _showItemForm(),
                                icon: const Icon(
                                  Icons.add,
                                  color: _Palette.milanoRedDeep,
                                ),
                                label: Text(
                                  'Add Menu Item',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: _Palette.milanoRedDeep,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _Palette.lemonChiffon,
                                  elevation: 4,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildSidebar() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _Palette.milanoRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _showCategoryForm(),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: _Palette.milanoRedDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            // Kept at the same height as before so the row's layout and
            // scroll behaviour are unaffected.
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 8),
              children: [
                _CategoryPill(
                  label: 'All Items',
                  icon: Icons.grid_view_rounded,
                  isSelected: _selectedCategoryId.isEmpty,
                  onTap: () => setState(() => _selectedCategoryId = ''),
                ),
                const SizedBox(width: 10),
                ..._categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _CategoryPill(
                      label: cat.name,
                      icon: categoryIconFor(cat.name),
                      isSelected: _selectedCategoryId == cat.id,
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      onLongPress: () => _showCategoryActions(cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
        boxShadow: _Palette.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  color: _Palette.milanoRedDeep,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: _TitleDivider(),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _showCategoryForm(),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: Text(
              'Add Category',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.milanoRedDeep,
              elevation: 3,
              shadowColor: _Palette.milanoRed.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SidebarItem(
            id: '',
            name: 'All Items',
            description: 'View all',
            icon: Icons.grid_view_rounded,
            isSelected: _selectedCategoryId.isEmpty,
            onTap: () => setState(() => _selectedCategoryId = ''),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              return _SidebarItem(
                id: cat.id,
                name: cat.name,
                description: cat.description ?? '',
                icon: categoryIconFor(cat.name),
                isSelected: _selectedCategoryId == cat.id,
                category: cat,
                onTap: () => setState(() => _selectedCategoryId = cat.id),
                onEdit: () => _showCategoryForm(cat),
                onDelete: _items.where((it) => it.categoryId == cat.id).isEmpty
                    ? () => _deleteCategory(cat.id)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  // Note: _buildSidebarItem is replaced by the _SidebarItem class below

  Widget _buildMainContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
            ),
            boxShadow: _Palette.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search,
                  color: _Palette.milanoRedDeep,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.inter(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: _Palette.milanoRedDeep,
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    hintStyle: GoogleFonts.inter(color: _Palette.textMuted),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _Palette.lemonChiffon.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredItems.length} found',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _Palette.milanoRedDeep,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _Palette.milanoRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Showing ${_filteredItems.length} items',
                style: GoogleFonts.inter(
                  color: _Palette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildItemsGrid(),
      ],
    );
  }

  /// Lays out the filtered menu items in a lightweight, dependency-free
  /// "masonry" arrangement instead of a fixed-aspect-ratio `GridView`.
  ///
  /// WHY THIS LAYOUT: a fixed-aspect-ratio `GridView` (tried in Passes 4–5)
  /// forces every card to the exact same cell height, which looks tidy
  /// while every card is collapsed — but it makes it impossible for a
  /// single card to grow when its description is expanded via "Read
  /// more"; the extra text either gets clipped or has to scroll inside a
  /// cramped box, pushing the "Edit Item" button out of view. That's not
  /// what's wanted here.
  ///
  /// Instead, `_filteredItems` is split into `cols` column buckets in the
  /// same left-to-right, top-to-bottom order a fixed grid would use
  /// (`index % cols`), and each bucket is laid out as an ordinary
  /// `Column` inside an `Expanded` slot of a `Row`. Each column sizes
  /// itself to its own content, so any single card is free to grow when
  /// "Read more" is tapped without disturbing its neighbours — the
  /// "Edit Item" button simply gets pushed down with the rest of that
  /// card's content and stays fully visible.
  ///
  /// Because every card's *collapsed* description is now a single
  /// clamped line (see `_MenuItemCardBody`), every collapsed card's
  /// content is effectively the same height already — so in practice
  /// this masonry layout renders every collapsed card at a uniform size
  /// with no wasted space, while still allowing individual cards to grow
  /// on demand. Column count and spacing scale with the available width
  /// — 2 columns on narrow/mobile layouts, 3 on medium widths, 4 on wide
  /// desktop layouts. No data, filtering, or mutation logic was touched
  /// here — layout only.
  Widget _buildItemsGrid() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              color: _Palette.milanoRedDeep.withValues(alpha: 0.25),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'No items found.',
              style: GoogleFonts.inter(
                color: _Palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth > 1100
            ? 4
            : c.maxWidth > 700
                ? 3
                : 2;
        final double spacing = c.maxWidth > 600 ? 22 : 14;

        // Same left-to-right, top-to-bottom item order a fixed grid
        // would use (index % cols) — so cards still read column-by-
        // column, row-by-row, exactly as expected.
        final List<List<int>> columns = List.generate(cols, (_) => <int>[]);
        for (var i = 0; i < items.length; i++) {
          columns[i % cols].add(i);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var col = 0; col < cols; col++) ...[
              if (col > 0) SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final i in columns[col]) ...[
                      _buildItemCard(items[i], i)
                          .animate()
                          .fadeIn(delay: (i * 30).ms, duration: 400.ms),
                      if (i != columns[col].last) SizedBox(height: spacing),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Builds a single menu-item card. The card's visual body (image, badges,
  /// name/price row and the expandable description) all live in
  /// `_MenuItemCardBody`, a small stateful widget so it can manage its own
  /// hover/expand state without touching any of the screen's data-loading
  /// or mutation logic below.
  Widget _buildItemCard(MenuItem item, int i) {
    String categoryName = 'General';
    try {
      categoryName =
          _categories.firstWhere((c) => c.id == item.categoryId).name;
    } catch (_) {}

    final hasPrepTime =
        item.preparationTime != null && item.preparationTime!.trim().isNotEmpty;

    return HoverableCard(
      child: _MenuItemCardBody(
        item: item,
        categoryName: categoryName,
        hasPrepTime: hasPrepTime,
        onToggleSpecial: () => _toggleSpecial(item.id),
        onToggleAvailability: () => _toggleItem(item.id),
        onEdit: () => _showItemForm(item),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Palette.danger.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _Palette.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: _Palette.danger,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: _Palette.textMuted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.milanoRed,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing only
/// a plain "<" glyph. Replaces the previous arrow-icon + "Back" label combo
/// with a minimal, professional control that matches the other 40×40
/// circular header buttons used across the app (notifications, profile).
/// Restyled with a gentle hover scale to match the richer nav controls
/// used on the dashboard header.
class _BackChevronButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackChevronButton({required this.onTap});

  @override
  State<_BackChevronButton> createState() => _BackChevronButtonState();
}

class _BackChevronButtonState extends State<_BackChevronButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _isHovered ? 1.08 : 1.0,
          curve: Curves.easeOutCubic,
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
                    : _Palette.lemonChiffon.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '‹',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small decorative gradient divider placed beneath the section title —
/// purely cosmetic, mirrors the same accent used on the admin dashboard.
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

class _SidebarItem extends StatefulWidget {
  final String id, name, description;
  final bool isSelected;
  final MenuCategory? category;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onEdit, onDelete;

  const _SidebarItem({
    required this.id,
    required this.name,
    required this.description,
    required this.isSelected,
    this.category,
    this.icon = Icons.restaurant_menu_rounded,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isAllItems = widget.id.isEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isHovered ? 1.02 : 1.0,
              _isHovered ? 1.02 : 1.0,
              1.0,
              1.0,
            ),
          decoration: BoxDecoration(
            gradient: isAllItems
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _Palette.milanoRedLight,
                      _Palette.milanoRedDeep,
                    ],
                  )
                : null,
            color: isAllItems
                ? null
                : (widget.isSelected
                    ? _Palette.milanoRedDeep.withValues(alpha: 0.06)
                    : (_isHovered ? Colors.grey.shade50 : Colors.white)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAllItems
                  ? Colors.transparent
                  : (widget.isSelected
                      ? _Palette.milanoRedDeep.withValues(alpha: 0.5)
                      : (_isHovered
                          ? _Palette.milanoRedDeep.withValues(alpha: 0.3)
                          : _Palette.milanoRedDeep.withValues(alpha: 0.1))),
              width: 1.2,
            ),
            boxShadow: isAllItems
                ? [
                    BoxShadow(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : (_isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isAllItems
                      ? Colors.white.withValues(alpha: 0.18)
                      : _Palette.milanoRedDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.icon,
                  size: 19,
                  color: isAllItems
                      ? _Palette.lemonChiffon
                      : _Palette.milanoRedDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color:
                            isAllItems ? Colors.white : _Palette.milanoRedDeep,
                        fontSize: 15,
                      ),
                    ),
                    if (widget.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        isAllItems
                            ? widget.description
                            : widget.description.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAllItems
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isAllItems &&
                  widget.isSelected &&
                  widget.onEdit != null) ...[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 16,
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.6),
                  ),
                  onPressed: widget.onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
              ],
              if (!isAllItems)
                Tooltip(
                  message: widget.onDelete != null
                      ? 'Delete category'
                      : 'Remove all items from this category before deleting',
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: widget.onDelete != null
                          ? Colors.grey.shade400
                          : Colors.grey.shade300,
                    ),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverableCard extends StatefulWidget {
  final Widget child;
  const HoverableCard({super.key, required this.child});

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? _Palette.milanoRedDeep.withValues(alpha: 0.55)
                : _Palette.milanoRedDeep.withValues(alpha: 0.14),
            width: _isHovered ? 1.4 : 1,
          ),
          boxShadow: _isHovered ? _Palette.glowShadow : _Palette.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// Menu item card body — restyled to match the reference food-app design:
/// a small, compact image up top (rounded corners, single heart/star
/// favorite-style toggle in the corner) with the bulk of the card given
/// to a clean content block below it — name, a short description line,
/// the price, and a full-width call-to-action pill button.
///
/// UI-ONLY CHANGES (no data loading, mutation, or callback logic touched):
///   • The image now takes a smaller share of the card, sized with a
///     fixed 4:3 `AspectRatio` instead of a flexed height, so it reads as
///     "small" the way it does in the reference design, instead of
///     dominating the card.
///   • The availability toggle and special/today's-special toggle are
///     still wired to the exact same `onToggleAvailability` /
///     `onToggleSpecial` callbacks as before — only their position and
///     styling changed (single rounded favorite-style toggle top-right
///     for "special", a compact status chip for availability) to match
///     the reference's cleaner corner-badge look.
///   • The old edit icon-button is now a full-width rounded action button
///     styled like the reference's "Add To Cart" pill (still calls the
///     same `onEdit` callback — only the visual treatment changed).
///   • The per-card delete button has been removed per request — the
///     "Edit Item" button is back to being the single, full-width action
///     on the card. Its callback (`onEdit`) is unchanged.
///
/// UI-ENHANCEMENT PASS 6:
///   • The card body is a free-sizing `Column` again (`mainAxisSize:
///     MainAxisSize.min`, no `Expanded`/`SingleChildScrollView`), so the
///     whole card — image, name, description, rating, price, and the
///     "Edit Item" button — simply grows to fit its own content. Paired
///     with the masonry grid in `_buildItemsGrid`, expanding one card's
///     description no longer disturbs any other card, and the "Edit
///     Item" button always stays fully visible below the description
///     instead of being pushed into a small internal scroll area.
///   • The description ("Read more" / "Show less") is a single clamped
///     line when collapsed. Tapping "Read more" swaps it to the full
///     text and an `AnimatedSize` smoothly grows the block — and with it
///     the whole card — to fit. Tapping "Show less" smoothly shrinks it
///     back.
///
/// UI-ENHANCEMENT PASS 7 (this pass): "Read more"/"Show less" now sits
/// inline at the end of the same line as the description text (matching
/// the reference design's "Tender, boneless murgh ... Read More" style)
/// instead of appearing on its own separate line underneath. A
/// `TextPainter` measures the available width at build time and finds
/// exactly how much of the collapsed description fits alongside
/// "… Read more" on a single line, so the link is never accidentally
/// clipped off the end the way plain `TextOverflow.ellipsis` could. When
/// expanded, "Show less" is likewise appended right after the full text.
/// No data, callback, or navigation logic was touched — only how the
/// description text and its link are composed and measured.
/// ─────────────────────────────────────────────────────────────────────────
class _MenuItemCardBody extends StatefulWidget {
  final MenuItem item;
  final String categoryName;
  final bool hasPrepTime;
  final VoidCallback onToggleSpecial;
  final VoidCallback onToggleAvailability;
  final VoidCallback onEdit;

  const _MenuItemCardBody({
    required this.item,
    required this.categoryName,
    required this.hasPrepTime,
    required this.onToggleSpecial,
    required this.onToggleAvailability,
    required this.onEdit,
  });

  @override
  State<_MenuItemCardBody> createState() => _MenuItemCardBodyState();
}

class _MenuItemCardBodyState extends State<_MenuItemCardBody> {
  bool _isHovered = false; // desktop/web hover on the image (subtle zoom)
  bool _descriptionExpanded = false; // "Read more" / "Show less" state

  /// Tap recognizer backing the inline "Read more" / "Show less" span
  /// inside the description `Text.rich`. Kept as a single long-lived
  /// recognizer (rather than creating a new one every build) and
  /// disposed in `dispose()`, as `TapGestureRecognizer` requires.
  late final TapGestureRecognizer _readMoreTapRecognizer;

  @override
  void initState() {
    super.initState();
    _readMoreTapRecognizer = TapGestureRecognizer()
      ..onTap = () => setState(
            () => _descriptionExpanded = !_descriptionExpanded,
          );
  }

  @override
  void dispose() {
    _readMoreTapRecognizer.dispose();
    super.dispose();
  }

  /// Finds the longest prefix of [text] that, together with the
  /// "… Read more" suffix, still fits within [maxWidth] on a single
  /// line — using a `TextPainter` binary search rather than relying on
  /// `TextOverflow.ellipsis`, which would just as happily truncate the
  /// appended "Read more" text itself along with the description.
  String _truncateForInlineLink({
    required String text,
    required TextStyle textStyle,
    required String suffixEllipsis,
    required String linkText,
    required TextStyle linkStyle,
    required double maxWidth,
  }) {
    final ellipsisPainter = TextPainter(
      text: TextSpan(text: suffixEllipsis, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final linkPainter = TextPainter(
      text: TextSpan(text: linkText, style: linkStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final double suffixWidth = ellipsisPainter.width + linkPainter.width;
    final double availableForText = maxWidth - suffixWidth;
    if (availableForText <= 0) return '';

    final fullPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    // Whole description already fits next to the link — no need to cut
    // it at all (this also covers very short descriptions).
    if (fullPainter.width <= availableForText) {
      return text;
    }

    int low = 0;
    int high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      final testPainter = TextPainter(
        text: TextSpan(text: text.substring(0, mid), style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: double.infinity);
      if (testPainter.width <= availableForText) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return text.substring(0, low).trimRight();
  }

  /// The description block: when collapsed, a single line with
  /// "… Read more" appended inline right after the (precisely measured)
  /// truncated text — matching the reference design's layout. When
  /// expanded, the full description is shown with "Show less" appended
  /// inline at the end. Tapping either link toggles
  /// `_descriptionExpanded`, and the surrounding `AnimatedSize` smoothly
  /// grows/shrinks the card to fit. When there's no description, the
  /// category name is shown instead (unchanged from before) with no
  /// link, since there's nothing further to reveal.
  Widget _buildDescriptionBlock() {
    final item = widget.item;
    final hasDescription =
        item.description != null && item.description!.trim().isNotEmpty;
    final fullText =
        hasDescription ? item.description!.trim() : widget.categoryName;

    final textStyle = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: _Palette.textMuted,
    );
    final linkStyle = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      color: _Palette.milanoRedDeep,
      decoration: TextDecoration.underline,
      decorationColor: _Palette.milanoRedDeep.withValues(alpha: 0.45),
    );

    if (!hasDescription) {
      // No description to expand — just show the category name, exactly
      // as before, with no inline link.
      return Text(
        fullText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: _descriptionExpanded
          ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: fullText, style: textStyle),
                  TextSpan(
                    text: '  Show less',
                    style: linkStyle,
                    recognizer: _readMoreTapRecognizer,
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final truncated = _truncateForInlineLink(
                  text: fullText,
                  textStyle: textStyle,
                  suffixEllipsis: '… ',
                  linkText: 'Read more',
                  linkStyle: linkStyle,
                  maxWidth: constraints.maxWidth,
                );
                final bool wasCut = truncated != fullText;
                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: wasCut ? '$truncated… ' : '$truncated  ',
                        style: textStyle,
                      ),
                      TextSpan(
                        text: 'Read more',
                        style: linkStyle,
                        recognizer: _readMoreTapRecognizer,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final categoryName = widget.categoryName;
    final rating = _displayRatingFor(item.id);

    // The outer column sizes itself to its own content again
    // (`mainAxisSize: MainAxisSize.min`): a fixed-ratio image up top,
    // then the content block directly below it — no bounding/scrolling
    // wrapper. Paired with the masonry grid in `_buildItemsGrid`, this
    // lets the whole card (and only this card) grow when its
    // description expands, so the "Edit Item" button always stays
    // visible below it rather than being confined to a small scroll
    // area. See the class doc comment above for the full rationale.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Small image block ─────────────────────────────────────────
        // Fixed 4:3 aspect ratio so the image keeps its proportions
        // correctly regardless of the card's overall (now fixed) size.
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo, with a gentle zoom on hover for a livelier feel.
                    AnimatedScale(
                      scale: _isHovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        color: _Palette.canvasDeep,
                        child:
                            item.imageUrl != null && item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                      child: Icon(
                                        categoryIconFor(categoryName),
                                        color: _Palette.textMuted,
                                        size: 32,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      categoryIconFor(categoryName),
                                      color: _Palette.textMuted,
                                      size: 32,
                                    ),
                                  ),
                      ),
                    ),
                    // Favorite/"special" toggle — a single rounded badge in
                    // the top-right corner, mirroring the reference
                    // design's heart button. Still calls the exact same
                    // onToggleSpecial callback; only the look changed.
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: widget.onToggleSpecial,
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: item.isSpecial
                                ? _Palette.lemonChiffon
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.isSpecial
                                    ? _Palette.lemonChiffonDeep.withValues(
                                        alpha: 0.45,
                                      )
                                    : Colors.black.withValues(alpha: 0.14),
                                blurRadius: item.isSpecial ? 10 : 6,
                                spreadRadius: item.isSpecial ? 1 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            item.isSpecial
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 13,
                            color: item.isSpecial
                                ? _Palette.milanoRedDeep
                                : _Palette.textMuted,
                          ),
                        ),
                      ),
                    ),
                    // Availability toggle — compact status chip, top-left.
                    // Still calls the exact same onToggleAvailability
                    // callback; only the look/position changed.
                    Positioned(
                      top: 6,
                      left: 6,
                      child: InkWell(
                        onTap: widget.onToggleAvailability,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? _Palette.success
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            item.isAvailable
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 11,
                            color: item.isAvailable
                                ? Colors.white
                                : _Palette.danger,
                          ),
                        ),
                      ),
                    ),
                    if (!item.isAvailable)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content block ─────────────────────────────────────────────
        // Same fields, same order, same callbacks as before. No bounding
        // box or scroll wrapper — the Column above sizes itself to fit
        // this content, so the card (and specifically the "Edit Item"
        // button below) grows and shrinks together with the description
        // block whenever "Read more"/"Show less" is tapped.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.isSpecial)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        size: 10,
                        color: _Palette.milanoRed,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "TODAY'S SPECIAL",
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          color: _Palette.milanoRed,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                item.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Palette.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Expandable description with "Read more"/"Show less" now
              // inline at the end of the same line (see
              // _buildDescriptionBlock doc comment above) — its
              // AnimatedSize grows this card (and only this card) when
              // tapped, so the "Edit Item" button always stays visible
              // below it.
              _buildDescriptionBlock(),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 11,
                    color: _Palette.lemonChiffonDeep,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _Palette.textMuted,
                    ),
                  ),
                  if (widget.hasPrepTime) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timer_outlined,
                      size: 10,
                      color: _Palette.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${item.preparationTime} min',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: _Palette.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${item.price.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRed,
                ),
              ),
              const SizedBox(height: 6),
              // Action row — the "Edit Item" pill (same visual language
              // as the reference design's "Add To Cart" button, still
              // wired to the exact same onEdit callback as before) is
              // the single, full-width action on the card.
              SizedBox(
                height: 40,
                child: InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _Palette.milanoRed,
                          _Palette.milanoRedDeep,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRed.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Item',
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _HeaderButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? _Palette.lemonChiffon
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? _Palette.lemonChiffon
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? _Palette.milanoRedDeep : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isPrimary ? _Palette.milanoRedDeep : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryPill({
    required this.label,
    this.icon = Icons.restaurant_menu_rounded,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _Palette.milanoRedLight,
                    _Palette.milanoRedDeep,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _Palette.milanoRedDeep
                : _Palette.milanoRedDeep.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isSelected ? _Palette.lemonChiffon : _Palette.milanoRedDeep,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : _Palette.milanoRedDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}