import 'dart:async';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'ai_service.dart';
import 'cv_model.dart';
import 'custom_bottom_menu.dart';
import 'cv_preview_screen.dart';
import 'database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  List<Map<String, dynamic>> referencesList = [];
  final TextEditingController _summaryController = TextEditingController();

  bool _isLoading = true;
  bool _isGeneratingAI = false;
  bool _isGeneratingPdf = false;
  Timer? _debounce;
  int? _profileId;
  CvModel? _currentCv;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _summaryController.dispose();
    super.dispose();
  }

  // 1. ዳታን ከ SQLite መጫን
  Future<void> _loadStoredData() async {
    try {
      final fullProfile = await DatabaseHelper.instance.getFullProfile();
      if (mounted && fullProfile != null) {
        _profileId = fullProfile['id'];
        _currentCv = CvModel();
        _currentCv!.fromMap(fullProfile);

        setState(() {
          _summaryController.text = fullProfile['summary'] ?? '';
          final savedRefs = fullProfile['user_references'] as List? ?? [];
          if (savedRefs.isNotEmpty) {
            referencesList =
                savedRefs.map((r) => Map<String, dynamic>.from(r)).toList();
          } else {
            _addNewReference();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGeneratePdf() async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);

    try {
      await _saveToDatabase(); // መጀመሪያ ሎካል ሴቭ

      final rawData = await DatabaseHelper.instance.getFullProfile();
      final settings = await DatabaseHelper.instance.getSettings();

      if (rawData != null && mounted) {
        CvModel model = CvModel();
        model.fromMap(rawData);

        // 1. መጀመሪያ ቫሪያብሎቹን እናውጅ (Declare)
        int templateIndex = settings['templateIndex'] ?? 0;
        Color primaryColor = Color(settings['themeColor'] ?? Colors.teal.value);

        // 2. ከዚያ ወደ Python API ለመላክ እንሞክር
        try {
          // ማሳሰቢያ፡ በ database_service.dart ላይ ባለው ፋንክሽን መሠረት 3 argument መሆኑን አረጋግጥ
          final userId =
              FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";
          await DatabaseService().saveCompleteCv(model, userId);
          debugPrint("Python API Sync Success ✅");
        } catch (cloudError) {
          debugPrint("Cloud Sync Failed (Offline Mode): $cloudError");
        }

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CvPreviewScreen(
              cvModel: model,
              templateIndex: templateIndex,
              primaryColor: primaryColor,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  // 3. AI Summary ማመንጫ
  Future<void> _generateAISummary() async {
    if (_isGeneratingAI) return;
    setState(() => _isGeneratingAI = true);

    try {
      final profile = await DatabaseHelper.instance.getFullProfile();
      List expList = profile?['experience'] ?? [];
      List eduList = profile?['education'] ?? [];
      // List skillList = profile?['skills'] ?? [];

      String userContext =
          "Experience: ${expList.isNotEmpty ? expList[0]['jobTitle'] : 'Professional'}. ";
      userContext +=
          "Education: ${eduList.isNotEmpty ? eduList[0]['degree'] : 'Graduate'}. ";

      String aiResult =
          await AIService.askAI(userContext, "summary", isAmharic: false);

      if (mounted) {
        await _typeWriterEffect(aiResult);
        setState(() => _isGeneratingAI = false);
        _onChanged();
      }
    } catch (e) {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  Future<void> _typeWriterEffect(String fullText) async {
    _summaryController.clear();
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (mounted) setState(() => _summaryController.text += fullText[i]);
    }
  }

  // 4. ተለዋዋጭ ሪፈረንስ መጨመር/መቀነስ
  void _addNewReference() {
    setState(() => referencesList
        .add({'name': '', 'jobTitle': '', 'organization': '', 'phone': ''}));
  }

  void _removeReference(int index) {
    setState(() => referencesList.removeAt(index));
    _onChanged();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 1000), () => _saveToDatabase());
  }

  Future<void> _saveToDatabase() async {
    if (_profileId == null) return;
    try {
      await DatabaseHelper.instance
          .updateProfileSummary(_profileId!, _summaryController.text);
      final db = await DatabaseHelper.instance.database;

      await db.delete('user_references',
          where: 'profileId = ?', whereArgs: [_profileId]);

      for (var ref in referencesList) {
        if (ref['name'].toString().trim().isNotEmpty) {
          await db.insert('user_references', {
            'profileId': _profileId,
            'name': ref['name'],
            'jobTitle': ref['jobTitle'],
            'organization': ref['organization'],
            'phone': ref['phone'],
          });
        }
      }
    } catch (e) {
      debugPrint("Auto-Save Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Final Review",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader(
                    "Professional Summary", Icons.description_outlined),
                _buildAISummaryTool(),
                _buildSummaryBox(),
                const SizedBox(height: 30),
                _buildSectionHeader("References", Icons.people_outline),
                const SizedBox(height: 10),
                ...referencesList
                    .asMap()
                    .entries
                    .map((entry) => _buildReferenceCard(entry.key)),
                TextButton.icon(
                  onPressed: _addNewReference,
                  icon: const Icon(Icons.add, color: Colors.teal),
                  label: const Text("Add Another Reference",
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 100), // ለ bottom buttons ቦታ
              ],
            ),
      bottomNavigationBar: _buildBottomActionPanel(),
    );
  }

  Widget _buildBottomActionPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("BACK",
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isGeneratingPdf ? null : _handleGeneratePdf,
                  child: _isGeneratingPdf
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text("PREVIEW",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        CustomBottomMenu(
          userCv: _currentCv,
          primaryColor: Colors.teal,
          contentColor: Colors.white,
          onRefresh: _loadStoredData,
        ),
      ],
    );
  }

  // --- UI Helpers ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAISummaryTool() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _isGeneratingAI ? null : _generateAISummary,
        icon: const Icon(Icons.auto_fix_high, size: 16, color: Colors.teal),
        label: Text(_isGeneratingAI ? "Writing..." : "AI Suggestion",
            style: const TextStyle(
                color: Colors.teal, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryBox() {
    return TextField(
      controller: _summaryController,
      maxLines: 5,
      onChanged: (_) => _onChanged(),
      decoration: InputDecoration(
        hintText: "Tell us about your career...",
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildReferenceCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Reference #${index + 1}",
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                if (referencesList.length > 1)
                  IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeReference(index)),
              ],
            ),
            _buildRefTextField("Name", index, 'name'),
            _buildRefTextField("Job Title", index, 'jobTitle'),
            _buildRefTextField("Organization", index, 'organization'),
            _buildRefTextField("Phone", index, 'phone'),
          ],
        ),
      ),
    );
  }

  Widget _buildRefTextField(String label, int index, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        initialValue: referencesList[index][key],
        onChanged: (v) {
          referencesList[index][key] = v;
          _onChanged();
        },
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
