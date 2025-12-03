import 'dart:convert';
import 'dart:io';
import 'package:invoice/models/add_items_model.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:invoice/models/settings_model.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceStorage {
  // -----------------------------------------------------------------
  // 🔹 FILE HANDLING
  // -----------------------------------------------------------------

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/Invoices.json");
  }

  static Future<Map<String, dynamic>> _loadData() async {
    final file = await _getFile();

    // If file doesn’t exist → create base structure
    if (!await file.exists()) {
      return {
        "profile": {},
        "customer": [],
        "invoice": [],
        "item": [],
        "settings": {},
      };
    }

    final content = await file.readAsString();

    // If empty or corrupted, return default structure
    if (content.trim().isEmpty) {
      return {
        "profile": {},
        "customer": [],
        "invoice": [],
        "item": [],
        "settings": {},
      };
    }

    try {
      final decoded = jsonDecode(content);
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      return {
        "profile": {},
        "customer": [],
        "invoice": [],
        "item": [],
        "settings": {},
      };
    }
  }

  static Future<void> _saveData(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data), flush: true);
    print("✅ Data saved to: ${file.path}");
  }

  // -----------------------------------------------------------------
  // 🚀 LOAD & SAVE ALL
  // -----------------------------------------------------------------

  static Future<Map<String, dynamic>> loadAll() async {
    final data = await _loadData();

    return {
      "customers": (data["customer"] as List? ?? [])
          .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      "invoices": (data["invoice"] as List? ?? [])
          .map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      "items": (data["item"] as List? ?? [])
          .map((e) => AddItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      "profile": data["profile"] != null && (data["profile"] as Map).isNotEmpty
          ? ProfileModel.fromJson(Map<String, dynamic>.from(data["profile"]))
          : null,
      "settings": SettingsModel.fromJson(
        Map<String, dynamic>.from(data["settings"] ?? {}),
      ),
    };
  }

  static Future<void> saveAll({
    required List<CustomerModel> customers,
    required List<InvoiceModel> invoices,
    required List<AddItemModel> items,
    ProfileModel? profile,
    required SettingsModel settings,
  }) async {
    final data = {
      "profile": profile?.toJson() ?? {},
      "customer": customers.map((e) => e.toJson()).toList(),
      "invoice": invoices.map((e) => e.toJson()).toList(),
      "item": items.map((e) => e.toJson()).toList(),
      "settings": settings.toJson(),
    };
    await _saveData(data);
  }

  // -----------------------------------------------------------------
  // 👤 CUSTOMER HANDLERS
  // -----------------------------------------------------------------

  static Future<List<CustomerModel>> loadCustomers() async {
    final data = await _loadData();
    return (data["customer"] as List)
        .map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveCustomers(List<CustomerModel> customers) async {
    final data = await _loadData();
    data["customer"] = customers.map((e) => e.toJson()).toList();
    await _saveData(data);
  }

  static Future<void> addCustomer(CustomerModel customer) async {
    final customers = await loadCustomers();
    customers.add(customer);
    await saveCustomers(customers);
  }

  static Future<void> updateCustomer(int index, CustomerModel updated) async {
    final customers = await loadCustomers();
    if (index >= 0 && index < customers.length) {
      customers[index] = updated;
      await saveCustomers(customers);
    }
  }

  static Future<void> deleteCustomer(int index) async {
    final customers = await loadCustomers();
    if (index >= 0 && index < customers.length) {
      customers.removeAt(index);
      await saveCustomers(customers);
    }
  }

  // -----------------------------------------------------------------
  // 🧾 INVOICE HANDLERS
  // -----------------------------------------------------------------

  static Future<List<InvoiceModel>> loadInvoices() async {
    final data = await _loadData();
    return (data["invoice"] as List)
        .map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveInvoices(List<InvoiceModel> invoices) async {
    final data = await _loadData();
    data["invoice"] = invoices.map((e) => e.toJson()).toList();
    await _saveData(data);
  }

  static Future<void> addInvoice(InvoiceModel invoice) async {
    final invoices = await loadInvoices();
    invoices.add(invoice);
    await saveInvoices(invoices);
  }

  static Future<void> deleteInvoice(int index) async {
    final invoices = await loadInvoices();
    if (index >= 0 && index < invoices.length) {
      invoices.removeAt(index);
      await saveInvoices(invoices);
    }
  }

  // -----------------------------------------------------------------
  // 🧾 INVOICE HANDLERS
  // -----------------------------------------------------------------

  static Future<List<AddItemModel>> loadItems() async {
    final data = await _loadData();
    return (data["item"] as List)
        .map((e) => AddItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveItems(List<AddItemModel> item) async {
    final data = await _loadData();
    data["item"] = item.map((e) => e.toJson()).toList();
    await _saveData(data);
  }

  static Future<void> addItems(AddItemModel item) async {
    final items = await loadItems();
    items.add(item);
    await saveItems(items);
  }

  static Future<void> updateItems(int index, AddItemModel updated) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items[index] = updated;
      await saveItems(items);
    }
  }

  static Future<void> deleteItems(int index) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await saveItems(items);
    }
  }

  // -----------------------------------------------------------------
  // 🧑‍💼 PROFILE HANDLERS
  // -----------------------------------------------------------------

  static Future<ProfileModel?> loadProfile() async {
    final data = await _loadData();
    if (data["profile"] == null || (data["profile"] as Map).isEmpty) {
      return null;
    }
    return ProfileModel.fromJson(Map<String, dynamic>.from(data["profile"]));
  }

  static Future<void> saveProfile(ProfileModel profile) async {
    final data = await _loadData();
    data["profile"] = profile.toJson();
    await _saveData(data);
  }

  // -----------------------------------------------------------------
  // ⚙️ SETTINGS HANDLERS (Model-based, not direct JSON)
  // -----------------------------------------------------------------

  static Future<void> saveSettings(SettingsModel settings) async {
    final data = await _loadData();
    data["settings"] = settings.toJson(); // Save model → JSON
    await _saveData(data);
  }

  static Future<SettingsModel> loadSettings() async {
    final data = await _loadData();
    final json = Map<String, dynamic>.from(data["settings"] ?? {});
    final settings = SettingsModel.fromJson(json);

    // If empty, write default model once
    if (data["settings"] == null || (data["settings"] as Map).isEmpty) {
      data["settings"] = settings.toJson();
      await _saveData(data);
      print("🟢 Default settings created in JSON");
    }

    return settings;
  }

  static Future<void> updateSetting(String key, dynamic value) async {
    final settings = await loadSettings();
    final json = settings.toJson();
    json[key] = value;
    await saveSettings(SettingsModel.fromJson(json));
  }

  static Future<void> updateTitleLabels({
    required String descTitle,
    required String qtyTitle,
    required String rateTitle,
  }) async {
    final settings = await loadSettings();
    settings
      ..descTitle = descTitle
      ..qtyTitle = qtyTitle
      ..rateTitle = rateTitle;
    await saveSettings(settings);
  }

  // -----------------------------------------------------------------
  // 📤 EXPORT FULL JSON FILE TO DOWNLOADS FOLDER
  // -----------------------------------------------------------------
  static Future<String?> exportDataToDownloads() async {
    try {
      final data = await _loadData();
      if (data.isEmpty) return null;

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      Directory downloadsDir;
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) return null;

        // Go up to /storage/emulated/0/Download
        final path = "${dir.path.split("/Android").first}/Download";
        downloadsDir = Directory(path);
      } else {
        downloadsDir =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
      final file = File("${downloadsDir.path}/invoice_$timestamp.json");


      await file.writeAsString(jsonString, flush: true);

      print("✅ File Successfully Exported In Your Download Folder");
      return file.path;
    } catch (e) {
      print("❌ Export failed: $e");
      return null;
    }
  }

  static Future<bool> hasDuplicates(File file) async {
    try {
      final jsonString = await file.readAsString();
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;

      Map<String, dynamic> newData = Map<String, dynamic>.from(decoded);
      Map<String, dynamic> oldData = await _loadData();

      for (var key in newData.keys) {
        if (oldData[key] is List && newData[key] is List) {
          for (var newItem in newData[key]) {
            final newId = newItem["id"] ?? newItem["invoiceID"];
            final exists = (oldData[key] as List).any(
              (item) => item["id"] == newId || item["invoiceID"] == newId,
            );
            if (exists) return true; // duplicate found
          }
        }
      }
      return false; // no duplicates
    } catch (_) {
      return false;
    }
  }

  // -----------------------------------------------------------------
  // 📤 IMPORT FULL JSON FILE FROM DOWNLOADS FOLDER
  // -----------------------------------------------------------------
  static Future<bool> importDataFromJsonFile({
    required File file,
    required bool userChoiceReplace,
    Future<void> Function()? onDataReload,
  }) async {
    try {
      final jsonString = await file.readAsString();
      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) return false;
      Map<String, dynamic> newData = Map<String, dynamic>.from(decoded);

      Map<String, dynamic> oldData = await _loadData();

      // ---------------------- SKIP MODE ----------------------
      if (!userChoiceReplace) {
        newData.forEach((key, value) {
          // LIST KEYS → customers, items, invoices
          if (oldData[key] is List && value is List) {
            List oldList = oldData[key];
            List newList = value;

            for (var newItem in newList) {
              final newId = newItem["id"] ?? newItem["invoiceNo"];
              final exists = oldList.any(
                    (item) =>
                item["id"] == newId ||
                    item["invoiceNo"] == newId,
              );
              if (!exists) oldList.add(newItem); // add only if not exists
            }
          }

          // PROFILE → merge but skip duplicate bank accounts
          else if (key == "profile" && value is Map) {
            if (oldData[key] is! Map) {
              oldData[key] = value;
            } else {
              Map<String, dynamic> newProfile = Map<String, dynamic>.from(value);
              newProfile.remove("bankAccounts");
              oldData[key].addAll(newProfile);

              if (value["bankAccounts"] is List) {
                List newBanks = value["bankAccounts"];
                oldData[key]["bankAccounts"] ??= [];
                List oldBanks = oldData[key]["bankAccounts"];

                for (var bank in newBanks) {
                  final newBankId = bank["id"];
                  final exists = oldBanks.any((b) => b["id"] == newBankId);
                  if (!exists) oldBanks.add(bank);
                }
              }
            }
          }

          // OTHER MAP KEYS → add only if key not found
          else {
            if (!oldData.containsKey(key)) oldData[key] = value;
          }
        });
      }

      // ---------------------- SMART REPLACE MODE ----------------------
      else {
        newData.forEach((key, value) {
          // LIST KEYS → customers, items, invoices
          if (oldData[key] is List && value is List) {
            List oldList = oldData[key];
            List newList = value;

            for (var newItem in newList) {
              final newId = newItem["id"] ?? newItem["invoiceNo"];
              final index = oldList.indexWhere(
                    (item) =>
                item["id"] == newId ||
                    item["invoiceNo"] == newId,
              );
              if (index != -1)
                oldList[index] = newItem; // replace
              else
                oldList.add(newItem); // add
            }
          }

          // PROFILE → merge + replace bank accounts
          else if (key == "profile" && value is Map) {
            if (oldData[key] is! Map) {
              oldData[key] = value;
            } else {
              Map<String, dynamic> newProfile = Map<String, dynamic>.from(value);
              newProfile.remove("bankAccounts");
              oldData[key].addAll(newProfile);

              if (value["bankAccounts"] is List) {
                List newBanks = value["bankAccounts"];
                oldData[key]["bankAccounts"] ??= [];
                List oldBanks = oldData[key]["bankAccounts"];

                for (var bank in newBanks) {
                  final newBankId = bank["id"];
                  final index = oldBanks.indexWhere((b) => b["id"] == newBankId);
                  if (index != -1)
                    oldBanks[index] = bank; // replace
                  else
                    oldBanks.add(bank); // add
                }
              }
            }
          }

          // OTHER KEYS → full overwrite
          else {
            oldData[key] = value;
          }
        });
      }

      await _saveData(oldData);
      if (onDataReload != null) await onDataReload();
      return true;
    } catch (e) {
      print("❌ Import failed: $e");
      return false;
    }
  }

}

class PdfSaver {
  static Future<File> savePdfFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    // Always available internal storage
    final dir = await getApplicationDocumentsDirectory();

    // Create folder if not exists
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(bytes, flush: true);

    return file;
  }
}
