import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/screens/home/invoice_list.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  static Future<void> saveUserData({
    required String name,
    required String email,
    required String address,
    required String contact,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("address", address);
    await prefs.setString("contact", contact);
    await prefs.setBool("isUserSaved", true);
  }

  static Future<Map<String, String?>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString("name"),
      "email": prefs.getString("email"),
      "address": prefs.getString("address"),
      "contact": prefs.getString("contact"),
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600; // tablet/desktop breakpoint

    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "User Details",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009A75),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Responsive Layout
                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        textFormField(
                                          controller: nameController,
                                          labelText: "Full Name",
                                          prefixIcon: Icon(Icons.person),
                                          keyboardType: TextInputType.multiline,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? "Please enter your name"
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        textFormField(
                                          controller: emailController,
                                          labelText: "Email",
                                          prefixIcon: Icon(Icons.email),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter your email";
                                            } else if (!RegExp(
                                              r'^[^@]+@[^@]+\.[^@]+',
                                            ).hasMatch(value)) {
                                              return "Enter a valid email";
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        textFormField(
                                          controller: addressController,
                                          labelText: "Address",
                                          prefixIcon: Icon(Icons.home),
                                          keyboardType: TextInputType.multiline,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? "Please enter your address"
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        textFormField(
                                          controller: contactController,

                                          labelText: "Contact No",
                                          prefixIcon: Icon(Icons.phone),
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                              10,
                                            ),
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  textFormField(
                                    controller: nameController,
                                    labelText: "Full Name",
                                    prefixIcon: Icon(Icons.person),
                                    keyboardType: TextInputType.multiline,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? "Please enter your name"
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  textFormField(
                                    controller: emailController,
                                    labelText: "Email",
                                    prefixIcon: Icon(Icons.email),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your email";
                                      } else if (!RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+',
                                      ).hasMatch(value)) {
                                        return "Enter a valid email";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  textFormField(
                                    controller: addressController,
                                    labelText: "Address",
                                    prefixIcon: Icon(Icons.home),
                                    keyboardType: TextInputType.multiline,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? "Please enter your address"
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  textFormField(
                                    controller: contactController,
                                    labelText: "Contact No",
                                    prefixIcon: Icon(Icons.phone),
                                    keyboardType: TextInputType.phone,
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
                              ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            label: 'Next',
                            icon: Icons.save,
                            color: Color(0xFF009A75),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await saveUserData(
                                  name: nameController.text,
                                  email: emailController.text,
                                  address: addressController.text,
                                  contact: contactController.text,
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const InvoiceListPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
