import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QuotationPdfGenerator {
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

  static Future<File?> generateQuotation(InvoiceModel invoice) async {
    final baseFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Regular.ttf"),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load("assets/Fonts/Roboto-Bold.ttf"),
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );

    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    final settings = AppData().settings;
    final currency = invoice.currencySymbol ?? "\$";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 35),
        build: (context) {
          return [
            /// 🔵 HEADER
            pw.Container(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
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
                    ],
                  ),
                  pw.Text(
                    "QUOTATION",
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            /// 🔵 BILL TO SECTION
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
                  ],
                ),
                // Right → Invoice details
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
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
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            /// 🔵 ITEM TABLE
            _itemTable(invoice, currency, invoice.items),

            pw.SizedBox(height: 50),

            /// 🔵 TOTAL BOX
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                padding: const pw.EdgeInsets.all(10),
                //  decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _totalRow(
                      "SubTotal",
                      "$currency ${toDouble(invoice.subtotal).toStringAsFixed(2)}",
                    ),
                    if (toDouble(invoice.discount) > 0)
                      _totalRow(
                        "Discount",
                        "$currency ${toDouble(invoice.discountAmount).toStringAsFixed(2)}",
                      ),
                    if (toDouble(invoice.tax) > 0)
                      _totalRow(
                        "Tax",
                        "$currency ${toDouble(invoice.taxAmount).toStringAsFixed(2)}",
                      ),
                    pw.Divider(),
                    pw.Text(
                      "Total : $currency ${toDouble(invoice.total).toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final file = await PdfSaver.savePdfFile(
      bytes: bytes,
      fileName: "Quotation.pdf",
    );

    return file;
  }

  /// 🧾 ITEM TABLE (PROPER ALIGNMENT)
  static pw.Widget _itemTable(
    InvoiceModel invoice,
    String currency,
    List<ItemModel> items,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    /// 🔵 Collect all custom field names
    final Set<String> customFieldNames = {};
    for (var item in items) {
      customFieldNames.addAll(item.customControllers.keys);
    }

    final defaultHeaders = _getHeaders(invoice);

    final List<String> headers = [
      defaultHeaders[0], // Description
      ...customFieldNames, // Dynamic Custom Fields
      defaultHeaders[1], // Qty
      defaultHeaders[2], // Rate
      defaultHeaders[3], // Amount
    ];

    /// 🔵 Dynamic Column Width
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    for (int i = 0; i < headers.length; i++) {
      if (i == 0) {
        columnWidths[i] = const pw.FlexColumnWidth(4); // Description big
      } else {
        columnWidths[i] = const pw.FlexColumnWidth(2);
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: columnWidths,
      children: [
        /// 🔵 HEADER ROW
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers.asMap().entries.map((entry) {
            final index = entry.key;
            final h = entry.value;
            return index == 0 ? _header1(h) : _header(h);
          }).toList(),
        ),

        /// 🔵 DATA ROWS
        ...items.map((item) {
          final qty = toDouble(item.qty.text);
          final rate = toDouble(item.rate.text);
          final amount = qty * rate;

          List<pw.Widget> row = [];

          /// Description
          row.add(_cell(item.desc.text));

          /// Custom Fields
          for (String field in customFieldNames) {
            final value = item.customControllers[field]?.text ?? "";
            row.add(_cell(value));
          }

          /// Qty
          row.add(_rightCell(qty.toStringAsFixed(0)));

          /// Rate
          row.add(_rightCell("$currency${rate.toStringAsFixed(2)}"));

          /// Amount
          row.add(_rightCell("$currency${amount.toStringAsFixed(2)}"));

          return pw.TableRow(children: row);
        }),
      ],
    );
  }

  static pw.Widget _header1(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );
  }

  static pw.Widget _header(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _rightCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      ),
    );
  }

  static pw.Widget _totalRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(title), pw.Text(value)],
      ),
    );
  }
}
