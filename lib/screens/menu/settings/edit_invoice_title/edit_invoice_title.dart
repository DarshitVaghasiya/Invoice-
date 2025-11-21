import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
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

  // 🔥 Dynamic controllers for custom fields
  final Map<String, TextEditingController> customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    final settings = AppData().settings;

    // Default labels if empty
    descController = TextEditingController(
      text: settings.descTitle.isNotEmpty ? settings.descTitle : "Product",
    );

    qtyController = TextEditingController(
      text: settings.qtyTitle.isNotEmpty ? settings.qtyTitle : "Qty",
    );

    rateController = TextEditingController(
      text: settings.rateTitle.isNotEmpty ? settings.rateTitle : "Price",
    );

    // 🔥 Load custom fields from settings
    for (var field in settings.customFields) {
      customFieldControllers[field] = TextEditingController(
        text: field,
      ); // default = field name itself
    }
  }

  void addCustomField() {
    setState(() {
      String newFieldName = "Field ${customFieldControllers.length + 1}";
      customFieldControllers[newFieldName] = TextEditingController(
        text: newFieldName,
      );
    });
  }

  Future<void> _saveTitles() async {
    final settings = AppData().settings;

    // Update basic fields
    AppData().settings = settings.copyWith(
      descTitle: descController!.text,
      qtyTitle: qtyController!.text,
      rateTitle: rateController!.text,
    );

    // 🔥 Update custom field names inside model
    List<String> updatedCustomFields = customFieldControllers.values
        .map((controller) => controller.text)
        .toList();

    AppData().settings = AppData().settings.copyWith(
      customFields: updatedCustomFields,
    );

    print("Updated Titles: ${AppData().settings.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Item Titles",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CustomIconButton(
              label: "Add Field",
              icon: Icons.add,
              textColor: Colors.white,
              backgroundColor: Color(0xFF009A75),
              onTap: addCustomField, // <-- Proper function call
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            textFormField(
              controller: descController!,
              labelText: "Description Title",
            ),
            const SizedBox(height: 16),

            textFormField(
              controller: qtyController!,
              labelText: "Quantity Title",
            ),
            const SizedBox(height: 16),

            textFormField(controller: rateController!, labelText: "Rate Title"),

            const SizedBox(height: 16),

            // 🔥 Dynamic Custom Fields
            ...customFieldControllers.entries.map((entry) {
              final keyName = entry.key;

              return Dismissible(
                key: Key(keyName),
                direction: DismissDirection.endToStart,

                // 🔥 Full-width red background with margin & radius
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),   // SAME as child padding
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 26),
                ),

                onDismissed: (_) {
                  setState(() {
                    customFieldControllers.remove(keyName);
                  });
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: textFormField(
                    controller: entry.value,
                    labelText: "Custom Field: $keyName",
                  ),
                ),
              );
            }).toList(),


            const SizedBox(height: 20),

            CustomElevatedButton(
              icon: Icons.save_rounded,
              label: "Save All Titles",
              color: const Color(0xFF009A75),
              onPressed: () async {
                await _saveTitles();

                // Return updated map properly
                Navigator.pop(context, {
                  'descLabel': descController!.text,
                  'qtyLabel': qtyController!.text,
                  'rateLabel': rateController!.text,
                  'customLabels': customFieldControllers
                      .map((key, controller) => MapEntry(key, controller.text))
                      .cast<String, String>(), // 🔥 FIX here
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
