import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invoice/Global%20Veriables/global_veriable.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/add_items_model.dart';
import 'package:invoice/widgets/buttons/custom_dialog.dart';
import 'package:uuid/uuid.dart';
import 'add_items.dart';

class ItemsList extends StatefulWidget {
  final bool isSelectionMode;

  const ItemsList({super.key, this.isSelectionMode = false});

  @override
  State<ItemsList> createState() => ItemsListState();
}

class ItemsListState extends State<ItemsList> {
  List<AddItemModel> items = [];
  List<AddItemModel> filteredItems = [];
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    items = List.from(AppData().items);
    _onSearchChanged(searchQuery);
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      filteredItems = items.where((item) {
        return item.title.toLowerCase().contains(searchQuery) ||
            item.details.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _deleteItems(AddItemModel item) async {
    final confirmed = await showCustomAlertDialog(
      context: context,
      title: "Delete Item",
      message: "Are you sure you want to permanently delete this item?",
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      btn3: "Delete",
      btn2: "Cancel",
    );

    if (confirmed == true) {
      setState(() {
        items.remove(item);
        AppData().items = List.from(items);
        _onSearchChanged(searchQuery); // refresh filter safely
      });
      await AppData().saveAllData();
    }
  }

  Future<void> _importCsvItems() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.length <= 1) return;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 3) continue;

        final title = row[0].toString().trim();
        final details = row[1].toString().trim();
        final price = double.tryParse(row[2].toString()) ?? 0;

        if (title.isEmpty) continue;

        AppData().items.add(
          AddItemModel(
            id: uuid.v4(),
            title: title,
            details: details,
            price: price,
          ),
        );
      }

      await _loadItems();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Items imported successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Import failed: $e")));
    }
  }

  void _showAddOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// drag handle
              Container(
                height: 4,
                width: 45,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Add Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                "Choose how you want to add items",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 22),

              /// ➕ Add Item
              _beautifulOptionTile(
                icon: Icons.add_rounded,
                title: "Add Item",
                subtitle: "Create item manually",
                gradient: const LinearGradient(
                  colors: [Color(0xFF009A75), Color(0xFF00C89A)],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddItems()),
                  );
                  _loadItems();
                },
              ),

              const SizedBox(height: 14),

              /// 📄 Import CSV
              _beautifulOptionTile(
                icon: Icons.file_upload_rounded,
                title: "Import CSV",
                subtitle: "Upload items from CSV file",
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7043), Color(0xFFFFA270)],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _importCsvItems();
                },
              ),
            ],
          ),
        );
      },
    );
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
            backgroundColor: const Color(0xFFF9FAFB),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              widget.isSelectionMode ? "Select Item" : "Items",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),

              Expanded(
                child: filteredItems.isEmpty
                    ? _emptyState()
                    : widget.isSelectionMode
                    ? _buildSimpleListView()
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          children: [
                            MasonryGridView.count(
                              crossAxisCount: isMobile
                                  ? 1
                                  : isTablet
                                  ? 2
                                  : 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 12,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              itemBuilder: (_, i) =>
                                  _itemCard(filteredItems[i]),
                            ),
                            SizedBox(height: 90),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: widget.isSelectionMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddOptionsSheet(context),
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

  Widget _beautifulOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleListView() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredItems.length,
      separatorBuilder: (context, _) => Divider(
        height: 1,
        color: Colors.grey.shade300,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          dense: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 0,
          ),
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

  Widget _itemCard(AddItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF009A75).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF009A75),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: item.details.isEmpty ? null : Text(item.details),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF009A75).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "₹${item.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF009A75),
            ),
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddItems(existingItem: item, index: items.indexOf(item)),
            ),
          );
          _loadItems();
        },
        onLongPress: () => _deleteItems(item),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF009A75).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 54,
                color: Color(0xFF009A75),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "No Items Yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Text(
              "Add items manually or import them\nusing a CSV file",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
