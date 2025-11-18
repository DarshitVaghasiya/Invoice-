import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator2 {
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

  static Future<File> generateClassicTemplate(InvoiceModel invoice) async {
    // 🔹 Load Fonts
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

    // 🔹 PDF Theme
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        fontFallback: [arabicFont, symbolsFont, thaiFont, dejavu],
      ),
    );

    final profile = AppData().profile;
    final settings = AppData().settings;
    final String currencySymbol = invoice.currencySymbol ?? '\$';
    final primaryColor = PdfColor.fromInt(0xFF009A75);
    final greyText = PdfColors.grey600;

    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        build: (context) {
          final widgets = <pw.Widget>[];

          // 🔹 Header Bar
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
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
                          textAlign: pw.TextAlign.left,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "INVOICE",
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        invoice.invoiceNo,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 25));

          // 🔹 Bill To + Dates
          widgets.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Bill To",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.billTo,
                      style: pw.TextStyle(fontSize: 12, color: greyText),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (invoice.poNumber != null &&
                        invoice.poNumber.toString().trim().isNotEmpty &&
                        invoice.poNumber.toString().trim() != "00")
                      _buildInfoRow("PO Number", invoice.poNumber),
                    _buildInfoRow("Date", invoice.date),
                    _buildInfoRow("Due Date", invoice.dueDate),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: pw.Text(
                        "Balance Due:  $currencySymbol${toDouble(invoice.total).toStringAsFixed(2)}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 25));
          // 🔹 Items Table
          final items = invoice.items;
          widgets.add(
            _itemTable(invoice, items, currencySymbol, primaryColor),
          );
          widgets.add(pw.SizedBox(height: 20));
          // 🔹 Totals Section
          widgets.add(
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: _buildTotalsSection(invoice, currencySymbol),
            ),
          );

          widgets.add(pw.SizedBox(height: 20));

          // 🔹 Notes & Bank Details
          widgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (settings.showBank && profile != null)
                  _buildBankSection(profile),
                if (settings.showNotes &&
                    (invoice.notes?.toString().trim().isNotEmpty ?? false))
                  _buildSection("Notes", invoice.notes ?? ''),
                if (settings.showTerms &&
                    (invoice.terms.toString().trim().isNotEmpty))
                  _buildSection(
                    "Terms & Conditions",
                    invoice.terms ?? "Terms & Conditions",
                  ),
              ],
            ),
          );

          return widgets;
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = "invoice_${invoice.invoiceNo}.pdf";
    final file = await PdfSaver.savePdfFile(bytes: bytes, fileName: fileName);

    return file;
  }

  // 🔹 Helper Widgets
  static pw.Widget _divider() => pw.Container(
    height: 1,
    color: PdfColors.grey300,
    margin: const pw.EdgeInsets.symmetric(vertical: 8),
  );

  static pw.Widget _buildInfoRow(String label, dynamic value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          "$label: ",
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(value?.toString() ?? "-", style: pw.TextStyle(fontSize: 12)),
      ],
    ),
  );

  static pw.Widget _buildTotalsSection(
    InvoiceModel invoice,
    String currencySymbol,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    final discount = toDouble(invoice.discount);
    final tax = toDouble(invoice.tax);
    final shipping = toDouble(invoice.shipping);

    return pw.Container(
      width: 200,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _totalRow(
            "SubTotal",
            "$currencySymbol${toDouble(invoice.subtotal).toStringAsFixed(2)}",
          ),
          if (discount > 0)
            _totalRow(
              "Discount",
              "$currencySymbol${toDouble(invoice.discountAmount).toStringAsFixed(2)}",
            ),
          if (tax > 0)
            _totalRow(
              "Tax (${invoice.tax}%)",
              "$currencySymbol${toDouble(invoice.taxAmount).toStringAsFixed(2)}",
            ),
          if (shipping > 0)
            _totalRow(
              "Shipping",
              "$currencySymbol${shipping.toStringAsFixed(2)}",
            ),
          pw.Divider(),
          pw.Container(
            color: PdfColors.grey200,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Total",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "$currencySymbol${invoice.total.toStringAsFixed(2)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
      ],
    ),
  );

  static pw.Widget _buildBankSection(dynamic profile) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        "Bank Details",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
      pw.SizedBox(height: 4),
      if (profile.bankName?.isNotEmpty == true)
        pw.Text(
          "Bank: ${profile.bankName}",
          style: const pw.TextStyle(fontSize: 12),
        ),
      if (profile.accountNumber?.isNotEmpty == true)
        pw.Text(
          "A/c No: ${profile.accountNumber}",
          style: const pw.TextStyle(fontSize: 12),
        ),
      if (profile.ifsc?.isNotEmpty == true)
        pw.Text(
          "IFSC: ${profile.ifsc}",
          style: const pw.TextStyle(fontSize: 12),
        ),
      if (profile.upi?.isNotEmpty == true)
        pw.Text("UPI: ${profile.upi}", style: const pw.TextStyle(fontSize: 12)),
      pw.SizedBox(height: 10),
    ],
  );

  static pw.Widget _buildSection(String title, String content) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        content,
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
      ),
      pw.SizedBox(height: 8),
    ],
  );

  static pw.Widget _itemTable(
    InvoiceModel invoice,
    List<ItemModel> items,
    String currency,
    PdfColor headerBg,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    final headers = _getHeaders(invoice);

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey600,
        width: 0.6,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.8),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerBg),
          children: [
            _headerCell(headers[0]),
            _headerCell(headers[1], align: pw.TextAlign.center),
            _headerCell(headers[2], align: pw.TextAlign.center),
            _headerCell(headers[3], align: pw.TextAlign.right),
          ],
        ),

        // Rows
        ...items.map((e) {
          final desc = e.desc.text.trim();
          final qty = toDouble(e.qty.text);
          final rate = toDouble(e.rate.text);
          final amt = qty * rate;

          return pw.TableRow(
            children: [
              _rowCell(desc),
              _rowCell(qty.toStringAsFixed(0), align: pw.TextAlign.center),
              _rowCell("$currency${rate.toStringAsFixed(2)}",
                  align: pw.TextAlign.center),
              _rowCell("$currency${amt.toStringAsFixed(2)}",
                  align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );

  }

  static pw.Widget _headerCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _rowCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
        textAlign: align,
      ),
    );
  }
}
