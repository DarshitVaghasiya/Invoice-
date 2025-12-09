import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:invoice/Global Veriables/global_veriable.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final String _productId = 'invoice_premium_lifetime';
  late bool available;
  List<ProductDetails> products = [];
  bool isPurchased = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    _initializePurchase();

    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseList) {
        _handlePurchase(purchaseList);
      },
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint("Purchase Stream Error: $error");
      },
    );
  }

  Future<void> _initializePurchase() async {
    available = await _inAppPurchase.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({_productId});
    products = response.productDetails;
  }

  Future<void> _proceed() async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product not available. Please try again later."),
        ),
      );
      return;
    }

    // Loader popup
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0072FF)),
      ),
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: products.first,
    );
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _inAppPurchase.purchaseStream.listen((purchaseList) {
      _handlePurchase(purchaseList);
    });
  }

  void _handlePurchase(List<PurchaseDetails> purchaseList) async {
    for (var purchase in purchaseList) {
      if (purchase.status == PurchaseStatus.purchased) {
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase); // acknowledgement
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isPurchase", true);
        isPurchase = true;

        if (!mounted) return;
        Navigator.pop(context);
        _successDialog();
      } else if (purchase.status == PurchaseStatus.error) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Payment Failed")));
      }
    }
  }

  Future<void> restorePurchase() async {
    await _inAppPurchase.restorePurchases();
  }

  void _successDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(
          Icons.check_circle,
          size: 60,
          color: Color(0xFF0072FF),
        ),
        content: const Text(
          "Payment Successful!\nPremium Lifetime Activated 🎉",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0072FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text(
              "Continue",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1000;

    double horizontalPadding = screenWidth * 0.05; // 5% of width

    double buttonFontSize = isMobile
        ? screenWidth * 0.06
        : isTablet
        ? screenWidth * 0.015
        : screenWidth * 0.03;

    double titleFontSize = isMobile
        ? screenWidth * 0.06
        : isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.03;

    double subtitleFont = isMobile
        ? screenWidth * 0.05
        : isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.02;

    double priceFont = isMobile
        ? screenWidth * 0.08
        : isTablet
        ? screenWidth * 0.03
        : screenWidth * 0.03;

    double featureFont = isMobile
        ? screenWidth * 0.045
        : isTablet
        ? screenWidth * 0.02
        : screenWidth * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF6FF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Upgrade",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEEF6FF),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        actions: isMobile
            ? null
            : [
                CustomIconButton(
                  label: "Restore Purchase",
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  borderColor: Colors.black,
                  textColor: Colors.black,
                  fontSize: buttonFontSize,
                  onTap: restorePurchase,
                ),
                SizedBox(width: 10),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: CustomIconButton(
                    label: "Proceed",
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    fontSize: buttonFontSize,
                    onTap: _proceed,
                  ),
                ),
              ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              isMobile
                  ? const SizedBox(height: 10)
                  : const SizedBox(height: 20),
              Text(
                "Upgrade once, unlock everything forever",
                style: TextStyle(
                  fontSize: subtitleFont,
                  color: Colors.black45,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),

              isMobile ? SizedBox(height: 25) : SizedBox(height: 40),
              isMobile
                  ? Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double h = constraints.maxHeight;
                          double w = constraints.maxWidth;

                          bool isSmall = h < 580 || w < 300;

                          double priceSize = isSmall ? 26 : 30;
                          double lifetimeSize = isSmall ? 16 : 20;
                          double featureSize = isSmall ? 14 : 17;
                          double spacing = isSmall ? 6 : 12;
                          double padding = isSmall ? 16 : 20;

                          return Column(
                            children: [
                              // IMAGE
                              Container(
                                height: isSmall ? h * 0.35 : h * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.12),
                                      blurRadius: 25,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.asset(
                                    "assets/icons/plan.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              SizedBox(height: spacing * 3),

                              // PRICING CARD (NO SCROLL + FIT TO SCREEN)
                              Container(
                                height: isSmall ? h * 0.6 : h * 0.50,
                                width: double.infinity,
                                padding: EdgeInsets.all(padding),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.96),
                                      Colors.blue.shade50.withOpacity(0.45),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 1.6,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade200.withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "₹ 500",
                                          style: TextStyle(
                                            fontSize: priceSize,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0072FF),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Lifetime",
                                          style: TextStyle(
                                            fontSize: lifetimeSize,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0072FF),
                                          ),
                                        ),
                                      ],
                                    ),

                                    _feature(
                                      "Unlimited Invoice Generate",
                                      featureSize,
                                    ),
                                    _feature(
                                      "Backup & Restore your data",
                                      featureSize,
                                    ),
                                    _feature(
                                      "All Invoice Templates Included",
                                      featureSize,
                                    ),
                                    _feature(
                                      "Unlimited Customers",
                                      featureSize,
                                    ),
                                    _feature(
                                      "Unlimited Items / Products",
                                      featureSize,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.4,
                      children: [
                        // IMAGE
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.12),
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Image.asset(
                                "assets/icons/plan.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // PRICING CONTAINER
                        Container(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.90),
                                Colors.blue.shade50.withOpacity(0.55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "₹ 499",
                                    style: TextStyle(
                                      fontSize: priceFont,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0072FF),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Lifetime",
                                    style: TextStyle(
                                      fontSize: isTablet ? 22 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0072FF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _feature(
                                "Unlimited invoice generate",
                                featureFont,
                              ),
                              _feature(
                                "Backup or restore your data",
                                featureFont,
                              ),
                              _feature(
                                "All invoice templates included",
                                featureFont,
                              ),
                              _feature("Add unlimited customers", featureFont),
                              _feature(
                                "Add unlimited items / products",
                                featureFont,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? LayoutBuilder(
              builder: (context, constraints) {
                double h =
                    constraints.maxHeight; // available height in bottom area
                double screenH = MediaQuery.of(context).size.height;

                bool isSmallScreen =
                    screenH < 770; // below 700px mobile → small

                double vertical = isSmallScreen ? 15 : 5;
                double buttonPadding = isSmallScreen ? 12 : 15;
                double fontSize = isSmallScreen ? 15 : 17;
                double spacing = isSmallScreen ? 8 : 10;

                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: vertical,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomElevatedButton(
                          label: "Proceed",
                          fontSize: fontSize,
                          borderRadius: BorderRadius.circular(12),
                          padding: EdgeInsets.symmetric(
                            vertical: buttonPadding,
                          ),
                          onPressed: _proceed,
                        ),
                        SizedBox(height: spacing),
                        CustomElevatedButton(
                          label: "Restore Purchase",
                          fontSize: fontSize,
                          borderColor: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          padding: EdgeInsets.symmetric(
                            vertical: buttonPadding,
                          ),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.black,
                          onPressed: restorePurchase,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _feature(String text, double font) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0072FF),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.check, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: font,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
