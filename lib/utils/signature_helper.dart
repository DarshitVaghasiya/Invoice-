import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class SignatureHelper {
  /// Converts Base64 string → pw.MemoryImage
  /// Returns null if Base64 is empty or invalid.
  static pw.MemoryImage? fromBase64(String? base64String) {
    if (base64String == null || base64String.trim().isEmpty) {
      return null;
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return pw.MemoryImage(bytes);
    } catch (e) {
      print("❌ SignatureHelper Error: $e");
      return null;
    }
  }
}
