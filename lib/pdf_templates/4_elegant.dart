import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator4 {
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

  static Future<File> generateElegantTemplate(InvoiceModel invoice) async {
    // --- Load Fonts ---
    final baseFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Regular.ttf"),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Bold.ttf"),
    );
    final fallbackFonts = [
      pw.Font.ttf(
        await rootBundle.load("assets/Fonts/NotoSansArabic-Regular.ttf"),
      ),
      pw.Font.ttf(
        await rootBundle.load("assets/Fonts/NotoSansSymbols2-Regular.ttf"),
      ),
      pw.Font.ttf(
        await rootBundle.load("assets/Fonts/NotoSansThai-Regular.ttf"),
      ),
      pw.Font.ttf(await rootBundle.load("assets/Fonts/DejaVuSans.ttf")),
    ];

    // --- Load Logo ---
    Uint8List? logo;
    try {
      final profile = AppData().profile;
      final base64Str = profile?.profileImageBase64;
      if (base64Str != null && base64Str.isNotEmpty) {
        logo = base64Decode(base64Str);
      }
    } catch (e) {
      print('⚠️ Error decoding logo Base64: $e');
    }

    // --- PDF Theme ---
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        fontFallback: fallbackFonts,
      ),
    );

    final settings = AppData().settings;
    final String currencySymbol = invoice.currencySymbol ?? '\$';

    // --- Colors ---
    final PdfColor headerBlue = PdfColor.fromInt(0xFF0A2E6E);
    final PdfColor darkText = PdfColor.fromInt(0xFF0D1B2A);
    final PdfColor grayText = PdfColor.fromInt(0xFF666666);
    final PdfColor lightGray = PdfColor.fromInt(0xFFF8F9FA);
    final PdfColor borderColor = PdfColor.fromInt(0xFFE5E7EB);

    // --- Page Content ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(5),
        footer: (context) => _footerSection(invoice, settings, lightGray),
        build: (context) {
          final items = invoice.items ?? [];

          return [
            _headerSection(invoice, logo, headerBlue),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _invoiceDetailsSection(invoice, grayText),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: -25),
                    child: pw.Divider(color: grayText, thickness: 1.5),
                  ),
                  pw.SizedBox(height: 10),
                  _itemTable(
                    items,
                    currencySymbol,
                    borderColor,
                    headerBlue,
                    invoice,
                  ),
                  pw.SizedBox(height: 40),
                  _totalSection(invoice, currencySymbol, headerBlue),
                  pw.SizedBox(height: 20),
                  if (settings.showNotes == true &&
                      (invoice.notes?.trim().isNotEmpty ?? false))
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "CONDITIONS / INSTRUCTIONS",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.notes ?? '',
                          style: pw.TextStyle(fontSize: 9, color: darkText),
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

    // --- Save PDF ---
    final bytes = await pdf.save();
    final fileName = "invoice_${invoice.invoiceNo}.pdf";
    final file = await PdfSaver.savePdfFile(bytes: bytes, fileName: fileName);
    return file;
  }

  // 🟦 HEADER
  static pw.Widget _headerSection(
    InvoiceModel invoice,
    Uint8List? logo,
    PdfColor headerBlue,
  ) {
    return pw.Container(
      color: headerBlue,
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Invoice",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: 70,
                height: 70,
                alignment: pw.Alignment.center,
                child: logo != null
                    ? pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain)
                    : pw.Text(
                        "Your\nLogo",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
              ),
            ],
          ),
          pw.Container(
            width: 300,
            child: pw.Text(
              textAlign: pw.TextAlign.right,
              invoice.from,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // 📄 INVOICE DETAILS
  static pw.Widget _invoiceDetailsSection(
    InvoiceModel invoice,
    PdfColor textColor,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "INVOICE DETAILS:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              "Invoice: ${invoice.invoiceNo}",
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
            pw.Text(
              "Date: ${invoice.date}",
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
            pw.Text(
              "Due: ${invoice.dueDate}",
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "BILL TO:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              invoice.billTo,
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  // 📋 ITEMS TABLE
  static pw.Widget _itemTable(
    List<ItemModel> items,
    String currency,
    PdfColor border,
    PdfColor headerBlue,
    InvoiceModel invoice,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;
    final headers = _getHeaders(invoice);
    return pw.Table(
      border: pw.TableBorder.symmetric(outside: pw.BorderSide.none),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.8),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: headerBlue, width: 3),
            ),
          ),
          children: [
            _tableHeaderCell(headers[0], headerBlue),
            _tableHeaderCell(headers[1], headerBlue, align: pw.TextAlign.center),
            _tableHeaderCell(headers[2], headerBlue, align: pw.TextAlign.center),
            _tableHeaderCell(headers[3], headerBlue, align: pw.TextAlign.right),
          ],
        ),
        // Rows
        ...items.map((e) {
          final qty = toDouble(e.qty.text);
          final rate = toDouble(e.rate.text);
          final amt = qty * rate;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: border, width: 2)),
            ),
            children: [
              _tableCell(e.desc.text),
              _tableCell(qty.toStringAsFixed(0), align: pw.TextAlign.center),
              _tableCell(
                "$currency${rate.toStringAsFixed(2)}",
                align: pw.TextAlign.center,
              ),
              _tableCell(
                "$currency${amt.toStringAsFixed(2)}",
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text.toUpperCase(),
        textAlign: align,
        style: pw.TextStyle(
          color: color,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  // 💰 TOTAL SECTION
  static pw.Widget _totalSection(
    InvoiceModel invoice,
    String currency,
    PdfColor headerBlue,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;
    final settings = AppData().settings;
    final showTerms =
        settings.showTerms == true &&
        (invoice.terms?.trim().isNotEmpty ?? false);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (showTerms)
          pw.Container(
            width: 220,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "TERMS",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.terms ?? '',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          )
        else
          pw.SizedBox(width: 220),
        pw.Container(
          width: 200,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _totalRow(
                "Subtotal",
                "$currency${toDouble(invoice.subtotal).toStringAsFixed(2)}",
              ),
              _totalRow(
                "Discount",
                "$currency${toDouble(invoice.discountAmount).toStringAsFixed(2)}",
              ),
              _totalRow(
                "Tax (${invoice.tax}%)",
                "$currency${toDouble(invoice.taxAmount).toStringAsFixed(2)}",
              ),
              _totalRow(
                "Shipping",
                "$currency${toDouble(invoice.shipping).toStringAsFixed(2)}",
              ),
              pw.Divider(color: PdfColors.grey500),
              _totalRow(
                "TOTAL",
                "$currency${toDouble(invoice.total).toStringAsFixed(2)}",
                bold: true,
                color: headerBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value, {
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 10,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 📜 FOOTER
  static pw.Widget _footerSection(
    InvoiceModel invoice,
    dynamic settings,
    PdfColor textColor,
  ) {
    final PdfColor headerBlue = PdfColor.fromInt(0xFF0A2E6E);
    final companyName = AppData().profile?.name;

    return pw.Container(
      alignment: pw.Alignment.bottomCenter,
      color: headerBlue,
      height: 70,
      padding: const pw.EdgeInsets.symmetric(vertical: 25, horizontal: 25),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            companyName ?? 'Your Company Name',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
