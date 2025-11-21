import 'package:flutter/material.dart';
import 'package:invoice/Screens/Menu/Items/items_list.dart';
import 'package:invoice/models/item_model.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

class ItemCard extends StatefulWidget {
  final int index;
  final ItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final String currencySymbol;
  final String? descLabel;
  final String? qtyLabel;
  final String? rateLabel;
  final Map<String, String>? customLabels;

  const ItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onChanged,
    required this.currencySymbol,
    this.descLabel,
    this.qtyLabel,
    this.rateLabel,
    this.customLabels,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Select And Type",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    CustomIconButton(
                      icon: Icons.close,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      textColor: Colors.red,
                      onTap: widget.onRemove,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Description Row + Dropdown
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: textFormField(
                        labelText: widget.descLabel ?? "Item Description",
                        controller: item.desc,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (_) => widget.onChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter item description.";
                          }
                          return null;
                        },
                      ),
                    ),

                    CustomIconButton(
                      borderColor: Colors.grey.shade400,
                      textColor: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      icon: Icons.arrow_drop_down_sharp,
                      iconSize: 25,
                      onTap: () async {
                        final selectedItem = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemsList(isSelectionMode: true),
                          ),
                        );

                        if (selectedItem != null) {
                          item.desc.text = selectedItem.title;
                          item.rate.text = selectedItem.price.toString();
                          widget.onChanged();
                        }
                      },
                    ),
                  ],
                ),

                // ---------------- CUSTOM FIELDS ----------------
                ...item.customControllers.entries.map((entry) {
                  final fieldKey = entry.key;

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: textFormField(
                            labelText:
                                widget.customLabels?[fieldKey] ?? fieldKey,
                            controller: entry.value,
                            maxLines: null,
                            onChanged: (_) => widget.onChanged(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter ${widget.customLabels?[fieldKey] ?? fieldKey}.";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // ---------------- QUANTITY × RATE ----------------
                Row(
                  children: [
                    Expanded(
                      child: textFormField(
                        labelText: widget.qtyLabel ?? "Quantity",
                        controller: item.qty,
                        maxLines: null,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => widget.onChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter quantity.";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("×", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: textFormField(
                        prefixText: "${widget.currencySymbol} ",
                        labelText: widget.rateLabel ?? "Rate",
                        controller: item.rate,
                        maxLines: null,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => widget.onChanged(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter rate.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
