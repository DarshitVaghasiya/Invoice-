import 'package:flutter/material.dart';
import 'package:invoice/Screens/Menu/Items/items_list.dart';
import 'package:invoice/models/item_model.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

class ItemCard extends StatelessWidget {
  final int index;
  final ItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final String? descLabel;
  final String? qtyLabel;
  final String? rateLabel;
  final String currencySymbol; // 👈 Add this

  const ItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onChanged,
    required this.currencySymbol, // 👈 Required now
    this.descLabel,
    this.qtyLabel,
    this.rateLabel,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 380 ? 20 : 25;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
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
                      padding: EdgeInsets.symmetric(vertical: 0),
                      textColor: Colors.red,
                      onTap: onRemove,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: textFormField(
                        labelText: descLabel ?? "Item Description",
                        controller: item.desc,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (_) => onChanged(),
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
                      iconSize: iconSize,
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
                          onChanged();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 🔹 Quantity × Rate Row
                Row(
                  children: [
                    Expanded(
                      child: textFormField(
                        labelText: qtyLabel ?? "Quantity",
                        controller: item.qty,
                        maxLines: null,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
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
                        prefixText: "$currencySymbol ",
                        labelText: rateLabel ?? "Rate",
                        controller: item.rate,
                        maxLines: null,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
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
