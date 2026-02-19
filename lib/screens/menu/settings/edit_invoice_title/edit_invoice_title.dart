import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/custom_field_model.dart';
import 'package:invoice/widgets/buttons/custom_dropdown_formfield.dart';
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
  final Map<String, CustomFieldModel> customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    final settings = AppData().settings;

    descController = TextEditingController(
      text: settings.descTitle.isNotEmpty ? settings.descTitle : "Product",
    );

    qtyController = TextEditingController(
      text: settings.qtyTitle.isNotEmpty ? settings.qtyTitle : "Qty",
    );

    rateController = TextEditingController(
      text: settings.rateTitle.isNotEmpty ? settings.rateTitle : "Price",
    );

    // Load custom fields
    for (int i = 0; i < settings.customFields.length; i++) {
      String id = "field_${i + 1}";

      customFieldControllers[id] = CustomFieldModel(
        label: settings.customFields[i]['label'] ?? '',
      );
    }
  }

  void addCustomField() {
    setState(() {
      int highest = 0;

      for (var key in customFieldControllers.keys) {
        final number = int.tryParse(key.split("_").last) ?? 0;
        if (number > highest) highest = number;
      }

      int newId = highest + 1;
      String key = "field_$newId";

      customFieldControllers[key] = CustomFieldModel(label: "Field $newId");
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

    List<Map<String, dynamic>> updatedCustomFields = customFieldControllers
        .values
        .map((e) => e.toJson())
        .toList();

    AppData().settings = AppData().settings.copyWith(
      customFields: updatedCustomFields,
    );

    print("Updated Titles: ${AppData().settings.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final crossAxisCount = isMobile ? 1 : 2;
        final mainSpacing = isMobile
            ? 10.0
            : isTablet
            ? 15.0
            : 0.0;
        final crossSpacing = isMobile
            ? 10.0
            : isTablet
            ? 15.0
            : 18.0;
        final double titleFontSize = isMobile ? 24 : (isTablet ? 28 : 32);

        final List<Widget> allFields = [
          textFormField(
            controller: descController!,
            labelText: "Description Title",
          ),
          textFormField(
            controller: qtyController!,
            labelText: "Quantity Title",
          ),
          textFormField(controller: rateController!, labelText: "Rate Title"),
          ...customFieldControllers.entries.map((entry) {
            final keyName = entry.key;
            return Dismissible(
              key: Key(keyName),
              direction: DismissDirection.endToStart,
              background: Container(
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
              child: customFieldRow(entry.key, entry.value),
            );
          }),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              "Add Fields And Titles",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            backgroundColor: const Color(0xFFF0F2F5),
            elevation: 0,
            foregroundColor: Colors.black,
            scrolledUnderElevation: 0,
            actions: [
              !isMobile
                  ? Row(
                      children: [
                        CustomIconButton(
                          label: "Save",
                          icon: Icons.save_rounded,
                          textColor: Colors.white,
                          iconSize: titleFontSize,
                          fontSize: 25,
                          backgroundColor: Color(0xFF009A75),
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          onTap: () async {
                            await _saveTitles();
                            Navigator.pop(context, {
                              'descLabel': descController!.text,
                              'qtyLabel': qtyController!.text,
                              'rateLabel': rateController!.text,
                              'customLabels': customFieldControllers.map(
                                (key, model) =>
                                    MapEntry(key, model.controller.text),
                              ),
                            });
                          },
                        ),
                        SizedBox(width: 20),
                      ],
                    )
                  : SizedBox(),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: CustomIconButton(
                  icon: Icons.add,
                  textColor: Colors.white,
                  backgroundColor: Color(0xFF009A75),
                  iconSize: isMobile ? 20 : 25,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  onTap: addCustomField,
                ),
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossSpacing,
                  mainAxisSpacing: mainSpacing,
                  childAspectRatio: isMobile
                      ? 6
                      : isTablet
                      ? 6.5
                      : 5,
                  children: allFields,
                ),
              ),
            ),
          ),
          bottomNavigationBar: isMobile
              ? Container(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
                  child: CustomElevatedButton(
                    label: "Save",
                    icon: Icons.save_rounded,
                    backgroundColor: const Color(0xFF009A75),
                    onPressed: () async {
                      await _saveTitles();
                      Navigator.pop(context, {
                        'descLabel': descController!.text,
                        'qtyLabel': qtyController!.text,
                        'rateLabel': rateController!.text,
                        'customLabels': customFieldControllers.map(
                          (key, model) => MapEntry(key, model.controller.text),
                        ),
                      });
                    },
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget customFieldRow(String key, CustomFieldModel model) {
    String customFieldLabel(String key) {
      final index = int.tryParse(key.split('_').last) ?? 0;
      return 'Custom Field $index';
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: textFormField(
            controller: model.controller,
            labelText: customFieldLabel(key),
          ),
        ),
        /*        const SizedBox(width: 8),

        SizedBox(
          width: 70,
          child: AppDropdownFormField<String>(
            labelText: "Op",
            value: model.operator,
            items: const [
              DropdownMenuItem(
                value: '+',
                child: Center(child: Text('+')),
              ),
              DropdownMenuItem(
                value: '-',
                child: Center(child: Text('-')),
              ),
              DropdownMenuItem(
                value: '*',
                child: Center(child: Text('×')),
              ),
              DropdownMenuItem(
                value: '/',
                child: Center(child: Text('÷')),
              ),
            ],
            onChanged: (val) => setState(() => model.operator = val!),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          flex: 2,
          child: AppDropdownFormField<String>(
            labelText: "Value",
            value: model.valueKey,
            items: [
              DropdownMenuItem(
                value: 'qty',
                child: Text(
                  qtyController?.text.isNotEmpty == true
                      ? qtyController!.text
                      : 'Qty',
                ),
              ),
              DropdownMenuItem(
                value: 'rate',
                child: Text(
                  rateController?.text.isNotEmpty == true
                      ? rateController!.text
                      : 'Rate',
                ),
              ),
              ...customFieldControllers.entries
                  .where((entry) => entry.key != key)
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value.controller.text.isNotEmpty
                            ? entry.value.controller.text
                            : entry.key, // fallback
                      ),
                    ),
                  ),
            ],
            onChanged: (val) => setState(() => model.valueKey = val!),
          ),
        ),*/
      ],
    );
  }

  InputDecoration commonInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      // 🔥 IMPORTANT
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12, // 🔽 reduce height
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }
}
