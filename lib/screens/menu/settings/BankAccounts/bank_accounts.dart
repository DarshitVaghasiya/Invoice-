// bank_account_list_masonry.dart
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

    setState(() {
      accounts = AppData().profile!.bankAccounts!;
      isLoading = false;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _colsForWidth(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1400) return 3;
    return 4;
  }

  double _estimatedTileHeight(BankAccountModel b, double baseWidth) {
    int filled = 0;
    if (b.bankName.isNotEmpty) filled++;
    if (b.accountHolder.isNotEmpty) filled++;
    if (b.accountNumber.isNotEmpty) filled++;
    if (b.ifsc.isNotEmpty) filled++;
    if (b.upi.isNotEmpty) filled++;
    return 120 + (filled * 20).toDouble();
  }

  // ⭐ FIXED — Save data to AppData().bankAccounts
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

    AppData().profile!.bankAccounts = accounts;
    await AppData().saveAllData();
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final isMobile = width < 600;

    final crossAxisCount = _colsForWidth(width);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Bank Accounts',
          style: TextStyle(
            color: Colors.black,
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 28,
            vertical: isMobile ? 12 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : accounts.isEmpty
                    ? _emptyState(width, height, isMobile)
                    : MasonryGridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        padding: const EdgeInsets.only(bottom: 14),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final bank = accounts[index];
                          final estimatedHeight = _estimatedTileHeight(
                            bank,
                            width,
                          );

                          final start = (index * 0.06).clamp(0.0, 0.8);
                          final anim = CurvedAnimation(
                            parent: _controller,
                            curve: Interval(start, 1.0, curve: Curves.easeOut),
                          );

                          return AnimatedBuilder(
                            animation: anim,
                            builder: (context, child) {
                              final v = anim.value;
                              return Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - v) * 12),
                                  child: Transform.scale(
                                    scale: 0.98 + (v * 0.02),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _MasonryGlassCard(
                              bank: bank,
                              editing: widget.editing,
                              height: estimatedHeight,
                              onEdit: (updated) async {
                                final i = AppData().profile!.bankAccounts!.indexWhere(
                                  (b) => b.id == updated.id,
                                );
                                if (i != -1) {
                                  AppData().profile!.bankAccounts![i] = updated;
                                }
                                await AppData().saveAllData();
                                await _loadAccounts();
                                widget.onUpdate();
                              },
                              onDelete: () async {
                                // ← NEW
                                setState(() {
                                  accounts.removeAt(index);
                                });
                                AppData().profile!.bankAccounts = accounts;
                                await AppData().saveAllData();
                                await _loadAccounts();
                                widget.onUpdate();
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

      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBankAccount()),
              );

              if (result != null && result is BankAccountModel) {
                setState(() {
                  accounts.add(result);
                });
                await _saveToProfile(); // (instead of manually adding + saving)
                await _loadAccounts();
                widget.onUpdate();

              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Bank Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF009A75),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(double w, double h, bool isMobile) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isMobile ? 120 : 140,
            height: isMobile ? 120 : 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.06),
                  Colors.black.withOpacity(0.02),
                ],
              ),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Center(
                child: Icon(
                  Icons.account_balance,
                  color: Colors.black,
                  size: isMobile ? 46 : 56,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No bank accounts yet',
            style: TextStyle(
              color: Colors.black,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your bank account or UPI ID to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
/// CARD WIDGET
/// ------------------------------------------------------
class _MasonryGlassCard extends StatelessWidget {
  final BankAccountModel bank;
  final bool editing;
  final double height;
  final void Function(BankAccountModel updated) onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const _MasonryGlassCard({
    required this.bank,
    required this.editing,
    required this.height,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF009A75);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.60),
                  Colors.white.withOpacity(0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBankAccount(existing: bank),
                ),
              );

              if (!context.mounted) return; // safety

              if (result is BankAccountModel) {
                onEdit(result); // ← update edited bank
              } else if (result == "primary") {
                onSetPrimary(); // ← set it as primary
              } else if (result == "delete") {
                onDelete(); // ← NEW
              }
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: _buildCardContent(accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(Color accent) {
    String safeLast4(String number) {
      if (number.length <= 4) return number;
      return number.substring(number.length - 4);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleAvatar(bank.bankName, accent),
              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  "${bank.bankName} •••• ${safeLast4(bank.accountNumber)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            "Account Holder",
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            bank.accountHolder,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          if (bank.isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF009A75).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  Widget _circleAvatar(String name, Color accent) {
    return Container(
      width: 58,
      height: 58,
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
