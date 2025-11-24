// bank_account_list_masonry.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
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
    accounts = List.from(widget.accounts);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // slight delay so page has time to paint
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
      setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // helper: returns adaptive cross axis count for masonry
  int _colsForWidth(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1400) return 3;
    return 4;
  }

  // Generates a small variable height for masonry look (based on content length)
  double _estimatedTileHeight(BankAccountModel b, double baseWidth) {
    // base roughly on number of non-empty fields
    int filled = 0;
    if (b.bankName.isNotEmpty) filled++;
    if (b.accountHolder.isNotEmpty) filled++;
    if (b.accountNumber.isNotEmpty) filled++;
    if (b.ifsc.isNotEmpty) filled++;
    if (b.upi.isNotEmpty) filled++;

    // return a height that varies between ~140 and ~220
    return 120 + (filled * 20).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // screen measurement
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
        scrolledUnderElevation: 0,
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
              // Body
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : accounts.isEmpty
                    ? _emptyState(width, height, isMobile)
                    : MasonryGridView.count(
                        // Masonry grid settings
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        // padding inside grid
                        padding: EdgeInsets.only(bottom: 14),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final bank = accounts[index];
                          // estimate height based on content (dynamic)
                          final estimatedHeight = _estimatedTileHeight(
                            bank,
                            width / crossAxisCount,
                          );

                          // Animate each child with a stagger offset
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
                              onEdit: (updated) {
                                setState(() => accounts[index] = updated);
                                widget.onUpdate();
                              },
                              onDelete: () {
                                setState(() => accounts.removeAt(index));
                                widget.onUpdate();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Floating button with subtle blur/glass
      floatingActionButton: (accounts.isEmpty)
          ? null
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddBankAccount()),
                    );

                    if (result != null && result is BankAccountModel) {
                      setState(() => accounts.add(result));
                      widget.onUpdate();
                      _controller.forward(from: 0);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Bank Account'),
                  backgroundColor: Color(0xFF009A75),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
    );
  }

  // Empty state UI
  Widget _emptyState(double w, double h, bool isMobile) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // soft glass bulb
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
          Text(
            'Add your bank account or UPI ID to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBankAccount()),
              );
              if (result != null && result is BankAccountModel) {
                setState(() => accounts.add(result));
                widget.onUpdate();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Bank Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.08),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single masonry glass card (dynamic height)
class _MasonryGlassCard extends StatelessWidget {
  final BankAccountModel bank;
  final bool editing;
  final double height;
  final void Function(BankAccountModel updated) onEdit;
  final VoidCallback onDelete;

  const _MasonryGlassCard({
    required this.bank,
    required this.editing,
    required this.height,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Colors.teal.shade400;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // background glass
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.04),
                  Colors.black.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
          ),

          // blur + content
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              // slight tint for readability
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: avatar + bank name + masked number
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              accent.withOpacity(0.95),
                              accent.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (bank.bankName.isNotEmpty ? bank.bankName[0] : 'B')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bank.bankName.isEmpty
                              ? 'Unnamed Bank'
                              : bank.bankName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        bank.accountNumber.isNotEmpty
                            ? '**** ${bank.accountNumber.length >= 4 ? bank.accountNumber.substring(bank.accountNumber.length - 4) : bank.accountNumber}'
                            : '',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // body info (wrap so card height adapts)
                  Text(
                    'Name: ${bank.accountHolder}',
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),


                  // actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomIconButton(
                        icon: Icons.edit_outlined,
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddBankAccount(existing: bank),
                            ),
                          );
                          if (updated != null && updated is BankAccountModel)
                            onEdit(updated);
                        },
                      ),
                      const SizedBox(width: 8),
                      // delete
                      CustomIconButton(
                        icon: Icons.delete_outline,
                        textColor: Colors.red,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
