import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';

class AppFonts {
  static Map<String, pw.Font> fontMap = {};

  static final List<String> availableFamilies = [
    "Poppins",
    "Arimo",
    "Times",
    "NotoSerif",
    "Abyssinica"
  ];

  static Future<void> init() async {
    if (fontMap.isNotEmpty) return;

    // 1. መሠረታዊ ፎንቶች
    final amharicMain = await _loadFont(
        "assets/fonts/NotoSerifEthiopic-VariableFont_wdth,wght.ttf");
    final timesReg = await _loadFont("assets/fonts/times_regular.ttf");
    final timesBold = await _loadFont("assets/fonts/times_bold.ttf");

    fontMap['Amharic'] = amharicMain ?? pw.Font.times();
    fontMap['Times-Regular'] = timesReg ?? pw.Font.times();
    fontMap['Times-Bold'] = timesBold ?? fontMap['Times-Regular']!;

    // 2. Poppins (ያሉህን ፋይሎች ብቻ ጥራ)
    final popReg = await _loadFont("assets/fonts/Poppins-Regular.ttf");
    final popBold = await _loadFont("assets/fonts/Poppins-Bold.ttf");
    if (popReg != null) fontMap["Poppins-Regular"] = popReg;
    if (popBold != null) fontMap["Poppins-Bold"] = popBold;

    // 3. Arimo (ያሉህን ፋይሎች ብቻ ጥራ)
    final arimoReg = await _loadFont("assets/fonts/Arimo-Regular.ttf");
    final arimoBold = await _loadFont("assets/fonts/Arimo-Bold.ttf");
    if (arimoReg != null) fontMap["Arimo-Regular"] = arimoReg;
    if (arimoBold != null) fontMap["Arimo-Bold"] = arimoBold;

    // 4. Abyssinica (ትክክለኛውን ፋይል ጥራ)
    final abyssSIL = await _loadFont("assets/fonts/AbyssinicaSIL-Regular.ttf");
    if (abyssSIL != null) fontMap["Abyssinica-Regular"] = abyssSIL;
  }

  static pw.TextStyle getStyle({
    required String text,
    required double size,
    String? preferredFamily,
    bool isBold = false,
    bool isItalic = false,
    PdfColor color = PdfColors.black,
  }) {
    pw.Font? selectedFont;

    if (hasEthiopic(text)) {
      selectedFont = fontMap['Amharic'];
    } else {
      String family = preferredFamily ?? 'Times';
      if (family == "Times New Roman") family = "Times";

      // ትክክለኛውን የፎንት ቁልፍ (Key) መፈለጊያ
      String key = "$family-Regular";
      if (isBold && isItalic)
        key = "$family-BoldItalic";
      else if (isBold)
        key = "$family-Bold";
      else if (isItalic) key = "$family-Italic";

      selectedFont = fontMap[key] ??
          fontMap["$family-Regular"] ??
          fontMap['Times-Regular'];
    }

    final finalFont =
        selectedFont ?? fontMap['Times-Regular'] ?? pw.Font.times();

    return pw.TextStyle(
      font: finalFont,
      fontSize: size,
      color: color,
      fontFallback: [fontMap['Amharic'] ?? pw.Font.times()],
    );
  }

  static bool hasEthiopic(String text) =>
      RegExp(r'[\u1200-\u137F]').hasMatch(text);

  static Future<pw.Font?> _loadFont(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return pw.Font.ttf(data);
    } catch (e) {
      debugPrint("⚠️ Font Load Warning ($path): $e");
      return null;
    }
  }
}
