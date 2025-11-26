import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

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
  late List<BankAccountModel> accounts;

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

  String generateTimestampId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final bankAccount = BankAccountModel(
      id: widget.existing?.id ?? generateTimestampId(),
      bankName: bankNameController.text.trim(),
      accountHolder: accountHolderController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      ifsc: ifscController.text.trim(),
      upi: upiController.text.trim(),
      isPrimary: isPrimary,
    );

    final appData = AppData();
    final profile = appData.profile!.bankAccounts; // ⬅ profile is a single ProfileModel

    if (profile != null) {
      // Editing existing bank account
      if (widget.existing != null) {
        final index = profile.indexWhere(
          (b) => b.id == widget.existing!.id,
        );
        if (index != -1) {
          profile[index] = bankAccount;
        }
      } else {
        // Adding new bank
        profile.add(bankAccount);
      }

      // Ensure only ONE primary
      if (bankAccount.isPrimary) {
        for (var b in profile) {
          if (b.id != bankAccount.id) b.isPrimary = false;
        }
      }
    }
    print(profile);
    Navigator.pop(context, bankAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Text(
          widget.existing == null ? "Add Bank Account" : "Edit Bank Account",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            color: const Color(0xFFF0F2F5),
            icon: const Text(
              "︙",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            onSelected: (value) async {
              if (value == 1) {
                Navigator.pop(context, "primary");
              } else if (value == 2) {
                if (widget.existing == null) {
                  await showCustomAlertDialog(
                    context: context,
                    title: "Cannot Delete",
                    message:
                        "Please add bank details before deleting this account.",
                    icon: Icons.info_outline,
                    iconColor: Colors.blueAccent,
                    singleButton: true,
                    confirmColor: Color(0xFF009A75),
                  );
                  return;
                }
                final confirm = await showCustomAlertDialog(
                  context: context,
                  title: "Delete Account",
                  message: "Are you sure you want to delete this account?",
                );

                if (confirm == true) {
                  Navigator.pop(context, "delete"); // return delete signal
                }
              }
            },

            itemBuilder: (context) => [
              if (widget.existing != null &&
                  widget.existing!.isPrimary == false)
                const PopupMenuItem(value: 1, child: Text("Set Primary")),

              const PopupMenuItem(value: 2, child: Text("Remove Account")),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TOP HEADER CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF80CBC4), Color(0xFF009688)],
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.existing == null
                        ? "Bank Account Details"
                        : "Update Your Bank Details",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Please fill in the necessary information",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FORM CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    textFormField(
                      labelText: "Bank Name",
                      controller: bankNameController,
                      validator: (v) => v!.isEmpty ? "Enter bank name" : null,
                    ),
                    const SizedBox(height: 15),

                    textFormField(
                      labelText: "Account Holder Name",
                      controller: accountHolderController,
                      validator: (v) =>
                          v!.isEmpty ? "Enter account holder name" : null,
                    ),
                    const SizedBox(height: 15),

                    textFormField(
                      labelText: "Account Number",
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? "Enter account number" : null,
                    ),
                    const SizedBox(height: 15),

                    textFormField(
                      labelText: "IFSC Code",
                      controller: ifscController,
                      validator: (v) => v!.isEmpty ? "Enter IFSC code" : null,
                    ),
                    const SizedBox(height: 15),

                    textFormField(
                      labelText: "UPI ID (Optional)",
                      controller: upiController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: CustomElevatedButton(
          label: "Save Bank Details",
          icon: Icons.save_rounded,
          color: const Color(0xFF009A75),
          onPressed: _saveBankAccount,
        ),
      ),
    );
  }
}
