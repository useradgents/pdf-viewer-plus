import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// A utility class for PDF-related operations
///
/// This is an internal utility class used by the PDF viewer components.
class PdfUtils {
  /// Loads PDF data from a URL or an asset path
  ///
  /// This method detects if the path is a URL (starting with http:// or https://)
  /// or an asset path, and loads the PDF data accordingly.
  ///
  /// Parameters:
  ///   - path: A string representing either a URL or an asset path to a PDF file
  ///
  /// Returns a [Uint8List] containing the PDF data
  ///
  /// Throws an exception if the PDF cannot be loaded
  static Future<Uint8List> loadPDF(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // It's a URL
      final response = await http.get(Uri.parse(path));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception('Failed to load PDF from URL');
    } else {
      // It's an asset
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    }
  }
}
