import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'add_bank.dart';

class BankAccountListMasonry extends StatefulWidget {
  final List<BankAccountModel> accounts;
  final bool editing;
  final VoidCallback onUpdate;

  const BankAccountListMasonry({
    super.key,
    required this.accounts,
    required this.editing,
    required this.onUpdate,
  });

  @override
  State<BankAccountListMasonry> createState() => _BankAccountListMasonryState();
}

class _BankAccountListMasonryState extends State<BankAccountListMasonry>
    with SingleTickerProviderStateMixin {
  late List<BankAccountModel> accounts;
  late final AnimationController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);
    accounts = AppData().profile!.bankAccounts ?? [];
    setState(() => isLoading = false);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Device-based responsiveness
  bool get isMobile => MediaQuery.of(context).size.width < 600;

  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  bool get isDesktop => MediaQuery.of(context).size.width >= 1100;

  int get crossAxisCount {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3; // desktop
  }

  double get titleSize => isMobile
      ? 20
      : isTablet
      ? 24
      : 28;

  double get cardTitleSize => isMobile
      ? 16.5
      : isTablet
      ? 18
      : 20;

  double get cardHolderSize => isMobile
      ? 14.5
      : isTablet
      ? 15.5
      : 17;

  double get padding => isMobile
      ? 14
      : isTablet
      ? 22
      : 30;

  double _estimatedTileHeight(BankAccountModel b) {
    int filled = 0;
    if (b.bankName.isNotEmpty) filled++;
    if (b.accountHolder.isNotEmpty) filled++;
    if (b.accountNumber.isNotEmpty) filled++;
    if (b.ifsc.isNotEmpty) filled++;
    if (b.upi.isNotEmpty) filled++;
    return 130 + (filled * 22);
  }

  Future<void> _saveToProfile() async {
    AppData().profile!.bankAccounts = accounts;
    await AppData().saveAllData();
    widget.onUpdate();
  }

  Future<void> setPrimaryAccount(int index) async {
    setState(() {
      for (int i = 0; i < accounts.length; i++) {
        accounts[i].isPrimary = (i == index);
      }
    });
    await _saveToProfile();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Bank Accounts',
          style: TextStyle(
            color: Colors.black,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding / 1.4,
          ),
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : accounts.isEmpty
                    ? _emptyState()
                    : MasonryGridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: accounts.length,
                        itemBuilder: (_, index) {
                          final bank = accounts[index];
                          final estimatedHeight = _estimatedTileHeight(bank);
                          final delay = (index * 0.08).clamp(0.0, 0.8);
                          final anim = CurvedAnimation(
                            parent: _controller,
                            curve: Interval(delay, 1.0, curve: Curves.easeOut),
                          );

                          return AnimatedBuilder(
                            animation: anim,
                            builder: (_, child) => Opacity(
                              opacity: anim.value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - anim.value) * 16),
                                child: child,
                              ),
                            ),
                            child: _MasonryGlassCard(
                              bank: bank,
                              editing: widget.editing,
                              height: estimatedHeight,
                              cardTitleSize: cardTitleSize,
                              cardHolderSize: cardHolderSize,
                              onEdit: (updated) async {
                                final i = AppData().profile!.bankAccounts!
                                    .indexWhere((b) => b.id == updated.id);
                                if (i != -1) accounts[i] = updated;
                                await _saveToProfile();
                                await _loadAccounts();
                              },
                              onDelete: () async {
                                setState(() => accounts.removeAt(index));
                                await _saveToProfile();
                                await _loadAccounts();
                              },
                              onSetPrimary: () => setPrimaryAccount(index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBankAccount()),
          );
          if (result != null && result is BankAccountModel) {
            setState(() => accounts.add(result));
            await _saveToProfile();
            await _loadAccounts();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add Bank Account',
          style: TextStyle(
            fontSize: isMobile ? 15 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF009A75),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Colors.black45,
          ),
          const SizedBox(height: 14),
          Text(
            "No bank accounts yet",
            style: TextStyle(
              fontSize: cardTitleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add your bank account or UPI ID to get started.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isMobile ? 13 : 15),
          ),
        ],
      ),
    );
  }
}

//
// ──────────────────────────────────────────────────────────────
// CARD WIDGET
// ──────────────────────────────────────────────────────────────
//
class _MasonryGlassCard extends StatelessWidget {
  final BankAccountModel bank;
  final bool editing;
  final double height;
  final double cardTitleSize;
  final double cardHolderSize;
  final void Function(BankAccountModel updated) onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _MasonryGlassCard({
    required this.bank,
    required this.editing,
    required this.height,
    required this.cardTitleSize,
    required this.cardHolderSize,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF009A75);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddBankAccount(existing: bank)),
        );

        if (!context.mounted) return;

        if (result is BankAccountModel) onEdit(result);
        if (result == "primary") onSetPrimary();
        if (result == "delete") onDelete();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            color: Colors.white,
            child: _content(accent),
          ),
        ),
      ),
    );
  }

  Widget _content(Color accent) {
    String safeLast4(String number) =>
        number.length <= 4 ? number : number.substring(number.length - 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _circle(accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "${bank.bankName} •••• ${safeLast4(bank.accountNumber)}",
                style: TextStyle(
                  fontSize: cardTitleSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          "Account Holder",
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bank.accountHolder,
          style: TextStyle(
            fontSize: cardHolderSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (bank.isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "PRIMARY ACCOUNT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _circle(Color accent) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.95), accent.withOpacity(0.70)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.account_balance_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
