import 'package:flutter/material.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/add_items_model.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:uuid/uuid.dart';

class AddItems extends StatefulWidget {
  final AddItemModel? existingItem; // Use model class instead of Map
  final int? index;

  const AddItems({super.key, this.existingItem, this.index});

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final details = TextEditingController();
  final price = TextEditingController();

  bool isEditing = false;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    if (widget.existingItem != null) {
      final I = widget.existingItem!;
      title.text = I.title;
      details.text = I.details;
      price.text = I.price.toString(); // ✅ convert safely to String
      isEditing = false;
    } else {
      isEditing = true;
    }
  }


  void saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = AddItemModel(
        id: widget.existingItem?.id ?? uuid.v4(),
        title: title.text.trim(),
        details: details.text.trim(),
        price: int.tryParse(price.text) ?? 0,

      );

      // ✅ Save or update in AppData
      if (widget.index != null) {
        AppData().items[widget.index!] = newItem;
      } else {
        AppData().items.add(newItem);
      }

      Navigator.pop(context, newItem);
    }
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
        double titleFontSize = isMobile ? 24 : (isTablet ? 22 : 26);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              widget.existingItem == null ? "Add Item" : "Edit Item",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFFF0F2F5),
            elevation: 0,
            foregroundColor: Colors.black,
            actions: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomIconButton(
                    icon: isEditing ? Icons.save : Icons.edit,
                    label: isEditing ? "Save" : "Edit",
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: isEditing
                        ? const Color(0xFF009A75)
                        : Colors.yellow.shade800,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (isEditing) saveItem();
                      setState(() => isEditing = !isEditing);
                    },
                  ),
                ),
            ],
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      _buildSection(
                        "Title",
                        [
                          textFormField(
                            labelText: "Title",
                            controller: title,
                            enabled: isEditing,
                            keyboardType: TextInputType.text,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? "Please enter a title"
                                : null,
                          ),
                          textFormField(
                            labelText: "Details",
                            controller: details,
                            enabled: isEditing,
                            keyboardType: TextInputType.text,
                          ),
                          textFormField(
                            labelText: "Prices",
                            controller: price,
                            enabled: isEditing,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        crossAxisCount,
                        spacing,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          bottomNavigationBar: isMobile
              ? Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            label: isEditing ? "Save" : "Edit",
                            icon: isEditing ? Icons.save : Icons.edit,
                            backgroundColor: isEditing
                                ? const Color(0xFF009A75)
                                : Colors.orange,
                            onPressed: () {
                              if (isEditing) saveItem();
                              setState(() => isEditing = !isEditing);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomIconButton(
                            label: "Cancel",
                            borderColor: Colors.red,
                            textColor: Colors.red,
                            fontSize: 18,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    int crossAxisCount,
    double spacing,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _buildResponsiveGrid(children, crossAxisCount, spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    List<Widget> children,
    int crossAxisCount,
    double spacing,
  ) {
    final double itemWidth =
        (MediaQuery.of(context).size.width -
            (crossAxisCount + 1) * spacing * 2) /
        crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children
          .map(
            (child) => SizedBox(width: itemWidth.clamp(260, 380), child: child),
          )
          .toList(),
    );
  }
}
