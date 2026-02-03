import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  // የ Render ሰርቨርህ Endpoint (ቁልፉ በሰርቨርህ በኩል ይያዛል)
  static const String _backendAiUrl =
      'https://cv-maker-pro.onrender.com/api/generate-summary';

  static Future<String> askAI(String contextData, String sectionType,
      {bool isAmharic = false}) async {
    try {
      // ለ Render ሰርቨር የሚላክ ዳታ
      final response = await http
          .post(
            Uri.parse(_backendAiUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({"context": contextData, "isAmharic": isAmharic}),
          )
          .timeout(const Duration(seconds: 45)); // AI ስለሆነ ትንሽ ሰዓት ሊወስድ ይችላል

      if (response.statusCode == 200) {
        // utf8.decode ለአማርኛ ፊደላት ወሳኝ ነው
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String result = data['summary'] ?? "";
        return _cleanResponse(result);
      } else {
        debugPrint("Server Error: ${response.statusCode} - ${response.body}");
        throw Exception("Backend failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Full AI Connection Error: $e");
      // ሰርቨሩ ካልሰራ የሚመለስ Default ጽሁፍ
      return isAmharic
          ? "ባለኝ የሥራ ልምድ እና ባካበትኩት ክህሎት ለድርጅትዎ ከፍተኛ አስተዋጽኦ ማበርከት የምችል ታታሪ ባለሙያ ነኝ።"
          : "I am an experienced professional with a proven track record of delivering high-quality results and contributing to success.";
    }
  }

  static String _cleanResponse(String text) {
    // አላስፈላጊ መለያዎችን (Labels) የሚያጠፋ
    final pattern = RegExp(
      r"Summary:|Result:|Note:|Paragraph:|Introduction:|Professional Summary:",
      caseSensitive: false,
    );

    return text
        .replaceAll('"', '')
        .replaceAll("'", "")
        .replaceAll(pattern, "")
        .trim();
  }
}
