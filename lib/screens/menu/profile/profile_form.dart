import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/data_storage/InvoiceStorage.dart';
import 'package:invoice/models/bank_account_model.dart';
import 'package:invoice/models/profile_model.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/utils/device_utils.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';

class InvoiceProfileForm extends StatefulWidget {
  const InvoiceProfileForm({super.key});

  @override
  State<InvoiceProfileForm> createState() => _InvoiceProfileFormState();
}

class _InvoiceProfileFormState extends State<InvoiceProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final panNoController = TextEditingController();
  final gstNoController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiController = TextEditingController();

  bool isEditing = false;
  bool showTaxDetails = true;
  bool showBank = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
    _loadSettings();
    _loadDeviceID();
  }

  String deviceID = "";

  Future<void> _loadDeviceID() async {
    deviceID = await DeviceUtils.getDeviceID();
    setState(() {});
  }

  Future<void> _loadSettings() async {
    final settings = await InvoiceStorage.loadSettings();
    setState(() {
      showTaxDetails = settings.showTax;
      showBank = settings.showBank;
    });
  }

  Future<void> _loadExistingProfile() async {
    final profile = AppData().profile;

    if (profile == null) {
      setState(() => isEditing = true);
      return;
    }

    setState(() {
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      streetController.text = profile.street;
      cityController.text = profile.city;
      stateController.text = profile.state;
      countryController.text = profile.country;
      panNoController.text = profile.pan;
      gstNoController.text = profile.gst;

      final defaultBank = AppData().profile!.bankAccounts!.isNotEmpty
          ? AppData().profile!.bankAccounts!.firstWhere(
              (b) => b.isPrimary,
              orElse: () => AppData().profile!.bankAccounts!.first,
            )
          : null;

      if (defaultBank != null) {
        bankNameController.text = defaultBank.bankName;
        accountHolderController.text = defaultBank.accountHolder;
        accountNumberController.text = defaultBank.accountNumber;
        ifscController.text = defaultBank.ifsc;
        upiController.text = defaultBank.upi;
      }
      print(profile);
      isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String base64Image;
    if (_profileImage != null) {
      final imageBytes = await _profileImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    } else {
      base64Image = AppData().profile?.profileImageBase64 ?? '';
    }
    String generateTimestampId() {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    List<BankAccountModel> updatedBankAccounts = List.from(
      AppData().bankAccounts,
    );


    if (bankNameController.text.isNotEmpty ||
        accountHolderController.text.isNotEmpty ||
        accountNumberController.text.isNotEmpty ||
        ifscController.text.isNotEmpty ||
        upiController.text.isNotEmpty) {
      final primaryBank = BankAccountModel(
        id: generateTimestampId(),
        bankName: bankNameController.text,
        accountHolder: accountHolderController.text,
        accountNumber: accountNumberController.text,
        ifsc: ifscController.text,
        upi: upiController.text,
        isPrimary: true,
      );

      updatedBankAccounts.removeWhere((b) => b.isPrimary);

      updatedBankAccounts.insert(0, primaryBank);
    }

    final profile = ProfileModel(
      userID: deviceID,
      profileImageBase64: base64Image,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      country: countryController.text,
      pan: panNoController.text,
      gst: gstNoController.text,
      bankAccounts: updatedBankAccounts,
    );

    AppData().profile = profile;
    AppData().bankAccounts = updatedBankAccounts;

    await InvoiceStorage.saveProfile(profile);

    setState(() => isEditing = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceListPage()),
    );
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    if (_profileImage == null) {
      await _selectImageFromGallery();
    } else {
      _showFullImagePreview();
    }
  }

  void _showFullImagePreview() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.95),
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(_profileImage!, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: CustomIconButton(
                  icon: Icons.close,
                  textColor: Colors.white,
                  iconSize: 32,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomIconButton(
                          icon: Icons.edit_outlined,
                          label: "Edit",
                          fontSize: 18,
                          textColor: Colors.white,
                          onTap: () async {
                            Navigator.pop(context);
                            await _selectImageFromGallery();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomIconButton(
                          icon: Icons.close,
                          label: "Remove",
                          fontSize: 18,
                          textColor: Colors.white,
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() => _profileImage = null);

                            // 🧹 Also clear from profile model & storage
                            final profile = AppData().profile;
                            if (profile != null) {
                              profile.profileImageBase64 = '';
                              await InvoiceStorage.saveProfile(profile);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Fixed version — shows image immediately after import
  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _profileImage = File(pickedFile.path);
    });

    final bytes = await _profileImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final existingProfile =
        AppData().profile ??
        ProfileModel(
          userID: '',
          profileImageBase64: '',
          name: '',
          email: '',
          phone: '',
          street: '',
          city: '',
          state: '',
          country: '',
          pan: '',
          gst: '',
          bankAccounts: [],
        );
    final updatedProfile = existingProfile.copyWith(
      profileImageBase64: base64Image,
    );
    AppData().profile = updatedProfile;
    await InvoiceStorage.saveProfile(updatedProfile);
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
        final double titleFontSize = isMobile ? 24 : (isTablet ? 28 : 32);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              isEditing ? "Create Profile" : "User Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFFF0F2F5),
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black,
            actions: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomIconButton(
                    icon: isEditing ? Icons.save : Icons.edit,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    label: isEditing ? "Save" : "Edit",
                    fontSize: 22,
                    iconSize: 30,
                    textColor: Colors.white,
                    backgroundColor: isEditing
                        ? const Color(0xFF009A75)
                        : Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (isEditing) {
                        _saveProfile();
                      } else {
                        setState(() => isEditing = true);
                      }
                    },
                  ),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSection(
                        "Organization Image",
                        [],
                        crossAxisCount,
                        spacing,
                      ),
                      _buildSection(
                        "Contact Info",
                        [
                          textFormField(
                            labelText: "Name",
                            controller: nameController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Phone Number",
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ],
                        crossAxisCount,
                        spacing,
                      ),
                      _buildSection(
                        "Address Info",
                        [
                          textFormField(
                            labelText: "Street",
                            controller: streetController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "City",
                            controller: cityController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "State",
                            controller: stateController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Country",
                            controller: countryController,
                            enabled: isEditing,
                          ),
                        ],
                        crossAxisCount,
                        spacing,
                      ),
                      _buildSection(
                        "Tax Info",
                        [
                          textFormField(
                            labelText: "PAN No",
                            controller: panNoController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "GST No",
                            controller: gstNoController,
                            enabled: isEditing,
                          ),
                        ],
                        crossAxisCount,
                        spacing,
                      ),
                      _buildSection(
                        "Payment Info",
                        [
                          textFormField(
                            labelText: "Bank Name",
                            controller: bankNameController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Account Holder Name",
                            controller: accountHolderController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Account Number",
                            controller: accountNumberController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "IFSC Code",
                            controller: ifscController,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "UPI ID",
                            controller: upiController,
                            enabled: isEditing,
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
                    height: 90,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            label: isEditing ? "Save" : "Edit",
                            icon: isEditing ? Icons.save : Icons.edit,
                            color: isEditing
                                ? const Color(0xFF009A75)
                                : Colors.orange,
                            onPressed: () {
                              if (isEditing) {
                                _saveProfile();
                              } else {
                                setState(() => isEditing = true);
                              }
                            },
                          ),
                        ),
                        if (!isEditing && AppData().profile != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomIconButton(
                              label: "Cancel",
                              borderColor: Colors.red,
                              textColor: Colors.red,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                        ],
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
    bool isOrgImageSection = title == "Organization Image";
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 825),
        child: Container(
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
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (isOrgImageSection)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF80CBC4), Color(0xFF009688)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (AppData()
                                            .profile
                                            ?.profileImageBase64
                                            ?.isNotEmpty ??
                                        false)
                                  ? MemoryImage(
                                      base64Decode(
                                        AppData().profile!.profileImageBase64!,
                                      ),
                                    )
                                  : null,
                              child:
                                  (_profileImage == null &&
                                      (AppData()
                                              .profile
                                              ?.profileImageBase64
                                              ?.isEmpty ??
                                          true))
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Color(0xFF009688),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              if (children.isNotEmpty) const SizedBox(height: 14),
              if (children.isNotEmpty)
                _buildResponsiveGrid(children, crossAxisCount, spacing),
            ],
          ),
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
