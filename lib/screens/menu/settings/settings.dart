import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/settings_model.dart';
import 'package:invoice/screens/menu/settings/Signature/signature.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'edit_invoice_title/edit_invoice_title.dart';
import 'setting_tiles/settings_tiles.dart' show SettingTile;
import 'Templates/templates.dart';

Future<void> saveSettings(SettingsModel settings) async {
  AppData().settings = settings;
  print("✅ Settings updated & saved globally: ${settings.toJson()}");
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsModel? settings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedSettings = AppData().settings;
    const defaultTemplate = "Simple";

    settings = SettingsModel(
      showTax: loadedSettings.showTax,
      showPurchaseNo: loadedSettings.showPurchaseNo,
      showBank: loadedSettings.showBank,
      showNotes: loadedSettings.showNotes,
      showTerms: loadedSettings.showTerms,
      selectedTemplate: loadedSettings.selectedTemplate.isEmpty
          ? defaultTemplate
          : loadedSettings.selectedTemplate,
      descTitle: loadedSettings.descTitle,
      qtyTitle: loadedSettings.qtyTitle,
      rateTitle: loadedSettings.rateTitle,
    );

    if (loadedSettings.selectedTemplate.isEmpty) {
      AppData().settings = settings!;
    }

    setState(() => isLoading = false);
  }

  Future<void> openFAQ() async {
    try {
      final byteData = await rootBundle.load('assets/PDF/FAQ.pdf');
      final file = File('${(await getTemporaryDirectory()).path}/AppInfo.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await OpenFilex.open(file.path);
    } catch (e) {
      print("Error opening FAQ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Scaling factors based on screen width
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1000;

    double horizontalPadding = screenWidth * 0.05; // 5% of width
    double verticalPadding = screenHeight * 0.03; // 3% of height
    double spacing = screenHeight * 0.02; // 2% of height

    double titleFontSize = isMobile
        ? screenWidth * 0.06
        : isTablet
        ? screenWidth * 0.04
        : screenWidth * 0.03;

    int crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    double childAspectRatio = screenWidth < 400
        ? 4.5
        : isMobile
        ? 5
        : isTablet
        ? 3.5
        : 3.8;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
                children: [
                  SettingTile(
                    title: "Choose Invoice Template",
                    subtitle: settings?.selectedTemplate,
                    icon: Icons.description_outlined,
                    onTap: () async {
                      final selectedName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InvoiceTemplates(),
                        ),
                      );
                      if (selectedName != null) {
                        setState(
                          () => settings?.selectedTemplate = selectedName,
                        );
                        await saveSettings(settings!);
                      }
                    },
                  ),
                  SettingTile(
                    title: "Change Invoice Form Title",
                    icon: Icons.label_important_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditTitle()),
                      );
                    },
                  ),
                  SettingTile(
                    title: "Tax Information",
                    icon: Icons.percent_outlined,
                    isToggle: true,
                    toggleValue: settings?.showTax ?? false,
                    onToggleChanged: (value) async {
                      setState(() => settings?.showTax = value);
                      await saveSettings(settings!);
                    },
                  ),
                  SettingTile(
                    title: "PO Number",
                    icon: Icons.shopping_bag_outlined,
                    isToggle: true,
                    toggleValue: settings?.showPurchaseNo ?? false,
                    onToggleChanged: (value) async {
                      setState(() => settings?.showPurchaseNo = value);
                      await saveSettings(settings!);
                    },
                  ),
                  SettingTile(
                    title: "Bank Details",
                    icon: Icons.account_balance_outlined,
                    isToggle: true,
                    toggleValue: settings?.showBank ?? false,
                    onToggleChanged: (value) async {
                      setState(() => settings?.showBank = value);
                      await saveSettings(settings!);
                    },
                  ),
                  SettingTile(
                    title: "Notes",
                    icon: Icons.note_outlined,
                    isToggle: true,
                    toggleValue: settings?.showNotes ?? false,
                    onToggleChanged: (value) async {
                      setState(() => settings?.showNotes = value);
                      await saveSettings(settings!);
                    },
                  ),
                  SettingTile(
                    title: "Terms",
                    icon: Icons.gavel_outlined,
                    isToggle: true,
                    toggleValue: settings?.showTerms ?? false,
                    onToggleChanged: (value) async {
                      setState(() => settings?.showTerms = value);
                      await saveSettings(settings!);
                    },
                  ),
               /*   SettingTile(
                    title: "Add Signature",
                    icon: Icons.edit_document,
                    onTap: () async {
                      final existingSignature =
                          AppData().settings.signatureBase64;

                      final String? signatureBase64 = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignatureScreen(
                            initialSignature: existingSignature,
                          ),
                        ),
                      );

                      if (signatureBase64 != null) {
                        setState(() {
                          settings = settings!.copyWith(
                            signatureBase64: signatureBase64,
                          );
                        });
                        await saveSettings(settings!);
                      }
                    },
                  ),
*/
                  SettingTile(
                    title: "FAQ",
                    icon: Icons.info_outline,
                    onTap: openFAQ,
                  ),
                ],
              ),
            ),
    );
  }
}
