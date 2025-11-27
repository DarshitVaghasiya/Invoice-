import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'customer_form.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList>
    with WidgetsBindingObserver {
  List<CustomerModel> customers = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      customers = List<CustomerModel>.from(AppData().customers);
    });
  }

  Future<void> _editCustomer(CustomerModel customer) async {
    final index = customers.indexOf(customer);
    if (index == -1) return;

    // Navigate to form and wait for result (returns updated customer)
    final updatedCustomer = await Navigator.push<CustomerModel?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CustomerForm(existingCustomer: customer, index: index),
      ),
    );

    if (updatedCustomer != null) {
      setState(() {
        // Update the in-memory customer list
        AppData().customers[index] = updatedCustomer;
        customers[index] = updatedCustomer;
      });
    }
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Customers",
      message:
      "Are you sure you want to permanently delete customer? This action cannot be undone.",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      confirmText: "Delete",
      cancelText: "Cancel",
    );

    if (confirmed == true) {
      setState(() {
        customers.remove(customer);
        AppData().customers = List.from(customers);
      });
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
            ? 12
            : isTablet
            ? 20
            : 32;
        double fontSize = isMobile
            ? 13
            : isTablet
            ? 15
            : 17;

        final filteredCustomers = customers.where((c) {
          final name = (c.name ?? "").toLowerCase();
          final email = (c.email ?? "").toLowerCase();
          return name.contains(searchQuery.toLowerCase()) ||
              email.contains(searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: Color(0xFFF0F2F5),
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Color(0xFFF0F2F5),
            foregroundColor: Colors.black,
            title: Text(
              "Customer List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 11,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 16, padding, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade500),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                  ),
                ),
              ),

              // 🧾 Customer List
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: filteredCustomers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No customers found",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: fontSize + 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: MasonryGridView.count(
                            crossAxisCount: isMobile
                                ? 1
                                : isTablet
                                ? 2
                                : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 12,
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              return _buildCustomerCard(customer, fontSize);
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerForm()),
              );
              await _loadCustomers();
            },
            icon: const Icon(Icons.add, size: 28),
            label: const Text(
              "New Customer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF009A75),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerCard(CustomerModel customer, double fontSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00B686).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF009A75), size: 24),
        ),
        title: Text(
          (customer.company.trim().isNotEmpty)
              ? customer.company
              : (customer.name ?? "Unnamed"),
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey.shade500,
        ),
        onTap: () => _editCustomer(customer),
        onLongPress: () => _deleteCustomer(customer),
        splashColor: Colors.transparent,
      ),
    );
  }
}
