import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:currency_picker/currency_picker.dart';
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
import 'package:invoice/widgets/buttons/custom_tabbar.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:uuid/uuid.dart';

class ClearCircleOverlayPainter extends CustomPainter {
  final Offset center;

  ClearCircleOverlayPainter({required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);

    final radius = size.width * 0.45;

    // Full screen path
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Circle hole
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Remove circle from background
    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      circlePath,
    );

    // Draw overlay
    canvas.drawPath(finalPath, overlayPaint);

    // White circle border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant ClearCircleOverlayPainter oldDelegate) {
    return oldDelegate.center != center;
  }
}

class InvoiceProfileForm extends StatefulWidget {
  const InvoiceProfileForm({super.key});

  @override
  State<InvoiceProfileForm> createState() => _InvoiceProfileFormState();
}

class _InvoiceProfileFormState extends State<InvoiceProfileForm> {
  Offset _circleCenter = Offset.zero;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _cropKey = GlobalKey();

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
  File? _originalImage;
  File? _profileImage;

  final TextEditingController currencyController = TextEditingController();
  bool showCurrency = true;
  Currency? selectedCurrency;
  String currencySymbol = '';
  bool canShowSkip = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
    _loadSettings();
    _loadDeviceID();
  }

  String deviceID = "";
  final uuid = Uuid();

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
      setState(() {
        isEditing = true;
        canShowSkip = true;
      });
      return;
    }

    setState(() {
      canShowSkip = !profile.skipUsed;
      isEditing = false;
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      streetController.text = profile.street;
      cityController.text = profile.city;
      stateController.text = profile.state;
      countryController.text = profile.country;
      panNoController.text = profile.pan;
      gstNoController.text = profile.gst;
      if (profile.currencyCode.isNotEmpty) {
        currencyController.text =
            "${profile.currencyCode} (${profile.currencySymbol})";
      }
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
      isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    String croppedBase64;
    String originalBase64;

    if (_profileImage == null && _originalImage != null) {
      await _cropAndSaveCircleImage();
    }
    // 🔵 CROPPED IMAGE (circle)
    if (_profileImage != null) {
      croppedBase64 = base64Encode(await _profileImage!.readAsBytes());
    } else {
      croppedBase64 = AppData().profile?.profileImageBase64 ?? '';
    }

    // 🔵 ORIGINAL IMAGE (full)
    if (_originalImage != null) {
      originalBase64 = base64Encode(await _originalImage!.readAsBytes());
    } else {
      originalBase64 = AppData().profile?.originalImageBase64 ?? '';
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
        id: uuid.v4(),
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
      userID: uuid.v4(),
      originalImageBase64: originalBase64,
      // ✅ FULL IMAGE
      profileImageBase64: croppedBase64,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      country: countryController.text,
      pan: panNoController.text,
      gst: gstNoController.text,
      currencyCode: selectedCurrency?.code ?? '',
      currencySymbol: selectedCurrency?.symbol ?? '',
      currencyName: selectedCurrency?.name ?? '',
      bankAccounts: updatedBankAccounts,
      skipUsed: AppData().profile?.skipUsed ?? false,
    );

    AppData().profile = profile;
    AppData().bankAccounts = updatedBankAccounts;

    await InvoiceStorage.saveProfile(profile);

    setState(() => isEditing = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceHomeTabPage()),
    );
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    if (_profileImage == null &&
        _originalImage == null &&
        (AppData().profile?.profileImageBase64?.isEmpty ?? true)) {
      await _selectImageFromGallery();
    } else {
      _showFullImagePreview();
    }
  }

  Future<void> _cropAndSaveCircleImage() async {
    if (_originalImage == null) {
      debugPrint("❌ Original image is null");
      return;
    }

    try {
      // 1️⃣ Load original image
      final bytes = await _originalImage!.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      final size = MediaQuery.of(context).size;
      final radius = size.width * 0.45;

      final scaleX = uiImage.width / size.width;
      final scaleY = uiImage.height / size.height;

      final centerX = _circleCenter.dx * scaleX;
      final centerY = _circleCenter.dy * scaleY;
      final imageRadius = radius * scaleX;

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint();

      // 3️⃣ Draw clipped circle
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(imageRadius, imageRadius),
            radius: imageRadius,
          ),
        ),
      );

      canvas.drawImageRect(
        uiImage,
        Rect.fromCircle(center: Offset(centerX, centerY), radius: imageRadius),
        Rect.fromLTWH(0, 0, imageRadius * 2, imageRadius * 2),
        paint,
      );

      final croppedImage = await recorder.endRecording().toImage(
        (imageRadius * 2).toInt(),
        (imageRadius * 2).toInt(),
      );

      final byteData = await croppedImage.toByteData(
        format: ImageByteFormat.png,
      );

      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await Directory.systemTemp.createTemp();
      final file = File('${tempDir.path}/profile_circle.png');
      await file.writeAsBytes(pngBytes);

      setState(() {
        _profileImage = file;
      });
    } catch (e) {
      debugPrint("Circle crop error: $e");
    }
  }

  Future<void> _showFullImagePreview() async {
    if (_originalImage == null) {
      final storedBase64 = AppData().profile?.originalImageBase64;

      if (storedBase64 != null && storedBase64.isNotEmpty) {
        final bytes = base64Decode(storedBase64);

        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/original_restore.png');
        await file.writeAsBytes(bytes);

        _originalImage = file; // ✅ NOW CROP WILL WORK
      }
    }

    final size = MediaQuery.of(context).size;
    _circleCenter = Offset(size.width / 2, size.height / 3);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.95),
        pageBuilder: (_, _, _) {
          return StatefulBuilder(
            builder: (context, setPreviewState) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    GestureDetector(
                      onPanUpdate: (details) {
                        setPreviewState(() {
                          _circleCenter += details.delta;
                        });
                      },
                      child: RepaintBoundary(
                        key: _cropKey,
                        child: Stack(
                          children: [
                            Center(
                              child: InteractiveViewer(
                                minScale: 1,
                                maxScale: 4,
                                child: _buildPreviewImage(),
                              ),
                            ),
                            CustomPaint(
                              size: MediaQuery.of(context).size,
                              painter: ClearCircleOverlayPainter(
                                center: _circleCenter,
                              ),
                            ),
                          ],
                        ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomIconButton(
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
                                label: "Remove",
                                fontSize: 18,
                                textColor: Colors.white,
                                onTap: () async {
                                  Navigator.pop(context);

                                  setState(() {
                                    _profileImage = null;
                                    _originalImage = null; // 🔥 VERY IMPORTANT

                                    if (AppData().profile != null) {
                                      AppData().profile!.profileImageBase64 =
                                          '';
                                      AppData().profile!.originalImageBase64 =
                                          '';
                                    }
                                  });

                                  if (AppData().profile != null) {
                                    await InvoiceStorage.saveProfile(
                                      AppData().profile!,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomIconButton(
                                label: "Save",
                                fontSize: 18,
                                textColor: Colors.white,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  if (_originalImage != null) {
                                    await _cropAndSaveCircleImage();
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPreviewImage() {
    if (_originalImage != null) {
      return Image.file(_originalImage!, fit: BoxFit.contain);
    }

    final originalBase64 = AppData().profile?.originalImageBase64;
    if (originalBase64 != null && originalBase64.isNotEmpty) {
      return Image.memory(base64Decode(originalBase64), fit: BoxFit.contain);
    }

    return const Icon(Icons.image_not_supported, color: Colors.white, size: 80);
  }

  /// ✅ Fixed version — shows image immediately after import
  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _originalImage = File(pickedFile.path); // 🔥 preview & crop
      _profileImage = null; // 🔥 reset old crop
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFullImagePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final crossAxisCount = isMobile ? 1 : 2;
        final crossAxisSpacing = isMobile ? 10.0 : 10.0;
        final double titleFontSize = isMobile ? 24 : (isTablet ? 28 : 32);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              AppData().profile == null
                  ? "Create profile"
                  : isEditing
                  ? "Update Profile"
                  : "User Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            backgroundColor: const Color(0xFFF0F2F5),
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black,
            actions: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomIconButton(
                    icon: isEditing ? Icons.save : Icons.edit,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    label: isEditing ? "Save" : "Edit",
                    fontSize: 20,
                    textColor: Colors.white,
                    backgroundColor: isEditing
                        ? const Color(0xFF009A75)
                        : Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (isEditing) {
                        if (!_formKey.currentState!.validate()) return;
                        _saveProfile();
                      } else {
                        setState(() => isEditing = true);
                      }
                    },
                  ),
                ),
              if (!isMobile)
                if (AppData().profile != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CustomIconButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      label: "Cancel",
                      fontSize: 20,
                      textColor: Colors.red,
                      borderColor: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              if (!isMobile)
                if (isEditing && AppData().profile == null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CustomIconButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      label: "Skip",
                      fontSize: 20,
                      textColor: Colors.black,
                      borderColor: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final skippedProfile = ProfileModel(
                          userID: uuid.v4(),
                          originalImageBase64: '',
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
                          currencyCode: '',
                          currencySymbol: '',
                          currencyName: '',
                          bankAccounts: [],
                          skipUsed: true, // 🔥 MARK SKIPPED
                        );

                        AppData().profile = skippedProfile;
                        await InvoiceStorage.saveProfile(skippedProfile);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InvoiceHomeTabPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
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
                        crossAxisSpacing,
                      ),
                      _buildSection(
                        "Contact Info",
                        [
                          textFormField(
                            labelText: "Name",
                            controller: nameController,
                            enabled: isEditing,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          textFormField(
                            labelText: "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: isEditing,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return "Enter valid email";
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              if (value.length != 10) {
                                return "Enter 10 digit number";
                              }
                              return null;
                            },
                          ),
                        ],
                        crossAxisCount,
                        crossAxisSpacing,
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
                        crossAxisSpacing,
                      ),
                      _buildSection(
                        "Select Currency",
                        [
                          textFormField(
                            labelText: "Select Currency",
                            controller: currencyController,
                            enabled: isEditing,
                            readOnly: true,
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            onTap: () {
                              showCurrencyPicker(
                                context: context,
                                showFlag: true,
                                showCurrencyName: true,
                                showCurrencyCode: true,
                                onSelect: (Currency currency) {
                                  setState(() {
                                    selectedCurrency = currency;
                                    currencyController.text =
                                        "${currency.code} (${currency.symbol})";
                                  });
                                },
                                theme: CurrencyPickerThemeData(
                                  bottomSheetHeight:
                                      MediaQuery.of(context).size.height * 0.95,
                                  backgroundColor: Colors.white,
                                  flagSize: 24,
                                  titleTextStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitleTextStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  inputDecoration: InputDecoration(
                                    labelText: 'Search Currency',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        crossAxisCount,
                        crossAxisSpacing,
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
                        crossAxisSpacing,
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
                        crossAxisSpacing,
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
                            backgroundColor: isEditing
                                ? const Color(0xFF009A75)
                                : Colors.orange.shade700,
                            onPressed: () {
                              if (isEditing) {
                                if (!_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please fill all required details before saving the profile.",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  _saveProfile();
                                }
                              } else {
                                setState(() => isEditing = true);
                              }
                            },
                          ),
                        ),
                        if (isEditing && AppData().profile == null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomIconButton(
                              label: "Skip",
                              borderColor: Colors.black,
                              textColor: Colors.black,
                              fontSize: 16,
                              onTap: () async {
                                final skippedProfile = ProfileModel(
                                  userID: uuid.v4(),
                                  originalImageBase64: '',
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
                                  currencyCode: '',
                                  currencySymbol: '',
                                  currencyName: '',
                                  bankAccounts: [],
                                  skipUsed: true, // 🔥 MARK SKIPPED
                                );

                                AppData().profile = skippedProfile;
                                await InvoiceStorage.saveProfile(
                                  skippedProfile,
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InvoiceHomeTabPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        if (AppData().profile != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomIconButton(
                              label: "Cancel",
                              borderColor: Colors.red,
                              textColor: Colors.red,
                              fontSize: 16,
                              onTap: () {
                                Navigator.pop(context);
                              },
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
    double crossAxisSpacing,
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
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
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
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover, // 🔥 MOST IMPORTANT
                                      )
                                    : (AppData()
                                              .profile
                                              ?.profileImageBase64
                                              ?.isNotEmpty ??
                                          false)
                                    ? Image.memory(
                                        base64Decode(
                                          AppData()
                                              .profile!
                                              .profileImageBase64!,
                                        ),
                                        fit: BoxFit.cover, // 🔥
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
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
                _buildResponsiveGrid(
                  children,
                  crossAxisCount,
                  crossAxisSpacing,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    List<Widget> children,
    int crossAxisCount,
    double crossAxisSpacing,
  ) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 5,
      children: children,
    );
  }
}
