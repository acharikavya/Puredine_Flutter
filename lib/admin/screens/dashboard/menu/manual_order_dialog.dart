import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/orders_service.dart';
import 'package:restaurant_unified_app/admin/services/tables_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "PUREDINE Maroon + Cream" palette — matches StaffScreen /
/// MenuScreen / AdminDashboardScreen exactly, so this dialog reads as part
/// of the same consistent brand. Used ONLY for this dialog's restyle.
/// Nothing here touches AppColors or any other file — pure UI enhancement,
/// no logic changed anywhere in this pass.
///
/// UI-ENHANCEMENT PASS 2: brought this dialog's header up to the same
/// richer "command bar" identity used on the Orders/Menu screens and the
/// Item Form dialog — a deeper four-stop diagonal gradient, a large faint
/// watermark emblem behind the title copy, and a fine glass highlight
/// line along the very top edge. No table loading, order submission,
/// validation, quantity, or category/item navigation logic was touched
/// anywhere in this pass — presentation only.
///
/// BUGFIX PASS: `_buildDesktopBody()` previously wrapped its two-column
/// `Row` in `IntrinsicHeight` (nested inside a `SingleChildScrollView`) in
/// order to give both columns a shared scroll bar. `IntrinsicHeight`
/// requires every descendant to be able to report its intrinsic height —
/// but `GridView`/`ListView` viewports (even with `shrinkWrap: true`)
/// explicitly do not support that computation and throw a layout
/// exception when asked to. The fix removes the shared-scroll wrapper and
/// gives each desktop column its own independent `SingleChildScrollView`
/// instead — no order/table/validation/submission logic was touched.
///
/// UI-ENHANCEMENT PASS 3: re-balanced the Milano Red/Wine + Gold Chiffon
/// identity so the dialog read as "majorly white" overall, with maroon
/// and gold used only as accents rather than a solid header fill.
///
/// UI-ENHANCEMENT PASS 4: presentation-only, exactly like every pass
/// above — no provider/service call, table loading, order submission,
/// validation, quantity, category/item navigation, or desktop/mobile
/// layout logic was touched anywhere in this file, and no field,
/// callback, or keyword was renamed.
///   1. PALETTE — full PUREDINE mapping, mirroring the exact swap already
///      done on StaffScreen. Every field name inside `_Palette` is
///      unchanged on purpose (every widget in this file already reads
///      from these exact names, so swapping only the underlying `Color`
///      values re-skins the whole dialog with no other code touched):
///        • `milanoRed`        → Deep Wine Maroon `#742A3C` (primary / topbar)
///        • `milanoRedLight`   → Wine `#813244` (topbar lighter gradient)
///        • `milanoRedDeep`    → Burgundy `#8A183F` (primary accent)
///        • `milanoRedDarkest` → Deep Brown/Black `#2E0D16`
///        • `canvas`           → Warm Off-White `#FBF8F5` (main background)
///        • `canvasDeep`       → Soft Cream `#F7F1ED` (card background)
///        • `lemonChiffon`     → Warm Gold `#F3C564` (gold accent)
///        • `lemonChiffonDeep` → deeper gold `#D9A421` (derived companion)
///        • `textDark`         → Deep Brown/Black `#2E0D16`
///        • `textMuted`        → Muted Taupe `#9B707A`
///        • `success`          → Fresh Green `#44AF70`
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so delete/error states stay legible.
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
///      maroon band spanning the header). It carries the same ambient
///      dressing used on the other admin headers: a soft warm-gold corner
///      glow, a large very faint watermark emblem (the same
///      `Icons.receipt_long_rounded` glyph already used in this dialog's
///      icon chip) sitting low-opacity behind the copy, a subtle diagonal
///      glass sheen, and a warm-gold hairline along the bottom edge.
///      Structurally nothing changed: the same icon chip, the same title
///      copy ("Create Manual Order"), the same subtitle copy ("Take an
///      order on behalf of a customer"), the same thin gold underline
///      accent, and the exact same `Navigator.pop(context)` close
///      callback. Only the copy's colors changed (white / soft-gold
///      instead of maroon / taupe) and the icon chip + close button were
///      restyled from Pass-3's maroon-on-white / cream-on-white "glass"
///      look to a light glass-on-wine treatment so both read clearly
///      against the new dark backdrop — their callbacks are unchanged.
///   3. TOP-TO-BOTTOM CONSISTENCY: so the whole dialog reads as one brand
///      rather than just a re-colored header, every card/section/dialog
///      border now uses Pale Rose, every small icon container uses the
///      Dusty Blush icon-BG, the field-label "badge" pill uses Soft
///      Yellow, and the primary "Submit Order" CTA button now carries the
///      supplied CTA gradient (`#6E1832 → #9B3E4E → #F3C564`) instead of a
///      flat fill — matching the "Login / CTA buttons" spec exactly. No
///      button's `onPressed` callback was touched.
///
/// UI-ENHANCEMENT PASS 5: presentation-only, exactly like every pass
/// above — no provider/service call, table loading, order submission,
/// validation, quantity, or category/item navigation logic was touched
/// anywhere in this file, and no field, callback, or keyword was renamed.
///   1. MOBILE CATEGORY GRID: on mobile widths the category cards
///      (`_CategoryCard`, inside `_buildCategoriesGrid`) were sized the
///      same as desktop, which made them feel cramped and let longer
///      names like "paneer pizza" wrap tightly right at the card edge.
///      The grid now takes an `isDesktop` flag (threaded down from
///      `_buildMenuSelection`, which is itself now passed the flag from
///      `_buildDesktopBody` / `_buildMobileBody`) and, on mobile only,
///      uses a taller `childAspectRatio`, more inter-card spacing, and a
///      larger icon/label inside `_CategoryCard` so every box has more
///      breathing room and the category name always has room to sit on
///      two lines without crowding. Desktop's grid numbers are
///      untouched.
///   2. FOOTER BUTTONS: the primary CTA's label was shortened from
///      "Submit Order" to just "Submit" (the button's `onPressed` is
///      still exactly `_isSubmitting ? null : _submitOrder` — only the
///      label text changed). Both the "Cancel" and the primary button
///      now use a smaller, more rectangular corner radius on mobile
///      widths (their desktop radius is unchanged) so they read as
///      squared-off buttons on phone screens, matching the reference
///      screenshot.
///
/// UI-ENHANCEMENT PASS 6: presentation/layout-only, exactly like every
/// pass above — no provider/service call, table loading, order
/// submission, validation, quantity, or category/item navigation logic
/// was touched anywhere in this file.
///   1. RESPONSIVE BREAKPOINTS: the old binary `isDesktop` (width > 900)
///      split has been replaced everywhere in this file with three
///      explicit tiers so tablets get their own tuned layout instead of
///      inheriting either the mobile stack or the full desktop spacing
///      verbatim:
///        • Mobile  — width <  600  → stacked single-column body
///        • Tablet  — 600 <= width < 1024 → two-column body, tuned
///          spacing/typography
///        • Desktop — width >= 1024 → two-column body, full spacing
///      The dialog's own width/height, the header's icon-chip/title
///      sizing, the order-details-form heading size, the category
///      grid's padding/spacing/aspect ratio, the `_CategoryCard` icon
///      and label sizing, and the footer's paddings/font sizes were all
///      given a tablet-tuned middle value between the existing mobile
///      and desktop numbers, so every one of the three views now has a
///      deliberate, proportioned layout instead of tablets simply
///      reusing the desktop or mobile numbers unmodified. The header and
///      footer were also pulled out into their own `_buildHeader()` /
///      `_buildFooter()` methods purely to keep this breakpoint logic
///      readable — their contents (copy, icons, callbacks) are unchanged.
///   2. FOOTER BUTTONS — EQUAL, NARROWER WIDTH: previously "Cancel" was a
///      content-sized `OutlinedButton` while the primary "Submit" button
///      was wrapped in `Expanded`, so it stretched to fill all remaining
///      footer width and ended up far wider than "Cancel". Both buttons
///      are now wrapped in a fixed `SizedBox` of the same width (tuned
///      per breakpoint: narrower on mobile, a little wider on tablet,
///      widest — but still compact — on desktop), so "Cancel" and
///      "Submit" always match each other and are both noticeably
///      narrower than the old stretched Submit button, on mobile,
///      tablet, and desktop alike. Their `onPressed` callbacks
///      (`Navigator.pop(context)` / `_isSubmitting ? null : _submitOrder`)
///      are completely unchanged.
///
/// TABLET-OVERFLOW FIX PASS 7: the "Order Mode" `SegmentedButton` (Dine-in
/// / Takeaway / Delivery) was forced to `width: double.infinity` inside
/// the left-hand details column. On tablet widths that left column is
/// only ~40% of the dialog's own width (itself already narrower than
/// desktop), so the three icon+label segments didn't have enough room and
/// Flutter threw a `RenderFlex overflowed` layout error/yellow-black
/// stripes specifically at tablet breakpoints. The fix wraps the
/// `SegmentedButton` in a horizontally-scrollable
/// `SingleChildScrollView(scrollDirection: Axis.horizontal)` instead of
/// forcing it to fill the full column width, so it now sizes to its own
/// natural (minimum) content width and — only if a viewport is ever too
/// narrow to fit that — scrolls sideways instead of overflowing. This is
/// a pure layout fix: the segmented control's `segments`, `selected`,
/// and `onSelectionChanged: (v) => setState(() => _orderMode = v.first)`
/// callback are completely untouched.
///
/// FOOTER BUTTONS PASS 8 (narrower, right-aligned, same line): "Cancel"
/// and "Submit" already shared one fixed `buttonWidth` and already sat
/// together on the same line at the right of the footer row (via the
/// footer's `MainAxisAlignment.spaceBetween`, with the total-amount
/// block taking the left side and this button `Row` taking the
/// remaining/right side). This pass only narrows `buttonWidth` a little
/// further at every breakpoint (mobile/tablet/desktop) so the pair reads
/// as more compact; the equal sizing, same-line placement, and
/// right-of-footer position are unchanged, and both `onPressed` callbacks
/// (`Navigator.pop(context)` / `_isSubmitting ? null : _submitOrder`) are
/// completely untouched.
///
/// TABLET-OVERFLOW FIX PASS 9 (Customer Details labels): the
/// "Customer Name" / "Customer Phone" field labels inside the
/// "Customer Details" card (built by `_fieldLabel(..., required: true)`)
/// used a plain `Row` for their color bar + label text + "*" + "REQUIRED"
/// pill. In the left-hand details column's narrower tablet width, that
/// Row's combined content didn't fit and Flutter threw a `RenderFlex
/// overflowed` layout error (the yellow/black stripe visible next to
/// "REQUIRED" in the Customer Details card on tablet). The fix swaps
/// that `Row` for a `Wrap` with the exact same children, in the exact
/// same order, with the exact same styling/colors/spacing — so the
/// "REQUIRED" pill now drops to its own line instead of overflowing
/// whenever space is tight, on tablet and every other breakpoint alike.
/// No label/badge text, color, or the `required`/`badge` logic was
/// touched, and no other field label, form field, or validator anywhere
/// in this file was changed.
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // PUREDINE Maroon + Cream — field names unchanged on purpose (see the
  // PASS 4 note above); only the underlying Color values changed.
  static const Color milanoRed =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedDeep =
      Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
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
    colors: [milanoRed, milanoRedLight],
  );

  /// The supplied CTA gradient, exactly: `#6E1832 → #9B3E4E → #F3C564`.
  /// Used for the primary "Submit" action button below.
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), lemonChiffon],
  );

  /// Themed soft shadow for resting surfaces — mirrors the shared shadow
  /// language used across StaffScreen / MenuScreen / AdminDashboardScreen.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
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
          color: milanoRedDarkest.withValues(alpha: 0.28),
          blurRadius: 44,
          offset: const Offset(0, 22),
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

class ManualOrderDialog extends StatefulWidget {
  final List<MenuItem> menuItems;
  final List<MenuCategory> categories;

  const ManualOrderDialog({
    super.key,
    required this.menuItems,
    required this.categories,
  });

  @override
  State<ManualOrderDialog> createState() => _ManualOrderDialogState();
}

class _ManualOrderDialogState extends State<ManualOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  List<TableModel> _tables = [];
  String? _selectedTableId;
  String _paymentMode = 'Cash';
  String _orderMode = 'Dine-in';

  bool _isLoadingTables = true;
  bool _isSubmitting = false;

  final Map<String, int> _selectedItems = {}; // menuItemId -> quantity

  // Navigation State for Menu Items
  String _viewMode = 'categories'; // 'categories' or 'items'
  MenuCategory? _activeCategory;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await TablesService.getTables();
      setState(() {
        _tables = tables;
        _isLoadingTables = false;
      });
    } catch (e) {
      setState(() => _isLoadingTables = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tables: $e')));
      }
    }
  }

  double get _totalAmount {
    double total = 0;
    _selectedItems.forEach((itemId, qty) {
      final item = widget.menuItems.firstWhere((i) => i.id == itemId);
      total += item.price * qty;
    });
    return total;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_orderMode == 'Dine-in' && _selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _themedSnack('Please select a table for Dine-in', isError: true),
      );
      return;
    }
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _themedSnack('Please add at least one item', isError: true),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final itemsList = _selectedItems.entries.map((e) {
        return {"menu_item_id": e.key, "quantity": e.value};
      }).toList();

      final orderTypeMap = {
        'Dine-in': 'DINE_IN',
        'Takeaway': 'TAKEAWAY',
        'Delivery': 'DELIVERY',
      };

      final payload = {
        "order_type": orderTypeMap[_orderMode] ?? 'DINE_IN',
        "table_id": _orderMode == 'Dine-in' ? _selectedTableId : null,
        "customer_name": _nameCtrl.text.trim(),
        "customer_phone": _phoneCtrl.text.trim(),
        "payment_mode": _paymentMode,
        "items": itemsList,
      };

      await OrdersService.createOrder(payload);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          _themedSnack('Order created successfully!'),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _themedSnack('Failed to create order: $e', isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  SnackBar _themedSnack(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? _Palette.danger : _Palette.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ── PASS 6: Responsive breakpoints ─────────────────────────────────
    // Three explicit size tiers instead of the old two-tier
    // (isDesktop / !isDesktop) split, so tablets get their own tuned
    // layout instead of inheriting either the cramped mobile stack or the
    // full desktop spacing verbatim.
    //   • Mobile:  width <  600         → stacked single-column body
    //   • Tablet:  600 <= width < 1024  → two-column body, tuned spacing
    //   • Desktop: width >= 1024        → two-column body, full spacing
    // No table loading, order submission, validation, quantity, or
    // category/item navigation logic was touched — this pass only tunes
    // sizes/paddings/widths per breakpoint plus the footer button sizing.
    final double width = size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1024;

    double dialogWidth;
    double dialogHeight;
    if (isDesktop) {
      dialogWidth = width > 1100 ? 1000 : width * 0.92;
      dialogHeight = size.height * 0.9;
    } else if (isTablet) {
      dialogWidth = width * 0.92;
      dialogHeight = size.height * 0.88;
    } else {
      dialogWidth = width * 0.96;
      dialogHeight = size.height * 0.94;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: _Palette.cardWhite,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: _Palette.paleRose.withValues(alpha: 0.7),
          ),
          boxShadow: _Palette.glowShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Header (mini navbar) ─────────────────────────────────────
            _buildHeader(isDesktop: isDesktop, isTablet: isTablet),

            // Body
            Expanded(
              child: isMobile
                  ? _buildMobileBody()
                  : _buildTwoColumnBody(
                      isDesktop: isDesktop, isTablet: isTablet),
            ),

            // ── Footer ────────────────────────────────────────────────────
            _buildFooter(isDesktop: isDesktop, isTablet: isTablet),
          ],
        ),
      ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOut).scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1, 1),
            duration: 220.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  // Pulled out of `build()` purely to keep the PASS 6 breakpoint logic
  // readable. Same icon chip, same title copy ("Create Manual Order"),
  // same subtitle copy ("Take an order on behalf of a customer"), same
  // thin gold underline accent, and the exact same `Navigator.pop(context)`
  // close callback as every earlier pass — only the chip/icon/title sizes
  // and the header's own padding now scale across mobile / tablet /
  // desktop instead of just mobile / desktop.
  Widget _buildHeader({required bool isDesktop, required bool isTablet}) {
    final double chipSize = isDesktop ? 48 : (isTablet ? 45 : 42);
    final double chipIconSize = isDesktop ? 24 : (isTablet ? 22 : 20);
    final double titleFontSize = isDesktop ? 26 : (isTablet ? 22 : 19);
    final double horizontalPadding = isDesktop ? 24 : (isTablet ? 22 : 20);
    final double verticalPadding = isDesktop ? 22 : (isTablet ? 20 : 18);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _Palette.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: _Palette.lemonChiffon.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _Palette.milanoRedDarkest.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft warm-gold corner glow — purely decorative.
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.lemonChiffon.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // A subtle secondary highlight low-left, echoing the second
            // ambient ribbon used on the other admin headers — a soft
            // warm-white tint so it still reads on the dark wine backdrop.
            Positioned(
              bottom: -44,
              left: -44,
              child: Container(
                width: 170,
                height: 170,
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
            // Large faint watermark emblem — sits low-opacity and large
            // behind the copy, matching the receipt icon already used in
            // the header's icon chip.
            Positioned(
              right: -14,
              bottom: -18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 128,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Fine dotted texture accent — matches the dashed dot row
            // used on the Menu/Dashboard/Staff headers.
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
                      width: 3.5,
                      height: 3.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 2
                            ? Colors.white.withValues(alpha: 0.85)
                            : _Palette.lemonChiffon.withValues(alpha: 0.45),
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
            // Fine glass highlight line along the very top edge.
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
                      _Palette.lemonChiffon.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon chip — a light glass-on-wine treatment so it
                  // reads clearly against the dark backdrop. Purely
                  // decorative, no callback.
                  Container(
                    width: chipSize,
                    height: chipSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _Palette.milanoRedDarkest.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: chipIconSize,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              _Palette.lemonChiffon,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Create Manual Order',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                                _Palette.lemonChiffon.withValues(alpha: 0.95),
                                _Palette.lemonChiffon.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Take an order on behalf of a customer',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeaderCloseButton(
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────
  // PASS 6/8: "Cancel" and "Submit" share one fixed width so they always
  // match each other and stay noticeably narrower than the old layout
  // (where "Submit" used to be wrapped in `Expanded` and stretch across
  // all remaining footer width). Sizing is tuned per breakpoint, and PASS
  // 8 narrows that shared width a little further while keeping both
  // buttons on the same line at the right side of the footer row (the
  // total-amount block sits on the left; `MainAxisAlignment.spaceBetween`
  // pushes this button `Row` to the right). `onPressed` callbacks
  // (`Navigator.pop(context)` / `_isSubmitting ? null : _submitOrder`) are
  // completely unchanged.
  Widget _buildFooter({required bool isDesktop, required bool isTablet}) {
    final double horizontalPadding = isDesktop ? 32 : (isTablet ? 24 : 16);
    final double verticalPadding = isDesktop ? 20 : (isTablet ? 18 : 16);
    // PASS 8: narrowed further from Pass 6's 132/122/104.
    final double buttonWidth = isDesktop ? 118 : (isTablet ? 108 : 92);
    final double buttonHeight = isDesktop ? 50 : (isTablet ? 48 : 44);
    final double buttonRadius = isDesktop ? 12 : (isTablet ? 11 : 9);
    final double buttonSpacing = isDesktop ? 14 : (isTablet ? 12 : 10);
    final double totalAmountFontSize = isDesktop ? 27 : (isTablet ? 24 : 20);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: _Palette.paleRose,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _Palette.milanoRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TOTAL AMOUNT',
                    style: GoogleFonts.inter(
                      color: _Palette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: totalAmountFontSize,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRed,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "Cancel" — fixed-width `SizedBox` so it always matches
              // the primary button's width below. `onPressed` is
              // unchanged.
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: OutlinedButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    backgroundColor: _Palette.canvas,
                    side: BorderSide(
                      color: _Palette.paleRose,
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(width: buttonSpacing),
              // "Submit" — same fixed width/height as "Cancel" above
              // (previously this button was `Expanded` and stretched to
              // fill all remaining footer width). `onPressed` is
              // unchanged.
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(buttonRadius),
                    gradient: _isSubmitting ? null : _Palette.ctaGradient,
                    color: _isSubmitting
                        ? _Palette.milanoRedDeep.withValues(alpha: 0.6)
                        : null,
                    boxShadow: _isSubmitting
                        ? const []
                        : [
                            BoxShadow(
                              color: _Palette.milanoRed.withValues(alpha: 0.32),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color:
                                  _Palette.lemonChiffon.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Submit',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  // ── Body layouts ──────────────────────────────────────────────────────
  // Tablet and desktop both get two independently-scrollable side-by-side
  // panels (the parent `Expanded` in `build()` already gives this `Row` a
  // fixed, bounded height to work within, so no outer scroll wrapper or
  // `IntrinsicHeight` is needed here). Each panel scrolls on its own via
  // its own `SingleChildScrollView`, and the inner `GridView`/`ListView`
  // stay `shrinkWrap: true` with `NeverScrollableScrollPhysics` so they
  // size to their content inside that per-panel scroll view instead of
  // fighting it for gesture/scroll ownership. Mobile keeps the original
  // stacked single-column layout.
  //
  // IMPORTANT: this is a pure layout fix — no table loading, order
  // submission, validation, quantity, or category/item navigation logic
  // was changed.
  Widget _buildTwoColumnBody(
      {required bool isDesktop, required bool isTablet}) {
    final double detailsPadding = isDesktop ? 32 : (isTablet ? 24 : 20);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left side: Details
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: _Palette.cardWhite,
              border: Border(
                right: BorderSide(
                  color: _Palette.paleRose,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(detailsPadding),
              child: _buildOrderDetailsForm(isTablet: isTablet),
            ),
          ),
        ),
        // Right side: Menu selection
        Expanded(
          flex: 6,
          child: Container(
            color: _Palette.canvas,
            child: SingleChildScrollView(
              child: _buildMenuSelection(isDesktop, isTablet),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildOrderDetailsForm(isTablet: false),
          ),
          Container(
            height: 1,
            color: _Palette.paleRose,
          ),
          Container(
            color: _Palette.canvas,
            child: _buildMenuSelection(false, false),
          ),
        ],
      ),
    );
  }

  InputDecoration _themedInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13),
      filled: true,
      fillColor: _Palette.canvas,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.paleRose,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _Palette.paleRose,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.milanoRedDeep, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _Palette.danger.withValues(alpha: 0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Palette.danger, width: 1.6),
      ),
    );
  }

  // PASS 6: now takes an optional `isTablet` flag purely to tune the
  // section heading's font size / top spacing a touch for the tablet
  // breakpoint. Every field, validator, and controller below is
  // unchanged.
  Widget _buildOrderDetailsForm({bool isTablet = false}) {
    final double headingFontSize = isTablet ? 17 : 19;
    final double sectionSpacing = isTablet ? 18 : 22;

    return Form(
      key: _formKey,
      child: Column(
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
                'Order Configuration',
                style: GoogleFonts.playfairDisplay(
                  fontSize: headingFontSize,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 50,
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    _Palette.milanoRedDeep.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: sectionSpacing),

          // Order Mode
          _fieldLabel('Order Mode'),
          // TABLET-OVERFLOW FIX PASS 7: this used to be forced to
          // `width: double.infinity` via an outer `SizedBox`, which — in
          // the narrower left-hand column tablet widths give this form —
          // could ask the three icon+label segments for less width than
          // they need and throw a `RenderFlex overflowed` layout error.
          // Wrapping it in a horizontally-scrollable
          // `SingleChildScrollView` instead lets the control size itself
          // to its natural content width and only scrolls sideways if a
          // viewport is ever too narrow, so it can never overflow. The
          // `segments`, `selected`, and `onSelectionChanged` callback
          // below are completely unchanged.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Dine-in',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Dine-in')),
                  icon: Icon(Icons.restaurant, size: 14),
                ),
                ButtonSegment(
                  value: 'Takeaway',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Takeaway')),
                  icon: Icon(Icons.shopping_bag, size: 14),
                ),
                ButtonSegment(
                  value: 'Delivery',
                  label:
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Delivery')),
                  icon: Icon(Icons.delivery_dining, size: 14),
                ),
              ],
              selected: {_orderMode},
              onSelectionChanged: (v) => setState(() => _orderMode = v.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _Palette.milanoRedDeep,
                selectedForegroundColor: Colors.white,
                foregroundColor: _Palette.milanoRedDeep,
                side: BorderSide(
                  color: _Palette.paleRose,
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Table selection (only for Dine-in)
          if (_orderMode == 'Dine-in') ...[
            _fieldLabel('Select Table'),
            _isLoadingTables
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      color: _Palette.milanoRedDeep,
                      backgroundColor: _Palette.paleRose,
                    ),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _selectedTableId,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _Palette.milanoRedDeep,
                    ),
                    style: GoogleFonts.inter(
                      color: _Palette.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _themedInputDecoration(),
                    hint: Text(
                      'Choose a table',
                      style: GoogleFonts.inter(color: _Palette.textMuted),
                    ),
                    items: _tables
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('Table ${t.tableNumber}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTableId = v),
                    validator: (v) => _orderMode == 'Dine-in' && v == null
                        ? 'Required'
                        : null,
                  ),
            const SizedBox(height: 20),
          ],

          // Payment Mode
          _fieldLabel('Payment Mode'),
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _Palette.milanoRedDeep,
            ),
            style: GoogleFonts.inter(
              color: _Palette.textDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: _themedInputDecoration(),
            items: [
              'Cash',
              'Card',
              'UPI',
              'Online',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMode = v!),
          ),

          const SizedBox(height: 24),

          // ── Customer Details ─────────────────────────────────────────
          // Pulled into its own clearly-bordered, titled section (icon +
          // heading + gold-tinted card) so it can no longer be missed while
          // scrolling the form. BOTH Name and Phone are REQUIRED fields —
          // each carries a red asterisk and a "REQUIRED" chip, and both
          // are wired into the existing form validator, so
          // `_submitOrder`'s already-present
          // `_formKey.currentState!.validate()` check will block
          // submission (with inline error messages) until both are
          // filled in.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _Palette.canvas,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _Palette.paleRose,
                width: 1.2,
              ),
              boxShadow: _Palette.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _Palette.dustyBlush,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 15,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Customer Details',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _Palette.milanoRedDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    'Both fields are required to place this order',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _Palette.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Customer Name', required: true),
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.inter(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _themedInputDecoration(
                    hintText: "Enter the customer's name",
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Customer name is required'
                      : null,
                ),
                const SizedBox(height: 18),
                _fieldLabel('Customer Phone', required: true),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _themedInputDecoration(
                    hintText: 'Enter a contact number',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Customer phone is required'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TABLET-OVERFLOW FIX (Customer Details labels): this label row —
  // color bar + label text + "*" + optional badge + optional "REQUIRED"
  // pill — used to be a plain `Row`. On the "Customer Name" / "Customer
  // Phone" labels (`required: true`), that Row's fixed-width bar, label
  // text, asterisk, and "REQUIRED" pill together needed more horizontal
  // space than the narrower left-hand details column has on tablet
  // widths, so Flutter threw a `RenderFlex overflowed` layout error
  // there (the yellow/black stripe). Swapping the `Row` for a `Wrap`
  // (same children, same order, same styling/colors/text/spacing) lets
  // the "REQUIRED" pill simply drop to its own line instead of
  // overflowing whenever the available width is tight, so it can no
  // longer overflow at any breakpoint. No label text, badge text, color,
  // or the `required`/`badge` conditions were changed.
  Widget _fieldLabel(String label, {String? badge, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: required ? _Palette.danger : _Palette.milanoRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: _Palette.milanoRedDeep,
              letterSpacing: 0.5,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 3),
            Text(
              '*',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: _Palette.danger,
              ),
            ),
          ],
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
          if (required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _Palette.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _Palette.danger.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                'REQUIRED',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _Palette.danger,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // PASS 6: now takes both `isDesktop` and `isTablet` so
  // `_buildCategoriesGrid` can size the category boxes for all three
  // breakpoints. `_buildItemsList` itself is unchanged — only how the
  // categories grid lays out.
  Widget _buildMenuSelection(bool isDesktop, bool isTablet) {
    if (_viewMode == 'categories') {
      return _buildCategoriesGrid(isDesktop, isTablet);
    } else {
      return _buildItemsList();
    }
  }

  // PASS 6: takes both `isDesktop` and `isTablet` so the grid can use a
  // tablet-tuned `childAspectRatio`/padding/spacing that sits between the
  // existing mobile and desktop numbers (via `_CategoryCard`'s `isTablet`
  // flag, a larger icon/label than desktop but a little tighter than
  // mobile). Desktop's numbers (padding 24, spacing 16, aspect ratio 1.4)
  // and mobile's numbers are both untouched. No navigation logic
  // (`onTap` → `_viewMode`/`_activeCategory`) was changed.
  Widget _buildCategoriesGrid(bool isDesktop, bool isTablet) {
    final double gridPadding = isDesktop ? 24 : (isTablet ? 22 : 18);
    final double gridSpacing = isDesktop ? 16 : (isTablet ? 15 : 14);
    final double aspectRatio = isDesktop ? 1.4 : (isTablet ? 1.3 : 1.0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: _Palette.milanoRedDeep,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Category',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: EdgeInsets.all(gridPadding),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (ctx, i) {
            final cat = widget.categories[i];
            return _CategoryCard(
              category: cat,
              isDesktop: isDesktop,
              isTablet: isTablet,
              onTap: () {
                setState(() {
                  _activeCategory = cat;
                  _viewMode = 'items';
                });
              },
            ).animate().fadeIn(delay: (i * 40).ms, duration: 300.ms);
          },
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = widget.menuItems
        .where((i) => i.isAvailable && i.categoryId == _activeCategory?.id)
        .toList();

    return Column(
      children: [
        // Back Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _Palette.milanoRedDeep,
                  ),
                  onPressed: () => setState(() => _viewMode = 'categories'),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _activeCategory?.name ?? 'Items',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length} items',
                  style: GoogleFonts.inter(
                    color: _Palette.milanoRedDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No items in this category.',
                    style: GoogleFonts.inter(color: _Palette.textMuted),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final qty = _selectedItems[item.id] ?? 0;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRedDeep.withValues(
                            alpha: qty > 0 ? 0.10 : 0.04,
                          ),
                          blurRadius: qty > 0 ? 16 : 10,
                          offset: Offset(0, qty > 0 ? 6 : 3),
                        ),
                      ],
                      border: Border.all(
                        color: qty > 0
                            ? _Palette.milanoRed.withValues(alpha: 0.45)
                            : _Palette.paleRose,
                        width: qty > 0 ? 1.6 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _Palette.canvasDeep,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: _Palette.textMuted,
                              size: 28,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _Palette.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item.price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: _Palette.milanoRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (qty > 0) ...[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: _Palette.milanoRed,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (qty == 1) {
                                      _selectedItems.remove(item.id);
                                    } else {
                                      _selectedItems[item.id] = qty - 1;
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  '$qty',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _Palette.textDark,
                                  ),
                                ),
                              ),
                            ],
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                qty > 0
                                    ? Icons.add_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: _Palette.success,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedItems[item.id] = qty + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}

/// Compact icon-only "close" control for the header — a circular glass
/// button showing only an "×" glyph. Mirrors the `_BackChevronButton`
/// treatment used on StaffScreen/MenuScreen/OrdersScreen/TablesScreen's
/// headers for a consistent brand feel across the admin app: a
/// translucent white circle with a white "×" and a warm-gold ring, so it
/// reads clearly against the wine header backdrop. The `onTap` callback
/// passed in from the header (`Navigator.pop(context)`) is completely
/// unchanged — only the look changed.
class _HeaderCloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HeaderCloseButton({required this.onTap});

  @override
  State<_HeaderCloseButton> createState() => _HeaderCloseButtonState();
}

class _HeaderCloseButtonState extends State<_HeaderCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
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
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final MenuCategory category;
  final VoidCallback onTap;
  // Lets the card size its icon/label a little larger on mobile so boxes
  // feel bigger and names don't crowd the edges, and gives tablet its own
  // in-between sizing. Defaults keep any other caller that doesn't pass
  // these the exact same look as before (desktop-sized).
  final bool isDesktop;
  final bool isTablet;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    this.isDesktop = true,
    this.isTablet = false,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.isDesktop;
    final isTablet = widget.isTablet;

    final double iconPadding = isDesktop ? 12 : (isTablet ? 13 : 16);
    final double iconSize = isDesktop ? 28 : (isTablet ? 29 : 32);
    final double labelFontSize = isDesktop ? 14 : (isTablet ? 14.5 : 15);
    final double horizontalContentPadding = isDesktop ? 0 : (isTablet ? 6 : 10);
    final double iconLabelSpacing = isDesktop ? 12 : (isTablet ? 13 : 14);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scaleByDouble(1.02, 1.02, 1.0, 1.0))
              : Matrix4.identity(),
          padding: EdgeInsets.symmetric(horizontal: horizontalContentPadding),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Palette.milanoRedLight, _Palette.milanoRedDeep],
                  )
                : null,
            color: _isHovered ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _Palette.milanoRedDeep.withValues(
                  alpha: _isHovered ? 0.22 : 0.06,
                ),
                blurRadius: _isHovered ? 18 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: _isHovered ? _Palette.milanoRedDeep : _Palette.paleRose,
              width: _isHovered ? 1.5 : 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.18)
                      : _Palette.dustyBlush,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color:
                      _isHovered ? _Palette.lemonChiffon : _Palette.milanoRed,
                  size: iconSize,
                ),
              ),
              SizedBox(height: iconLabelSpacing),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 0 : 6,
                ),
                child: Text(
                  widget.category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: GoogleFonts.inter(
                    fontWeight: _isHovered ? FontWeight.w800 : FontWeight.bold,
                    fontSize: labelFontSize,
                    color: _isHovered ? Colors.white : _Palette.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
