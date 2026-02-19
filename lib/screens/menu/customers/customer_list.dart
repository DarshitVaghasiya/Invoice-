import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/Global%20Veriables/global_veriable.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'customer_form.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomer = [];
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      filteredCustomer = customers.where((customer) {
        return customer.company.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _loadCustomers() async {
    customers = List.from(AppData().customers);
    _onSearchChanged(searchQuery);
  }

  Future<void> _editCustomer(CustomerModel customer) async {
    final index = customers.indexOf(customer);
    if (index == -1) return;

    final updatedCustomer = await Navigator.push<CustomerModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerForm(existingCustomer: customer, index: index),
      ),
    );

    if (updatedCustomer != null) {
      setState(() {
        customers[index] = updatedCustomer;
        AppData().customers = List.from(customers);
        _onSearchChanged(searchQuery); // refresh filter
      });
    }
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Customer",
      message: "Are you sure you want to permanently delete this customer?",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      btn3: "Delete",
      btn2: "Cancel",
    );

    if (confirmed == true) {
      setState(() {
        customers.remove(customer);
        AppData().customers = List.from(customers);
        _onSearchChanged(searchQuery); // refresh filter
      });
      await AppData().saveAllData();
    }
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
            ? 13
            : isTablet
            ? 15
            : 17;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),

          /// 🔝 AppBar
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFF0F2F5),
            title: Text(
              "Customers",
              style: TextStyle(
                fontSize: fontSize + 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          /// 📄 Body
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),

              /// 🧾 Customer List / Empty State
              Expanded(
                child: filteredCustomer.isEmpty
                    ? _emptyCustomerState(fontSize)
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          children: [
                            MasonryGridView.count(
                              crossAxisCount: isMobile
                                  ? 1
                                  : isTablet
                                  ? 2
                                  : 3,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredCustomer.length,
                              itemBuilder: (context, index) {
                                return _buildCustomerCard(
                                  filteredCustomer[index],
                                  fontSize,
                                );
                              },
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          /// ➕ FAB
          floatingActionButton: FloatingActionButton.extended(
            elevation: 6,
            backgroundColor: const Color(0xFF009A75),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              "New Customer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              if (!isPurchase && customers.length >= 3) {
                showLimitDialog("Only 3 customers allowed in Free plan.");
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerForm()),
              );
              _loadCustomers();
            },
          ),
        );
      },
    );
  }

  /// 🧩 Customer Card
  Widget _buildCustomerCard(CustomerModel customer, double fontSize) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _editCustomer(customer),
      onLongPress: () => _deleteCustomer(customer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF009A75).withOpacity(0.12),
              child: const Icon(Icons.person_rounded, color: Color(0xFF009A75)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                customer.company.trim().isNotEmpty
                    ? customer.company
                    : (customer.name ?? "Unnamed"),
                style: TextStyle(
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  /// 🚫 Empty State
  Widget _emptyCustomerState(double fontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF009A75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.groups,
                size: 48,
                color: Color(0xFF009A75),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "No customers yet",
              style: TextStyle(
                fontSize: fontSize + 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                "Add your first customer to start managing invoices easily.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
