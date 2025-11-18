import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGenerator3 {
  static List<String> _getHeaders(InvoiceModel invoice) {
    final settings = AppData().settings;

    return [
      (invoice.descLabel).trim().isNotEmpty
          ? invoice.descLabel
          : settings.descTitle,
      (invoice.qtyLabel).trim().isNotEmpty
          ? invoice.qtyLabel
          : settings.qtyTitle,
      (invoice.rateLabel).trim().isNotEmpty
          ? invoice.rateLabel
          : settings.rateTitle,
      "Amount",
    ];
  }

  static Future<File> generateModernTemplate(InvoiceModel invoice) async {
    // --- Load fonts ---
    final baseFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Regular.ttf"),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Bold.ttf"),
    );
    final arabicFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/NotoSansArabic-Regular.ttf"),
    );
    final symbolsFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/NotoSansSymbols2-Regular.ttf"),
    );
    final thaiFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/NotoSansThai-Regular.ttf"),
    );
    final dejavu = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/DejaVuSans.ttf"),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        fontFallback: [arabicFont, symbolsFont, thaiFont, dejavu],
      ),
    );

    final settings = AppData().settings;
    final String currencySymbol = invoice.currencySymbol ?? '\$';
    final darkBlue = PdfColor.fromInt(0xFF1C2331);
    final accentBlue = PdfColor.fromInt(0xFF0E7490);
    final lightGray = PdfColor.fromInt(0xFFF5F6FA);

    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) =>
            _buildFooter(context, invoice, settings, darkBlue, accentBlue),
        build: (context) {
          final items = (invoice.items).map((e) => e).toList();

          final headers = _getHeaders(invoice);

          return [
            // --- Header Section ---
            _buildHeader(invoice, accentBlue),

            pw.Container(
              color: lightGray,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 20,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(invoice, darkBlue),
                  pw.SizedBox(height: 20),

                  // --- Items Table ---
                  pw.TableHelper.fromTextArray(
                    headers: headers,
                    data: items.map((item) {
                      final qty = toDouble(item.qty.text);
                      final rate = toDouble(item.rate.text);
                      final amount = qty * rate;
                      return [
                        item.desc.text,
                        item.qty.text,
                        "$currencySymbol${rate.toStringAsFixed(2)}",
                        "$currencySymbol${amount.toStringAsFixed(2)}",
                      ];
                    }).toList(),
                    headerDecoration: pw.BoxDecoration(color: accentBlue),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    border: pw.TableBorder.symmetric(
                      outside: const pw.BorderSide(color: PdfColors.grey300),
                      inside: const pw.BorderSide(color: PdfColors.grey200),
                    ),
                    headerPadding: const pw.EdgeInsets.all(6),
                    cellPadding: const pw.EdgeInsets.all(6),
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.center,
                    },
                    columnWidths: {
                      0: const pw.FlexColumnWidth(5),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1.8),
                    },
                  ),

                  pw.SizedBox(height: 16),

                  // --- Totals Section ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 220,
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            _totalRow(
                              "SubTotal",
                              "$currencySymbol${toDouble(invoice.subtotal).toStringAsFixed(2)}",
                            ),
                            _totalRow(
                              "Discount",
                              "$currencySymbol${toDouble(invoice.discountAmount).toStringAsFixed(2)}",
                            ),
                            _totalRow(
                              "Shipping",
                              "$currencySymbol${toDouble(invoice.shipping).toStringAsFixed(2)}",
                            ),
                            _totalRow(
                              "Tax (${invoice.tax}%)",
                              "$currencySymbol${toDouble(invoice.taxAmount).toStringAsFixed(2)}",
                            ),
                            pw.Divider(color: PdfColors.grey300, height: 10),
                            _totalRow(
                              "Total",
                              "$currencySymbol${toDouble(invoice.total).toStringAsFixed(2)}",
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = "invoice_${invoice.invoiceNo}.pdf";
    final file = await PdfSaver.savePdfFile(bytes: bytes, fileName: fileName);

    return file;
  }

  // --- Header Section ---
  static pw.Widget _buildHeader(InvoiceModel invoice, PdfColor accentBlue) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: accentBlue,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(6),
          topRight: pw.Radius.circular(6),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 300,
            child: pw.Text(
              invoice.from,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoice.invoiceNo,
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Info Section ---
  static pw.Widget _buildInfoSection(InvoiceModel invoice, PdfColor darkBlue) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (invoice.poNumber != null &&
                invoice.poNumber.toString().trim().isNotEmpty)
              _infoRow("PO Number", invoice.poNumber ?? ''),
            _infoRow("Date Of Issue", invoice.date),
            _infoRow("Due Date", invoice.dueDate),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "BILL TO:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: darkBlue,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 150,
              child: pw.Text(
                invoice.billTo,
                style: const pw.TextStyle(fontSize: 11),
                softWrap: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Footer Section ---
  static pw.Widget _buildFooter(
    pw.Context context,
    InvoiceModel invoice,
    dynamic settings,
    PdfColor darkBlue,
    PdfColor accentBlue,
  ) {
    final showTerms = settings.showTerms == true;
    final showNotes = settings.showNotes == true;
    final hasTerms = invoice.terms?.toString().trim().isNotEmpty == true;
    final hasNotes = invoice.notes?.toString().trim().isNotEmpty == true;

    if (context.pageNumber != context.pagesCount) return pw.SizedBox();
    if ((!showTerms && !showNotes) || (!hasTerms && !hasNotes)) {
      return pw.SizedBox();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (showTerms && hasTerms) ...[
            pw.Text(
              "TERMS & CONDITIONS",
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: darkBlue,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.terms ?? '',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 8),
          ],
          if (showNotes && hasNotes) ...[
            pw.Text(
              "NOTES",
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: darkBlue,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.notes ?? '',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey400, height: 1),
          pw.Center(
            child: pw.Text(
              "Thank you for your business!",
              style: pw.TextStyle(
                fontSize: 10,
                color: accentBlue,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  static pw.Widget _infoRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.Text(
          "$label: ",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );

  static pw.Widget _totalRow(String label, String value, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}
