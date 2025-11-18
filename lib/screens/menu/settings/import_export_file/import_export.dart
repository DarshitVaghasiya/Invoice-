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
                   /* _buildActionButton(
                      label: "Export File",
                      icon: Icons.upload_file_outlined,
                      color: Colors.blueAccent,
                      onPressed: () async {
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

                          final path =
                              await InvoiceStorage.exportDataToDownloads();
                          if (path != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("✅ Exported to $path")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("❌ Export failed")),
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildActionButton(
                      label: "Import File",
                      icon: Icons.download_outlined,
                      color: Colors.green,
                      onPressed: () async {
                        setState(() => isProcessing = true);

                        final success = await InvoiceStorage.importDataFromJsonFile(
                          onDataReload: () async {
                            // Reload data into AppData (your global data holder)
                            final allData = await InvoiceStorage.loadAll();
                            AppData().customers = allData["customers"];
                            AppData().invoices = allData["invoices"];
                            AppData().items = allData["items"];
                            AppData().profile = allData["profile"];
                            AppData().settings = allData["settings"];

                            setState(() {}); // 🔄 Refresh UI
                          },
                        );

                        setState(() => isProcessing = false);

                        if (success) {
                          // ✅ Import succeeded → go to list page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvoiceListPage(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // ❌ Import failed → show error, stay on same screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "❌ Import failed",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),*/
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
