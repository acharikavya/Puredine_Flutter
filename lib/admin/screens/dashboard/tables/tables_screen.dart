import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';
import 'package:restaurant_unified_app/admin/services/tables_service.dart';
import 'package:restaurant_unified_app/utils/file_download_helper.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// AdminDashboardScreen, MenuScreen, OrdersScreen, ProfileScreen,
/// StaffLandingScreen, and StaffScreen exactly, so this screen reads as
/// part of the same consistent brand instead of its own one-off theme.
/// Used ONLY for this screen's restyle. Nothing here touches AppColors or
/// any other file — pure UI enhancement, no logic changed anywhere here.
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
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  _Palette._();

  static const Color milanoRed = Color(0xFF8B1D1D); // Primary maroon
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF320A0A); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF2563EB);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milanoRedLight, milanoRedDeep],
  );

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used across the other admin screens.
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
                    side: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                    ),
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
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: _Palette.milanoRedDeep,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: _Palette.milanoRedDeep,
        ),
      );

      final image = await painter.toImage(512);

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

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
    } catch (e) {
      debugPrint('Download failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download QR'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQRDialog(TableModel t) {
    const baseUrl = 'https://customerfinal1.vercel.app/customer/scan-qr';
    final qrData = (t.qrCode != null && t.qrCode!.isNotEmpty)
        ? '$baseUrl?token=${t.qrCode}'
        : '$baseUrl?table=${t.id}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _Palette.canvas,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _Palette.milanoRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: _Palette.milanoRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Code - Table ${t.tableNumber}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _Palette.milanoRedDeep,
                          ),
                        ),
                        Text(
                          'Table ${t.tableNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _Palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: _Palette.textMuted,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _Palette.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _Palette.milanoRed.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _Palette.milanoRedDeep,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: _Palette.milanoRedDeep,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _Palette.lemonChiffon.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _downloadQR(t, qrData);
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Download PNG',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Palette.milanoRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link copied to clipboard'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Copy Link',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Palette.info,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
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
          decoration: BoxDecoration(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.table_restaurant_rounded,
            color: _Palette.milanoRedDeep,
            size: 26,
          ),
        ),
        title: Text(
          'Add Table',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _Palette.milanoRedDeep,
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
                    side: BorderSide(
                      color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                    ),
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
        fillColor: _Palette.lemonChiffon.withValues(alpha: 0.35),
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

    return Scaffold(
      backgroundColor: _Palette.canvas,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft lemon/ruby glows plus a faint textured
          // photograph, matching the rest of the admin app's "foggy"
          // backdrop so this screen feels like one cohesive brand.
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
                  // Matches the Admin Orders screen's Pass-2 backdrop
                  // treatment.
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
                          horizontal:
                              isMobile ? 16 : (size.width > 1400 ? 64 : 40),
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
                                    color: _Palette.milanoRed,
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

  /// Branded "floating navbar" header — mirrors the exact treatment used on
  /// AdminDashboardScreen / MenuScreen / OrdersScreen / ProfileScreen /
  /// StaffLandingScreen / StaffScreen. UI-ENHANCEMENT PASS 2 pushes this
  /// further into the same "command bar" identity used on the Admin
  /// Orders screen: a richer four-stop diagonal gradient, a large faint
  /// watermark emblem behind the title, and a fine glass highlight line
  /// along the top edge. The previous long "Add Table" pill button
  /// remains a compact circular icon button (table icon + small gold "+"
  /// badge), tucked into the top row next to the back button — matching
  /// the "add staff" icon button pattern used on StaffScreen's header.
  /// Purely visual; the navigation and add-table actions underneath are
  /// unchanged.
  Widget _buildHeader(bool isMobile) {
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the Admin
          // Orders screen's Pass-2 "faceted" surface language.
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
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: const Border(
            bottom: BorderSide(color: _Palette.lemonChiffon, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.milanoRedDeep.withValues(alpha: 0.35),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _Palette.lemonChiffon.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Subtle decorative diagonal ribbon accents (purely cosmetic,
            // matches the dashboard/menu/orders/profile/staff headers for a
            // consistent brand feel).
            Positioned(
              top: -60,
              right: -40,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 240,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _Palette.lemonChiffon.withValues(alpha: 0.14),
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
                  width: 220,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Soft gold glow anchored behind the add-table icon button —
            // matches the same glow StaffScreen uses behind its add-staff
            // icon button.
            Positioned(
              top: -30,
              right: 20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.lemonChiffon.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Large faint watermark emblem — a unique signature touch
            // this header didn't previously have, sitting low-opacity and
            // large behind the copy, never competing with the title or
            // controls. Matches the Admin Orders screen's Pass-2
            // watermark treatment.
            Positioned(
              right: isMobile ? -20 : -10,
              bottom: isMobile ? -18 : -14,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.06,
                  child: Icon(
                    Icons.table_restaurant_rounded,
                    size: isMobile ? 120 : 170,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used across the other admin headers.
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
                          alpha: i == 2 ? 0.85 : 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Fine glass highlight line along the very top edge, giving
            // the full-width panel a polished, "premium glass" finish —
            // matches the Admin Orders / Dashboard headers' top edge
            // treatment.
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

            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 40,
                isMobile ? 16 : 24,
                isMobile ? 20 : 40,
                isMobile ? 20 : 28,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        if (!isMobile) ...[
                          Text(
                            _todayLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 1,
                            height: 18,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          const SizedBox(width: 18),
                        ],
                        _addIconButton(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _titleBlock(fontSize: isMobile ? 26 : 34),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.1, duration: 450.ms);
  }

  Widget _titleBlock({required double fontSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tables Management',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const _TitleDivider(),
        const SizedBox(height: 10),
        Text(
          'Manage restaurant tables and QR codes',
          style: GoogleFonts.inter(
            color: _Palette.lemonChiffon,
            fontSize: fontSize > 30 ? 14 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Compact circular icon-only "add table" button, tucked into the top
  /// right corner of the navbar next to the back button — replaces the
  /// previous long "Add Table" pill button that sat beside/below the
  /// title. Shows a table icon with a small gold "+" badge in the corner,
  /// and matches the exact 46×46 circular styling StaffScreen uses for its
  /// "add staff" icon button.
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
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                    color: _Palette.milanoRedDeep,
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
                      color: _Palette.milanoRedDeep,
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
              _Palette.milanoRedDeep,
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
              _Palette.milanoRed,
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
          _Palette.milanoRedDeep,
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
          _Palette.milanoRed,
          false,
          Icons.people_alt_outlined,
        ),
      ],
    );
  }

  /// UI-ENHANCEMENT PASS 2: this stat card now carries the same slim
  /// color-coded top cap used on the Admin Orders screen's stat cards
  /// (a thin bar in the card's accent color, plus a small glowing dot
  /// next to the label), so both admin screens share one consistent
  /// "stat card" identity. Same label/value/color/icon inputs as before
  /// — purely presentational restructuring, no data changed.
  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    bool isMobile,
    IconData icon,
  ) {
    Widget cardContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: _Palette.cardWhite,
              border: Border.all(
                color: color.withValues(alpha: 0.18),
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
                          fontSize: isMobile ? 20 : 24,
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
                  child: Icon(icon, color: color, size: isMobile ? 16 : 20),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 20,
                color: _Palette.milanoRedDeep,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _Palette.textDark,
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
                          color: _Palette.milanoRedDeep,
                        ),
                        filled: true,
                        fillColor: _Palette.lemonChiffon.withValues(
                          alpha: 0.2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _Palette.milanoRedDeep.withValues(
                              alpha: 0.15,
                            ),
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
                            color: _Palette.milanoRedDeep,
                          ),
                          filled: true,
                          fillColor: _Palette.lemonChiffon.withValues(
                            alpha: 0.2,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
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
        color: _Palette.lemonChiffon.withValues(alpha: 0.2),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _Palette.milanoRedDeep,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
          ),
          boxShadow: _Palette.softShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.table_bar_outlined,
                size: 40,
                color: _Palette.milanoRedDeep.withValues(alpha: 0.4),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.10),
        ),
        boxShadow: _Palette.softShadow,
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _Palette.lemonChiffon.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
        ),
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
                  color: isOccupied
                      ? _Palette.milanoRed.withValues(alpha: 0.1)
                      : _Palette.success.withValues(alpha: 0.1),
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
                border: Border.all(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 60,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _Palette.milanoRedDeep,
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
          color: _Palette.milanoRedDeep.withValues(alpha: 0.55),
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
            : Border(
                bottom: BorderSide(
                  color: _Palette.milanoRedDeep.withValues(alpha: 0.08),
                ),
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
                  border: Border.all(
                    color: _Palette.milanoRedDeep.withValues(alpha: 0.15),
                  ),
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
                      ? _Palette.milanoRed.withValues(alpha: 0.08)
                      : _Palette.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: t.status == 'OCCUPIED'
                        ? _Palette.milanoRed.withValues(alpha: 0.25)
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
