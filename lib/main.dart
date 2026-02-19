import 'package:flutter/material.dart';
import 'package:invoice/Screens/Menu/Profile/profile_form.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/widgets/buttons/custom_tabbar.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Global Veriables/global_veriable.dart';
import 'app_data/app_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "eZInvoice";

  final prefs = await SharedPreferences.getInstance();
  isPurchase = prefs.getBool("isPurchase") ?? true;

  await AppData().loadAllData();
  final profile = AppData().profile;
  runApp(MyApp(showProfileForm: profile == null));
}

class MyApp extends StatefulWidget {
  final bool? showProfileForm;

  const MyApp({super.key, this.showProfileForm});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      AppData().saveAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: widget.showProfileForm == true
          ? const InvoiceProfileForm()
          : const InvoiceHomeTabPage(),
    );
  }
}
