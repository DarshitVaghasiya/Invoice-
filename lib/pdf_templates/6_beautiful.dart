import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/item_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:invoice/utils/signature_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerators6 {
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

  static final PdfColor teal = PdfColor.fromHex('#0B7A75');
  static final PdfColor tealLight = PdfColor.fromHex('#E8F7F6');
  static final PdfColor tableHeader = PdfColor.fromHex('#0A6C69');
  static final PdfColor greyBorder = PdfColor.fromHex('#E3E3E3');

  static Future<File> generateBeautifulTemplate(
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

    final settings = AppData().settings;
    final String currency = invoice.currencySymbol ?? '\$';
    final profile = AppData().profile;
    final pw.MemoryImage? signatureImage = SignatureHelper.fromBase64(
      settings.signatureBase64,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        footer: (context) {
          // ❗ SHOW ONLY ON LAST PAGE
          if (context.pageNumber != context.pagesCount) {
            return pw.SizedBox();
          }
          return pw.Container(
            margin: const pw.EdgeInsets.symmetric(
              horizontal: -25,
              vertical: -20,
            ),
            height: 100,
            child: pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#0B7A75'),
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(80),
                      ),
                    ),
                  ),
                ),

                pw.Positioned(
                  right: 40,
                  bottom: 25,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        profile?.name ?? '',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Positioned(
                  left: 40,
                  bottom: 25,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Get in Touch",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        profile?.phone ?? '',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                        ),
                      ),
                      pw.Text(
                        profile?.email ?? '',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

        build: (context) {
          final items = (invoice.items as List? ?? [])
              .map((e) => e is ItemModel ? e : ItemModel.fromJson(e))
              .toList();

          return [
            // TOP TEAL HEADER WITH CURVE (simulated using stacked rounded container)
            pw.Padding(
              padding: const pw.EdgeInsets.only(
                left: -25,
                right: -25,
                top: -20,
              ),
              child: pw.Container(
                height: 120,
                child: pw.Stack(
                  children: [
                    // background teal rectangle with gradient-like subtle effect
                    pw.Container(
                      height: 120,
                      decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(
                          colors: [teal, PdfColor.fromHex('#078F8A')],
                          begin: pw.Alignment.topLeft,
                          end: pw.Alignment.bottomRight,
                        ),
                        borderRadius: const pw.BorderRadius.only(
                          bottomLeft: pw.Radius.circular(60),
                        ),
                      ),
                    ),

                    // curved accent at top-right (simulated by a large circle chip)
                    pw.Positioned(
                      right: -40,
                      top: -30,
                      child: pw.Container(
                        width: 180,
                        height: 180,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(120),
                        ),
                      ),
                    ),

                    // INVOICE text (left)
                    pw.Positioned(
                      left: 30,
                      top: 30,
                      child: pw.Text(
                        "INVOICE",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),

                    // invoice no box small under brand on right
                    pw.Positioned(
                      right: 25,
                      bottom: 20,
                      child:
                          profile?.profileImageBase64 != null &&
                              profile!.profileImageBase64!.isNotEmpty
                          ? pw.Container(
                              width: 80,
                              // Adjust as per your design
                              height: 80,
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(8),
                                color: PdfColors.white,
                                border: pw.Border.all(
                                  color: PdfColor.fromHex('#078F8A'),
                                  width: 2,
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.Image(
                                  pw.MemoryImage(
                                    base64Decode(
                                      profile.profileImageBase64!,
                                    ), // ✅ decode Base64, don't read file
                                  ),
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            )
                          : pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(6),
                              ),
                              child: pw.Text(
                                " ",
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 18),

            // Invoice To / Invoice details two-column like image
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Invoice To
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Bill To:",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        invoice.billTo,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                // Right: small invoice meta box
                pw.SizedBox(width: 12),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: greyBorder),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _metaRow("Invoice No:", invoice.invoiceNo),
                        if (AppData().settings.showPurchaseNo)
                          _metaRow("PO Number:", invoice.poNumber ?? '-'),
                        _metaRow("Date:", invoice.date),
                        _metaRow("Due Date:", invoice.dueDate),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 18),

            // Items table header + rows (styled to match)
            _itemsTable(items, currency, invoice),

            pw.SizedBox(height: 40),

            // Bottom left: payment info and terms (conditional) - show only if any setting true
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column: Payment Info and Terms
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (AppData().settings.showBank && bankAccount != null)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: greyBorder),
                            borderRadius: pw.BorderRadius.circular(6),
                            color: PdfColors.white,
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "PAYMENT INFO",
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                "Bank: ${bankAccount.bankName}",
                                style: pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                "Name: ${bankAccount.accountHolder}",
                                style: pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                "Account No: ${bankAccount.accountNumber}",
                                style: pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                "IFSC: ${bankAccount.ifsc}",
                                style: pw.TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      if (AppData().settings.showTerms &&
                          (invoice.terms ?? '').trim().isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8),
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: greyBorder),
                              borderRadius: pw.BorderRadius.circular(6),
                              color: PdfColors.white,
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "Terms & Conditions",
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 6),
                                pw.Text(
                                  invoice.terms ?? '-',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Right Column: totals (matching image layout)
                pw.SizedBox(width: 12),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: greyBorder),
                          borderRadius: pw.BorderRadius.circular(6),
                          color: PdfColors.white,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _rowTotal(
                              "Sub Total",
                              "$currency${_toDouble(invoice.subtotal).toStringAsFixed(2)}",
                            ),
                            _rowTotal(
                              invoice.discountType == 'percent'
                                  ? "Discount (${invoice.discount}%) : "
                                  : "Discount : ",
                              "$currency${_toDouble(invoice.discountAmount).toStringAsFixed(2)}",
                            ),
                            _rowTotal(
                              "Tax (${invoice.tax}%)",
                              "$currency${_toDouble(invoice.taxAmount).toStringAsFixed(2)}",
                            ),
                            _rowTotal(
                              "Shipping",
                              "$currency${_toDouble(invoice.shipping).toStringAsFixed(2)}",
                            ),
                            pw.Divider(),
                            // total badge
                            pw.Container(
                              margin: const pw.EdgeInsets.only(top: 6),
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: pw.BoxDecoration(
                                color: teal,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    "Total",
                                    style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    "$currency${_toDouble(invoice.total).toStringAsFixed(2)}",
                                    style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
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
              ],
            ),

            pw.SizedBox(height: 18),

            // Notes block (if shown separately and not inside previous - image shows terms left and signature bottom left)
            if (AppData().settings.showNotes &&
                (invoice.notes ?? '').trim().isNotEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: greyBorder),
                  borderRadius: pw.BorderRadius.circular(6),
                  color: PdfColors.white,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Note",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      invoice.notes ?? '-',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    if (signatureImage != null)
                      pw.Align(
                        alignment: pw.Alignment.bottomRight,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 120,
                              height: 60,
                              child: pw.Image(
                                signatureImage,
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              "Authorized Signature",
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  // helpers
  static double _toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0.0;

  static pw.Widget _metaRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(value, style: pw.TextStyle(fontSize: 9)),
      ],
    ),
  );

  static pw.Widget _rowTotal(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9)),
        pw.Text(value, style: pw.TextStyle(fontSize: 9)),
      ],
    ),
  );

  static pw.Widget _itemsTable(
    List<ItemModel> items,
    String currency,
    InvoiceModel invoice,
  ) {
    // ---------------------------------------------
    // 🔥 1. Collect all unique custom field names
    // ---------------------------------------------
    final Set<String> customFieldNames = {};
    for (var item in items) {
      customFieldNames.addAll(item.customControllers.keys);
    }
    final customFields = customFieldNames.toList();

    // ---------------------------------------------
    // 🔥 2. Base headers (Description, Qty, Rate, Amount)
    // ---------------------------------------------
    final defaultHeaders = _getHeaders(invoice);

    // ---------------------------------------------
    // 🔥 3. TABLE HEADERS → SL + Description + Custom Fields + Qty + Rate + Amount
    // ---------------------------------------------
    final headers = [
      'SL',
      defaultHeaders[0], // Description
      ...customFields, // ⬅ Dynamic custom fields
      defaultHeaders[1], // Qty
      defaultHeaders[2], // Rate
      defaultHeaders[3], // Amount
    ];

    // ---------------------------------------------
    // 🔥 4. Build table rows dynamically
    // ---------------------------------------------
    final tableData = List.generate(items.isEmpty ? 5 : items.length, (i) {
      if (items.isEmpty) {
        return [
          '00',
          'Item name goes here',
          ...List.generate(customFields.length, (_) => ''), // custom fields
          '0',
          '$currency.00',
          '$currency.00',
        ];
      }

      final item = items[i];
      double customValue = 1.0;

      for (final controller in item.customControllers.values) {
        final v = double.tryParse(controller.text.trim());
        if (v != null && v > 0) {
          customValue *= v;
        }
      }

      final qty = double.tryParse(item.qty.text) ?? 1;
      final rate = double.tryParse(item.rate.text) ?? 0;
      final amt = customValue * qty * rate;

      // 🔥 fetch each custom field's value for this item
      final customValues = customFields.map((field) {
        return item.customControllers[field]?.text ?? '';
      }).toList();

      return [
        (i + 1).toString().padLeft(2, '0'),
        item.desc.text,
        ...customValues, // ⬅ dynamic custom values
        qty.toStringAsFixed(0),
        "$currency${rate.toStringAsFixed(2)}",
        "$currency${amt.toStringAsFixed(2)}",
      ];
    });

    // ---------------------------------------------
    // 🔥 5. Return final table
    // ---------------------------------------------
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: tableData,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: PdfColor.fromHex('#E6EEF0'),
          width: 0.5,
        ),
        bottom: pw.BorderSide(color: PdfColor.fromHex('#E6EEF0'), width: 0.5),
        top: pw.BorderSide(color: PdfColor.fromHex('#E6EEF0'), width: 0.5),
        left: pw.BorderSide.none,
        right: pw.BorderSide.none,
      ),
      headerDecoration: pw.BoxDecoration(color: tableHeader),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellDecoration: (col, dataRow, rowNum) {
        return pw.BoxDecoration(
          color: rowNum % 2 == 0
              ? PdfColor.fromHex('#F6FAF9')
              : PdfColors.white,
        );
      },

      // ---------------------------------------------
      // 🔥 Column widths adjusted automatically
      // ---------------------------------------------
      columnWidths: {
        0: const pw.FixedColumnWidth(25), // SL
        1: const pw.FlexColumnWidth(5), // Description
        for (int k = 0; k < customFields.length; k++)
          (2 + k): const pw.FlexColumnWidth(1.5), // Custom fields
        (2 + customFields.length): const pw.FlexColumnWidth(1.5), // Qty
        (3 + customFields.length): const pw.FlexColumnWidth(1.5), // Rate
        (4 + customFields.length): const pw.FlexColumnWidth(2), // Amount
      },

      cellAlignments: {
        0: pw.Alignment.center, // SL
        1: pw.Alignment.centerLeft, // Desc
        for (int k = 0; k < customFields.length; k++)
          (2 + k): pw.Alignment.center, // Custom fields
        (2 + customFields.length): pw.Alignment.center, // Qty
        (3 + customFields.length): pw.Alignment.centerRight, // Rate
        (4 + customFields.length): pw.Alignment.centerRight, // Amount
      },
    );
  }
}
