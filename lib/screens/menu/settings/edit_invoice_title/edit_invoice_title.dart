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
      customFieldControllers[id] = TextEditingController(
        text: settings.customFields[i],
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
      String uniqueKey = "field_$newId";

      customFieldControllers[uniqueKey] = TextEditingController(
        text: "Field $newId",
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
        .map((c) => c.text)
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
        final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
        final spacing = isMobile ? 10.0 : 18.0;
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
              child: textFormField(
                controller: entry.value,
                labelText: "Custom Field",
              ),
            );
          }),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              "Item Titles",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            backgroundColor: const Color(0xFFF0F2F5),
            elevation: 0,
            foregroundColor: Colors.black,
            centerTitle: true,
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
                                (key, controller) =>
                                    MapEntry(key, controller.text),
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
                constraints: const BoxConstraints(maxWidth: 825),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: isMobile ? 6 : (isTablet ? 6.5 : 4),
                  children: allFields,
                ),
              ),
            ),
          ),
          bottomNavigationBar: isMobile
              ? Container(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
                  child: CustomElevatedButton(
                    label: "Save All Titles",
                    icon: Icons.save_rounded,
                    backgroundColor: const Color(0xFF009A75),
                    onPressed: () async {
                      await _saveTitles();
                      Navigator.pop(context, {
                        'descLabel': descController!.text,
                        'qtyLabel': qtyController!.text,
                        'rateLabel': rateController!.text,
                        'customLabels': customFieldControllers.map(
                          (key, controller) => MapEntry(key, controller.text),
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
}
