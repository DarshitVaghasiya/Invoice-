import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:uuid/uuid.dart';

class AddBankAccount extends StatefulWidget {
  final BankAccountModel? existing;

  const AddBankAccount({super.key, this.existing});

  @override
  State<AddBankAccount> createState() => _AddBankAccountState();
}

class _AddBankAccountState extends State<AddBankAccount> {
  final _formKey = GlobalKey<FormState>();

  final bankNameController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiController = TextEditingController();

  bool isPrimary = false;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      bankNameController.text = widget.existing!.bankName;
      accountHolderController.text = widget.existing!.accountHolder;
      accountNumberController.text = widget.existing!.accountNumber;
      ifscController.text = widget.existing!.ifsc;
      upiController.text = widget.existing!.upi;
      isPrimary = widget.existing!.isPrimary;
    }
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final bankAccount = BankAccountModel(
      id: widget.existing?.id ?? uuid.v4(),
      bankName: bankNameController.text,
      accountHolder: accountHolderController.text,
      accountNumber: accountNumberController.text,
      ifsc: ifscController.text,
      upi: upiController.text,
      isPrimary: isPrimary,
    );

    final profile = AppData().profile!.bankAccounts;

    if (profile != null) {
      if (widget.existing != null) {
        final index = profile.indexWhere((b) => b.id == widget.existing!.id);
        if (index != -1) profile[index] = bankAccount;
      }
      if (bankAccount.isPrimary) {
        for (var b in profile) {
          if (b.id != bankAccount.id) b.isPrimary = false;
        }
      }
    }

    Navigator.pop(context, bankAccount);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;
    final double spacing = isMobile
        ? 14
        : isTablet
        ? 18
        : 24;
    final double horizontalPadding = isMobile
        ? 18
        : isTablet
        ? 32
        : 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Text(
          widget.existing == null ? "Add Bank Account" : "Edit Bank Account",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!isMobile)
            CustomIconButton(
              label: "Save",
              icon: Icons.save_rounded,
              textColor: Colors.white,
              backgroundColor: const Color(0xFF009A75),
              onTap: _saveBankAccount,
              fontSize: 20,
              iconSize: 26,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            ),
          PopupMenuButton<int>(
            color: Colors.white,
            icon: const Text("︙", style: TextStyle(fontSize: 22)),
            onSelected: (value) {
              if (value == 1) Navigator.pop(context, "primary");
              if (value == 2) Navigator.pop(context, "delete");
            },
            itemBuilder: (context) => [
              if (widget.existing?.isPrimary == false)
                const PopupMenuItem(value: 1, child: Text("Set Primary")),
              const PopupMenuItem(value: 2, child: Text("Remove Account")),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: spacing,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: EdgeInsets.all(spacing * 1.6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 18 : 26),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFA5E6D7), Color(0xFF009A75)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: isMobile ? 40 : 55,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.existing == null
                            ? "Bank Account Details"
                            : "Update Your Bank Details",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Provide the required information to continue",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spacing * 2),

                const Text(
                  "Account Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 12),

                // Form Card + Responsive LayoutBuilder
                Container(
                  padding: EdgeInsets.fromLTRB(25, 30, 25, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double w = constraints.maxWidth;
                        int columns = w < 600 ? 1 : 2; // Option-B

                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: w < 600 ? 6.5 : 6.8,
                              ),
                          children: [
                            textFormField(
                              labelText: "Bank Name",
                              controller: bankNameController,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter bank name" : null,
                            ),
                            textFormField(
                              labelText: "Account Holder Name",
                              controller: accountHolderController,
                              validator: (v) => v!.isEmpty
                                  ? "Enter account holder name"
                                  : null,
                            ),
                            textFormField(
                              labelText: "Account Number",
                              controller: accountNumberController,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter account number" : null,
                            ),
                            textFormField(
                              labelText: "IFSC Code",
                              controller: ifscController,
                              validator: (v) =>
                                  v!.isEmpty ? "Enter IFSC code" : null,
                            ),
                            textFormField(
                              labelText: "UPI ID (Optional)",
                              controller: upiController,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: isMobile
          ? Container(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
              child: CustomElevatedButton(
                label: "Save Bank Details",
                icon: Icons.save_rounded,
                backgroundColor: const Color(0xFF009A75),
                onPressed: _saveBankAccount,
              ),
            )
          : null,
    );
  }
}
