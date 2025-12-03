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

    // ── Modern RESPONSIVE BREAKPOINTS ─────────────────────────────────────
    final isSmallMobile = width < 400; // 360 width phones
    final isLargeMobile = width >= 400 && width < 600; // 420 wide phones
    final isMobile = width < 600; // common flag for logic
    final isTablet = width >= 600 && width < 1100;
    final isDesktop = width >= 1100;

    final double titleFont = isSmallMobile
        ? 22
        : isLargeMobile
        ? 25
        : isTablet
        ? 30
        : 34;
    final double cardTitleFont = isSmallMobile
        ? 20
        : isLargeMobile
        ? 22
        : isTablet
        ? 24
        : 26;

    final double spacing = isSmallMobile
        ? 12
        : isLargeMobile
        ? 14
        : isTablet
        ? 20
        : 26;
    final double horizontalPadding = isSmallMobile
        ? 14
        : isLargeMobile
        ? 20
        : isTablet
        ? 32
        : 60;

    final int formGridColumns = isMobile
        ? 1
        : isTablet
        ? 1
        : 2;

    final double iconSize = isSmallMobile
        ? 35
        : isLargeMobile
        ? 40
        : 50;

    // ─────────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Text(
          widget.existing == null ? "Add Bank Account" : "Edit Bank Account",
          style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF0F2F5),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!isMobile)
            CustomIconButton(
              label: "Save",
              icon: Icons.save_rounded,
              textColor: Colors.white,
              iconSize: titleFont,
              fontSize: 22,
              backgroundColor: const Color(0xFF009A75),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              onTap: _saveBankAccount,
            ),
          PopupMenuButton<int>(
            color: Colors.white,
            icon: Text("︙", style: TextStyle(fontSize: isMobile ? 22 : 26)),
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── PROFILE HEADER CARD ────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(spacing * 1.6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 18 : 28),
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
                          size: iconSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.existing == null
                            ? "Bank Account Details"
                            : "Update Your Bank Details",
                        style: TextStyle(
                          fontSize: cardTitleFont,
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

                Text(
                  "Account Information",
                  style: TextStyle(
                    fontSize: isMobile ? 19 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                // ── FORM CARD ─────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(isMobile ? 18 : spacing),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: formGridColumns,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: isMobile ? 6.5 : 6.8,
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
                          validator: (v) =>
                              v!.isEmpty ? "Enter account holder name" : null,
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
