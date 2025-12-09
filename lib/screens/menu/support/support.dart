import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_elevatedbutton.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:invoice/widgets/buttons/custom_textformfield.dart';
import 'package:url_launcher/url_launcher.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void sendEmail() async {
    final toEmail = "darshitvaghasiya19@gmail.com";
    final desc = descriptionController.text.trim();

    final body = Uri.encodeComponent(desc);
    final url = "mailto:$toEmail?&body=$body";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not open email app");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        foregroundColor: Colors.black,
        title: const Text(
          "Support",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          if (!isMobile)
            Padding(
              padding: EdgeInsetsGeometry.only(right: 20),
              child: CustomIconButton(
                label: "Send Message",
                textColor: Colors.white,
                backgroundColor: Colors.blue,
                fontSize: 22,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    sendEmail();
                  }
                },
              ),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Text(
                        "We're here to help 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Share your issue or feedback and our team will reach out to you soon.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// Issue Field Card
                  textFormField(
                    labelText: "Describe your issue",
                    controller: descriptionController,
                    maxLines: 7,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your message";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      /// Bottom Submit Button
      bottomNavigationBar: isMobile
          ? Container(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
              child: CustomElevatedButton(
                fontSize: 20,
                label: "Send Message",
                borderRadius: BorderRadius.circular(18),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    sendEmail();
                  }
                },
              ),
            )
          : null,
    );
  }
}
