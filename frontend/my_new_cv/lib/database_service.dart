import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'cv_model.dart';

class DatabaseService {
  // 1. የ Render ሰርቨር አድራሻ
  static const String baseUrl = "https://cv-maker-pro.onrender.com";
  static const String syncUrl = "$baseUrl/api/sync-cv";

  // --- 1. መረጃውን ወደ ሰርቨር መላክ (Sync) ---
  Future<bool> saveCompleteCv(CvModel cvData, String userId) async {
    try {
      // ዳታውን ወደ Map ቀይር
      final Map<String, dynamic> payload = cvData.toMap();

      // የ User ID መጨመር
      payload['uid'] = userId;

      debugPrint("🚀 Sending Payload to Render...");
      debugPrint("Payload content: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(syncUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Sync Successful: ${response.body}");
        return true;
      } else {
        // ስህተት ካለ እዚህ ጋር ዝርዝሩን ያሳየናል
        debugPrint("❌ Sync Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Connection Error: $e");
      return false;
    }
  }

  // --- 2. መረጃውን ከ ሰርቨር መልሶ ለማምጣት ---
  Future<Map<String, dynamic>?> fetchUserCv(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$syncUrl/$userId"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Fetch Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("⚠️ API Fetch Error: $e");
      return null;
    }
  }
}
