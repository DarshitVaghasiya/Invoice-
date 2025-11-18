import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  final String? initialSignature; // 🟢 new param to show existing signature

  const SignatureScreen({super.key, this.initialSignature});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: null,
  );

  Uint8List? _existingSignatureBytes;

  @override
  void initState() {
    super.initState();
    if (widget.initialSignature != null &&
        widget.initialSignature!.isNotEmpty) {
      _existingSignatureBytes = base64Decode(widget.initialSignature!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    final Uint8List? data = await _controller.toPngBytes();
    if (data != null && data.isNotEmpty) {
      final String base64Signature = base64Encode(data);
      Navigator.pop(context, base64Signature);
    } else if (_existingSignatureBytes != null) {
      // 🟢 Return existing if user didn’t change
      Navigator.pop(context, widget.initialSignature);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a signature before saving.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Create Signature",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ⭐ FULLSCREEN SIGNATURE AREA
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                // ⭐ THIS LayoutBuilder expands correctly
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AbsorbPointer(
                            absorbing: _existingSignatureBytes != null,
                            child: Signature(
                              controller: _controller,
                              backgroundColor: Colors.grey[100]!,
                            ),
                          ),

                          if (_existingSignatureBytes != null)
                            Image.memory(
                              _existingSignatureBytes!,
                              fit: BoxFit.contain,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ BUTTONS
            Row(
              children: [
                Expanded(
                  child: CustomIconButton(
                    label: "Clear",
                    borderColor: Colors.black,
                    backgroundColor: Colors.white,
                    onTap: () {
                      _controller.clear();
                      setState(() => _existingSignatureBytes = null);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomIconButton(
                    label: "Save",
                    backgroundColor: const Color(0xFF009A75),
                    borderColor: const Color(0xFF009A75),
                    textColor: Colors.white,
                    onTap: _saveSignature,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
