import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/Global%20Veriables/global_veriable.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/models/settings_model.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/screens/menu/settings/BankAccounts/bank_accounts.dart';
import 'package:invoice/screens/menu/settings/Signature/signature.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'package:invoice/widgets/buttons/custom_tabbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'edit_invoice_title/edit_invoice_title.dart';
import 'setting_tiles/settings_tiles.dart' show SettingTile;
import 'Templates/templates.dart';
import 'package:file_picker/file_picker.dart';

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
  List<BankAccountModel> bankAccounts = [];
  bool isEditing = false;

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
      signatureBase64: loadedSettings.signatureBase64,
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

  Future<void> _importData() async {
    if (!isPurchase) {
      showLimitDialog("Import is available in Premium only.");
      return;
    }

    final selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (selectedFile == null || selectedFile.files.single.path == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ No file selected")));
      return;
    }

    final file = File(selectedFile.files.single.path!);

    // 1️⃣ Check duplicates first
    bool duplicatesExist = await InvoiceStorage.hasDuplicates(file);

    bool userReplaceChoice = false;

    // 2️⃣ Only show Replace / Skip if duplicate exists
    if (duplicatesExist) {
      final result = await showCustomAlertDialog(
        context: context,
        title: "Import Data",
        message:
            "Some records already exist in your system.\nDo you want to replace them or skip your existing ones?",
        btn3: "Replace",
        btn2: "Skip",
        btn1: "Cancel",
        btn3Color: Color(0xFF0072FF),
        btn2Color: Color(0xFF6D6D6D),
        btn1Color: Color(0xFFE53935),
        addButton: true,
      );

      if (result == null) return;
      userReplaceChoice = result;
    }

    // 3️⃣ Import
    final success = await InvoiceStorage.importDataFromJsonFile(
      file: file,
      userChoiceReplace: userReplaceChoice,
      onDataReload: () async {
        await AppData().loadAllData();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceHomeTabPage()),
          );
        }
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "✅ Import Completed" : "❌ Import Failed"),
      ),
    );
  }

  Future<void> _exportData() async {
    if (!isPurchase) {
      showLimitDialog("Export is available in Premium only.");
      return;
    }

    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Export File",
      message: "Are you sure you want to export all data?",
      btn3: "Yes",
      btn2: "No",
      btn3Color: Color(0xFF009A75),
      btn2Color: Colors.red,
    );

    if (confirmed == true) {
      AppData().saveAllData();

      final path = await InvoiceStorage.exportDataToDownloads();
      if (path != null) {
        print("✅ File exported to: $path");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Exported to $path")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ Export failed")));
      }
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
    double verticalPadding = screenWidth * 0.01; // 5% of width
    double spacing = screenHeight * 0.01; // 2% of height

    double titleFontSize = isMobile
        ? screenWidth * 0.06
        : isTablet
        ? screenWidth * 0.03
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
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                    title: "Add Items Fields And Edit Title",
                    icon: Icons.label_important_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditTitle()),
                      );
                    },
                  ),
                  SettingTile(
                    title: "Bank Account",
                    icon: Icons.account_balance_sharp,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BankAccountListMasonry(
                            accounts: bankAccounts,
                            editing: isEditing,
                            onUpdate: () {
                              setState(() {});
                            },
                          ),
                        ),
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
                    icon: Icons.details_outlined,
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
                  SettingTile(
                    title: "Add Signature",
                    icon: Icons.edit_document,
                    onTap: () async {
                      final existingSignature =
                          AppData().settings.signatureBase64;

                      final width = MediaQuery.of(context).size.width;

                      final bool isMobile = width < 600; // 👈 Mobile check

                      // ⭐ Force landscape ONLY for mobile
                      if (isMobile) {
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                      }

                      // Open signature screen
                      final String? signatureBase64 = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignatureScreen(
                            initialSignature: existingSignature,
                          ),
                        ),
                      );

                      // ⭐ Restore portrait ONLY for mobile
                      if (isMobile) {
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      }

                      // Save signature if returned
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
                  SettingTile(
                    title: "Import File",
                    icon: Icons.download_outlined,
                    onTap: _importData,
                  ),
                  SettingTile(
                    title: "Export File",
                    icon: Icons.upload_outlined,
                    onTap: _exportData,
                  ),
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
