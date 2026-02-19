import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/screens/menu/reports/report_pdf.dart';

enum Status { date, customer, amount }

class ReportsList extends StatefulWidget {
  const ReportsList({super.key});

  @override
  State<ReportsList> createState() => _ReportsListState();
}

class _ReportsListState extends State<ReportsList> {
  late List items;
  Status selectedStatus = Status.date;
  String selectedFilter = "date";
  String? selectedCustomer;
  List<String> customerList = [];

  // Report filter type
  String reportType = "All";
  DateTimeRange? customRange;
  late List allFilteredItems;

  List getPaidInvoices() {
    return AppData().invoices
        .where((e) => (e.status.toString().toLowerCase() == "paid"))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    allFilteredItems = getPaidInvoices();
    items = List.from(allFilteredItems);
    _applySortByDate();
  }

  void _applySortByDate() {
    items.sort((a, b) {
      List<String> pa = a.date.split('-');
      List<String> pb = b.date.split('-');
      DateTime dateA = DateTime(
        int.parse(pa[2]),
        int.parse(pa[1]),
        int.parse(pa[0]),
      );
      DateTime dateB = DateTime(
        int.parse(pb[2]),
        int.parse(pb[1]),
        int.parse(pb[0]),
      );
      return dateB.compareTo(dateA);
    });
  }

  DateTime parseDate(String d) {
    List<String> p = d.split("-");
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  // REPORT TYPE FILTER HANDLING
  void _applyReportType() async {
    List allInvoices = getPaidInvoices();

    DateTime now = DateTime.now();
    setState(() {
      if (reportType == "Weekly") {
        allFilteredItems = allInvoices
            .where(
              (e) => parseDate(e.date).isAfter(now.subtract(Duration(days: 7))),
            )
            .toList();
      } else if (reportType == "Monthly") {
        allFilteredItems = allInvoices
            .where(
              (e) =>
                  parseDate(e.date).isAfter(now.subtract(Duration(days: 30))),
            )
            .toList();
      } else if (reportType == "Yearly") {
        allFilteredItems = allInvoices
            .where(
              (e) =>
                  parseDate(e.date).isAfter(now.subtract(Duration(days: 365))),
            )
            .toList();
      } else if (reportType == "Custom") {
        _selectCustomDate();
      } else {
        allFilteredItems = allInvoices;
      }

      items = List.from(allFilteredItems);

      // update customer dropdown list also
      customerList =
          allFilteredItems
              .map((e) => e.billTo.trim().split('\n').first)
              .toSet()
              .cast<String>()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  // CUSTOM DATE RANGE PICK
  void _selectCustomDate() async {
    ThemeData baseTheme = Theme.of(context);

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: const Color(0xFF009A75),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        customRange = picked;

        items = getPaidInvoices().where((e) {
          DateTime d = parseDate(e.date);
          return d.isAfter(picked.start.subtract(Duration(days: 1))) &&
              d.isBefore(picked.end.add(Duration(days: 1)));
        }).toList();

        allFilteredItems = List.from(items);

        // UPDATE CUSTOMER DROPDOWN LIST BASED ON FILTERED INVOICES
        customerList =
            items
                .map((e) => e.billTo.trim().split('\n').first as String)
                .toSet()
                .cast<String>()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (selectedCustomer != null &&
            !customerList.contains(selectedCustomer)) {
          selectedCustomer = null;
        }
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter != "customer") selectedCustomer = null;

      items = List.from(allFilteredItems);

      if (filter == "date") {
        selectedStatus = Status.date;
        _applySortByDate();
      } else if (filter == "customer") {
        selectedStatus = Status.customer;

        customerList =
            items
                .map((e) => e.billTo.trim().split('\n').first)
                .toSet()
                .cast<String>()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      } else if (filter == "amount") {
        selectedStatus = Status.amount;
        items.sort((a, b) {
          double totalA = double.tryParse(a.total.toString()) ?? 0;
          double totalB = double.tryParse(b.total.toString()) ?? 0;
          return totalB.compareTo(totalA);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

        double padding = isMobile
            ? 14
            : isTablet
            ? 22
            : 32;
        double fontSize = isMobile
            ? 16
            : isTablet
            ? 16
            : 19;
        return Scaffold(
          backgroundColor: Color(0xFFF0F2F5),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFF0F2F5),
            foregroundColor: Colors.black,
            scrolledUnderElevation: 0,
            title: Text(
              "Reports",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 1.5,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsetsGeometry.only(right: 5),
                child: PopupMenuButton<int>(
                  icon: const Icon(Icons.file_download, size: 26),
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (v) async {
                    if (v == 1) {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No data available to download report",
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      await ReportPdf.onDownloadReport(
                        items.cast<InvoiceModel>(),
                      );

                      // ✅ SUCCESS MESSAGE AFTER SAVE
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Report downloaded successfully"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 22,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text("Download PDF"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<String>(
                      elevation: 4,
                      color: Colors.white,
                      onSelected: (v) {
                        setState(() => reportType = v);
                        _applyReportType();
                      },
                      itemBuilder: (context) => [
                        _simpleItem("All", "All Report"),
                        _simpleItem("Weekly", "Weekly Report"),
                        _simpleItem("Monthly", "Monthly Report"),
                        _simpleItem("Yearly", "Yearly Report"),
                        _simpleItem("Custom", "Custom Report"),
                      ],
                      child: Row(
                        children: [
                          Text(
                            "$reportType Report",
                            style: TextStyle(
                              color: Color(0xFF982014),
                              fontWeight: FontWeight.w600,
                              fontSize: fontSize,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF982014),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      elevation: 4,
                      color: Colors.white,
                      onSelected: _applyFilter,
                      itemBuilder: (context) => [
                        _simpleItem(
                          "date",
                          "Date Wise",
                          icon: Icons.date_range,
                        ),
                        _simpleItem(
                          "customer",
                          "Customer Wise",
                          icon: Icons.person,
                        ),
                        _simpleItem(
                          "amount",
                          "Amount Wise",
                          icon: Icons.currency_rupee,
                        ),
                      ],
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF982014),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // CUSTOMER DROPDOWN
              if (selectedFilter == "customer")
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      underline: SizedBox(),
                      hint: Text("Select Customer"),
                      value: selectedCustomer,
                      items: customerList
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCustomer = value;

                          items = allFilteredItems
                              .where(
                                (e) =>
                                    e.billTo.trim().split('\n').first ==
                                    selectedCustomer,
                              )
                              .toList();
                        });
                      },
                    ),
                  ),
                ),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 72,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No Reports Found",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try changing filters or date range",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : MasonryGridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        crossAxisCount: isMobile
                            ? 1
                            : isTablet
                            ? 2
                            : 3,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final invoice = items[index];
                          final companyName = invoice.billTo
                              .trim()
                              .split('\n')
                              .first;

                          return Column(
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  companyName,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  invoice.date,
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                trailing: Text(
                                  "${invoice.currencySymbol ?? '\$'} ${invoice.total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF009A75),
                                  ),
                                ),
                              ),
                              const Divider(height: 0),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _simpleItem(
    String value,
    String label, {
    IconData? icon,
  }) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.black87),
            SizedBox(width: 14),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
