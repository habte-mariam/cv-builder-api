import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart'; 
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart'; // ይህን መጨመርዎን ያረጋግጡ
import 'master_template.dart'; 
import 'cv_model.dart'; 
import 'app_fonts.dart';
import 'database_helper.dart'; 

class PdfGenerator {
  /// ፒዲኤፉን ዳታ (Uint8List) አድርጎ የሚያመነጭ ፋንክሽን
  static Future<Uint8List> generatePdf(
    CvModel model,
    int templateIndex,
    Color flutterColor,
    String fontFamily, 
    String fontSizeString,
  ) async {
    await AppFonts.init(); 

    // የጽሁፍ መጠን ሎጂክ
    double bodySize;
    switch (fontSizeString) {
      case "Small": bodySize = 8.5; break;
      case "Large": bodySize = 12.0; break;
      case "Medium":
      default: bodySize = 10.0; break;
    }

    final pdf = pw.Document();
    final PdfColor primaryColor = PdfColor.fromInt(flutterColor.value);

    // የፕሮፋይል ፎቶ ካለ ማንበብ
    pw.MemoryImage? img;
    if (model.profileImagePathPath.isNotEmpty) {
      final File imageFile = File(model.profileImagePathPath);
      if (await imageFile.exists()) {
        img = pw.MemoryImage(await imageFile.readAsBytes());
      }
    }

    // ዲዛይኑን መምረጥ
    CvDesign selectedDesign = CvDesign.values[templateIndex % CvDesign.values.length];

    // ገጹን ማዘጋጀት
    MasterTemplate.addPage(
      pdf,
      model,
      selectedDesign,
      primaryColor,
      img,
      bodySize,
      fontFamily, 
    );

    return pdf.save();
  }

  /// ፒዲኤፉን "Downloads" ፎልደር ውስጥ ሴቭ አድርጎ ዳታቤዝ ላይ የሚመዘግብ ፋንክሽን
  static Future<String?> downloadAndSaveCv(
  BuildContext context, 
  Uint8List pdfBytes, 
  String firstName
) async {
  try {
    // 1. የ Storage ፍቃድ መጠየቅ (ለአንድሮይድ)
    if (Platform.isAndroid) {
      // አንድሮይድ 13+ (SDK 33) ከሆነ 'manageExternalStorage' ወይም በቀጥታ መጻፍ ይቻላል
      // ነገር ግን ለተኳኋኝነት 'storage' ፐርሚሽን መጠየቅ የተለመደ ነው
      var status = await Permission.storage.request();
      
      // ፍቃድ ከተከለከለ ለተጠቃሚው ማሳወቅ
      if (status.isDenied || status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please grant storage permission to download the CV"))
          );
          // ወደ ስልኩ ሴቲንግ እንዲሄድ መጋበዝ ይቻላል
          if (status.isPermanentlyDenied) {
            openAppSettings();
          }
        }
        return null;
      }
    }

    Directory? downloadsDirectory;
    
    if (Platform.isAndroid) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (!await downloadsDirectory.exists()) {
        downloadsDirectory = await getExternalStorageDirectory();
      }
    } else {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    }

    final String fileName = "${firstName}_CV_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final String filePath = "${downloadsDirectory!.path}/$fileName";
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    await DatabaseHelper.instance.insertSavedCv(fileName, filePath);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("CV Saved to Downloads!"),
          backgroundColor: Colors.indigo[900],
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "OPEN",
            textColor: Colors.yellow,
            onPressed: () => OpenFilex.open(filePath),
          ),
        ),
      );
    }
    return filePath;
  } catch (e) {
    debugPrint("Download Error: $e");
    return null;
  }
}
}