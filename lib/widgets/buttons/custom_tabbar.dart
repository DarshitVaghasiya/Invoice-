import 'package:flutter/material.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/screens/home/quotation_list.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/layout/drawer.dart';

class InvoiceHomeTabPage extends StatefulWidget {
  const InvoiceHomeTabPage({super.key});

  @override
  State<InvoiceHomeTabPage> createState() => _InvoiceHomeTabPageState();
}

class _InvoiceHomeTabPageState extends State<InvoiceHomeTabPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  late TabController _tabController;
  String appBarTitle = "Dashboard";

  String selectedFilter = "all";

  void _applyFilter(String value) {
    setState(() {
      selectedFilter = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          appBarTitle = _tabController.index == 0 ? "Dashboard" : "Quotation";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        final isTablet =
            constraints.maxWidth >= 400 && constraints.maxWidth < 1000;
        final double titleFontSize = isMobile ? 22 : (isTablet ? 26 : 28);
        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFFF0F2F5),
            foregroundColor: Colors.black,
            title: Text(
              appBarTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),

            /// 🔹 Filter Menu
            actions: _tabController.index == 0
                ? [
                    PopupMenuButton<String>(
                      key: _menuKey,
                      color: Colors.white,
                      tooltip: "Filter invoices",
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: _applyFilter,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "all",
                          child: Row(
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 10),
                              Text("All Invoices"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "paid",
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Text("Paid Invoices"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "unpaid",
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined, color: Colors.orange),
                              SizedBox(width: 10),
                              Text("Unpaid Invoices"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "overdue",
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Overdue Invoices"),
                            ],
                          ),
                        ),
                      ],
                      child: CustomIconButton(
                        label: selectedFilter == "all"
                            ? "Filter"
                            : selectedFilter[0].toUpperCase() +
                                  selectedFilter.substring(1),
                        icon: Icons.filter_list_rounded,
                        fontSize: isMobile ? 14 : 18,
                        onTap: () {
                          final dynamic state = _menuKey.currentState;
                          state.showButtonMenu();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                  ]
                : [],

            /// 🔹 Custom TabBar
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(isMobile ? 50 : 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: CustomTabBar(
                  controller: _tabController,
                  fontSize: isMobile ? 15 : 18,
                  height: isMobile ? 50 : 60,
                ),
              ),
            ),
          ),

          drawer: const AppDrawer(),

          /// 🔹 Tab Pages
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              InvoiceListPage(selectedFilter: selectedFilter),
              const QuotationListScreen(),
            ],
          ),
        );
      },
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final double fontSize;
  final double height;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF009A75),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
        tabs: const [
          Tab(text: "Invoice"),
          Tab(text: "Quotation"),
        ],
      ),
    );
  }
}
