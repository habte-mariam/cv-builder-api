import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  // ለደህንነት ሲባል ቁልፉን በ environment variable መጠቀም ይመከራል
  // ካልሆነ ግን ያንተን ቁልፍ እዚህ ጋር መተካት ትችላለህ
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY', 
      defaultValue: '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');
      
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> askAI(String contextData, String sectionType, {bool isAmharic = false}) async {
    try {
      String systemRole = """
        You are an elite CV ghostwriter. 
        TASK: Write a unique professional summary based ONLY on the provided user data.
        
        STRICT RULES:
        1. PERSPECTIVE: Always write in the FIRST-PERSON ("I", "My").
        2. STRUCTURE: Write exactly ONE cohesive, flowing paragraph. 
        3. LENGTH: The summary MUST be detailed, spanning approximately 5 to 7 lines.
        4. NO BUZZWORDS: Do not use: 'leverage', 'passionate', 'dynamic', 'synergy', 'cutting-edge'.
        5. NO TEMPLATES: Never start with generic "I am a professional...". 
        6. DATA-DRIVEN: Integrate specific job titles, degrees, and skills provided in the context.
        7. CLEAN: No quotes, no "Summary:" label, no intro/outro filler.
      """;

      String userPrompt = isAmharic 
        ? "እባክህ የሚከተለውን መረጃ ተጠቅመህ 'እኔ' ብለህ የሚጀምር፣ በ 7 መስመር የተቀነባበረ አንድ ፕሮፌሽናል አንቀጽ ብቻ ጻፍ። መረጃው፡ $contextData"
        : "Transform this data into a single, compelling 7-line professional paragraph in the first person: $contextData. Focus on specific achievements and avoid generic phrases.";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": systemRole},
            {"role": "user", "content": userPrompt}
          ],
          "temperature": 0.7,
          "max_tokens": 500, // ወደ 500 ዝቅ ብሏል (ለ 7 መስመር በቂ ነው)
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        // utf8.decode መጠቀሙ ለአማርኛ ፊደላት ወሳኝ ነው
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String result = data['choices'][0]['message']['content'];
        return _cleanResponse(result);
      } else {
        debugPrint("API Error Detail: ${response.body}");
        throw Exception("Status Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Full AI Connection Error: $e");
      return isAmharic 
        ? "ባለኝ የሥራ ልምድ እና ባካበትኩት ክህሎት ለድርጅትዎ ከፍተኛ አስተዋጽኦ ማበርከት የምችል ታታሪ ባለሙያ ነኝ።"
        : "I am an experienced professional with a proven track record of delivering high-quality results and contributing to success.";
    }
  }

  static String _cleanResponse(String text) {
    // አላስፈላጊ ቃላትን በሙሉ (በትንሽም በትልቅም ቢጻፉ) የሚያጠፋ Regex
    final pattern = RegExp(
      r"Summary:|Result:|Note:|Paragraph:|Introduction:|Professional Summary:",
      caseSensitive: false,
    );
    
    return text
        .replaceAll('"', '') // ጥቅሶችን ለማጥፋት
        .replaceAll("'", "")
        .replaceAll(pattern, "") // መግቢያ መለያዎችን ለማጥፋት
        .trim();
  }
}