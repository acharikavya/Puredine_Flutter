import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/tables_service.dart';
import 'package:restaurant_unified_app/utils/file_download_helper.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local screen palette — matches AdminDashboardScreen, MenuScreen,
/// OrdersScreen, ProfileScreen, StaffLandingScreen, and StaffScreen
/// exactly, so this screen reads as part of the same consistent brand
/// instead of its own one-off theme. Used ONLY for this screen's restyle.
/// Nothing here touches AppColors or any other file — pure UI
/// enhancement, no logic changed anywhere here.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header up to the same
/// distinctive "command bar" identity used on the Admin Orders screen — a
/// richer four-stop diagonal gradient, a large faint watermark emblem,
/// and a fine glass highlight line along the top edge. The full-screen
/// backdrop gained an extra ambient glow + a diagonal sheen for more
/// depth, and the stat cards picked up the same slim color-coded top cap
/// used on the Orders screen's stat cards so each figure has its own
/// subtle identity at a glance. No provider, service, filtering, dialog,
/// QR-generation, or download logic was touched anywhere in this pass —
/// only presentation changed.
///
/// UI-ENHANCEMENT PASS 3: tightened the vertical space above the
/// "Tables Management" title inside the header — reduced the header's
/// top padding and the gap between the top icon row and the title block
/// so the heading sits right under the top edge instead of floating
/// further down the bar. Purely a spacing tweak; no provider, service,
/// filtering, dialog, QR-generation, or download logic was touched.
///
/// UI-ENHANCEMENT PASS 4: the title block ("Tables Management" + its
/// subtitle) now sits on the SAME row as the add-table icon button,
/// instead of stacking underneath a separate top row. This pulls the
/// title further up (level with the button, right at the top of the
/// header) instead of floating lower in the bar. Purely a layout/spacing
/// change — no provider, service, filtering, dialog, QR-generation, or
/// download logic was touched.
///
/// UI-ENHANCEMENT PASS 5: restyled the QR Code dialog (`_showQRDialog`)
/// to fully match the screen's maroon × gold theme — a themed
/// command-bar header, a gold-ring frame around the QR canvas, and
/// gradient maroon/gold action buttons replacing the plain red/blue
/// buttons. The dialog heading was simplified to just the table number
/// (no more "QR Code -" prefix and no duplicate subtitle line
/// underneath). Purely presentational — the QR data, download, and
/// copy-link logic are byte-for-byte unchanged.
///
/// UI-ENHANCEMENT PASS 6 (bugfix, purely visual): fixed a mobile-only
/// render overflow inside the QR dialog's action-button row ("Download
/// PNG" / "Copy Link"). The dialog card previously used a hard-coded
/// `width: 360`, which is wider than the viewport on narrow phones, so
/// the icon+label content inside each button had less room than it
/// needed and Flutter reported a RenderFlex overflow. Fixed by:
///   1. Making the dialog card's width responsive (same clamp pattern as
///      the existing `_dialogWidth()` helper used by the Add Table
///      dialog), via a new `_qrDialogWidth()` helper, so the card never
///      exceeds the actual screen width.
///   2. Wrapping each button's icon+label content in a
///      `FittedBox(fit: BoxFit.scaleDown)` so that on any remaining
///      ultra-narrow screens the content scales down instead of
///      overflowing.
/// No provider, service, filtering, dialog-trigger, QR-generation,
/// download, or copy-link logic was touched — only the sizing/wrapping
/// needed to make the button row render without an overflow error.
///
/// UI-ENHANCEMENT PASS 7: `_buildHeader()` was rebuilt from the dark
/// four-stop maroon "command bar" into a bright, majority-white top bar
/// with a date "pill" on the left and the circular "Add Table" icon
/// button on the right.
///
/// UI-ENHANCEMENT PASS 8: the promo-banner panel's circular decorative
/// graphic on the right previously showed a real network photo
/// (`Image.network(...)` with an `errorBuilder` fallback). That photo was
/// removed entirely — the circular badge became a plain solid-color icon
/// badge instead (no network image, no fallback branch needed).
///
/// UI-ENHANCEMENT PASS 9: `_buildHeader()` was rebuilt again to match
/// StaffScreen's flat header — no date "pill" bar, no circular
/// badge/photo of any kind, just a plain white bar with a hairline
/// bottom border, a faint watermark icon behind the copy, a two-tone
/// `ShaderMask` title, the date as plain inline text (desktop only), the
/// same subtitle copy, a thin gold underline accent, and the exact same
/// circular "Add Table" icon button (`_addIconButton()`, same
/// `_showAddDialog` callback).
///
/// UI-ENHANCEMENT PASS 10: presentation-only, exactly like every pass
/// above — no provider, service, data loading, filtering, dialog,
/// QR-generation, download, or copy-link logic anywhere in this file was
/// touched, and no state field, controller, callback, or keyword was
/// renamed.
///   1. PALETTE — full PUREDINE mapping: every field name inside
///      `_Palette` is unchanged on purpose (every widget in this file
///      already reads from these exact names, so swapping only the
///      underlying `Color` values re-skins the whole screen with no
///      other code touched):
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
///        • `info`             → Deep Wine Maroon `#742A3C`, so the QR
///          action icon stops being a stray blue against the warm palette
///        • `danger` is kept as a clear alert red (not part of the
///          supplied palette) so delete/error states stay legible.
///      Four supporting PUREDINE tones were ADDED as new fields —
///      `dustyBlush` (`#F3D9DC`, icon backgrounds), `paleRose`
///      (`#EFD7DA`, card borders), `softYellow` (`#FCE1AB`, gold
///      highlight) and `paleMint` (`#EAF6EF`, success backgrounds).
///      Nothing existing was removed. `headerGradient` now holds the
///      supplied header gradient exactly (`#742A3C → #813244`), and a
///      new `ctaGradient` holds the supplied CTA gradient exactly
///      (`#6E1832 → #9B3E4E → #F3C564`).
///   2. TOP BAR: `_buildHeader()` is no longer a flat white bar — it now
///      carries the PUREDINE Deep Wine Maroon → Wine diagonal gradient,
///      a medium-depth (not near-black) maroon band running the full
///      width from the very top of the screen down to the scrollable
///      body. It gained the same ambient dressing the other admin
///      headers use — a soft warm-gold corner glow, a large very faint
///      watermark emblem, and a subtle diagonal glass sheen — plus a
///      warm-gold hairline along its bottom edge. Structurally nothing
///      inside changed: the same title, the same desktop-only inline
///      date, the same subtitle copy, the same gold underline accent,
///      and the exact same `_addIconButton()` with the exact same
///      `_showAddDialog` callback. Only the copy's colors changed
///      (white / soft-gold instead of maroon / taupe) so it reads
///      clearly against the wine backdrop.
///   3. TOP-TO-BOTTOM CONSISTENCY: so the whole screen reads as one
///      brand rather than just a re-colored header, the card surfaces
///      below it were tuned to the same spec — cards use the Pale Rose
///      border and Soft Cream tints, small icon containers use the
///      Dusty Blush icon-BG, the stats row/filter bar/table panel share
///      the same rounded, softly shadowed treatment, and the backdrop
///      gained an extra low blush glow so the bottom of a long scroll
///      keeps the same warm tint as the top.
///
/// UI-ENHANCEMENT PASS 11 (this pass): responsive/tablet-laptop polish —
/// no provider, service, data loading, filtering, dialog, QR-generation,
/// download, or copy-link logic anywhere in this file was touched, and
/// no state field, controller, callback, or keyword was renamed. See the
/// per-method doc comments below for exactly what changed (an extra
/// `isDesktopWide` (≥1024px) breakpoint tier layered on top of the
/// existing `isMobile` (<800px) split, plus a small step-up in the body's
/// horizontal padding for the 1024–1399px laptop range — sizing only).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  // PUREDINE Maroon + Cream — field names unchanged on purpose (see the
  // PASS 10 note above); only the underlying Color values changed.
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
  static const Color info =
      Color(0xFF742A3C); // Deep Wine Maroon (was a stray blue)

  // PASS 10: four supporting PUREDINE tones added — nothing above this
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
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E1832), Color(0xFF9B3E4E), lemonChiffon],
  );

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used across the other admin screens.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRed.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
}

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<TableModel> _tables = [];
  List<TableModel> _filteredTables = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _statusFilter = 'All Status';
  String _tableTypeFilter = 'All Tables';

  final _tableNumCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '4');

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
    _loadTables();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tableNumCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final list = await TablesService.getTables();
      setState(() {
        _tables = list;
        _applyFilters();
      });
    } catch (e) {
      // Error ignored
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTables = _tables.where((t) {
        final matchesSearch = t.tableNumber.toLowerCase().contains(query);
        final matchesStatus = _statusFilter == 'All Status' ||
            (_statusFilter == 'Occupied' && t.status == 'OCCUPIED') ||
            (_statusFilter == 'Empty' && t.status == 'EMPTY');
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _toggleTable(String id) async {
    try {
      await TablesService.toggleTable(id);
      _loadTables();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _deleteTable(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _Palette.cardWhite,
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
          'Delete Table',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _Palette.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this table? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: _Palette.textMuted, fontSize: 13.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // NOTE: the two buttons are wrapped in a single Row (instead of
        // being passed to `actions` as separate Expanded items) because
        // AlertDialog renders its `actions` list inside an internal
        // OverflowBar, which does not provide the FlexParentData that
        // Expanded needs — passing Expanded directly as an actions item
        // throws "Incorrect use of ParentDataWidget". Wrapping them in one
        // Row (itself a proper Flex) as the single actions item keeps the
        // exact same equal-width, 10px-gapped button layout without the
        // crash. (Same fix applied to StaffScreen's dialogs.)
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    side: const BorderSide(color: _Palette.paleRose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
        ],
      ),
    );
    if (confirm == true) {
      try {
        await TablesService.deleteTable(id);
        _loadTables();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  Future<void> _downloadQR(TableModel t, String qrData) async {
    try {
      const double qrSize = 1024;
      const double padding = 120;
      const double canvasSize = qrSize + (padding * 2);

      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,

        // Maximum error correction for easier scanning.
        errorCorrectionLevel: QrErrorCorrectLevel.H,

        // Keep modules clean and separated.
        gapless: false,

        // BLACK QR
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),

        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),

        // WHITE QR background.
        emptyColor: Colors.white,
      );

      // Create a completely opaque white image.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // White background over the ENTIRE exported image.
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          canvasSize,
          canvasSize,
        ),
        Paint()..color = Colors.white,
      );

      // Put the QR in the middle, leaving a large white quiet zone.
      canvas.save();

      canvas.translate(padding, padding);

      painter.paint(
        canvas,
        const Size(qrSize, qrSize),
      );

      canvas.restore();

      // Convert to final PNG.
      final picture = recorder.endRecording();

      final image = await picture.toImage(
        canvasSize.toInt(),
        canvasSize.toInt(),
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to create QR PNG');
      }

      final bytes = byteData.buffer.asUint8List();

      debugPrint('QR PNG generated: ${bytes.length} bytes');

      final success = await downloadFile(
        bytes,
        'table_${t.tableNumber}_qr.png',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'QR downloaded successfully' : 'Failed to download QR',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('QR download failed: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download QR'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// UI-ENHANCEMENT PASS 6: computes the QR dialog card's width so it
  /// always fits the current screen instead of using a hard-coded 360px,
  /// which was the root cause of the mobile "RenderFlex overflowed by
  /// 18 pixels" error inside the action-button row. Desktop/tablet keeps
  /// the original 360px card width; on narrow phones the width shrinks to
  /// (screen width − outer insets) so the card — and everything inside
  /// it, including the Download/Copy buttons — never overflows. Mirrors
  /// the same clamp pattern as the existing `_dialogWidth()` helper used
  /// by the Add Table dialog.
  double _qrDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const outerInset = 48.0; // default showDialog horizontal insets
    if (screenWidth < 360 + outerInset) {
      return (screenWidth - outerInset).clamp(240.0, 360.0);
    }
    return 360.0;
  }

  /// UI-ENHANCEMENT PASS 5: restyled to match the screen's maroon × gold
  /// theme end-to-end — a themed command-bar header (replacing the plain
  /// white header row), a gold-ring frame around the QR canvas, and
  /// gradient maroon/gold action buttons (replacing the flat red
  /// "Download PNG" / blue "Copy Link" buttons). The heading now shows
  /// ONLY the table number ("Table 86") — the old "QR Code - Table 86"
  /// prefix and the duplicate "Table 86" subtitle line beneath it have
  /// been removed. The QR data, download callback, and copy-to-clipboard
  /// callback are all byte-for-byte unchanged.
  ///
  /// UI-ENHANCEMENT PASS 6 (bugfix, purely visual): the card width now
  /// comes from `_qrDialogWidth()` instead of a fixed 360, and each
  /// action button's icon+label is wrapped in a `FittedBox` so the
  /// "Download PNG" / "Copy Link" row can never overflow on narrow mobile
  /// screens. See the PASS 6 note above `_Palette` for full details.
  ///
  /// UI-ENHANCEMENT PASS 7: the command-bar header strip switched from a
  /// solid dark maroon gradient with white text/icons to a light
  /// background with maroon text/icons and a gold bottom border.
  ///
  /// UI-ENHANCEMENT PASS 10: the dialog's colors now come from the
  /// PUREDINE palette via the same `_Palette` fields as before (its
  /// header strip sits on Soft Cream with a Warm Gold bottom border, the
  /// primary button uses the Deep Wine Maroon → Wine gradient and the
  /// secondary the Warm Gold → deeper-gold pair). The QR data, download
  /// callback, and copy-to-clipboard callback remain byte-for-byte
  /// unchanged.
  void _showQRDialog(TableModel t) {
    const baseUrl = 'https://customerfinal1.vercel.app/customer/scan-qr';
    final qrData = (t.qrCode != null && t.qrCode!.isNotEmpty)
        ? '$baseUrl?token=${t.qrCode}'
        : '$baseUrl?table=${t.id}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          // Responsive width — fixes the mobile-only RenderFlex overflow
          // that occurred when this was hard-coded to 360 on screens
          // narrower than ~360 + 48px of dialog insets.
          width: _qrDialogWidth(ctx),
          decoration: BoxDecoration(
            color: _Palette.canvas,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _Palette.lemonChiffon.withValues(alpha: 0.5),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.milanoRedDarkest.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: _Palette.lemonChiffon.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Command-bar header — a light Soft Cream strip with
              // maroon text/icons and a Warm Gold bottom border, matching
              // the rest of the screen's PUREDINE identity. Heading still
              // shows only "Table {number}".
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                decoration: const BoxDecoration(
                  color: _Palette.canvasDeep,
                  border: Border(
                    bottom: BorderSide(
                      color: _Palette.lemonChiffon,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _Palette.dustyBlush,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _Palette.lemonChiffonDeep.withValues(
                            alpha: 0.55,
                          ),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: _Palette.milanoRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Table ${t.tableNumber}',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: _Palette.milanoRed,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _Palette.milanoRed.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 17,
                            color: _Palette.milanoRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gold-ring QR frame — a slim maroon → gold gradient
                    // border wrapping the white QR canvas, matching the
                    // theme's signature "gold glow" edge treatment.
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _Palette.lemonChiffon,
                            _Palette.milanoRed,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _Palette.milanoRed.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _Palette.cardWhite,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 220,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: _Palette.milanoRedDarkest,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: _Palette.milanoRedDarkest,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _Palette.lemonChiffon.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              _Palette.lemonChiffonDeep.withValues(alpha: 0.4),
                        ),
                      ),
                      child: SelectableText(
                        qrData,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _Palette.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        // Primary action — solid maroon gradient, matching
                        // the header bar and the app's primary CTA color.
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(ctx);
                                _downloadQR(t, qrData);
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      _Palette.milanoRedLight,
                                      _Palette.milanoRed,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _Palette.milanoRed
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 4,
                                  ),
                                  // FittedBox guarantees this icon+label
                                  // content can never overflow its
                                  // Expanded button, even on the
                                  // narrowest phone screens — the fix for
                                  // the reported mobile RenderFlex
                                  // overflow.
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.download_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Download PNG',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Secondary action — gold gradient with deep
                        // maroon text/icon for contrast, so the two
                        // buttons read as one cohesive maroon×gold pair
                        // instead of the previous mismatched red/blue.
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: qrData),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Link copied to clipboard'),
                                  ),
                                );
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      _Palette.softYellow,
                                      _Palette.lemonChiffon,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _Palette.lemonChiffonDeep
                                        .withValues(alpha: 0.45),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _Palette.lemonChiffonDeep
                                          .withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 4,
                                  ),
                                  // Same overflow-safe wrapper as the
                                  // Download button above.
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.copy,
                                          size: 17,
                                          color: _Palette.milanoRed,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Copy Link',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _Palette.milanoRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
    );
  }

  /// Computes a dialog content width that always fits the current screen.
  /// Desktop/tablet gets a fixed 420px width; on narrow phones the width
  /// shrinks to (screen width − outer insets) so the dialog never
  /// overflows. Mirrors the exact same helper added to StaffScreen's
  /// `_showAddDialog`/`_showEditDialog`.
  double _dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const outerInset = 48.0; // matches insetPadding horizontal (24 + 24)
    if (screenWidth < 480) {
      return (screenWidth - outerInset).clamp(240.0, 420.0);
    }
    return 420.0;
  }

  void _showAddDialog() {
    _tableNumCtrl.clear();
    _capacityCtrl.text = '4';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: _Palette.cardWhite,
        // Matches the mobile-safe insetPadding added to StaffScreen's
        // dialogs so this dialog always has consistent breathing room from
        // the screen edges on phones.
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        icon: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: _Palette.dustyBlush,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.table_restaurant_rounded,
            color: _Palette.milanoRed,
            size: 26,
          ),
        ),
        title: Text(
          'Add Table',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRed,
          ),
        ),
        // Width is derived from the actual screen size (see _dialogWidth)
        // instead of sizing purely from intrinsic content width, so the
        // dialog always fits comfortably on narrow phones — same
        // responsive-width treatment as StaffScreen's Add/Edit dialogs.
        content: SizedBox(
          width: _dialogWidth(ctx),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                _tableNumCtrl,
                'Table Number',
                Icons.table_restaurant_outlined,
              ),
              const SizedBox(height: 14),
              _dialogField(
                _capacityCtrl,
                'Capacity',
                Icons.groups_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // NOTE: the two buttons are wrapped in a single Row (instead of
        // being passed to `actions` as separate Expanded items) because
        // AlertDialog renders its `actions` list inside an internal
        // OverflowBar, which does not provide the FlexParentData that
        // Expanded needs — passing Expanded directly as an actions item
        // throws "Incorrect use of ParentDataWidget". Wrapping them in one
        // Row (itself a proper Flex) as the single actions item keeps the
        // exact same equal-width, 10px-gapped button layout without the
        // crash. (Same fix applied to StaffScreen's dialogs.)
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textMuted,
                    side: const BorderSide(color: _Palette.paleRose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.milanoRed,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await TablesService.createTable({
                        'table_number': _tableNumCtrl.text,
                        'capacity': int.tryParse(_capacityCtrl.text) ?? 4,
                      });
                      _loadTables();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                      }
                    }
                  },
                  child: Text(
                    'Add',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: _Palette.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: _Palette.milanoRed),
        labelStyle: GoogleFonts.inter(color: _Palette.textMuted),
        filled: true,
        fillColor: _Palette.canvasDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _Palette.milanoRed, width: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    // PASS 11: extra sizing-only tier for laptop/large-monitor widths —
    // does not change the `isMobile` (<800) structural switch used
    // throughout this file (stat row layout, filters bar layout, table
    // list layout are all untouched), only how much horizontal breathing
    // room the scrollable body and a few internal paddings get on
    // genuinely large screens.
    final bool isDesktopWide = size.width >= 1024;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/wine/blush glows plus a faint
          // textured photograph, matching the rest of the admin app's
          // "foggy" backdrop so this screen feels like one cohesive brand.
          Positioned.fill(
            child: Container(
              color: _Palette.canvas,
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffon.withValues(alpha: 0.5),
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
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRed.withValues(alpha: 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Extra low, wide glow further down the page — gives the
                  // long tables list a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  Positioned(
                    top: 640,
                    right: -110,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRedLight.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // PASS 10: a soft blush glow low on the left, so the
                  // bottom of a long scroll carries the same warm brand
                  // tint as the top instead of fading to flat white.
                  Positioned(
                    bottom: 60,
                    left: -60,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.dustyBlush.withValues(alpha: 0.45),
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

          // Faint diagonal sheen sweeping across the body — a subtle extra
          // layer of depth so the cream backdrop doesn't read as flat
          // behind the header, echoing the glass-highlight language used
          // in the header itself. Matches the Admin Orders screen exactly.
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

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _Palette.milanoRed),
                )
              : Column(
                  children: [
                    _buildHeader(isMobile),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? 16
                              : (size.width > 1400
                                  ? 64
                                  : (isDesktopWide ? 48 : 40)),
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsRow(isMobile),
                            const SizedBox(height: 24),
                            _buildFiltersBar(isMobile),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _Palette.milanoRedDeep,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Showing ${_filteredTables.length} tables',
                                  style: GoogleFonts.inter(
                                    color: _Palette.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTablesList(isMobile),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// PASS 9 made this a flat white bar matching StaffScreen's header.
  ///
  /// PASS 10: the same bar now carries the PUREDINE Deep Wine Maroon →
  /// Wine gradient (`#742A3C → #813244`) instead of flat white — a
  /// medium-depth maroon top bar spanning the full width of the screen,
  /// with a soft warm-gold corner glow, a large very faint watermark
  /// emblem behind the copy, a subtle diagonal glass sheen, and a
  /// warm-gold hairline along the bottom edge. Structurally identical to
  /// before: the same two-tone `ShaderMask` title, the same desktop-only
  /// inline date text (no pill/container around it), the same subtitle
  /// copy, the same thin gold underline accent, and the exact same
  /// circular "Add Table" icon button (`_addIconButton()`, same
  /// `_showAddDialog` callback, completely unchanged). Only the copy's
  /// colors changed so it reads clearly on the wine backdrop. No
  /// navigation, dialog, or any other logic was touched — presentation
  /// only.
  ///
  /// PASS 11: added an `isDesktopWide` (≥1024px) tier on top of the
  /// existing `isMobile` split, so the header's padding and title/
  /// subtitle font sizes step up a little further on laptop-sized
  /// screens instead of reusing the same values a mid-size tablet gets.
  /// The title, the desktop-only inline date, the subtitle copy, the
  /// gold underline accent, and `_addIconButton()`/`_showAddDialog` are
  /// completely unchanged in structure and behaviour.
  Widget _buildHeader(bool isMobile) {
    final double _headerWidth = MediaQuery.of(context).size.width;
    final bool isDesktopWide = _headerWidth >= 1024;
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
      ),
      child: Stack(
        children: [
          // Ambient dressing for the wine backdrop — a soft warm-gold
          // corner glow, a large very faint watermark emblem behind the
          // copy, and a diagonal glass sheen. Purely decorative, clipped
          // to the header's own bounds.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -50,
                      child: Container(
                        width: 230,
                        height: 230,
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
                      right: isMobile ? -22 : -14,
                      bottom: isMobile ? -20 : -16,
                      child: Icon(
                        Icons.table_bar_rounded,
                        size: isMobile ? 120 : 160,
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
                isMobile ? 18 : (isDesktopWide ? 40 : 32),
                isMobile ? 16 : (isDesktopWide ? 26 : 22),
                isMobile ? 18 : (isDesktopWide ? 40 : 32),
                isMobile ? 18 : (isDesktopWide ? 28 : 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — the two-tone title, the date (desktop
                  // only, plain text, no pill), and the "add table" icon
                  // button, all on one line. No search bar and no date
                  // pill/circle of any kind here.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              _Palette.lemonChiffon,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Tables Management',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize:
                                  isMobile ? 21 : (isDesktopWide ? 32 : 28),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isMobile) ...[
                        Text(
                          _todayLabel(),
                          style: GoogleFonts.inter(
                            fontSize: isDesktopWide ? 13 : 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: _Palette.softYellow,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      _addIconButton(),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    'Manage restaurant tables and QR codes',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: isMobile ? 12.5 : (isDesktopWide ? 15 : 14),
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  // Thin gold gradient hairline — the same soft divider
                  // language used across the rest of the app's headers.
                  // Purely decorative.
                  Container(
                    width: 46,
                    height: 3,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact circular icon-only "add table" button — completely
  /// unchanged: same `_showAddDialog` callback, same table icon with a
  /// small "+" badge in the corner. Its gold fill already read as the
  /// header's primary affordance, and it reads even more clearly against
  /// the new wine backdrop, so nothing inside it needed to change.
  Widget _addIconButton() {
    return Tooltip(
      message: 'Add Table',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _showAddDialog,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Palette.lemonChiffon,
              boxShadow: [
                BoxShadow(
                  color: _Palette.milanoRedDarkest.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.4,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.table_restaurant_rounded,
                    size: 22,
                    color: _Palette.milanoRed,
                  ),
                ),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _Palette.milanoRed,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 11,
                      color: Colors.white,
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

  Widget _buildStatsRow(bool isMobile) {
    final total = _tables.length;
    final active = _tables.where((t) => t.isActive).length;
    final occupied = _tables.where((t) => t.status == 'OCCUPIED').length;
    final empty = total - occupied;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard(
              'Total',
              total.toString(),
              _Palette.milanoRed,
              isMobile,
              Icons.table_bar_outlined,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Active',
              active.toString(),
              _Palette.success,
              isMobile,
              Icons.check_circle_outline,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Empty',
              empty.toString(),
              _Palette.success,
              isMobile,
              Icons.event_seat_outlined,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Occupied',
              occupied.toString(),
              _Palette.milanoRedDeep,
              isMobile,
              Icons.people_alt_outlined,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _buildStatCard(
          'Total Tables',
          total.toString(),
          _Palette.milanoRed,
          false,
          Icons.table_bar_outlined,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          'Active',
          active.toString(),
          _Palette.success,
          false,
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          'Empty',
          empty.toString(),
          _Palette.success,
          false,
          Icons.event_seat_outlined,
        ),
        const SizedBox(width: 20),
        _buildStatCard(
          'Occupied',
          occupied.toString(),
          _Palette.milanoRedDeep,
          false,
          Icons.people_alt_outlined,
        ),
      ],
    );
  }

  /// This stat card carries the same slim color-coded top cap used on the
  /// Admin Orders screen's stat cards (a thin bar in the card's accent
  /// color, plus a small glowing dot next to the label), so both admin
  /// screens share one consistent "stat card" identity. Same
  /// label/value/color/icon inputs as before.
  ///
  /// PASS 10: the card body sits on a white → Soft Cream wash with a Pale
  /// Rose border, matching the PUREDINE card spec — decoration only, no
  /// data changed.
  ///
  /// PASS 11: added the same `isDesktopWide` (≥1024px) tier used
  /// elsewhere, so the card's inner padding, value font size, and icon
  /// chip size step up a little further on laptop-sized screens (desktop/
  /// non-mobile branch only — the mobile horizontal-scroll card sizing is
  /// untouched). Same label/value/color/icon inputs as before.
  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    bool isMobile,
    IconData icon,
  ) {
    final double _cardWidth = MediaQuery.of(context).size.width;
    final bool isDesktopWide = !isMobile && _cardWidth >= 1024;

    Widget cardContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Slim color-coded top cap — an instant visual cue tying this
          // card to its meaning, matching the Admin Orders screen's stat
          // cards exactly.
          Container(height: 3, color: color.withValues(alpha: 0.65)),
          Container(
            padding: EdgeInsets.all(
              isMobile ? 16 : (isDesktopWide ? 24 : 20),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _Palette.canvasDeep],
              ),
              border: Border.all(
                color: _Palette.paleRose,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                color: _Palette.textMuted,
                                fontSize: isMobile ? 11 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: isMobile ? 20 : (isDesktopWide ? 27 : 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 16 : (isDesktopWide ? 22 : 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return SizedBox(width: 140, child: cardContent);
    }

    return Expanded(child: cardContent);
  }

  Widget _buildFiltersBar(bool isMobile) {
    final double _filtersWidth = MediaQuery.of(context).size.width;
    final bool isDesktopWide = _filtersWidth >= 1024;
    return Container(
      padding: EdgeInsets.all(isDesktopWide ? 20 : 16),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _Palette.dustyBlush,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: _Palette.milanoRed,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Filters',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _Palette.milanoRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isMobile
              ? Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: _Palette.textDark),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.inter(
                          color: _Palette.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: _Palette.milanoRed,
                        ),
                        filled: true,
                        fillColor: _Palette.canvasDeep,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _Palette.paleRose,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _Palette.paleRose,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: _Palette.milanoRed,
                            width: 1.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            _statusFilter,
                            ['All Status', 'Occupied', 'Empty'],
                            (v) {
                              setState(() {
                                _statusFilter = v!;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(color: _Palette.textDark),
                        decoration: InputDecoration(
                          hintText: 'Search by table number...',
                          hintStyle: GoogleFonts.inter(
                            color: _Palette.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: _Palette.milanoRed,
                          ),
                          filled: true,
                          fillColor: _Palette.canvasDeep,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _Palette.paleRose,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _Palette.paleRose,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                            borderSide: BorderSide(
                              color: _Palette.milanoRed,
                              width: 1.4,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        _statusFilter,
                        ['All Status', 'Occupied', 'Empty'],
                        (v) {
                          setState(() {
                            _statusFilter = v!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(_tableTypeFilter, ['All Tables'], (
                        v,
                      ) {
                        setState(() => _tableTypeFilter = v!);
                      }),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _Palette.canvasDeep,
        border: Border.all(color: _Palette.paleRose),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _Palette.milanoRed,
          ),
          dropdownColor: _Palette.cardWhite,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _Palette.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTablesList(bool isMobile) {
    if (_filteredTables.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: _Palette.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Palette.paleRose),
          boxShadow: _Palette.softShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.table_bar_outlined,
                size: 40,
                color: _Palette.milanoRed.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 12),
              Text(
                'No tables found',
                style: GoogleFonts.inter(
                  color: _Palette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredTables.length,
        itemBuilder: (ctx, i) => _buildTableMobileCard(_filteredTables[i]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _Palette.lemonChiffon.withValues(alpha: 0.30),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                _headerCell('TABLE NUMBER', 2),
                _headerCell('QR CODE', 2),
                _headerCell('STATUS', 2),
                _headerCell('ACTIVE', 2),
                _headerCell('ACTIONS', 2),
              ],
            ),
          ),
          // List Items
          ..._filteredTables.asMap().entries.map(
                (entry) => _buildTableRow(entry.value, entry.key),
              ),
        ],
      ),
    );
  }

  Widget _buildTableMobileCard(TableModel t) {
    const baseUrl = 'https://customerfinal1.vercel.app/customer/scan-qr';
    final qrData = (t.qrCode != null && t.qrCode!.isNotEmpty)
        ? '$baseUrl?token=${t.qrCode}'
        : '$baseUrl?table=${t.id}';
    final bool isOccupied = t.status == 'OCCUPIED';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palette.paleRose),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.tableNumber,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _Palette.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOccupied ? _Palette.dustyBlush : _Palette.paleMint,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isOccupied ? 'OCC' : 'EMP',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color:
                        isOccupied ? _Palette.milanoRedDeep : _Palette.success,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showQRDialog(t),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: _Palette.paleRose),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 60,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _Palette.milanoRedDarkest,
                ),
              ),
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showQRDialog(t),
                  icon: const Icon(
                    Icons.qr_code,
                    size: 18,
                    color: _Palette.info,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteTable(t.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: _Palette.milanoRedDeep,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: t.isActive,
                    onChanged: (v) => _toggleTable(t.id),
                    activeColor: _Palette.milanoRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: _Palette.milanoRedDarkest.withValues(alpha: 0.65),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTableRow(TableModel t, int index) {
    const baseUrl = 'https://customerfinal1.vercel.app/customer/scan-qr';
    final qrData = (t.qrCode != null && t.qrCode!.isNotEmpty)
        ? '$baseUrl?token=${t.qrCode}'
        : '$baseUrl?table=${t.id}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: index == _filteredTables.length - 1
            ? null
            : const Border(
                bottom: BorderSide(color: _Palette.paleRose),
              ),
      ),
      child: Row(
        children: [
          // Table Number
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.tableNumber,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _Palette.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.id.length > 8 ? '${t.id.substring(0, 8)}...' : t.id,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _Palette.textMuted.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // QR Preview
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              width: 48,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: _Palette.paleRose),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 40,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _Palette.textDark,
                  ),
                ),
              ),
            ),
          ),
          // Status Chip
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: t.status == 'OCCUPIED'
                      ? _Palette.dustyBlush
                      : _Palette.paleMint,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: t.status == 'OCCUPIED'
                        ? _Palette.milanoRedDeep.withValues(alpha: 0.25)
                        : _Palette.success.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  t.status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: t.status == 'OCCUPIED'
                        ? _Palette.milanoRedDeep
                        : _Palette.success,
                  ),
                ),
              ),
            ),
          ),
          // Active Switch
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Switch(
                value: t.isActive,
                onChanged: (v) => _toggleTable(t.id),
                activeThumbColor: _Palette.milanoRed,
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(
                  Icons.qr_code_scanner,
                  _Palette.info,
                  () => _showQRDialog(t),
                ),
                const SizedBox(width: 12),
                _actionIcon(
                  Icons.download_rounded,
                  _Palette.success,
                  () => _downloadQR(t, qrData),
                ),
                const SizedBox(width: 12),
                _actionIcon(
                  Icons.delete_rounded,
                  _Palette.milanoRedDeep,
                  () => _deleteTable(t.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing only
/// a plain "‹" glyph. Replaces the previous arrow-icon + "Back" label combo
/// with a minimal, professional control, matching the same treatment used
/// on OrdersScreen and MenuScreen.
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
    );
  }
}

/// Small decorative gradient divider placed beneath the header title —
/// purely cosmetic, mirrors the same accent used on the dashboard, menu,
/// orders, profile, and staff screens so the title treatment matches
/// exactly across the admin app.
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
