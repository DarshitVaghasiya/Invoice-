import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:invoice/utils/signature_helper.dart';
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
                  _itemTable(invoice, items, currencySymbol, accentBlue),

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
                              invoice.discountType == 'percent'
                                  ? "Discount (${invoice.discount}%) : "
                                  : "Discount : ",
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

  static pw.Widget _itemTable(
    InvoiceModel invoice,
    List<ItemModel> items,
    String currencySymbol,
    PdfColor accentBlue,
  ) {
    double toDouble(dynamic val) => double.tryParse(val?.toString() ?? '') ?? 0;

    // 🔥 Extract all custom field names dynamically
    final Set<String> customFieldNames = {};
    for (var item in items) {
      customFieldNames.addAll(item.customControllers.keys);
    }
    final customFieldsList = customFieldNames.toList();

    final defaultHeaders = _getHeaders(invoice);
    // 🔥 Build header list
    final List<String> headers = [
      defaultHeaders[0], // Description
      ...customFieldNames, // Custom fields
      defaultHeaders[1], // Qty
      defaultHeaders[2], // Rate
      defaultHeaders[3], // Amount
    ];

    // 🔥 Build dynamic alignments
    final cellAlignments = <int, pw.Alignment>{
      0: pw.Alignment.centerLeft, // Description
    };

    for (int i = 0; i < customFieldsList.length; i++) {
      cellAlignments[i + 1] = pw.Alignment.center; // Custom fields center
    }

    final base = customFieldsList.length;
    cellAlignments[base + 1] = pw.Alignment.center; // Qty
    cellAlignments[base + 2] = pw.Alignment.center; // Rate
    cellAlignments[base + 3] = pw.Alignment.centerRight; // Amount

    // 🔥 Build dynamic column widths
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(5), // Description
    };

    for (int i = 0; i < customFieldsList.length; i++) {
      columnWidths[i + 1] = const pw.FlexColumnWidth(1.5);
    }

    columnWidths[base + 1] = const pw.FlexColumnWidth(1.5); // Qty
    columnWidths[base + 2] = const pw.FlexColumnWidth(1.5); // Rate
    columnWidths[base + 3] = const pw.FlexColumnWidth(1.8); // Amount

    // 🔥 Build the table
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: items.map((item) {
        double customValue = 1.0;

        for (final controller in item.customControllers.values) {
          final v = double.tryParse(controller.text.trim());
          if (v != null && v > 0) {
            customValue *= v;
          }
        }
        final qty = toDouble(item.qty.text);
        final rate = toDouble(item.rate.text);
        final amt = customValue * qty * rate;

        return [
          item.desc.text,

          // Custom field values
          ...customFieldsList.map(
            (field) => item.customControllers[field]?.text ?? "-",
          ),

          qty.toStringAsFixed(0),
          "$currencySymbol${rate.toStringAsFixed(2)}",
          "$currencySymbol${amt.toStringAsFixed(2)}",
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
      cellAlignments: cellAlignments,
      columnWidths: columnWidths,
    );
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

  static pw.Widget _buildFooter(
    pw.Context context,
    InvoiceModel invoice,
    dynamic settings,
    PdfColor darkBlue,
    PdfColor accentBlue,
  ) {
    if (context.pageNumber != context.pagesCount) return pw.SizedBox();

    BankAccountModel? bankAccount;
    final allAccounts = AppData().profile!.bankAccounts;
    if (allAccounts!.isNotEmpty) {
      bankAccount = allAccounts.firstWhere(
        (acc) => acc.isPrimary == true,
        orElse: () => allAccounts.first,
      );
    } else {
      bankAccount = null;
    }

    final showBank = settings.showBank == true;
    final showTerms = settings.showTerms == true;
    final showNotes = settings.showNotes == true;

    final hasTerms = (invoice.terms?.trim().isNotEmpty ?? false);
    final hasNotes = (invoice.notes?.trim().isNotEmpty ?? false);

    final signatureImage = SignatureHelper.fromBase64(settings.signatureBase64);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // ---------- LEFT SECTION (Bank + Terms + Notes) ----------
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (showBank && bankAccount != null) ...[
                  pw.Text(
                    "Bank Details",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),

                  if ((bankAccount.bankName).trim().isNotEmpty)
                    pw.Text(
                      "Bank Name: ${bankAccount.bankName}",
                      style: pw.TextStyle(fontSize: 12),
                    ),

                  if ((bankAccount.accountHolder).trim().isNotEmpty)
                    pw.Text(
                      "Account Holder: ${bankAccount.accountHolder}",
                      style: pw.TextStyle(fontSize: 12),
                    ),

                  if ((bankAccount.accountNumber).trim().isNotEmpty)
                    pw.Text(
                      "Account Number: ${bankAccount.accountNumber}",
                      style: pw.TextStyle(fontSize: 12),
                    ),

                  if ((bankAccount.ifsc).trim().isNotEmpty)
                    pw.Text(
                      "IFSC Code: ${bankAccount.ifsc}",
                      style: pw.TextStyle(fontSize: 12),
                    ),

                  if ((bankAccount.upi).trim().isNotEmpty)
                    pw.Text(
                      "UPI ID: ${bankAccount.upi}",
                      style: pw.TextStyle(fontSize: 12),
                    ),

                  pw.SizedBox(height: 10),
                ],

                if (showTerms && hasTerms) ...[
                  pw.Text(
                    "TERMS & CONDITIONS",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: darkBlue,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    invoice.terms ?? "",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 10),
                ],

                if (showNotes && hasNotes) ...[
                  pw.Text(
                    "NOTES",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: darkBlue,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    invoice.notes ?? "",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ],
            ),
          ),

          // ---------- RIGHT SIDE: Signature aligned next to Notes ----------
          if (signatureImage != null)
            pw.Column(
              children: [
                pw.Container(
                  width: 130,
                  height: 65,
                  child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Authorized Signature",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
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
