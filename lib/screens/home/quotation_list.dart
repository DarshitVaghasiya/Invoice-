import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/models/quotation_model.dart';
import 'package:invoice/pdf_templates/quotation.dart';
import 'package:invoice/screens/forms/invoice_form.dart';
import 'package:invoice/screens/home/pdf_preview.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({super.key});

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  List<QuotationModel> quotation = [];
  List<CustomerModel> customers = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storedList = AppData().quotations;

    setState(() {
      quotation = storedList.reversed.toList();
    });
  }

  Future<void> _deleteInvoice(QuotationModel quotationModel) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Quotation",
      message: "Are you sure you want to permanently delete this quotation?",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      btn3: "Delete",
      btn2: "Cancel",
    );

    if (confirmed == true) {
      // Remove from original list
      AppData().quotations.removeWhere(
        (e) => e.quotationID == quotationModel.quotationID,
      );

      await AppData().saveAllData();

      // Reload properly (with reverse)
      _loadData();
    }
  }

  Future<void> _createNewQuotation() async {
    final newQuotation = await Navigator.push<QuotationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const InvoiceFormPage(isQuotation: true),
      ),
    );

    if (newQuotation != null) _loadData();
  }

  Future<void> _editQuotation(QuotationModel quotations) async {
    final index = quotation.indexOf(quotations);

    final updatedQuotation = await Navigator.push<QuotationModel>(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormPage(
          isQuotation: true,
          existingData: quotations.toJson(),
          index: index,
        ),
      ),
    );

    if (updatedQuotation != null) _loadData();
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
        return Scaffold(
          backgroundColor: Color(0xFFF0F2F5),
          body: quotation.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔵 Gradient Circle with Shadow
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 72,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        // 🧾 Title
                        Text(
                          "No Quotations Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MasonryGridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quotation.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final quotation = this.quotation[index];
                            final isExpanded = expandedIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandedIndex = isExpanded ? null : index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// HEADER
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF0079D0),
                                                  Color(0xFF00B4DB),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      quotation.billTo
                                                          .split('\n')
                                                          .first,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 16
                                                            : 20,
                                                        //  fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Issued on ${quotation.date}",
                                                      style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 12
                                                            : 14,
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF0079D0),
                                                            Color(0xFF00B4DB),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "QUOTATION",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: isMobile
                                                          ? 12
                                                          : 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      /// TOTAL SECTION
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Amount",
                                                style: TextStyle(
                                                  fontSize: isMobile ? 12 : 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Text(
                                                "${quotation.currencySymbol ?? '\$'}${quotation.total.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: isMobile ? 20 : 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0079D0),
                                                ),
                                              ),
                                            ],
                                          ),

                                          /// ARROW
                                          AnimatedRotation(
                                            turns: isExpanded ? 0.5 : 0,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                isMobile ? 6 : 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF0079D0,
                                                ).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                size: isMobile ? 24 : 26,
                                                color: Color(0xFF0079D0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      /// EXPANDED SECTION
                                      AnimatedCrossFade(
                                        duration: const Duration(
                                          milliseconds: 350,
                                        ),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        firstChild: const SizedBox(),
                                        secondChild: Column(
                                          children: [
                                            const SizedBox(height: 5),
                                            Divider(
                                              color: Colors.grey.shade200,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                _modernButton(
                                                  icon:
                                                      Icons.visibility_outlined,
                                                  iconSize: isMobile ? 20 : 24,
                                                  fontSize: isMobile ? 13 : 16,
                                                  label: "View",
                                                  color: const Color(
                                                    0xFF0079D0,
                                                  ),
                                                  onTap: () async {
                                                    final file =
                                                        await QuotationPdfGenerator.generateQuotation(
                                                          quotation,
                                                        );

                                                    if (file == null) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Failed to generate PDF",
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            PdfPreviewScreen(
                                                              file: file,
                                                              isQuotation: true,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                _modernButton(
                                                  icon: Icons
                                                      .mode_edit_outline_outlined,
                                                  iconSize: isMobile ? 20 : 24,
                                                  fontSize: isMobile ? 13 : 16,
                                                  label: "Edit",
                                                  color: Colors.orange,
                                                  onTap: () =>
                                                      _editQuotation(quotation),
                                                ),
                                                _modernButton(
                                                  icon: Icons.delete_outline,
                                                  iconSize: isMobile ? 20 : 24,
                                                  fontSize: isMobile ? 13 : 16,
                                                  label: "Delete",
                                                  color: Colors.red,
                                                  onTap: () =>
                                                      _deleteInvoice(quotation),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),

          floatingActionButton: FloatingActionButton.extended(
            heroTag: "quick_btn",
            onPressed: _createNewQuotation,
            icon: Icon(
              Icons.add,
              size: isMobile
                  ? 18
                  : isTablet
                  ? 20
                  : 22,
            ),
            label: Text(
              "New Quotation",
              style: TextStyle(
                fontSize: isMobile
                    ? 14
                    : isTablet
                    ? 16
                    : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Color(0xFF009A75),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _modernButton({
    required IconData icon,
    required double iconSize,
    required String label,
    required double fontSize,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
