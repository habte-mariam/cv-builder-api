import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'cv_model.dart';
import 'pdf_generator.dart';
import 'database_helper.dart';
import 'database_service.dart';

class CvPreviewScreen extends StatefulWidget {
  final CvModel cvModel;
  final int templateIndex;
  final Color primaryColor;

  const CvPreviewScreen({
    super.key,
    required this.cvModel,
    required this.templateIndex,
    required this.primaryColor,
  });

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  Uint8List? _currentPdfBytes;
  bool _isSyncing = false;

// 1. ዳታውን ወደ Python/Supabase የሚልክ ተግባር (Manual)
  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    try {
      // 💡 በየጊዜው አዲስ UID በመፍጠር "Duplicate Key" ስህተትን እናስቀራለን
      final String uniqueUid = "user_${DateTime.now().millisecondsSinceEpoch}";

      debugPrint("🚀 Syncing to Python Server at 192.168.1.100...");
      debugPrint("🔑 Using Temporary UID: $uniqueUid");

      await DatabaseService().saveCompleteCv(widget.cvModel, uniqueUid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("✅ Cloud Sync Successful! (ID: $uniqueUid)"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("❌ Sync Error: $e");
      if (mounted) {
        String errorMsg = e.toString();
        // ለተጠቃሚው ግልጽ የሆነ መልእክት ለማሳየት
        if (errorMsg.contains("timed out")) {
          errorMsg = "ሰርቨሩ አልተገኘም (IP አድራሻውን ወይም WiFi ቼክ ያድርጉ)";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Connection Error: $errorMsg"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CV Preview",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        // *** ዋናው ለውጥ እዚህ ጋር ነው - የደመና ምልክቱን ይጨምራል ***
        actions: [
          _isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined,
                      color: Colors.indigo, size: 28),
                  onPressed: _manualSync, // ይህንን ተጫን ዳታው እንዲላክ
                  tooltip: "Sync to Cloud",
                ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 900 ? 800 : screenWidth,
          child: PdfPreview(
            build: (PdfPageFormat format) async {
              try {
                final settings = await DatabaseHelper.instance.getSettings();
                final String fontFamily = settings['fontFamily'] ?? 'Poppins';
                final String fontSize = settings['fontSize'] ?? 'Medium';

                final Uint8List pdfBytes = await PdfGenerator.generatePdf(
                  widget.cvModel,
                  widget.templateIndex,
                  widget.primaryColor,
                  fontFamily,
                  fontSize,
                );

                _currentPdfBytes = pdfBytes;
                return pdfBytes;
              } catch (e) {
                return await _errorPdf("ስህተት ተከስቷል: ${e.toString()}");
              }
            },
            initialPageFormat: PdfPageFormat.a4,
            canChangePageFormat: false,
            canDebug: false,
            loadingWidget:
                const CircularProgressIndicator(color: Colors.indigo),
            actions: [
              PdfPreviewAction(
                icon: const Icon(Icons.save_alt),
                onPressed: (context, build, format) async {
                  if (_currentPdfBytes != null) {
                    await PdfGenerator.downloadAndSaveCv(
                        context, _currentPdfBytes!, widget.cvModel.firstName);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _errorPdf(String message) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Text(message))));
    return pdf.save();
  }
}
