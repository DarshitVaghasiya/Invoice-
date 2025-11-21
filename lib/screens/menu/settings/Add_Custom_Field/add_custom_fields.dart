import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

class AddCustomFields extends StatefulWidget {
  const AddCustomFields({super.key});

  @override
  State<AddCustomFields> createState() => _AddCustomFieldsState();
}

class _AddCustomFieldsState extends State<AddCustomFields> {
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Add Custom Field"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            textFormField(
              labelText: "Field Title (e.g. Delivery Note)",
              controller: titleController,
            ),
            const SizedBox(height: 30),
            CustomElevatedButton(
              label: "Add Field",
              icon: Icons.add_circle_outline,
              color: Color(0xFF009A75),
              onPressed: () {
                final newField = titleController.text.trim();
                if (newField.isEmpty) return;

                final settings = AppData().settings;

                settings.customFields = [...(settings.customFields), newField];

                Navigator.pop(context, newField);
              },
            ),
          ],
        ),
      ),
    );
  }
}
