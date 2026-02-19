import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/Global%20Veriables/global_veriable.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:invoice/pdf_templates/1_simple.dart';
import 'package:invoice/pdf_templates/2_classic.dart';
import 'package:invoice/pdf_templates/3_modern.dart';
import 'package:invoice/pdf_templates/4_elegant.dart';
import 'package:invoice/pdf_templates/5_attractive.dart';
import 'package:invoice/pdf_templates/6_beautiful.dart';
import 'package:invoice/screens/forms/invoice_form.dart';
import 'package:invoice/screens/home/pdf_preview.dart';
import 'package:invoice/screens/home/rate_us_dialog.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';

class InvoiceListPage extends StatefulWidget {
  final String selectedFilter;

  const InvoiceListPage({super.key, required this.selectedFilter});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<InvoiceModel> invoices = [];
  List<CustomerModel> customers = [];

  static const Color primaryColor = Color(0xFF009A75);
  static const Color unpaidColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF0F2F5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storedList = AppData().invoices;

    setState(() {
      invoices = storedList.reversed.toList();
    });

    /*    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];

      if (invoice.status != 'paid') {
        DateTime? dueDate;

        // Parse dueDate safely (supports DateTime or dd-MM-yyyy or ISO)
        if (invoice.dueDate is DateTime) {
          dueDate = invoice.dueDate as DateTime;
        } else if (invoice.dueDate is String) {
          String dateStr = invoice.dueDate as String;
          if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateStr)) {
            final parts = dateStr.split('-');
            dueDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } else {
            dueDate = DateTime.tryParse(dateStr);
          }
        } else {
          dueDate = DateTime.tryParse(invoice.dueDate.toString());
        }

        if (dueDate != null) {
          final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
          if (dueDay.isBefore(today)) {
            invoices[i] = invoice.copyWith(status: 'overdue');
          } else {
            invoices[i] = invoice.copyWith(status: 'unpaid');
          }
        }
      }
    }

    // Sort invoices by issue date (latest first)
    invoices.sort((a, b) {
      int statusPriority(String status) {
        switch (status) {
          case 'overdue':
            return 0; // Highest priority
          case 'unpaid':
            return 1;
          case 'paid':
            return 2;
          default:
            return 3;
        }
      }

      // First compare by status priority
      final statusCompare = statusPriority(
        a.status,
      ).compareTo(statusPriority(b.status));

      if (statusCompare != 0) return statusCompare;

      // If same status → sort by latest date
      DateTime parseDate(dynamic value) {
        if (value is DateTime) return value;

        final str = value.toString();
        if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(str)) {
          final parts = str.split('-');
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
        return DateTime.tryParse(str) ?? DateTime(2000);
      }

      final dateA = parseDate(a.date);
      final dateB = parseDate(b.date);

      return dateB.compareTo(dateA); // Latest first
    });

    // Save back to AppData
    AppData().invoices = invoices;

    setState(() {});*/
  }

  Future<void> _createNewInvoice() async {
    bool hasRated = AppData().userHasRated;

    // Show rating popup after 3 invoices AND only if user has not rated
    if (invoices.length >= 3 && !hasRated) {
      await showRateUsDialog(context, (rating) {
        if (rating > 0) {
          AppData().markUserRated(); // save inside InvoiceModel
        }
      });
    }

    // Restrict free plan
    if (!isPurchase && invoices.length >= 10) {
      showLimitDialog(
        "You can create only 10 invoices in Free plan.\\nUpgrade to create unlimited invoices.",
      );
      return;
    }

    // Open new invoice page
    final newInvoice = await Navigator.push<InvoiceModel>(
      context,
      MaterialPageRoute(builder: (context) => const InvoiceFormPage()),
    );

    if (newInvoice != null) _loadData();
  }

  Future<void> _editInvoice(InvoiceModel invoice) async {
    final index = invoices.indexOf(invoice);
    final updatedInvoice = await Navigator.push<InvoiceModel>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InvoiceFormPage(existingData: invoice.toJson(), index: index),
      ),
    );
    if (updatedInvoice != null) _loadData();
  }

  Future<void> _deleteInvoice(InvoiceModel invoice) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Invoice",
      message:
          "Are you sure you want to permanently delete invoice ${invoice.invoiceNo}? This action cannot be undone.",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      btn3: "Delete",
      btn2: "Cancel",
    );

    if (confirmed == true) {
      setState(() {
        AppData().invoices.removeWhere(
          (inv) => inv.invoiceID == invoice.invoiceID,
        );
        invoices = List.from(AppData().invoices);
      });
      await AppData().saveAllData();
      _loadData();
    }
  }

  Future<void> _paymentStatus(InvoiceModel invoice) async {
    final index = AppData().invoices.indexWhere(
      (inv) => inv.invoiceNo == invoice.invoiceNo,
    );
    if (index != -1) {
      final isPaid = invoice.status == 'paid';
      final newStatus = isPaid ? 'unpaid' : 'paid';
      final updated = invoice.copyWith(status: newStatus);
      AppData().invoices[index] = updated;

      await _loadData();
    }
  }

  Future<void> _generateAndOpenPdf(
    InvoiceModel invoice,
    ProfileModel? profile,
  ) async {
    final template = AppData().settings.selectedTemplate;
    try {
      File? file;
      switch (template) {
        case "Simple":
          file = await PdfGenerator1.generateSimpleTemplates(invoice);
          break;
        case "Classic":
          file = await PdfGenerator2.generateClassicTemplate(invoice);
          break;
        case "Modern":
          file = await PdfGenerator3.generateModernTemplate(invoice);
          break;
        case "Elegant":
          file = await PdfGenerator4.generateElegantTemplate(invoice);
          break;
        case "Attractive":
          file = await PdfGenerators5.generateAttractiveTemplate(
            invoice,
            profile,
          );
          break;
        case "Beautiful":
          file = await PdfGenerators6.generateBeautifulTemplate(
            invoice,
            profile,
          );
          break;
        default:
          file = await PdfGenerator1.generateSimpleTemplates(invoice);
      }

      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create PDF file.")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PdfPreviewScreen(file: file!)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        final isTablet =
            constraints.maxWidth >= 400 && constraints.maxWidth < 1000;

        final isMobile1 = constraints.maxWidth < 440;
        final isTablet1 =
            constraints.maxWidth >= 440 && constraints.maxWidth < 1000;
        final crossAxisCount = isMobile1
            ? 1
            : isTablet1
            ? 2
            : 3;

        final filteredInvoices = invoices.where((invoice) {
          if (widget.selectedFilter == "paid") {
            return invoice.status == "paid";
          }
          if (widget.selectedFilter == "unpaid") {
            return invoice.status == "unpaid";
          }
          if (widget.selectedFilter == "overdue") {
            return invoice.status == "overdue";
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: backgroundColor,
          body: filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: isMobile
                            ? 70
                            : isTablet
                            ? 80
                            : 85,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.selectedFilter == "all"
                            ? "No invoices found. Create one to get started!"
                            : "No ${widget.selectedFilter} invoices match the filter.",
                        style: TextStyle(
                          fontSize: isMobile
                              ? 15
                              : isTablet
                              ? 18
                              : 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: isMobile ? 15 : 20,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = filteredInvoices[index];
                            final companyName = invoice.billTo
                                .trim()
                                .split('\\n')
                                .first;
                            return buildInvoiceCard(
                              context,
                              invoice,
                              companyName,
                              AppData().profile,
                            );
                          },
                        ),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: "invoice_btn",
            onPressed: _createNewInvoice,
            extendedPadding: EdgeInsets.symmetric(horizontal: 16),
            icon: Icon(
              Icons.add,
              size: isMobile
                  ? 18
                  : isTablet
                  ? 20
                  : 22,
            ),
            label: Text(
              "New Invoice",
              style: TextStyle(
                fontSize: isMobile
                    ? 14
                    : isTablet
                    ? 16
                    : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget buildInvoiceCard(
    BuildContext context,
    InvoiceModel invoice,
    String companyName,
    ProfileModel? profile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        final isTablet =
            constraints.maxWidth >= 400 && constraints.maxWidth < 1000;

        final bool isPaid = invoice.status == 'paid';
        final bool isOverdue = invoice.status == 'overdue';
        final Color statusTextColor = isPaid
            ? Colors.green
            : (isOverdue ? Colors.red : Colors.orange);
        final Color statusBackgroundColor = statusTextColor.withOpacity(0.15);

        final screenWidth = MediaQuery.of(context).size.width;

        final double textWidth = isMobile
            ? screenWidth * 0.48
            : isTablet
            ? screenWidth * 0.30
            : screenWidth * 0.18;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "INV: ${invoice.invoiceNo}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile
                          ? 13
                          : isTablet
                          ? 17
                          : 18,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      invoice.status.toUpperCase(),
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: isMobile
                            ? 10
                            : isTablet
                            ? 13
                            : 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Amount + Dates Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amount Due",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "${invoice.currencySymbol ?? '\$'}${invoice.total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: isMobile
                              ? 18
                              : isTablet
                              ? 22
                              : 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0079D0),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Issued Date",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        invoice.date.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 13 : 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Client + Due Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Client / Company",
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3),
                        SizedBox(
                          width: textWidth,
                          child: Text(
                            companyName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isMobile ? 13 : 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Due Date",
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        invoice.dueDate.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 13 : 15,
                          color: isOverdue ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(color: Colors.grey.shade300, height: 20),

              // Buttons Row
              Row(
                children: [
                  // PAY
                  Expanded(
                    child: IgnorePointer(
                      ignoring: isPaid,
                      child: Opacity(
                        opacity: isPaid ? 0.5 : 1,
                        child: CustomIconButton(
                          label: "Pay",
                          icon: Icons.check_circle_outline,
                          fontSize: isMobile ? 12 : 15,
                          iconSize: isMobile ? 20 : 25,
                          backgroundColor: isPaid
                              ? Colors.grey.shade200
                              : const Color(0xFFE6F5F1),
                          textColor: isPaid
                              ? Colors.grey
                              : const Color(0xFF009A75),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          onTap: () async {
                            if (isPaid) return;
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Confirm Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: isMobile ? 18 : 22,
                                    color: Colors.black87,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to mark this invoice as paid?',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 15,
                                    height: 1.4,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  CustomIconButton(
                                    label: "No",
                                    borderColor: Colors.red,
                                    textColor: Colors.red,
                                    onTap: () => Navigator.pop(context, false),
                                  ),
                                  CustomIconButton(
                                    label: "Yes",
                                    borderColor: Colors.green,
                                    textColor: Colors.green,
                                    onTap: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              _paymentStatus(invoice);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),

                  // VIEW
                  Expanded(
                    child: CustomIconButton(
                      label: "PDF",
                      icon: Icons.visibility_outlined,
                      backgroundColor: Colors.blue.shade50,
                      fontSize: isMobile ? 12 : 15,
                      iconSize: isMobile ? 20 : 25,
                      textColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      onTap: () => _generateAndOpenPdf(invoice, profile),
                    ),
                  ),

                  SizedBox(width: 6),

                  // EDIT
                  Expanded(
                    child: IgnorePointer(
                      ignoring: isPaid,
                      child: Opacity(
                        opacity: isPaid ? 0.5 : 1,
                        child: CustomIconButton(
                          label: "Edit",
                          icon: Icons.edit_outlined,
                          fontSize: isMobile ? 12 : 15,
                          iconSize: isMobile ? 20 : 25,
                          backgroundColor: isPaid
                              ? Colors.grey.shade200
                              : unpaidColor.withOpacity(0.15),
                          textColor: isPaid
                              ? Colors.grey.shade500
                              : unpaidColor,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          onTap: () => _editInvoice(invoice),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 6),

                  // DELETE
                  Expanded(
                    child: IgnorePointer(
                      ignoring: isPaid,
                      child: Opacity(
                        opacity: isPaid ? 0.5 : 1,
                        child: CustomIconButton(
                          label: "Delete",
                          icon: Icons.delete_outline_rounded,
                          fontSize: isMobile ? 12 : 15,
                          iconSize: isMobile ? 20 : 25,
                          backgroundColor: isPaid
                              ? Colors.grey.shade200
                              : Colors.red.shade50,
                          textColor: isPaid ? Colors.grey : Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          onTap: () => _deleteInvoice(invoice),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
