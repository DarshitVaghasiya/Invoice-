import 'package:flutter/material.dart';
import 'package:invoice/Global%20Veriables/global_veriable.dart';
import 'package:invoice/app_data/app_data.dart';
class InvoiceTemplates extends StatefulWidget {
  const InvoiceTemplates({super.key});

  @override
  State<InvoiceTemplates> createState() => _InvoiceTemplatesState();
}

class _InvoiceTemplatesState extends State<InvoiceTemplates> {
  final List<Map<String, String>> templates = [
    {"image": "assets/images/temp1.png", "name": "Simple"},
    {"image": "assets/images/temp2.png", "name": "Classic"},
    {"image": "assets/images/temp3.png", "name": "Modern"},
    {"image": "assets/images/temp4.png", "name": "Elegant"},
    {"image": "assets/images/temp5.png", "name": "Attractive"},
    {"image": "assets/images/temp6.png", "name": "Beautiful"},
  ];

  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }

  // 🔹 Load previously selected template
  void _loadSelectedTemplate() {
    final savedName = AppData().settings.selectedTemplate;

    final index = templates.indexWhere(
      (t) => t['name']!.toLowerCase() == savedName.toLowerCase(),
    );

    if (index != -1) {
      selectedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Choose Template",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF0F2F5),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          double aspectRatio;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2;
            aspectRatio = 0.72;
          } else if (constraints.maxWidth < 1000) {
            crossAxisCount = 3;
            aspectRatio = 0.8;
          } else {
            crossAxisCount = 3;
            aspectRatio = 1.0;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: templates.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = templates[index];
                final bool isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () async {
                    if (!isPurchase && index > 1) {
                      showLimitDialog(
                        "This template is available for Premium only.\nUpgrade to unlock all templates.",
                      );
                      return;
                    }

                    final selectedName = item['name']!;

                    // 🔥 Save to SettingsModel instead of SharedPreferences
                    AppData().settings.selectedTemplate = selectedName;
                    await AppData().saveAllData();

                    if (mounted) Navigator.pop(context, selectedName);
                  },

                  child: Stack(
                    children: [
                      // 🔹 Card with border if selected
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF009A75)
                                : Colors.transparent,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                child: Image.asset(
                                  item['image']!,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Text("Image not found"),
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF009A75).withOpacity(0.1)
                                    : Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  item['name']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Color(0xFF009A75)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ Tick mark on top-right corner if selected
                      if (isSelected)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF009A75),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // 🔒 Lock overlay for premium templates (index > 1 & not purchased)
                      if (!isPurchase && index > 1)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
