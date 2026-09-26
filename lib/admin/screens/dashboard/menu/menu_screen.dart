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
import 'package:provider/provider.dart';
import 'package:restaurant_unified_app/admin/core/models/notification_model.dart';
import 'package:restaurant_unified_app/admin/core/providers/notification_provider.dart';

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
/// UI-ENHANCEMENT PASS 7: "Read more" now sits inline at the
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
///
/// UI-ENHANCEMENT PASS 8: "Read more" is now only shown when
/// it's actually needed. Previously the link appeared on every card with
/// a description, even short ones that already fit on a single line with
/// room to spare — clicking it in that case just re-displayed the exact
/// same text with a pointless "Show less" appended. The collapsed
/// description is now first measured against the available width on its
/// own (no link involved); if it already fits fully on one line, it's
/// rendered as plain, non-interactive text with no "Read more" affordance
/// at all. The "Read more" link — and the tap-to-expand/collapse
/// behaviour — now only appears for descriptions that genuinely don't fit
/// on one line. No data, callback, or navigation logic was touched —
/// presentation only.
///
/// UI-ENHANCEMENT PASS 9: removed the empty vertical space that used to
/// sit at the top of the header — the date/notification-bell row
/// previously had generous top padding and an 18px gap before the title
/// block. The header's top/bottom padding and the gap beneath the
/// date/bell row were both tightened.
///
/// UI-ENHANCEMENT PASS 10: a second, more aggressive spacing
/// pass to close the gap that was still visible between the header's top
/// edge (dotted accent) and the "Menu Management" title. The header's
/// top padding is now asymmetric — a minimal `top: 4` instead of a
/// uniform `12` on all sides — and the gap between the date/bell row and
/// the title block is trimmed from `8` down to `4`. Bottom padding stays
/// at `12` so the action buttons on desktop keep their breathing room.
/// No data, callback, layout structure, or navigation logic was touched
/// anywhere in this pass — spacing values only.
///
/// UI-ENHANCEMENT PASS 11: the mobile header's "Order" /
/// "Specials" / "Add Item" buttons previously sat in a horizontally
/// scrolling `Row` where each `_HeaderButton` sized itself to its own
/// icon+label content — so the three buttons ended up with visibly
/// different widths and didn't line up cleanly across the header. The
/// scrolling wrapper is now a plain `Row` where each button is wrapped
/// in `Expanded`, so all three buttons always share the available width
/// equally and their edges align, and `_HeaderButton`'s own content is
/// now centered within that equal-width slot instead of hugging the
/// left edge. No callback, route, or any other logic was touched — only
/// how these three buttons size and align relative to each other.
///
/// UI-ENHANCEMENT PASS 12: the "Menu Management" title
/// previously sat on its own line below the date/notification-bell row
/// (which used a `Spacer()` to push the date+bell to the right with
/// nothing on the left). The title text now sits on that same top row —
/// replacing the `Spacer()` — so the title, the date (desktop only), and
/// the notification bell all share one line, with the title taking the
/// remaining space via `Expanded`. The divider, subtitle ("Manage your
/// restaurant menu items and categories" on desktop), and the
/// Order/Specials/Add Item action buttons stay exactly where they were,
/// directly beneath that row — only the title's position moved up. No
/// data, callback, route, or any other logic was touched anywhere in
/// this pass — layout only.
///
/// UI-ENHANCEMENT PASS 13: two changes, both purely
/// presentational — no data loading, filtering, mutation, dialog,
/// navigation, or callback logic anywhere in this file was touched.
///   1. COLOR THEME: every `_Palette` value below now points at a single
///      consistent brand identity, instead of any prior theme. The field
///      names (`milanoRed`, `milanoRedDeep`, `lemonChiffon`, `canvas`,
///      etc.) are unchanged on purpose — every other widget in this file
///      already reads from these exact fields, so leaving the names
///      alone and only swapping the underlying `Color` values re-skins
///      the entire screen (header, sidebar, cards, badges, dialogs,
///      toast) without touching a single reference to `_Palette`
///      anywhere else.
///   2. HEADER: `_buildCustomHeader()` is rebuilt from the old dark
///      gradient "command bar" into a lighter, standard-mobile-app
///      layout in the spirit of a payments-app home screen — a plain
///      title row with the notification bell, a large rounded pill
///      search bar (same `_searchQuery` state and `onChanged` handler as
///      before), and a row of icon-tile quick actions beneath it for
///      "Add Item", "Create Order", and "Today's Special" (the exact
///      same three callbacks — `_showItemForm`, `_showManualOrderForm`,
///      `_showTodaySpecialDialog` — as the old header's buttons). The
///      old inline search box inside `_buildMainContent()` was removed
///      since the header now owns search; the "X found" count chip that
///      used to sit next to it moved into the new header search bar so
///      that feature is preserved, not dropped. The sidebar, the item
///      grid, the "Showing N items" row, dialogs, and every data/mutation
///      method below are completely untouched.
///
/// UI-ENHANCEMENT PASS 14: this pass only tightens the "standard
/// mobile screen" feel a bit further — a hairline bottom border under
/// the header for cleaner separation from the scrollable body, and a
/// touch more depth (subtle shadow + hover lift) on the quick-action
/// tiles so they read as proper tappable cards. No color values, data
/// loading, filtering, mutation, dialog, navigation, or callback logic
/// was touched anywhere in this pass — spacing/elevation only.
///
/// UI-ENHANCEMENT PASS 15: added a few extra decorative
/// touches so the screen feels more lively and polished rather than
/// flat:
///   1. The "Menu Management" title is rendered with a two-tone
///      `ShaderMask`, and a small row of accent dots sits above it — a
///      "dotted texture accent" language.
///   2. A large, very faint leaf watermark sits behind the header copy
///      (bottom-right), a soft botanical backdrop touch.
///   3. The three quick-action tiles have a soft gradient icon circle
///      with a thin accent ring, instead of a flat cream circle, so
///      they read as more inviting brand-colored buttons.
///   4. Menu items marked "Today's Special" get a thin accent left bar
///      down the edge of the card, so specials visually pop out from
///      the grid at a glance.
///
/// UI-ENHANCEMENT PASS 16: palette fine-tuned plus a few more
/// "premium" decorative touches — still zero changes to data loading,
/// filtering, mutation, dialog, navigation, or callback logic anywhere
/// in this file — presentation only.
///   1. PALETTE: values nudged for a more refined, premium tone.
///   2. CARDS: corner radius increased slightly (20→22) and the resting
///      shadow warmed to match the accent tint used elsewhere, for a
///      softer, more premium card feel.
///   3. RATING + PREP-TIME: now sit inside a small soft pill chip
///      instead of bare text/icons, echoing the pill language used
///      throughout the app.
///   4. PRICE: now rendered as a soft tinted pill badge instead of
///      plain text, so it reads as a clear price tag against the card.
///   5. "TODAY'S SPECIAL" label: now sits inside a small accent-tinted
///      pill instead of bare text, so specials pop even more clearly.
///   6. HEADER: a thin gradient hairline now sits under the subtitle,
///      above the search bar — a soft divider language.
///   7. SIDEBAR "All Items" tile and selected category pills: selected
///      state now carries a slightly warmer accent-tinted ring to match
///      the richer accent language elsewhere on the screen.
///
/// UI-ENHANCEMENT PASS 17-19: intermediate client-supplied brand
/// palette experiments — zero changes to data loading, filtering,
/// mutation, dialog, navigation, or callback logic anywhere in this
/// file — palette only.
///
/// UI-ENHANCEMENT PASS 20: a prior refinement pass, palette
/// only, no structural changes.
///
/// UI-ENHANCEMENT PASS 21: re-themed the screen to a Milano
/// Red/Wine + Golden Chiffon identity, with white/near-white kept as
/// the dominant surface color throughout — zero changes to data
/// loading, filtering, mutation, dialog, navigation, or callback logic
/// anywhere in this file — palette only.
///
/// UI-ENHANCEMENT PASS 22: restructured the header to match a
/// GPay-style top bar (search pill + circular icon top row, promo-style
/// banner beneath it, icon-tile quick actions) — zero changes to data
/// loading, filtering, mutation, dialog, navigation, or callback logic
/// anywhere in this file — layout/presentation only.
///
/// UI-ENHANCEMENT PASS 23 (swaps in the "PUREDINE Maroon +
/// Cream" brand palette): zero changes to data loading, filtering,
/// mutation, dialog, navigation, or callback logic anywhere in this
/// file — only the underlying `Color` values inside `_Palette` below
/// were swapped. Every field name is exactly the same as before, so
/// every widget already reading from `_Palette.milanoRed`,
/// `_Palette.lemonChiffon`, `_Palette.canvas`, etc. is automatically
/// re-skinned with no other code touched:
///   • `milanoRed` (primary accent) → Burgundy `#8A183F` — used for the
///     header title, buttons, sidebar "All Items" tile gradient, price
///     pill, and "Edit Item" CTA gradient start stop.
///   • `milanoRedDeep` (primary / topbar) → Deep Wine Maroon `#742A3C` —
///     used as the dominant "deep" brand tone across icons, borders,
///     shadows, and text accents.
///   • `milanoRedLight` (topbar lighter gradient) → Wine `#813244`.
///   • `milanoRedDarkest` (fourth gradient stop) → Deep Brown/Black
///     `#2E0D16`.
///   • `lemonChiffon` / `lemonChiffonDeep` (gold accent family) → Warm
///     Gold `#F3C564` and a deeper, more saturated gold derived from the
///     same family for contrast — used for the accent dots, dividers,
///     selected pill rings, quick-action icon rings, and the "Today's
///     Special" badge/accent bar.
///   • `canvas` (main background) → Warm Off-White `#FBF8F5`, so the
///     warm cream reads as the dominant surface color across the whole
///     screen.
///   • `canvasDeep` (card/secondary surface tint) → Soft Cream
///     `#F7F1ED` — used for the rating/prep-time pill chip and the
///     quick-action icon fill.
///   • `cardWhite` → Soft Cream `#F7F1ED` (card background per the
///     palette).
///   • `success` → Fresh Green `#44AF70`, used for the "available"
///     checkmark badge.
///   • `danger` kept as a clear, distinct alert red (not part of the
///     supplied palette) so delete/error states stay legible against
///     the new warm palette.
///   • `textDark` / `textMuted` → Deep Brown/Black `#2E0D16` and Muted
///     Taupe `#9B707A`, so body copy reads warmly against the new
///     cream canvas.
///   This single swap re-tunes every surface in the file (header,
///   sidebar, search bar, cards, badges, dialogs, toast, buttons) to the
///   new PUREDINE brand identity with no structural changes anywhere.
///
/// UI-ENHANCEMENT PASS 24: wine topbar + full PUREDINE
/// palette pass — zero changes to data loading, filtering, mutation,
/// dialog, navigation, or callback logic anywhere in this file —
/// palette/presentation only.
///   1. PALETTE: four supporting PUREDINE tones that weren't wired up
///      yet were added to `_Palette` — `dustyBlush` (`#F3D9DC`),
///      `paleRose` (`#EFD7DA`), `softYellow` (`#FCE1AB`) and `paleMint`
///      (`#EAF6EF`). Every field already in `_Palette` keeps the exact
///      same hex value it had after Pass 23 — this only adds new
///      fields, nothing existing was changed.
///   2. HEADER: `_buildCustomHeader()`'s outer panel is no longer a
///      light cream surface — it's now a medium-depth wine/maroon
///      gradient (`milanoRedDeep` → `milanoRedLight`, the exact
///      "`#742A3C` → `#813244`" combination called out for the top
///      header), plus a soft ambient glow and a large, very faint
///      watermark emblem for depth, and a thin warm-gold hairline along
///      the bottom edge instead of the old faint maroon-on-cream one.
///      Every element inside the header — the search pill (with the
///      exact same `_searchQuery` state/`onChanged` handler and "X
///      found" chip it always had), the promo-style title/subtitle
///      banner, and the notification bell — is completely unchanged in
///      structure and behaviour; only the backdrop behind them, plus a
///      couple of shadow/border tints so they still read clearly
///      against the new deeper backdrop, changed.
///   3. CARDS: `HoverableCard`'s resting border and the header banner's
///      border now use the palette's own `paleRose` (`#EFD7DA`) — the
///      exact card-border tone called out in the PUREDINE spec — instead
///      of a translucent wine tint.
///   4. ICON CHIPS: a handful of small, purely neutral icon-container
///      backgrounds (the sidebar's folder icon, each category's icon
///      tile, the category bottom-sheet's icon tile and its "Edit
///      Category" icon) now use the palette's `dustyBlush` (`#F3D9DC`)
///      "Icon BG" tone instead of a translucent wine tint — every icon,
///      label, and tap target inside them is unchanged.
///   No data loading, filtering, mutation, dialog, navigation, or
///   callback logic anywhere in this file was touched in this pass.
///
/// UI-ENHANCEMENT PASS 25: the three quick-action tiles ("Add Item",
/// "Create Order", "Today's Special") previously
/// lived inside the header's wine-gradient panel, below the promo
/// banner. They now sit outside/below the header panel entirely, as
/// their own row directly on the screen's canvas background — still the
/// very first thing above the sidebar/item-grid content, just no longer
/// inside the header's colored backdrop. This is a pure layout move: the
/// row is now built by its own `_buildQuickActionsRow()` method and
/// inserted into the outer body `Column` right after `_buildCustomHeader()`
/// or; the three tiles themselves (`_QuickActionTile`), their icons,
/// labels, and — most importantly — their exact same callbacks
/// (`_showItemForm`, `_showManualOrderForm`, `_showTodaySpecialDialog`)
/// are completely untouched. No data loading, filtering, mutation,
/// dialog, navigation, or callback logic anywhere in this file was
/// touched in this pass — only where this one row sits on the screen.
///
/// UI-ENHANCEMENT PASS 26: even after Pass 25 moved the
/// quick-action tiles out from inside the header panel, the header
/// `Container`'s own `boxShadow` (a wide, heavily blurred wine-tinted
/// shadow with a `blurRadius` of 24 and a downward `Offset(0, 10)`) was
/// still bleeding a soft colored tint down past the header's bottom
/// edge and across the space where the three quick-action cards sit —
/// making that area read as if it had its own colored "topbar"
/// background behind the cards. That `boxShadow` has been removed from
/// `_buildCustomHeader()`'s outer `Container` decoration, so the header
/// still keeps its own gradient background and bottom hairline border,
/// but no shadow spills down into the quick-action tiles' area beneath
/// it. Nothing else — the header's gradient, its search pill, its promo
/// banner, the quick-action tiles themselves, their icons, labels, or
/// callbacks — was touched. No data loading, filtering, mutation,
/// dialog, navigation, or callback logic anywhere in this file was
/// touched in this pass — this single decorative shadow was removed.
///
/// UI-ENHANCEMENT PASS 27: two purely structural/decorative
/// changes — no data loading, filtering, mutation, dialog, navigation,
/// or callback logic anywhere in this file was touched, and no widget,
/// callback, field, or keyword was renamed.
///   1. SCROLL STARTS AT THE QUICK-ACTION CARDS: the "Add Item" /
///      "Create Order" / "Today's Special" row (still built by the exact
///      same `_buildQuickActionsRow()` method, with the exact same three
///      `_QuickActionTile`s and the exact same three callbacks) used to
///      sit in the outer, non-scrolling body `Column` — pinned in place
///      directly under the fixed header, so only the sidebar/item grid
///      beneath it actually scrolled. It has now been moved INSIDE the
///      body's `SingleChildScrollView`, as the very first child of the
///      scrollable content, so scrolling now begins right at those three
///      cards: they scroll away together with the categories row and the
///      item grid. The header itself stays fixed at the top exactly as
///      before.
///   2. NO TOPBAR BACKGROUND BEHIND THE CARDS: because that row is now
///      part of the scrollable body, it renders directly on the screen's
///      own canvas/ambient backdrop — there is no separate colored
///      "topbar" strip or panel behind it at all. The header's bottom
///      hairline `border` (the thin gold line that used to sit right
///      above the cards and read like the bottom edge of a topbar band)
///      has also been removed from `_buildCustomHeader()`'s decoration,
///      so nothing colored sits between the header and the cards. The
///      header's own gradient background is unchanged; the scroll view's
///      former top padding (`28`) was folded into the quick-action row's
///      own padding so spacing stays visually the same.
///
/// UI-ENHANCEMENT PASS 28 (this pass): responsive/tablet-laptop polish —
/// no data loading, filtering, mutation, dialog, navigation, or callback
/// logic anywhere in this file was touched, and no widget, callback,
/// field, or keyword was renamed. See the per-method doc comments below
/// for exactly what changed (extra breakpoint tiers and sizing only).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  // NOTE: field names are unchanged from the previous theme on purpose
  // (see Pass 23 above) — every other widget in this file reads from
  // these exact names, so only the underlying Color values change.
  static const Color milanoRed = Color(0xFF8A183F); // Burgundy (Primary accent)
  static const Color milanoRedDeep =
      Color(0xFF742A3C); // Deep Wine Maroon (Primary / Topbar)
  static const Color milanoRedLight =
      Color(0xFF813244); // Wine (Topbar lighter gradient)
  static const Color milanoRedDarkest =
      Color(0xFF2E0D16); // Deep Brown/Black (fourth gradient stop)
  static const Color lemonChiffon = Color(0xFFF3C564); // Warm Gold (Accent)
  static const Color lemonChiffonDeep =
      Color(0xFFD9A421); // Deeper, more saturated Warm Gold
  static const Color canvas =
      Color(0xFFFBF8F5); // Warm Off-White (Main background)
  static const Color canvasDeep =
      Color(0xFFF7F1ED); // Soft Cream (Card background / secondary tint)
  static const Color cardWhite = Color(0xFFF7F1ED); // Soft Cream (Card bg)
  static const Color textDark = Color(0xFF2E0D16); // Deep Brown/Black text
  static const Color textMuted = Color(0xFF9B707A); // Muted Taupe
  static const Color success = Color(0xFF44AF70); // Fresh Green
  static const Color danger = Color(0xFFE0323F); // Clear alert red

  // PASS 24: four supporting PUREDINE tones added — nothing above this
  // line was changed; these are new fields only.
  static const Color dustyBlush =
      Color(0xFFF3D9DC); // Blush/Pink tint (Icon BG)
  static const Color paleRose = Color(0xFFEFD7DA); // Light pink (Card border)
  static const Color softYellow = Color(0xFFFCE1AB); // Gold highlight
  static const Color paleMint = Color(0xFFEAF6EF); // Mint background

  /// Themed soft shadow for resting cards/panels — replaces the generic
  /// AppShadows.card so every surface shares the same warm, branded tint.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.05),
          blurRadius: 6,
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
          color: lemonChiffon.withValues(alpha: 0.12),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final notifProv = context.read<NotificationProvider>();
      notifProv.startPolling();
      notifProv.addListener(_onNotificationChanged);
    });
  }

  @override
  void dispose() {
    final notifProv = context.read<NotificationProvider>();

    notifProv.removeListener(_onNotificationChanged);

    super.dispose();
  }

  void _onNotificationChanged() {
    if (!mounted) return;

    final notifProv = context.read<NotificationProvider>();

    if (notifProv.notifications.isNotEmpty) {
      final latest = notifProv.notifications.first;

      if (!latest.isRead) {
        _showTopToast(latest);
      }
    }
  }

  void _showTopToast(NotificationModel notification) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        notification: notification,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
        onView: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }

          context.go(
            '/admin/orders?highlightOrderId=${notification.orderId}',
          );
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
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
                        color: _Palette.dustyBlush.withValues(alpha: 0.6),
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
                    color: _Palette.dustyBlush.withValues(alpha: 0.6),
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
    // PASS 28: extra sizing-only tier for laptop/large-monitor widths —
    // does not change the `isDesktop` (>800) structural switch above
    // (still exactly the same Row-vs-Column decision as before), only
    // how wide the sidebar column and the overall content area are
    // allowed to grow on genuinely large screens.
    final bool isDesktopWide = mediaQuery.size.width >= 1280;
    final double sidebarWidth = isDesktopWide ? 320 : 300;
    final double contentMaxWidth = isDesktopWide ? 1440 : 1360;

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

          // PASS 27: `_buildQuickActionsRow()` is NO LONGER called here in
          // the outer, non-scrolling Column. It has moved down into the
          // body's SingleChildScrollView (below) as the very first item of
          // the scrollable content, so scrolling now starts right at the
          // "Add Item" / "Create Order" / "Today's Special" cards, and
          // nothing colored (no topbar strip / no header shadow / no
          // header bottom hairline) sits behind that row anymore. The
          // method itself, the three tiles, and their three callbacks are
          // completely unchanged.

          // ── Main Body Section ────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // ── Ambient background dressing ─────────────────────────
                // Purely decorative — soft gold/wine glows plus a faint
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
                        // Extra soft glow, lower-center — adds a touch
                        // more richness to the full-screen backdrop.
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
                // white/cream backdrop doesn't read as flat behind the
                // header, echoing the glass-highlight language used in the
                // header itself. Matches the Orders screen's Pass-2
                // treatment.
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
                //
                // PASS 27: the scroll view's own horizontal/top padding was
                // moved onto the inner blocks so the quick-action row can
                // be the very first scrollable child and keep its own
                // padding. Everything below it (the sidebar/categories row
                // and the item grid) still sits inside the exact same
                // 24px horizontal / max-width 1360 layout it always had.
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _Palette.milanoRed,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: 100 + bottomSafePad, // Extra bottom padding
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: contentMaxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // PASS 27: the "Add Item" / "Create Order" /
                                // "Today's Special" tiles — same method,
                                // same tiles, same callbacks as before —
                                // are now the first thing inside the
                                // scrollable area, so the scroll begins
                                // right here, on the plain canvas
                                // background with no topbar behind it.
                                _buildQuickActionsRow(),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                  child: _error != null
                                      ? _buildError()
                                      : isDesktop
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: sidebarWidth,
                                                  child: _buildSidebar(),
                                                ),
                                                const SizedBox(width: 32),
                                                Expanded(
                                                  child: _buildMainContent(),
                                                ),
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

  /// PASS 13: rebuilt from the old dark-maroon gradient "command bar"
  /// into a lighter, standard-mobile-app header laid directly on the
  /// screen's own canvas (no separate colored panel) — a title +
  /// notification-bell row, a large rounded pill search bar underneath
  /// (same `_searchQuery` state / `onChanged` handler the old inline
  /// search box used). All callbacks referenced from the header are the
  /// exact same methods used elsewhere — only their look changed. The
  /// sidebar, item grid, and every data/mutation method elsewhere in this
  /// file are untouched.
  ///
  /// PASS 14: added a hairline bottom border so the header reads as a
  /// clearly separated surface above the scrollable body, matching a
  /// standard mobile app's header/content split — a spacing/elevation
  /// tweak only, no structural or logic change.
  ///
  /// PASS 16: a thin gold gradient hairline now sits between the
  /// subtitle and the search bar (a soft divider language) — spacing/
  /// decoration only, no structural or logic change.
  ///
  /// PASS 22: restructures the header to match a GPay-style top bar:
  /// zero changes to data loading, filtering, mutation, dialog,
  /// navigation, or callback logic anywhere in this file — layout/
  /// presentation only.
  ///   1. TOP ROW: the very first row in the header is now a large
  ///      rounded search pill next to a circular icon on the right —
  ///      mirroring the GPay home screen's very top row ("Pay anyone on
  ///      UPI" search bar + round profile photo). The search pill uses
  ///      the exact same `_searchQuery` state, the exact same
  ///      `onChanged` handler, and the exact same "X found" chip the
  ///      search bar always had — only its position (now the first
  ///      element in the header) changed. The circular icon on the
  ///      right is the exact same `_MenuNotificationBell` widget/
  ///      callback as before, simply moved up into this top row instead
  ///      of sitting next to the title.
  ///   2. PROMO-STYLE BANNER: directly beneath the top row sits a
  ///      soft rounded panel that mirrors the shape of the GPay home
  ///      screen's banner ("No more QR approvals" card) — the screen
  ///      title/subtitle/accent-dots/divider on the left (all the exact
  ///      same text and elements the header already had) and, on the
  ///      right, a circular glowing badge holding a restaurant/food
  ///      photo — standing in for the illustration GPay shows in that
  ///      same spot. This image is purely decorative (an `errorBuilder`
  ///      falls back to a plain restaurant icon if it can't load) and
  ///      is not tied to any data, callback, or navigation logic.
  ///
  /// PASS 23: the header (and every surface beneath it) now pulls its
  /// colors from the re-themed `_Palette` (PUREDINE Maroon + Cream) —
  /// no structure, spacing, or logic in this method was touched.
  ///
  /// PASS 24: the header's outer panel is now a medium-depth wine/
  /// maroon gradient backdrop (`milanoRedDeep` → `milanoRedLight`)
  /// instead of the flat light-cream panel from Pass 22/23, with a
  /// soft ambient glow + a large, very faint watermark emblem behind
  /// it for depth, and a warm-gold hairline along the bottom edge. The
  /// search pill, the promo-style title/subtitle banner (now bordered
  /// in `paleRose` per the PUREDINE card spec), and the notification
  /// bell are all completely unchanged in structure/behaviour — same
  /// `_searchQuery` state, same "X found" chip — only a couple of
  /// shadow/border tints were adjusted so they read clearly against the
  /// new deeper backdrop.
  ///
  /// PASS 25: the icon-tile quick actions ("Add Item", "Create Order",
  /// "Today's Special") that used to be the last element inside this
  /// header's Column have been moved OUT of this widget entirely — they
  /// now live in the standalone `_buildQuickActionsRow()` method. This
  /// method's Column now ends right after the promo-style
  /// title/subtitle banner. Nothing else in this header — the search
  /// pill, the banner, the notification bell — changed in any way.
  ///
  /// PASS 26: the outer `Container`'s `boxShadow` has been removed. It
  /// previously cast a wide, blurred wine-tinted shadow (`blurRadius:
  /// 24`, `offset: Offset(0, 10)`) below the header that was visibly
  /// bleeding a colored tint down into the quick-action tiles' row
  /// beneath it.
  ///
  /// PASS 27: the outer `Container`'s bottom hairline `border` has also
  /// been removed. With the quick-action row now scrolling underneath
  /// the header (see `build()`), that thin gold line was the last piece
  /// of colored "topbar" chrome sitting directly above the three cards.
  /// The header keeps its wine gradient background, its ambient
  /// dressing, its search pill, its promo banner, and its notification
  /// bell exactly as before — only the `border` entry was dropped from
  /// this decoration.
  ///
  /// PASS 28: added an `isDesktopWide` (≥1024px) tier and an
  /// `isPhoneCompact` (<380px) tier on top of the existing `isMobile`
  /// (<800px) split, so padding, title/subtitle font sizes, the
  /// promo-banner photo badge, and the row's internal spacing now step
  /// up smoothly for laptop-sized screens instead of reusing the same
  /// "≥800" values a mid-size tablet gets. No structure, callback, or
  /// data logic touched — sizing math only.
  Widget _buildCustomHeader() {
    final double _headerWidth = MediaQuery.of(context).size.width;
    final isMobile = _headerWidth < 800;
    final bool isPhoneCompact = _headerWidth < 380;
    final bool isDesktopWide = _headerWidth >= 1024;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _Palette.milanoRedDeep,
            _Palette.milanoRedLight,
          ],
        ),
        // PASS 26: boxShadow removed — it was bleeding a colored tint
        // down into the quick-action tiles' row directly beneath the
        // header.
        // PASS 27: the bottom hairline border was removed too, so no
        // colored strip sits between the header and the now-scrollable
        // quick-action cards.
      ),
      child: Stack(
        children: [
          // PASS 24: decorative ambient dressing for the new wine
          // backdrop — a soft gold glow near the top-right corner and a
          // large, very faint watermark emblem low behind the header
          // copy, plus a subtle diagonal glass sheen. Purely
          // presentational, clipped to the header's own bounds; no
          // data, callback, or navigation logic lives in this Stack.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: Stack(
                  children: [
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
                              _Palette.lemonChiffon.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -30,
                      bottom: -55,
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 180,
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
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 18 : 32,
                isMobile ? 14 : 20,
                isMobile ? 18 : 32,
                isMobile ? 16 : 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PASS 22: GPay-style top row — a large rounded pill
                  // search bar paired with a circular icon on the right,
                  // matching the reference GPay home screen's very top row.
                  // Same `_searchQuery` state, the exact same `onChanged`
                  // handler, and the exact same "X found" chip the search
                  // bar has always had — only its position changed. The
                  // circular icon is the exact same `_MenuNotificationBell`
                  // widget/callback as before, just moved up to this row.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.milanoRedDarkest.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.search_rounded,
                                color: _Palette.milanoRedDeep
                                    .withValues(alpha: 0.55),
                                size: 21,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  style: GoogleFonts.inter(
                                    color: _Palette.textDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5,
                                  ),
                                  cursorColor: _Palette.milanoRedDeep,
                                  decoration: InputDecoration(
                                    hintText: 'Search menu items...',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: false,
                                    hintStyle: GoogleFonts.inter(
                                      color: _Palette.textMuted,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                              // Same "X found" chip the search box has
                              // always shown — relocated along with the
                              // search field itself, nothing else changed.
                              if (_searchQuery.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _Palette.lemonChiffon.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_filteredItems.length} found',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: _Palette.milanoRedDeep,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _MenuNotificationBell(),
                    ],
                  ),
                  SizedBox(height: isMobile ? 14 : 18),
                  // PASS 22: GPay-style promo banner — a soft rounded panel
                  // holding the screen title/subtitle on the left and a
                  // circular glowing badge with a restaurant photo on the
                  // right, mirroring the reference GPay home screen's
                  // banner layout (headline + subtext on the left,
                  // illustration on the right). Purely decorative/layout —
                  // every piece of text/element here already existed in the
                  // header before; no data, callback, or navigation logic
                  // lives in this panel.
                  //
                  // PASS 24: this panel's border now uses the PUREDINE
                  // spec's own `paleRose` card-border tone instead of a
                  // translucent wine tint, and its drop shadow is tuned
                  // for the new dark backdrop behind it. Nothing inside —
                  // text, accent dots, divider, photo — was touched.
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _Palette.canvasDeep,
                          _Palette.canvas,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _Palette.paleRose,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Palette.milanoRedDarkest.withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small gold accent-dot row above the title —
                              // a "dotted texture accent" language, purely
                              // decorative.
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
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
                                          alpha: i == 2 ? 0.9 : 0.32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Two-tone ShaderMask on the title — same
                              // text, same font/weight as before.
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    _Palette.milanoRedDeep,
                                    _Palette.lemonChiffon,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Menu Management',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: isMobile ? 20 : 27,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 4 : 6),
                              Text(
                                'Manage your restaurant menu items and categories',
                                style: GoogleFonts.inter(
                                  color: _Palette.textMuted,
                                  fontSize: isMobile ? 12 : 13.5,
                                ),
                              ),
                              if (!isMobile) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _todayLabel(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: _Palette.textMuted,
                                  ),
                                ),
                              ],
                              SizedBox(height: isMobile ? 10 : 12),
                              // Thin gold gradient hairline — a soft divider
                              // language. Purely decorative.
                              Container(
                                width: 46,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      _Palette.lemonChiffon
                                          .withValues(alpha: 0.9),
                                      _Palette.lemonChiffon
                                          .withValues(alpha: 0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isMobile ? 12 : 20),
                        // GPay-style glowing circular illustration — a
                        // restaurant/food photo standing in for the
                        // reference app's illustration on the right side of
                        // its banner. Purely decorative: if the image can't
                        // load, `errorBuilder` falls back to a plain
                        // restaurant icon instead — no logic tied to it.
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: isMobile ? 72 : 92,
                              height: isMobile ? 72 : 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _Palette.lemonChiffon
                                        .withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: isMobile ? 56 : 72,
                              height: isMobile ? 56 : 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _Palette.lemonChiffon
                                      .withValues(alpha: 0.55),
                                  width: 2,
                                ),
                                boxShadow: _Palette.softShadow,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: _Palette.milanoRedDeep,
                                    child: const Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PASS 25 (new method): the "Add Item" / "Create Order" / "Today's
  /// Special" icon-tile quick actions, living outside of
  /// `_buildCustomHeader()`'s wine-gradient panel. This is the exact same
  /// `Row` of three `Expanded`-wrapped `_QuickActionTile` widgets that
  /// used to sit at the bottom of the header, with the exact same three
  /// callbacks (`_showItemForm`, `_showManualOrderForm`,
  /// `_showTodaySpecialDialog`) — only the surrounding container/position
  /// changed.
  ///
  /// PASS 26: no change to this method itself — it never had a background
  /// of its own. The colored tint that used to appear behind it came from
  /// the header's `boxShadow`, which was removed in
  /// `_buildCustomHeader()`.
  ///
  /// PASS 27: this row is now called from inside the body's
  /// `SingleChildScrollView` (see `build()`) instead of from the outer
  /// fixed `Column`, so it is the first thing that scrolls. Its own top
  /// padding was raised from `16` to `24` to absorb the top padding the
  /// scroll view used to apply, so the spacing above the three cards
  /// looks the same as before. The three tiles, their icons, labels, and
  /// callbacks are untouched, and it still has no background of its own —
  /// it renders straight onto the screen's canvas.
  ///
  /// PASS 28: added the same `isDesktopWide` (≥1024px) tier used in
  /// `_buildCustomHeader()`, so the row's horizontal padding and the gap
  /// between tiles step up a little further on laptop-sized screens. Each
  /// `_QuickActionTile` is now also told whether it's on a wide screen
  /// (`isWide:`) so its own icon/label sizing can scale up to match — see
  /// `_QuickActionTile`'s doc comment. No callback wiring changed.
  Widget _buildQuickActionsRow() {
    final double _rowWidth = MediaQuery.of(context).size.width;
    final isMobile = _rowWidth < 800;
    final bool isDesktopWide = _rowWidth >= 1024;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : (isDesktopWide ? 40 : 32),
        isDesktopWide ? 28 : 24,
        isMobile ? 18 : (isDesktopWide ? 40 : 32),
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionTile(
              icon: Icons.add_circle_rounded,
              label: 'Add Item',
              onTap: () => _showItemForm(),
              isWide: isDesktopWide,
            ),
          ),
          SizedBox(width: isMobile ? 10 : (isDesktopWide ? 22 : 16)),
          Expanded(
            child: _QuickActionTile(
              icon: Icons.receipt_long_rounded,
              label: 'Create Order',
              onTap: _showManualOrderForm,
              isWide: isDesktopWide,
            ),
          ),
          SizedBox(width: isMobile ? 10 : (isDesktopWide ? 22 : 16)),
          Expanded(
            child: _QuickActionTile(
              icon: Icons.star_rounded,
              label: "Today's Special",
              onTap: _showTodaySpecialDialog,
              isWide: isDesktopWide,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final double _sidebarWidth = MediaQuery.of(context).size.width;
    final isMobile = _sidebarWidth < 800;
    final bool isDesktopWide = _sidebarWidth >= 1024;

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
                  color: _Palette.dustyBlush.withValues(alpha: 0.6),
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
          color: _Palette.paleRose,
        ),
        boxShadow: _Palette.softShadow,
      ),
      padding: EdgeInsets.all(isDesktopWide ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: isDesktopWide ? 38 : 34,
                height: isDesktopWide ? 38 : 34,
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: _Palette.milanoRedDeep,
                  size: isDesktopWide ? 20 : 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isDesktopWide ? 24 : 22,
                  fontWeight: FontWeight.bold,
                  color: _Palette.milanoRedDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 44),
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
  /// desktop layouts, and 5 on very wide laptop/monitor widths (Pass 28
  /// — a small additional tier so ultra-wide screens don't stretch 4
  /// columns unnecessarily wide; everything below 1500px is completely
  /// unchanged from before). No data, filtering, or mutation logic was
  /// touched here — layout only.
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
            color: _Palette.paleRose,
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
        final cols = c.maxWidth > 1500
            ? 5
            : c.maxWidth > 1100
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
                  ? _Palette.lemonChiffon.withValues(alpha: 0.55)
                  : (widget.isSelected
                      ? _Palette.lemonChiffon.withValues(alpha: 0.6)
                      : (_isHovered
                          ? _Palette.milanoRedDeep.withValues(alpha: 0.3)
                          : _Palette.paleRose)),
              width: isAllItems || widget.isSelected ? 1.4 : 1.2,
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
                      : _Palette.dustyBlush.withValues(alpha: 0.6),
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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered
                ? _Palette.milanoRedDeep.withValues(alpha: 0.55)
                : _Palette.paleRose,
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
/// UI-ENHANCEMENT PASS 7: "Read more"/"Show less" now sits
/// inline at the end of the same line as the description text (matching
/// the reference design's "Tender, boneless murgh ... Read More" style)
/// instead of appearing on its own separate line underneath. A
/// `TextPainter` measures the available width at build time and finds
/// exactly how much of the collapsed description fits alongside
/// "… Read more" on a single line, so the link is never accidentally
/// clipped off the end the way plain `TextOverflow.ellipsis` could. When
/// expanded, "Show less" is likewise appended right after the full text.
///
/// UI-ENHANCEMENT PASS 8: the collapsed description is now
/// checked, up front, against the available width on its own — with no
/// link involved at all. If the full text already fits on a single line,
/// it's shown as plain, non-clickable text and no "Read more" link is
/// rendered. Only when the full text genuinely doesn't fit does the
/// truncate-and-append-"Read more" logic from Pass 7 kick in, and only
/// then does tapping become possible. No data, callback, or navigation
/// logic was touched — only how/when the link itself is shown.
///
/// UI-ENHANCEMENT PASS 16/21/23: purely decorative refinements —
///   • The rating + prep-time row sits inside a small soft pill chip
///     instead of bare text/icons.
///   • The price renders as a soft wine-tinted pill badge instead of
///     plain text.
///   • The "TODAY'S SPECIAL" label sits inside a small gold-tinted pill
///     instead of bare text.
/// No data, callback, or navigation logic was touched.
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

  /// Measures whether [text] already fits, in full, on a single line
  /// within [maxWidth] — with no "Read more" link involved at all. Used
  /// up front to decide whether the description needs truncation/a link
  /// in the first place (Pass 8), before ever reasoning about the link.
  bool _fitsOnOneLine({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);
    return painter.width <= maxWidth;
  }

  /// Finds the longest prefix of [text] that, together with the
  /// "… Read more" suffix, still fits within [maxWidth] on a single
  /// line — using a `TextPainter` binary search rather than relying on
  /// `TextOverflow.ellipsis`, which would just as happily truncate the
  /// appended "Read more" text itself along with the description.
  ///
  /// Only ever called once `_fitsOnOneLine` has already established that
  /// the full text does NOT fit on its own — so a genuine cut is always
  /// needed here.
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

  /// The description block.
  ///
  /// Behaviour (Pass 8):
  ///   • No description at all → category name shown, plain, no link
  ///     (unchanged from before).
  ///   • Description present AND it already fits on one line at the
  ///     available width → shown as plain text, no "Read more" link, not
  ///     tappable. There's nothing to expand, so no affordance is shown.
  ///   • Description present AND it does NOT fit on one line → exactly
  ///     the Pass 7 behaviour: collapsed shows a precisely-measured
  ///     truncated line with "… Read more" appended inline; tapping it
  ///     expands to the full text with "Show less" appended inline, and
  ///     `AnimatedSize` smoothly grows/shrinks the card to fit.
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
                // Pass 8: decide, up front and with no link involved at
                // all, whether the full description already fits on one
                // line at this width.
                final bool fitsFully = _fitsOnOneLine(
                  text: fullText,
                  textStyle: textStyle,
                  maxWidth: constraints.maxWidth,
                );

                if (fitsFully) {
                  // The whole description already reads fine on one
                  // line — no truncation happened, so there's nothing
                  // to "read more" of. Show it plainly, not tappable.
                  return Text(
                    fullText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  );
                }

                // Only reached when the description genuinely doesn't
                // fit on one line — find exactly how much of it fits
                // alongside "… Read more" and show that, with the link
                // appended inline and tappable.
                final truncated = _truncateForInlineLink(
                  text: fullText,
                  textStyle: textStyle,
                  suffixEllipsis: '… ',
                  linkText: 'Read more',
                  linkStyle: linkStyle,
                  maxWidth: constraints.maxWidth,
                );
                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$truncated… ',
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
    //
    // PASS 15: "Today's Special" items now get a thin gold accent bar
    // down the left edge of the card (purely decorative, driven by the
    // same `item.isSpecial` flag already used everywhere else on this
    // card) so specials visually pop out from the grid at a glance.
    final Widget cardBody = Column(
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
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _Palette.lemonChiffon.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.45),
                        width: 0.8,
                      ),
                    ),
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
              // Expandable description with "Read more"/"Show less" —
              // only rendered when the description doesn't already fit
              // on one line (see _buildDescriptionBlock doc comment
              // above). Its AnimatedSize grows this card (and only this
              // card) when tapped, so the "Edit Item" button always
              // stays visible below it.
              _buildDescriptionBlock(),
              const SizedBox(height: 5),
              // PASS 16: rating + prep-time now sit inside a small
              // soft-cream pill chip instead of bare text/icons —
              // purely decorative, same values/icons as before.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: _Palette.canvasDeep.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
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
                      const Icon(
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
              ),
              const SizedBox(height: 8),
              // PASS 16: price now rendered as a soft wine-tinted pill
              // badge instead of plain text — same value/formatting as
              // before, purely decorative wrapper.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _Palette.milanoRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _Palette.milanoRed,
                  ),
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

    if (!item.isSpecial) {
      return cardBody;
    }

    // PASS 15: thin gold accent bar down the left edge for specials —
    // purely decorative, wraps the exact same `cardBody` built above
    // with no change to its content, callbacks, or sizing behaviour.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: _Palette.lemonChiffon,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Expanded(child: cardBody),
      ],
    );
  }
}

/// PASS 11: previously sized itself purely to its own icon+label content
/// (via `mainAxisSize: MainAxisSize.min` on the inner `Row`, with no
/// alignment set on the outer `Container`), which is exactly why the
/// three mobile header buttons ended up with different widths — each one
/// only ever took up as much space as its own text needed. Left in place,
/// unused, after Pass 13 replaced the header's buttons with
/// `_QuickActionTile` — kept so nothing else that might reference it
/// elsewhere is affected, and because an unused private class causes no
/// compile error.
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? _Palette.milanoRedDeep : Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? _Palette.milanoRedDeep : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PASS 13: standard-mobile-app "quick action" icon tile — an icon in a
/// soft rounded square above a short label, in the spirit of a payments
/// app's Scan/Pay/Bank-transfer row. Used for the screen's three quick
/// actions. Purely presentational: the `onTap` passed in is whatever
/// callback the caller gives it (in `_buildQuickActionsRow`, the same
/// `_showItemForm` / `_showManualOrderForm` / `_showTodaySpecialDialog`
/// methods the old header buttons called).
///
/// PASS 14: the tile itself now carries a subtle resting shadow (in
/// addition to the icon circle's existing `softShadow`) and a slightly
/// stronger hover/press tint, so each tile reads as a distinct tappable
/// card rather than a flat tinted rectangle — a depth/elevation tweak
/// only, the `onTap` wiring is unchanged.
///
/// PASS 25: this tile renders outside of the header's wine-gradient
/// panel (on the screen's own canvas background, via
/// `_buildQuickActionsRow`) instead of inside it — its own styling,
/// shadow, and border already read fine on a light background, so
/// nothing inside this widget needed to change to support the move.
///
/// PASS 26/27: no change to this widget. The colored bleed that used to
/// sit behind these tiles came from the header's own `boxShadow` (removed
/// in Pass 26) and its bottom hairline border (removed in Pass 27), not
/// from anything in this class. As of Pass 27 these tiles are simply the
/// first scrollable content in the body.
///
/// PASS 28: added an optional `isWide` flag (defaults to `false`, so
/// every existing call site that doesn't pass it renders exactly as
/// before). When `true` — passed from `_buildQuickActionsRow()` on
/// laptop-sized (≥1024px) screens — the icon circle, icon glyph, tile
/// padding, and label text step up to a slightly larger, more "premium"
/// size. The `onTap` wiring and every other behaviour are unchanged.
class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double iconCircleSize = widget.isWide ? 48 : 40;
    final double iconGlyphSize = widget.isWide ? 24 : 20;
    final double tilePaddingV = widget.isWide ? 18 : 14;
    final double labelFontSize = widget.isWide ? 12.5 : 11.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: tilePaddingV, horizontal: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? _Palette.milanoRedDeep.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? _Palette.milanoRedDeep.withValues(alpha: 0.25)
                  : _Palette.paleRose,
            ),
            boxShadow: _isHovered ? _Palette.glowShadow : _Palette.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PASS 15: soft gradient fill + thin accent ring instead
              // of a flat cream circle, so each quick-action icon reads
              // as a more inviting, on-brand button.
              Container(
                width: iconCircleSize,
                height: iconCircleSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _Palette.canvasDeep,
                      _Palette.lemonChiffon.withValues(alpha: 0.22),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _Palette.lemonChiffon.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  boxShadow: _Palette.softShadow,
                ),
                child: Icon(
                  widget.icon,
                  color: _Palette.milanoRedDeep,
                  size: iconGlyphSize,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w700,
                  color: _Palette.textDark,
                ),
              ),
            ],
          ),
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
                ? _Palette.lemonChiffon.withValues(alpha: 0.7)
                : _Palette.paleRose,
            width: isSelected ? 1.3 : 1,
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

/// Notification bell for the Menu Management header. Previously this
/// only lived on the dashboard ("Home") screen; since Home was removed
/// from the bottom nav, it moved here — same NotificationProvider, same
/// unread badge, same tap-to-view-notifications behavior as before.
///
/// PASS 13: restyled for the header's new light background — previously
/// a translucent-white circle with a white icon (designed for the old
/// dark maroon gradient header), now a white circle with a soft shadow
/// and a deep wine icon, matching the rest of the new light header. Same
/// `NotificationProvider`, same unread badge, same
/// tap-to-view-notifications behavior as before.
///
/// PASS 24: the header behind this bell is a wine/maroon gradient again
/// (see `_buildCustomHeader`), but the bell itself is unchanged — still
/// a white circle with a deep-wine icon, same `NotificationProvider`,
/// same unread badge, same tap behaviour. It already reads clearly
/// against the new darker backdrop, so nothing here needed to change.
class _MenuNotificationBell extends StatefulWidget {
  const _MenuNotificationBell();

  @override
  State<_MenuNotificationBell> createState() => _MenuNotificationBellState();
}

class _MenuNotificationBellState extends State<_MenuNotificationBell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final unread = prov.unreadCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showNotificationOverlay(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered
                  ? _Palette.lemonChiffon.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.milanoRedDarkest.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: _Palette.milanoRedDeep,
                  size: 21,
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
                          color: Colors.white,
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
                const Divider(height: 1, color: _Palette.lemonChiffonDeep),
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
                          subtitle: Text(
                            _formatTimeAgo(n.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _Palette.textMuted,
                            ),
                          ),
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

  String _formatTimeAgo(DateTime dt) {
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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
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
                        Container(
                          width: 4,
                          height: 34,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: _Palette.milanoRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: _Palette.milanoRed,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'New Order',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _Palette.milanoRedDeep,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDismiss,
                          icon: const Icon(Icons.close),
                          color: _Palette.textMuted,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.notification.message,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _Palette.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: widget.onView,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Palette.milanoRedDeep,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('View Order'),
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
      ),
    );
  }
}
