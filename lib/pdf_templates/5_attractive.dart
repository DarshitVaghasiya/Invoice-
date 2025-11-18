import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerators5 {
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

  static Future<File> generateAttractiveTemplate(
    InvoiceModel invoice,
    ProfileModel? profile,
  ) async {
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

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        fontFallback: fallbackFonts,
      ),
    );

    final String currency = invoice.currencySymbol ?? '₹';
    final PdfColor headerBlue = PdfColor.fromHex('#003366');
    final PdfColor lightBlue = PdfColor.fromHex('#E8F0FE');
    final PdfColor accentBlue = PdfColor.fromHex('#0055A4');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (context) {
          final items = (invoice.items as List? ?? [])
              .map((e) => e is ItemModel ? e : ItemModel.fromJson(e))
              .toList();

          return [
            // HEADER WITH CURVE
            pw.Padding(
              padding: const pw.EdgeInsets.only(
                top: -25,
                left: -25,
                right: -25,
              ),
              child: pw.Container(
                height: 130,
                child: pw.Stack(
                  children: [
                    pw.Container(
                      height: 130,
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [
                            PdfColor.fromHex('#003366'),
                            PdfColor.fromHex('#007BFF'),
                          ],
                          begin: pw.Alignment.topLeft,
                          end: pw.Alignment.bottomRight,
                        ),
                        borderRadius: const pw.BorderRadius.only(
                          bottomLeft: pw.Radius.circular(80),
                        ),
                      ),
                    ),
                    pw.Positioned(
                      left: 30,
                      top: 35,
                      child: pw.Text(
                        "INVOICE",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Positioned(
                      right: 30,
                      top: 50,
                      child: pw.Text(
                        "No: ${invoice.invoiceNo}",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // BILL INFO SECTION
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBlue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _labelText("BILL TO:"),
                      pw.Text(
                        invoice.billTo,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 12),
                      _labelText("PO: ${invoice.poNumber}"),
                      _labelText("DATE: ${invoice.date}"),
                      _labelText("DUE: ${invoice.dueDate}"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _labelText("FROM:"),
                      pw.Container(
                        width: 200,
                        child: pw.Text(
                          invoice.from,
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ITEMS TABLE
            _itemTable(items, currency, accentBlue, invoice),

            pw.SizedBox(height: 20),
            // TOTAL SECTION
            _totalSection(invoice, currency, accentBlue),

            pw.SizedBox(height: 20),

            // NOTES & PAYMENT INFO
            // Show container only if ANY of the three settings are true
            if (AppData().settings.showNotes ||
                AppData().settings.showTerms ||
                AppData().settings.showBank)
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F9FAFB'),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // NOTES Section
                    if (AppData().settings.showNotes &&
                        (invoice.notes ?? '').trim().isNotEmpty) ...[
                      _sectionTitle("NOTES"),
                      pw.Text(
                        invoice.notes!,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                    ],

                    // TERMS Section
                    if (AppData().settings.showTerms &&
                        (invoice.terms ?? '').trim().isNotEmpty) ...[
                      _sectionTitle("TERMS"),
                      pw.Text(
                        invoice.terms!,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                    ],

                    // PAYMENT INFO Section
                    if (AppData().settings.showBank) ...[
                      _sectionTitle("PAYMENT INFORMATION"),
                      pw.Text(
                        "Bank: ${profile?.bankName ?? '-'}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "Name: ${profile?.accountHolder ?? '-'}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "Account No: ${profile?.accountNumber ?? '-'}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "IFSC: ${profile?.ifsc ?? '-'}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ],
                ),
              ),

            pw.SizedBox(height: 30),

            // FOOTER
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: headerBlue,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Center(
                child: pw.Text(
                  "Thank you for your business!",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
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

  // TEXT HELPERS
  static pw.Widget _labelText(String text) => pw.Text(
    text,
    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
  );

  static pw.Widget _sectionTitle(String text) => pw.Text(
    text,
    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
  );

  // TABLE
  static pw.Widget _itemTable(
    List<ItemModel> items,
    String currency,
    PdfColor accentBlue,
    InvoiceModel invoice,
  ) {
    final settings = AppData().settings;

    final headers = _getHeaders(invoice);

    // ✅ Rename this to `rows` to avoid collision
    final rows = List.generate(items.isEmpty ? 5 : items.length, (i) {
      if (items.isEmpty) {
        return ['Item', '1', '0.00', '0.00'];
      }
      final e = items[i];
      final qty = double.tryParse(e.qty.text) ?? 1;
      final rate = double.tryParse(e.rate.text) ?? 0;
      final total = qty * rate;
      return [
        e.desc.text,
        qty.toStringAsFixed(0),
        "$currency${rate.toStringAsFixed(2)}",
        "$currency${total.toStringAsFixed(2)}",
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      // ✅ use rows instead of data
      border: null,
      headerDecoration: pw.BoxDecoration(color: accentBlue),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellDecoration: (index, data, rowNum) {
        return pw.BoxDecoration(
          color: rowNum % 2 == 0
              ? PdfColor.fromHex('#F3F6FB')
              : PdfColors.white,
        );
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.8),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _totalSection(
    InvoiceModel invoice,
    String currency,
    PdfColor accentBlue,
  ) {
    double toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F3F6FB'),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _row(
              "Subtotal",
              "$currency${toDouble(invoice.subtotal).toStringAsFixed(2)}",
            ),
            _row(
              "Discount",
              "$currency${toDouble(invoice.discountAmount).toStringAsFixed(2)}",
            ),
            _row(
              "Tax (${invoice.tax}%)",
              "$currency${toDouble(invoice.taxAmount).toStringAsFixed(2)}",
            ),
            _row(
              "Shipping",
              "$currency${toDouble(invoice.shipping).toStringAsFixed(2)}",
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Total",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "$currency${toDouble(invoice.total).toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    color: accentBlue,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );
}
