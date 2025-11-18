import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice/widgets/buttons/custom_iconbutton.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  final String? initialSignature;

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
  bool isFullscreen = false;

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
      Navigator.pop(context, widget.initialSignature);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Please add a signature before saving.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      body: Stack(
        children: [
          // ⭐ Page content (your existing appbar + signature area)
          Column(
            children: [
              // ⭐ Animated AppBar
              AnimatedContainer(
                margin: EdgeInsets.only(top: 20, right: 5, left: 5),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: isFullscreen ? 0 : kToolbarHeight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isFullscreen ? 0 : 1,
                  child: _buildAppBar(),
                ),
              ),

              // ⭐ Signature Drawing Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    bottom: 10,
                    right: 16,
                  ),
                  child: _buildSignatureArea(),
                ),
              ),
            ],
          ),

          // ⭐ Floating FULLSCREEN EXIT button
          if (isFullscreen)
            Positioned(
              top: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: isFullscreen ? 1 : 0,
                child: _floatingExitButton(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _floatingExitButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.fullscreen_exit, color: Colors.white, size: 20),
          onPressed: () {
            setState(() => isFullscreen = false);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ⭐ RESPONSIVE APP BAR (NO OVERFLOW)
  // ---------------------------------------------------------------------
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(color: Color(0xFFF0F2F5)),
      child: Row(
        children: [
          // 🟩 EXPANDED LEFT SIDE (Prevents Overflow)
          Expanded(
            child: Row(
              children: [
                CustomIconButton(
                  icon: Icons.arrow_back,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    "Create Signature",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🟦 AUTO RESPONSIVE BUTTONS (Wrap)
          Wrap(
            spacing: 10,
            children: [
              CustomIconButton(
                icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                backgroundColor: Colors.white,
                borderColor: Colors.black,
                textColor: Colors.black,
                iconSize: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                onTap: () {
                  setState(() => isFullscreen = !isFullscreen);
                },
              ),

              CustomIconButton(
                icon: Icons.refresh_rounded,
                backgroundColor: Colors.white,
                borderColor: Colors.black,
                textColor: Colors.black,
                iconSize: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                onTap: () {
                  _controller.clear();
                  setState(() => _existingSignatureBytes = null);
                },
              ),

              CustomIconButton(
                icon: Icons.check,
                backgroundColor: Colors.white,
                borderColor: Color(0xFF009A75),
                textColor: Color(0xFF009A75),
                iconSize: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                onTap: _saveSignature,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ⭐ SIGNATURE DRAWING AREA
  // ---------------------------------------------------------------------
  Widget _buildSignatureArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Signature(
                    controller: _controller,
                    backgroundColor: Colors.grey[100]!,
                  ),

                  if (_existingSignatureBytes != null)
                    IgnorePointer(
                      child: Image.memory(
                        _existingSignatureBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
