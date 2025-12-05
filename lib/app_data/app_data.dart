import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/add_items_model.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/models/invoice_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:invoice/models/settings_model.dart';

class AppData {
  static final AppData _instance = AppData._internal();

  factory AppData() => _instance;

  AppData._internal();

  List<CustomerModel> customers = [];
  List<InvoiceModel> invoices = [];
  List<AddItemModel> items = [];
  int lastInvoiceNumber = 0;
  ProfileModel? profile;
  SettingsModel settings = SettingsModel();
  List<BankAccountModel> bankAccounts = [];

  bool get userHasRated {
    return invoices.any((invoice) => invoice.hasRated == true);
  }

  void markUserRated() {
    if (invoices.isNotEmpty) {
      invoices.last.hasRated = true;
    }
  }

  // ✅ Default labels
  static Map<String, String> itemTitles = {
    'descLabel': 'Product',
    'qtyLabel': 'Qty',
    'rateLabel': 'Price',
  };

  // ✅ Load everything from local storage
  Future<void> loadAllData() async {
    final all = await InvoiceStorage.loadAll();
    customers = all["customers"];
    invoices = all["invoices"];
    items = all["items"];
    profile = all["profile"];

    final storedList = all["bankAccounts"];

    if (storedList is List) {
      bankAccounts = storedList.map((e) {
        if (e is BankAccountModel) {
          return e; // Already parsed model
        } else if (e is Map<String, dynamic>) {
          return BankAccountModel.fromJson(e); // JSON → Model
        } else {
          throw Exception("Invalid bank account data type: ${e.runtimeType}");
        }
      }).toList();
    } else {
      bankAccounts = [];
    }


    final settingsData = all["settings"];
    if (settingsData is SettingsModel) {
      settings = settingsData;
    } else if (settingsData is Map<String, dynamic>) {
      settings = SettingsModel.fromJson(settingsData);
    } else {
      settings = SettingsModel(); // default
    }

    _recalculateLastNumber();
  }

  void _recalculateLastNumber() {
    if (invoices.isEmpty) {
      lastInvoiceNumber = 0;
      return;
    }

    final nums =
        invoices
            .map(
              (inv) =>
                  int.tryParse(
                    inv.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0,
            )
            .toList()
          ..sort();

    int next = 1;
    for (final n in nums) {
      if (n == next) {
        next++;
      } else if (n > next) {
        break;
      }
    }
    lastInvoiceNumber = next - 1;
  }

  String previewNextInvoiceNo() {
    if (invoices.isEmpty) return "#01";

    final usedNumbers = invoices
        .map(
          (inv) =>
              int.tryParse(inv.invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) ??
              0,
        )
        .toList();

    int maxNumber = usedNumbers.isEmpty
        ? 0
        : usedNumbers.reduce((a, b) => a > b ? a : b);

    return "#${(maxNumber + 1).toString().padLeft(2, '0')}";
  }

  void incrementInvoiceNo(String invoiceNo) {
    final num = int.tryParse(invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (num > lastInvoiceNumber) lastInvoiceNumber = num;
  }

  // ✅ Update full settings
  void updateSettings(SettingsModel newSettings) {
    settings = newSettings;
  }

  // ✅ Update a single field
  void updateSettingField(String key, dynamic value) {
    final json = settings.toJson();
    json[key] = value;
    settings = SettingsModel.fromJson(json);
  }

  Future<void> saveAllData() async {
    await InvoiceStorage.saveAll(
      customers: customers,
      invoices: invoices,
      items: items,
      profile: profile,
      settings: settings,
    );
  }
}
