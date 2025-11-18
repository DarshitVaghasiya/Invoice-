import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/add_items_model.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'add_items.dart';

class ItemsList extends StatefulWidget {
  final bool isSelectionMode;

  const ItemsList({super.key, this.isSelectionMode = false});

  @override
  State<ItemsList> createState() => ItemsListState();
}

class ItemsListState extends State<ItemsList> {
  List<AddItemModel> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      items = List<AddItemModel>.from(AppData().items);
    });
  }

  Future<void> _deleteItems(int index) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Item",
      message:
          "Are you sure you want to permanently delete this item? This action cannot be undone.",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      confirmText: "Delete",
      cancelText: "Cancel",
    );

    if (confirmed == true) {
      setState(() {
        AppData().items.removeAt(index);
        items.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

        double padding = isMobile ? 12 : (isTablet ? 20 : 32);
        double fontSize = isMobile ? 13 : (isTablet ? 15 : 17);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: const Color(0xFFF9FAFB),
            foregroundColor: Colors.black,
            title: Text(
              widget.isSelectionMode ? "Select Item" : "Items List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 10,
              ),
            ),
            centerTitle: true,
          ),
          body: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_list,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No Items found",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: fontSize + 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: widget.isSelectionMode
                      ? _buildSimpleListView()
                      : _buildGridView(isMobile, isTablet),
                ),
          floatingActionButton: widget.isSelectionMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItems()),
                    );
                    await _loadItems();
                  },
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text(
                    "Add Item",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF009A75),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
        );
      },
    );
  }

  /// 🔹 Simple sober list for selection mode
  Widget _buildSimpleListView() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, _) => Divider(
        height: 1,
        color: Colors.grey.shade300,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          dense: false,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          title: Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: item.details.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.details,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
              ),
            ),
          )
              : null,
          trailing: Text(
            "₹${item.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF009A75),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: Colors.white,
          onTap: () => Navigator.pop(context, item),
        );
      },
    );
  }



  /// 🔹 Grid view for normal mode
  Widget _buildGridView(bool isMobile, bool isTablet) {
    return MasonryGridView.count(
      crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
      mainAxisSpacing: 10,
      crossAxisSpacing: 12,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item, index);
      },
    );
  }

  /// 🔹 Detailed card for normal mode
  Widget _buildItemCard(AddItemModel item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00B686).withOpacity(0.1),
          child: const Icon(Icons.shopping_bag, color: Color(0xFF009A75)),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.details.isNotEmpty)
              Text(
                item.details,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            const SizedBox(height: 4),
          ],
        ),
        // ✅ Proper trailing section
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "₹${item.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF009A75),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItems(existingItem: item, index: index),
            ),
          );
          await _loadItems();
        },
        onLongPress: () => _deleteItems(index),
      ),
    );
  }

}
