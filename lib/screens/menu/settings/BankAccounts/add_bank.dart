import 'package:flutter/material.dart';
import 'package:invoice/models/bank_account_model.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      bankNameController.text = widget.existing!.bankName;
      accountHolderController.text = widget.existing!.accountHolder;
      accountNumberController.text = widget.existing!.accountNumber;
      ifscController.text = widget.existing!.ifsc;
      upiController.text = widget.existing!.upi;
    }
  }

  String generateTimestampId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: Text(
          widget.existing == null ? "Add Bank Account" : "Edit Bank Account",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textFormField(
                labelText: "Bank Name",
                controller: bankNameController,
                validator: (v) => v!.isEmpty ? "Enter bank name" : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              textFormField(
                labelText: "Account Holder Name",
                controller: accountHolderController,
                validator: (v) =>
                v!.isEmpty ? "Enter account holder name" : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              textFormField(
                labelText: "Account Number",
                controller: accountNumberController,
                validator: (v) => v!.isEmpty ? "Enter account number" : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              textFormField(
                labelText: "IFSC Code",
                controller: ifscController,
                validator: (v) => v!.isEmpty ? "Enter IFSC" : null,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              textFormField(
                labelText: "UPI ID",
                controller: upiController,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: CustomElevatedButton(
          label: "Save",
          icon: Icons.save,
          color: const Color(0xFF009A75),
          onPressed: _saveBankAccount,
        ),
      ),
    );
  }

  void _saveBankAccount() {
    if (!_formKey.currentState!.validate()) return;

    final bankAccount = BankAccountModel(
      id: widget.existing?.id ?? generateTimestampId(), // keep old ID if editing
      bankName: bankNameController.text.trim(),
      accountHolder: accountHolderController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      ifsc: ifscController.text.trim(),
      upi: upiController.text.trim(),
    );

    Navigator.pop(context, bankAccount);
  }
}
