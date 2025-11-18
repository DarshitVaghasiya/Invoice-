import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator1 {
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

  static Future<File?> generateSimpleTemplates(InvoiceModel invoice) async {

    final baseFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Regular.ttf"),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Bold.ttf"),
    );
    // Arabic + Symbols fallback fonts
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

    // Create a Theme with fallbacks
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        fontFallback: [arabicFont, symbolsFont, thaiFont, dejavu],
      ),
    );

    double _toDouble(dynamic val) =>
        double.tryParse(val?.toString() ?? '') ?? 0;

    final profile = AppData().profile;
    final settings = AppData().settings;
    final bool showTax = settings.showTax;
    final bool showBank = settings.showBank;
    final String currencySymbol = invoice.currencySymbol ?? '\$';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        build: (context) {
          final widgets = <pw.Widget>[];

          // 🔹 Header
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Company/Seller Name: ",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Container(
                      width: 300, // ✅ set max width so text can wrap
                      child: pw.Text(
                        invoice.from,
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 14,
                        ),
                        textAlign: pw.TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                    pw.SizedBox(height: 5),

                    if (showTax && profile != null) ...[
                      if ((profile.pan).toString().trim().isNotEmpty)
                        pw.Row(
                          children: [
                            pw.Text(
                              "PAN No: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              profile.pan.toString(),
                              style: const pw.TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      pw.SizedBox(height: 5),
                      if ((profile.gst).toString().trim().isNotEmpty)
                        pw.Row(
                          children: [
                            pw.Text(
                              "GST No: ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              profile.gst.toString(),
                              style: const pw.TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "INVOICE",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      invoice.invoiceNo,
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 30));

          // 🔹 Bill To + Invoice Details
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left → Bill To
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Bill To :",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(invoice.billTo),
                    pw.SizedBox(height: 4),
                  ],
                ),
                // Right → Invoice details
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        if (invoice.poNumber != null &&
                            invoice.poNumber.toString().trim().isNotEmpty &&
                            invoice.poNumber.toString().trim() != "00")
                          pw.SizedBox(
                            width: 120,
                            child: pw.Text(
                              "PO Number:",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        pw.SizedBox(
                          width: 100,
                          child: pw.Text(
                            invoice.poNumber ?? '',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    // Date
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            "Date:",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 100,
                          child: pw.Text(
                            invoice.date,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),

                    // Due Date
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            "Due Date:",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 100,
                          child: pw.Text(
                            invoice.dueDate,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),

                    // Balance Due
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            "Balance Due: ",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            "$currencySymbol${_toDouble(invoice.total).toStringAsFixed(2)}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 40));
          final items = invoice.items;
          final PdfColor headerBlue = PdfColors.grey;

          widgets.add(_itemTable(invoice, items, currencySymbol, headerBlue));
          widgets.add(pw.SizedBox(height: 70));

          // 🔹 Totals
          final discount = _toDouble(invoice.discount);
          final tax = _toDouble(invoice.tax);
          final shipping = _toDouble(invoice.shipping);

          widgets.add(
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // Subtotal
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(0),
                        ),
                        child: pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              "SubTotal : ",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              "$currencySymbol${_toDouble(invoice.subtotal).toStringAsFixed(2)}",
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),

                  // Discount
                  if (discount > 0) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Discount : ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          (invoice.discountType) == 'percent'
                              ? "${discount.toStringAsFixed(2)}%"
                              : "$currencySymbol${discount.toStringAsFixed(2)}",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],

                  // Tax
                  if (tax > 0) ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Tax : ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "${tax.toStringAsFixed(2)}%",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],

                  // Shipping
                  if (shipping > 0) ...[
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Shipping : ",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "$currencySymbol${shipping.toStringAsFixed(2)}",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ],

                  pw.SizedBox(height: 8),

                  // Total
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Total : ",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "$currencySymbol${_toDouble(invoice.total).toStringAsFixed(2)}",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.Spacer());

          // 🔹 Footer only on the last page
          widgets.add(
            pw.Align(
              alignment: pw.Alignment.bottomLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (showBank && profile != null) ...[
                    pw.Text(
                      "Bank Details",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    if ((profile.bankName).toString().trim().isNotEmpty)
                      pw.Text(
                        "Bank Name: ${profile.bankName}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if ((profile.accountHolder)
                        .toString()
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        "Account Holder: ${profile.accountHolder}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if ((profile.accountNumber)
                        .toString()
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        "Account Number: ${profile.accountNumber}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if ((profile.ifsc).toString().trim().isNotEmpty)
                      pw.Text(
                        "IFSC Code: ${profile.ifsc}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    if ((profile.upi).toString().trim().isNotEmpty)
                      pw.Text(
                        "UPI ID: ${profile.upi}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    pw.SizedBox(height: 10),
                  ],

                  if (settings.showNotes == true &&
                      invoice.notes != null &&
                      invoice.notes.toString().trim().isNotEmpty) ...[
                    pw.Text(
                      "Notes",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.notes ?? "Notes",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                  ],

                  if (settings.showTerms == true &&
                      invoice.terms != null &&
                      invoice.terms.toString().trim().isNotEmpty) ...[
                    pw.Text(
                      "Terms",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.terms ?? "Terms",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    // 🔹 PDF bytes
    final bytes = await pdf.save();
    final fileName = "invoice_${invoice.invoiceNo}.pdf";
    final file = await PdfSaver.savePdfFile(bytes: bytes, fileName: fileName);

    return file;
  }

  // Item table now requires invoice so header labels can be dynamic
  static pw.Widget _itemTable(
    InvoiceModel invoice,
    List<ItemModel> items,
    String currency,
    PdfColor headerBg,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    final headers = _getHeaders(invoice);

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.8),
      },
      children: [
        // 🔵 HEADER (Same as your screenshot)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: headerBg, // dark background
          ),
          children: [
            _headerCell(headers[0]),
            _headerCell(headers[1], align: pw.TextAlign.center),
            _headerCell(headers[2], align: pw.TextAlign.center),
            _headerCell(headers[3], align: pw.TextAlign.right),
          ],
        ),

        // 🔵 ROWS
        ...items.map((e) {
          final desc = e.desc.text.trim();
          final qty = toDouble(e.qty.text);
          final rate = toDouble(e.rate.text);
          final amt = qty * rate;

          return pw.TableRow(
            children: [
              _rowCell(desc),
              _rowCell(qty.toStringAsFixed(0), align: pw.TextAlign.center),
              _rowCell(
                "$currency${rate.toStringAsFixed(2)}",
                align: pw.TextAlign.center,
              ),
              _rowCell(
                "$currency${amt.toStringAsFixed(2)}",
                align: pw.TextAlign.right,
              ),
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
      padding: const pw.EdgeInsets.symmetric(horizontal:6,vertical: 6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
        textAlign: align,
      ),
    );
  }

}
