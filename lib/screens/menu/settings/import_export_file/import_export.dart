/*
import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';

class ImportExportFile extends StatefulWidget {
  const ImportExportFile({super.key});

  @override
  State<ImportExportFile> createState() => _ImportExportFileState();
}

class _ImportExportFileState extends State<ImportExportFile> {
  bool isProcessing = false;

  Future<void> _importData() async {
    // First pick the JSON file
    final selectedFile = await InvoiceStorage.pickJsonFile();
    if (selectedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ No file selected")));
      return;
    }

    // Step 1 → Ask Append or Overwrite
    final type = await showCustomAlertDialog(
      context: context,
      title: "Import Data",
      message: "How do you want to import data?",
      confirmText: "Overwrite",
      cancelText: "Append",
      confirmColor: Colors.red,
      cancelColor: Colors.blue,
    );

    if (type == null) return;

    bool overwrite = type == true;

    // Step 2 → Confirmation Dialog
    final confirm = await showCustomAlertDialog(
      context: context,
      title: overwrite ? "Overwrite Data" : "Append Data",
      message: overwrite
          ? "⚠ This will delete all current data and replace with file.\nAre you sure?"
          : "New data will be merged with existing data.\nContinue?",
      confirmText: "Confirm",
      cancelText: "Cancel",
      confirmColor: Colors.green,
      cancelColor: Colors.red,
    );

    if (confirm != true) return;

    // Process Import
    setState(() => isProcessing = true);

    final success = await InvoiceStorage.importDataFromJsonFile(
      filePath: selectedFile, // <-- send file path
      overwrite: overwrite,
      onDataReload: () async {
        final all = await InvoiceStorage.loadAll();
        AppData().customers = all["customers"];
        AppData().invoices = all["invoices"];
        AppData().items = all["items"];
        AppData().bankAccounts = all["bankAccounts"];
        AppData().profile = all["profile"];
        AppData().settings = all["settings"];
        setState(() {});
      },
    );

    setState(() => isProcessing = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const InvoiceListPage()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Import failed"), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> _exportData() async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Export File",
      message: "Are you sure you want to export all data?",
      confirmText: "Yes",
      cancelText: "No",
      confirmColor: Colors.green,
      cancelColor: Colors.red,
    );

    if (confirmed == true) {
      AppData().saveAllData();

      final path = await InvoiceStorage.exportDataToDownloads();
      if (path != null) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Import and Export File",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: isProcessing
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      label: "Export File",
                      icon: Icons.upload_file_outlined,
                      color: Colors.blueAccent,
                      onPressed: _exportData,
                    ),

                    const SizedBox(height: 20),
                    _buildActionButton(
                      label: "Import File",
                      icon: Icons.download_outlined,
                      color: Colors.green,
                      onPressed: _importData
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
*/
