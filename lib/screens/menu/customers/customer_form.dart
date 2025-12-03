import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/app_data/app_data.dart';
import 'package:invoice/models/customer_model.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:uuid/uuid.dart';

class CustomerForm extends StatefulWidget {
  final CustomerModel? existingCustomer;
  final int? index;

  const CustomerForm({super.key, this.existingCustomer, this.index});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();
  final panNo = TextEditingController();
  final gstNo = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  bool isEditing = false;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (widget.existingCustomer != null) {
      final c = widget.existingCustomer!;
      nameController.text = c.name;
      emailController.text = c.email;
      phoneController.text = c.phone;
      companyController.text = c.company;
      panNo.text = c.panCard;
      gstNo.text = c.gst;
      streetController.text = c.street;
      cityController.text = c.city;
      stateController.text = c.state;
      countryController.text = c.country;
      isEditing = false;
    } else {
      isEditing = true;
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = CustomerModel(
      id: widget.existingCustomer?.id ?? uuid.v4(),
      company: companyController.text,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      panCard: panNo.text,
      gst: gstNo.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      country: countryController.text,
    );

    // ✅ Update in-memory data only
    if (widget.index != null) {
      AppData().customers[widget.index!] = customer;
    } else {
      AppData().customers.add(customer);
    }

    // ✅ Return updated customer model to previous screen
    Navigator.pop(context, customer);
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
        double titleFontSize = isMobile ? 24 : (isTablet ? 22 : 26);

        return Scaffold(
          backgroundColor: Color(0xFFF0F2F5),
          appBar: AppBar(
            title: Text(
              widget.existingCustomer == null
                  ? "Customer Information"
                  : "Customer Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFF0F2F5),
            scrolledUnderElevation: 0,
            elevation: 0,
            foregroundColor: Colors.black,
            actions: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomIconButton(
                    icon: isEditing ? Icons.save : Icons.edit,
                    label: isEditing ? "Save" : "Edit",
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: isEditing
                        ? const Color(0xFF009A75)
                        : Colors.yellow.shade800,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (isEditing) {
                        _saveCustomer();
                      } else {
                        setState(() => isEditing = true);
                      }
                    },
                  ),
                ),
            ],
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      _buildSection(
                        "Organization Information",
                        [
                          textFormField(
                            labelText: "Company",
                            controller: companyController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Name",
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please Enter Name.";
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
                                return "Please Enter Email.";
                              }
                              return null;
                            },
                          ),
                          textFormField(
                            labelText: "Phone Number",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: isEditing,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your contact no";
                              } else if (!RegExp(
                                r'^[0-9]{10}$',
                              ).hasMatch(value)) {
                                return "Enter a valid 10-digit number";
                              }
                              return null;
                            },
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
                            controller: panNo,
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "GST No",
                            controller: gstNo,
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
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
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "City",
                            controller: cityController,
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "State",
                            controller: stateController,
                            keyboardType: TextInputType.text,
                            enabled: isEditing,
                          ),
                          textFormField(
                            labelText: "Country",
                            controller: countryController,
                            keyboardType: TextInputType.text,
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
                    height: 100,
                    width: double.infinity,
                    child: Row(
                      children: [
                        // Left button
                        Expanded(
                          child: CustomElevatedButton(
                            label: isEditing ? "Save" : "Edit",
                            icon: isEditing ? Icons.save : Icons.edit,
                            backgroundColor: isEditing
                                ? const Color(0xFF009A75)
                                : Colors.orange,
                            onPressed: () {
                              if (isEditing) {
                                _saveCustomer();
                              } else {
                                setState(() => isEditing = true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right button
                        Expanded(
                          child: CustomIconButton(
                            label: "Cancel",
                            borderColor: Colors.red,
                            textColor: Colors.red,
                            fontSize: 18,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
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
    return Container(
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _buildResponsiveGrid(children, crossAxisCount, spacing),
          ],
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
      alignment: WrapAlignment.start,
      children: children
          .map(
            (child) => SizedBox(width: itemWidth.clamp(260, 380), child: child),
          )
          .toList(),
    );
  }
}
