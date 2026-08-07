import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../contexts/auth_provider.dart';
import '../contexts/orders_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../../core/currency_utils.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Local "Theme 1 — Dark Maroon × Soft Cream × Gold Glow" palette — matches
/// the Order Details / Dashboard / Menu Management / Payment screens
/// exactly (#8B1D1D primary / #F4C430 gold accent), so this screen now
/// reads as part of the same cohesive, professional brand. Used ONLY for
/// this screen's visual layer. Nothing here touches AppColors, AppTheme,
/// or any other file, and no logic — PDF generation, printing, sharing,
/// navigation — changed anywhere in this file.
///
/// UI-ENHANCEMENT PASS 2: brings this screen's header and section cards up
/// to the same distinctive "command bar" identity used on the Payment /
/// Create Order / Orders screens — a four-stop diagonal gradient header, a
/// large faint watermark emblem, a glass highlight line along the top
/// edge, and a new live quick-stats readout strip (Total Paid / Items /
/// Method) built entirely from values already available at the call site.
/// The full-screen backdrop gained an extra ambient glow + a diagonal
/// sheen for more depth, and the receipt-detail / order-items sections
/// picked up a slim color-coded accent rail down the left edge, matching
/// the Payment / Create Order screens' card treatment. No provider,
/// controller, route, PDF, or payment logic was touched anywhere in this
/// pass — only presentation changed.
///
/// NOTE: this is a private class redeclared identically to the ones in
/// the other staff screens (private classes can't be shared across files
/// without a new shared import, which would go beyond a pure UI-only
/// change here).
/// ─────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color milanoRed = Color(0xFF8B1D1D); // Dark Maroon (Primary)
  static const Color milanoRedDeep = Color(0xFF4E0F0F); // Deepest maroon
  static const Color milanoRedLight = Color(0xFFA83030); // Lighter maroon
  static const Color milanoRedDarkest =
      Color(0xFF320A0A); // Fourth gradient stop
  static const Color lemonChiffon = Color(0xFFF4C430); // Gold Glow (Accent)
  static const Color lemonChiffonDeep = Color(0xFFD9A62A); // Deeper gold
  static const Color canvas = Color(0xFFFFF8F0); // Soft Cream background
  static const Color canvasDeep = Color(0xFFF5E9D6); // Deeper cream
  static const Color textDark = Color(0xFF3A1608);
  static const Color textMuted = Color(0xFF8A6F5E);
  static const Color gold = Color(0xFFF4C430);
  static const Color goldLight = Color(0xFFF7D66B);
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFF0FDF4);

  /// Themed soft shadow for resting cards/panels — matches the exact
  /// softShadow used on Menu/Dashboard/Order Details/Payment so every
  /// card on this screen carries the same warm, branded elevation.
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Richer navbar/header shadow stack — the same three-layer shadow
  /// language used on the Order Details / Dashboard / Payment headers
  /// (deep maroon drop shadow + soft ambient gold bloom + fine black
  /// contact shadow).
  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: milanoRedDeep.withValues(alpha: 0.40),
          blurRadius: 34,
          offset: const Offset(0, 15),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.12),
          blurRadius: 40,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Soft inner "glass" shadow used on the header's quick-stats readout
  /// strip — pure decoration, gives the capsule a faint pressed-glass
  /// depth. Matches the Payment / Create Order / Orders screens'
  /// statCapsuleShadow exactly.
  static List<BoxShadow> get statCapsuleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: lemonChiffon.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ];
}

const List<String> _kMonthNames = [
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
  return '${_kMonthNames[now.month - 1]} ${now.day}, ${now.year}';
}

class BillScreen extends StatelessWidget {
  final String orderId;

  final int finalTotal;
  final String paymentMethod;

  const BillScreen({
    super.key,
    required this.orderId,
    required this.finalTotal,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final auth = context.read<StaffAuthProvider>();
    final order = provider.findById(orderId);
    final billNumber =
        'BILL-${orderId.substring(0, orderId.length < 8 ? orderId.length : 8).toUpperCase()}';

    void goBack() => auth.role == StaffRole.billingStaff
        ? context.go('/staff/billing')
        : context.go('/staff/dashboard');

    // Purely display values for the header's quick-stats strip — derived
    // from data already available here (order + constructor fields). No
    // new data source, no logic change.
    final itemsCount = order?.itemsDetails.length ?? 0;

    return Scaffold(
      backgroundColor: _Palette.canvas,
      // Full-screen, edge-to-edge treatment — header now draws behind the
      // status bar, matching the Order Details / Payment screens.
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient background dressing ─────────────────────────────────
          // Purely decorative — soft gold/ruby glows plus a faint textured
          // photograph, matching the Menu Management / Dashboard / Payment
          // screens' "foggy" backdrop so the whole app feels like one
          // cohesive brand.
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
                            _Palette.lemonChiffon.withValues(alpha: 0.30),
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
                  Positioned(
                    top: 300,
                    right: -110,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.lemonChiffonDeep.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Extra low, wide glow further down the page — gives the
                  // long scroll area a second soft focal point instead of
                  // all the ambient light sitting only near the header.
                  // Matches the Payment / Orders / Order Details screens'
                  // Pass-2 backdrop treatment.
                  Positioned(
                    top: 640,
                    left: -70,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _Palette.milanoRedLight.withValues(alpha: 0.05),
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

          // Faint diagonal sheen sweeping across the whole page — a subtle
          // extra layer of depth so the cream backdrop doesn't read as
          // flat behind the header, echoing the glass-highlight language
          // used in the header itself. Matches the Payment / Orders /
          // Order Details screens exactly.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.30),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ── Header — same Dark Maroon gradient, rounded "floating
              // navbar" corners, dotted texture accent, and diagonal
              // ribbon glows used throughout the app, now restyled into a
              // richer "command bar" with a live quick-stats readout. This
              // screen never had a header before this pass — the back
              // arrow simply triggers the exact same navigation as the
              // "Back to Billing / Back to Dashboard" button already at
              // the bottom of the receipt, so no new behavior is
              // introduced. ─────────────────────────────────────────────
              _ScreenHeader(
                title: 'Payment Receipt',
                subtitle: billNumber,
                dateLabel: _todayLabel(),
                onBack: goBack,
                totalPaidLabel: '₹$finalTotal',
                itemsCount: itemsCount,
                methodLabel: paymentMethod.toUpperCase(),
              ),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Receipt card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _Palette.milanoRedDeep.withValues(
                                alpha: 0.10,
                              ),
                            ),
                            boxShadow: _Palette.softShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Top accent bar — same Dark Maroon gradient
                              // + lemon-chiffon edge used across the app.
                              Container(
                                height: 8,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _Palette.milanoRedLight,
                                      _Palette.milanoRedDeep,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  children: [
                                    // Success Icon
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: _Palette.successBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: _Palette.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _Palette.gold.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _Palette.success
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Payment Successful',
                                      style: AppTheme.serif(
                                        size: 24,
                                        weight: FontWeight.w900,
                                        color: _Palette.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transaction Completed',
                                      style: AppTheme.sans(
                                        size: 14,
                                        color: _Palette.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Receipt details — UI-ENHANCEMENT
                                    // PASS 2: wrapped with a slim maroon
                                    // accent rail down the left edge,
                                    // matching the Payment / Create Order
                                    // screens' card treatment. Same
                                    // content as before.
                                    Container(
                                      decoration: BoxDecoration(
                                        color: _Palette.canvas,
                                        borderRadius: BorderRadius.circular(
                                          18,
                                        ),
                                        border: Border.all(
                                          color: _Palette.milanoRedDeep
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: 0,
                                            child: Container(
                                              width: 5,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    _Palette.milanoRed
                                                        .withValues(
                                                      alpha: 0.85,
                                                    ),
                                                    _Palette.milanoRed
                                                        .withValues(
                                                      alpha: 0.35,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Total Amount',
                                                      style: AppTheme.sans(
                                                        size: 12,
                                                        weight: FontWeight.w700,
                                                        color:
                                                            _Palette.textMuted,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹$finalTotal',
                                                      style: AppTheme.serif(
                                                        size: 32,
                                                        weight: FontWeight.w900,
                                                        color:
                                                            _Palette.textDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Divider(
                                                    color: _Palette
                                                        .milanoRedDeep
                                                        .withValues(
                                                      alpha: 0.10,
                                                    ),
                                                    height: 1,
                                                  ),
                                                ),
                                                _ReceiptRow(
                                                  'Bill Number',
                                                  billNumber,
                                                  mono: true,
                                                ),
                                                const SizedBox(height: 10),
                                                if (order != null) ...[
                                                  _ReceiptRow(
                                                    'Table',
                                                    order.table,
                                                  ),
                                                  if (order.customerName !=
                                                      null) ...[
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    _ReceiptRow(
                                                      'Customer',
                                                      order.customerName!,
                                                    ),
                                                  ],
                                                ],
                                                const SizedBox(height: 10),
                                                _ReceiptRow(
                                                  'Date',
                                                  _formatDate(),
                                                ),
                                                const SizedBox(height: 10),
                                                _ReceiptRow(
                                                  'Payment Method',
                                                  paymentMethod.toUpperCase(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Breakdown — UI-ENHANCEMENT PASS 2:
                                    // now wrapped with a slim gold accent
                                    // rail down the left edge, matching
                                    // the "Items" section on the Payment
                                    // screen. Same content as before.
                                    if (order != null)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: _Palette.milanoRedDeep
                                                .withValues(alpha: 0.08),
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 0,
                                              bottom: 0,
                                              left: 0,
                                              child: Container(
                                                width: 5,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      _Palette.gold.withValues(
                                                        alpha: 0.85,
                                                      ),
                                                      _Palette.gold.withValues(
                                                        alpha: 0.35,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                18,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const _SectionHeader(
                                                    'Order Items',
                                                  ),
                                                  const SizedBox(height: 12),
                                                  ...order.itemsDetails.map(
                                                    (item) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 6,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            '${item.quantity}x ${item.name}',
                                                            style:
                                                                AppTheme.sans(
                                                              size: 13,
                                                              color: _Palette
                                                                  .textMuted,
                                                            ),
                                                          ),
                                                          Text(
                                                            '₹${(item.quantity * (double.tryParse(item.price) ?? 0)).round()}',
                                                            style:
                                                                AppTheme.sans(
                                                              size: 13,
                                                              weight: FontWeight
                                                                  .w600,
                                                              color: _Palette
                                                                  .textDark,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 20,
                                                    color: _Palette
                                                        .milanoRedDeep
                                                        .withValues(
                                                      alpha: 0.10,
                                                    ),
                                                  ),
                                                  if (order.subtotal > 0) ...[
                                                    _BreakdownRow(
                                                      'Subtotal',
                                                      '₹${order.subtotal.round()}',
                                                    ),
                                                    const SizedBox(height: 6),
                                                  ],
                                                  if (order.tax > 0) ...[
                                                    _BreakdownRow(
                                                      'Tax',
                                                      '₹${order.tax.round()}',
                                                    ),
                                                    const SizedBox(height: 6),
                                                  ],
                                                  Divider(
                                                    height: 16,
                                                    color: _Palette
                                                        .milanoRedDeep
                                                        .withValues(
                                                      alpha: 0.10,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Total Paid',
                                                        style: AppTheme.sans(
                                                          size: 16,
                                                          weight:
                                                              FontWeight.w800,
                                                          color:
                                                              _Palette.textDark,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹$finalTotal',
                                                        style: AppTheme.sans(
                                                          size: 20,
                                                          weight:
                                                              FontWeight.w900,
                                                          color: _Palette
                                                              .milanoRedDeep,
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

                                    const SizedBox(height: 24),

                                    // Action buttons
                                    PrimaryButton(
                                      label: 'Print Receipt',
                                      icon: Icons.print_rounded,
                                      color: _Palette.milanoRedDeep,
                                      onTap: () => _printReceiptPdf(
                                        context,
                                        order,
                                        billNumber,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    PrimaryButton(
                                      label: 'Download as PDF',
                                      icon: Icons.picture_as_pdf_rounded,
                                      color: _Palette.textDark,
                                      onTap: () => _downloadReceiptPdf(
                                        context,
                                        order,
                                        billNumber,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    PremiumBackButton(
                                      label: auth.role == StaffRole.billingStaff
                                          ? 'Back to Billing'
                                          : 'Back to Dashboard',
                                      onTap: goBack,
                                    ),
                                  ],
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
            ],
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generatePdfDoc(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final restaurantName =
        context.read<StaffAuthProvider>().user?.restaurantName;
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      restaurantName?.isNotEmpty == true
                          ? restaurantName!.toUpperCase()
                          : 'RESTAURANT',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(fontSize: 14, font: font),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(height: 2, color: PdfColors.black),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Bill info
              _pdfInfoRow('Bill Number', billNumber, font, boldFont),
              if (order != null) ...[
                _pdfInfoRow('Table', order.table, font, boldFont),
                if (order.customerName != null)
                  _pdfInfoRow('Customer', order.customerName!, font, boldFont),
              ],
              _pdfInfoRow('Date', _formatDate(), font, boldFont),
              _pdfInfoRow(
                'Payment Method',
                paymentMethod.toUpperCase(),
                font,
                boldFont,
              ),

              pw.SizedBox(height: 16),
              pw.Container(height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 16),

              // Order items header
              if (order != null) ...[
                pw.Text(
                  'Order Items',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 10),
                // Items table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Item',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...order.itemsDetails.map<pw.TableRow>(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              item.name,
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${item.quantity}',
                              style: pw.TextStyle(font: font),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              CurrencyUtils.format(
                                (item.quantity *
                                        (double.tryParse(item.price) ?? 0))
                                    .round(),
                              ),
                              style: pw.TextStyle(font: font),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Totals
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                if (order.subtotal > 0)
                  _pdfInfoRow(
                    'Subtotal',
                    CurrencyUtils.format(order.subtotal.round()),
                    font,
                    boldFont,
                  ),
                if (order.tax > 0)
                  _pdfInfoRow(
                    'Tax',
                    CurrencyUtils.format(order.tax.round()),
                    font,
                    boldFont,
                  ),
                //f (tipAmount > 0)

                pw.SizedBox(height: 6),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                    pw.Text(
                      CurrencyUtils.format(finalTotal),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'Thank you for dining with us!',
                  style: pw.TextStyle(fontSize: 12, font: font),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _printReceiptPdf(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final pdf = await _generatePdfDoc(context, order, billNumber);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$billNumber',
    );
  }

  Future<void> _downloadReceiptPdf(
    BuildContext context,
    dynamic order,
    String billNumber,
  ) async {
    final pdf = await _generatePdfDoc(context, order, billNumber);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Receipt_$billNumber.pdf',
    );
  }

  pw.Widget _pdfInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, font: font)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    return '${now.day} ${_month(now.month)} ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

/// Small decorative gradient divider placed beneath a title — purely
/// cosmetic, mirrors the same accent used on the Menu Management / Order
/// Details / Payment screens.
class _TitleDivider extends StatelessWidget {
  final double width;
  const _TitleDivider({this.width = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _Palette.gold.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Screen header — restyled into its own distinctive "command bar"
// identity, matching the Payment / Order Details / Orders screens'
// Pass-2 treatment exactly: a richer four-stop diagonal gradient, a
// large faint watermark emblem behind the title, a fine glass highlight
// line along the top edge, layered ribbon glows, a dotted texture
// accent, and a floating date pill on wide screens. UI-ENHANCEMENT PASS
// 2 adds a live quick-stats readout strip (Total Paid / Items / Method)
// built from values already available at the call site — no new data
// source, purely a display addition. The back control is now the same
// compact, icon-only "‹" chip used on the Payment / Order Details
// screens' header, and it still calls the exact same navigation as the
// "Back to Billing / Back to Dashboard" button below — no new behavior
// introduced, only a richer, more unique visual treatment. ────────────
class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onBack;
  final String totalPaidLabel;
  final int itemsCount;
  final String methodLabel;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onBack,
    required this.totalPaidLabel,
    required this.itemsCount,
    required this.methodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Richer four-stop diagonal maroon gradient — deeper and more
          // dimensional than a flat three-stop wash, matching the
          // Payment / Order Details / Orders screens' "faceted" surface
          // language.
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
          // "floating navbar" feel that matches the rest of the app
          // exactly, instead of a flat hard-edged band.
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isMobile ? 28 : 38),
            bottomRight: Radius.circular(isMobile ? 28 : 38),
          ),
          border: Border(
            bottom: BorderSide(
              color: _Palette.lemonChiffon.withValues(alpha: 0.9),
              width: 4,
            ),
          ),
          boxShadow: _Palette.heroShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle decorative diagonal ribbon accents (purely
            // cosmetic, matches the rest of the app's headers for a
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
                        _Palette.lemonChiffon.withValues(alpha: 0.16),
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
            // Soft gold radial glow behind the brand icon, echoing the
            // Dashboard / Order Details / Payment header treatment.
            Positioned(
              top: -50,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.gold.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Extra ambient gold glow, lower-right — matches the fuller
            // "full-screen backdrop" glow used on the Payment / Order
            // Details headers.
            Positioned(
              bottom: -70,
              right: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _Palette.gold.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Large faint watermark emblem — a unique signature touch,
            // sits low-opacity and large behind the copy, never competing
            // with the title or the stats strip. Matches the Payment /
            // Order Details / Orders screens' Pass-2 header exactly.
            Positioned(
              right: isMobile ? -30 : -10,
              bottom: isMobile ? -22 : -16,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: isMobile ? 140 : 190,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Fine dotted texture accent, matching the app's refined
            // decorative language used on the other headers.
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

            // Fine glass highlight line along the very top edge, giving
            // the full-width panel a polished, "premium glass" finish —
            // matches the Dashboard / Payment / Order Details headers'
            // top edge treatment.
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

            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  16,
                  isMobile ? 16 : 24,
                  22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // ── Icon-only back control — a single "‹" glyph,
                        // no arrow icon and no "Back" label, matching the
                        // Payment / Order Details screens' header
                        // control. This still calls the exact same
                        // onBack callback, so no navigation behavior is
                        // new. ────────────────────────────────────────
                        _BackChevronButton(onTap: onBack),
                        const Spacer(),
                        if (!isMobile)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _Palette.lemonChiffon.withValues(
                                  alpha: 0.25,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: _Palette.lemonChiffon.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateLabel,
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ).copyWith(letterSpacing: 0.3),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Brand icon chip — thin gold border + soft
                        // gold glow, matching every other staff screen's
                        // header icon. ────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _Palette.gold.withValues(alpha: 0.8),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Palette.gold.withValues(alpha: 0.3),
                                blurRadius: 14,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
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
                                title,
                                style: AppTheme.serif(
                                  size: isMobile ? 22 : 26,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(height: 1.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const _TitleDivider(),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _Palette.gold.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  subtitle,
                                  style: AppTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: _Palette.lemonChiffon,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _Palette.lemonChiffon.withValues(
                                alpha: 0.25,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            dateLabel,
                            style: AppTheme.sans(
                              size: 10.5,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ── Live quick-stats readout strip — Total Paid /
                    // Items / Method, built straight from values already
                    // available at the call site. Purely a display
                    // addition; no new data source and no logic change.
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.22),
                            Colors.black.withValues(alpha: 0.14),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                        boxShadow: _Palette.statCapsuleShadow,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _HeaderStatPill(
                              icon: Icons.payments_rounded,
                              value: totalPaidLabel,
                              label: 'Total Paid',
                              accent: const Color(0xFF34D399),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.shopping_basket_rounded,
                              value: '$itemsCount',
                              label: 'Items',
                              accent: const Color(0xFFFBBF24),
                            ),
                            const _HeaderStatDivider(),
                            _HeaderStatPill(
                              icon: Icons.credit_card_rounded,
                              value: methodLabel,
                              label: 'Method',
                              accent: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 550.ms, delay: 200.ms)
                        .slideY(begin: 0.2, duration: 550.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 450.ms).slideY(begin: -0.15, duration: 450.ms);
  }
}

/// Slim vertical divider used between stat pills in the header's readout
/// strip — purely decorative spacing element, no logic. Matches the
/// Payment / Order Details / Orders screens' Pass-2 header strip exactly.
class _HeaderStatDivider extends StatelessWidget {
  const _HeaderStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withValues(alpha: 0.10),
    );
  }
}

/// A single stat readout module (icon badge + value + label) used inside
/// the header's live stats strip. Purely presentational — takes whatever
/// value/label/accent it's given.
class _HeaderStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _HeaderStatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      constraints: const BoxConstraints(maxWidth: 130),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: Icon(icon, size: 13, color: accent),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.sans(
                    size: 14,
                    weight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label.toUpperCase(),
                  style: AppTheme.sans(
                    size: 8.5,
                    weight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.6),
                  ).copyWith(letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact icon-only "back" control — a circular glass button showing
/// only a plain "‹" glyph. Replaces the previous arrow_back_rounded icon
/// box with the same minimal, professional control used on the Payment /
/// Order Details screens' header, for a consistent brand-wide top bar.
/// Still calls the exact same onTap/onBack callback — no navigation
/// logic touched.
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
            style: AppTheme.sans(
              size: 24,
              weight: FontWeight.w900,
              color: Colors.white,
            ).copyWith(height: 1.0),
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _ReceiptRow(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sans(size: 13, color: _Palette.textMuted),
        ),
        Text(
          value,
          style: mono
              ? TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _Palette.textDark,
                )
              : AppTheme.sans(
                  size: 13,
                  weight: FontWeight.w700,
                  color: _Palette.textDark,
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: _Palette.milanoRed,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTheme.sans(
              size: 11,
              weight: FontWeight.w800,
              color: _Palette.textMuted,
            ).copyWith(letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  const _BreakdownRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sans(size: 13, color: _Palette.textMuted),
        ),
        Text(
          value,
          style: AppTheme.sans(
            size: 14,
            weight: FontWeight.w600,
            color: _Palette.textDark,
          ),
        ),
      ],
    );
  }
}
