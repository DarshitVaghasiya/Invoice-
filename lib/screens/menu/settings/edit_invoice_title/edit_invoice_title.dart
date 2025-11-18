import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

class EditTitle extends StatefulWidget {
  const EditTitle({super.key});

  @override
  State<EditTitle> createState() => _EditTitleState();
}

class _EditTitleState extends State<EditTitle> {
  TextEditingController? descController;
  TextEditingController? qtyController;
  TextEditingController? rateController;

  // bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // Load runtime settings from AppData (model only, not from JSON)
    final settings = AppData().settings;

    // ✅ Default titles
    const defaultDesc = "Product";
    const defaultQty = "Qty";
    const defaultRate = "Price";

    // Initialize controllers
    descController = TextEditingController(
      text: settings.descTitle.isNotEmpty ? settings.descTitle : defaultDesc,
    );
    qtyController = TextEditingController(
      text: settings.qtyTitle.isNotEmpty ? settings.qtyTitle : defaultQty,
    );
    rateController = TextEditingController(
      text: settings.rateTitle.isNotEmpty ? settings.rateTitle : defaultRate,
    );

    // ✅ Update model if empty (not JSON yet)
    if (settings.descTitle.isEmpty ||
        settings.qtyTitle.isEmpty ||
        settings.rateTitle.isEmpty) {
      AppData().settings = settings.copyWith(
        descTitle: defaultDesc,
        qtyTitle: defaultQty,
        rateTitle: defaultRate,
      );
    }

    //setState(() => isLoading = false);
  }

  Future<void> _saveTitles() async {
    // ✅ Update runtime model class (not JSON)
    AppData().settings = AppData().settings.copyWith(
      descTitle: descController?.text,
      qtyTitle: qtyController?.text,
      rateTitle: rateController?.text,
    );

    print("🟢 Updated runtime settings: ${AppData().settings.toJson()}");

    // ❌ Do NOT save JSON here.
    // JSON will be updated later via AppData.saveAllData() on app close or settings exit.
  }

  @override
  void dispose() {
    descController?.dispose();
    qtyController?.dispose();
    rateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

        final double horizontalPadding = isMobile
            ? 16
            : isTablet
            ? 40
            : 100;
        final double spacing = isMobile ? 12 : 20;
        final double titleFontSize = isMobile ? 24 : 28;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title:  Text(
              "Item Titles",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textFormField(
                        controller: descController!,
                        labelText: "Description Title",
                        hintText: "Enter description label (e.g. Product)",
                      ),
                      SizedBox(height: spacing),
                      textFormField(
                        controller: qtyController!,
                        labelText: "Quantity Title",
                        hintText: "Enter quantity label (e.g. Qty)",
                      ),
                      SizedBox(height: spacing),
                      textFormField(
                        controller: rateController!,
                        labelText: "Rate Title",
                        hintText: "Enter rate label (e.g. Price)",
                      ),
                      SizedBox(height: spacing * 2.2),

                      Center(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 250,
                          child: CustomElevatedButton(
                            icon: Icons.save_rounded,
                            label: "Save Title",
                            color: const Color(0xFF009A75),
                            onPressed: () async {
                              await _saveTitles();

                              Navigator.pop(context, {
                                'descLabel': descController!.text,
                                'qtyLabel': qtyController!.text,
                                'rateLabel': rateController!.text,
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
