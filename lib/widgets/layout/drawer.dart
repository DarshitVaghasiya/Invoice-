import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invoice/Screens/Menu/Customers/customer_list.dart';
import 'package:invoice/Screens/Menu/Items/items_list.dart';
import 'package:invoice/Screens/Menu/Profile/profile_form.dart';
import 'package:invoice/Screens/Menu/Settings/settings.dart';
import 'package:invoice/app_data/app_data.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? name;
  String? email;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    final profile = AppData().profile;
    if (profile != null) {
      name = profile.name.isNotEmpty ? profile.name : "No Name";
      email = profile.email.isNotEmpty ? profile.email : "No Email";
      imagePath = (profile.profileImageBase64?.isNotEmpty ?? false)
          ? profile.profileImageBase64
          : null;
    } else {
      name = "No Name";
      email = "No Email";
      imagePath = null;
    }
  }


  Future<void> loadProfileData() async {
    final profile = AppData().profile;

    if (!mounted) return; // ✅ Prevent calling setState after widget disposed

    if (profile != null) {
      setState(() {
        name = (profile.name.toString().trim().isNotEmpty)
            ? profile.name
            : "No Name";
        email = (profile.email.toString().trim().isNotEmpty)
            ? profile.email
            : "No Email";
        imagePath =
            (profile.profileImageBase64 != null &&
                profile.profileImageBase64.toString().trim().isNotEmpty)
            ? profile.profileImageBase64
            : null;
      });
    } else {
      setState(() {
        name = "No Name";
        email = "No Email";
        imagePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF008A6D)),
            accountName: Text(
              name ?? "Loading...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (imagePath != null && imagePath!.isNotEmpty)
                  ? MemoryImage(base64Decode(imagePath!)) // ✅ Decode Base64 string
                  : null,
              child: (imagePath == null || imagePath!.isEmpty)
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF00A884))
                  : null,
            ),

          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF00A884)),
            title: const Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceProfileForm(),
                ),
              );
              await loadProfileData(); // refresh after profile change
            },
          ),

          // Customer List
          ListTile(
            leading: const Icon(Icons.groups, color: Colors.purple),
            title: const Text(
              "Customer List",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerList()),
              );
            },
          ),

          // Items List
          ListTile(
            leading: const Icon(Icons.view_list, color: Colors.blue),
            title: const Text(
              "Items List",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ItemsList()),
              );
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.grey),
            title: const Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
