import 'dart:async';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'reference_screen.dart';
import 'custom_bottom_menu.dart'; // Ensure this import exists
import 'cv_model.dart'; // Required for the menu

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final Map<String, List<String>> categorizedSkills = {
    "Technology & IT": ["Software Development", "Mobile App Development", "Website Development", "Database Management (SQL)", "Networking", "Cybersecurity", "Data Analysis", "Artificial Intelligence", "IT Support"],   
    "Business & Finance": ["Accounting & Tax", "Banking Operations", "Financial Analysis", "Auditing", "Business Management", "Investment", "Economics", "Micro-finance", "Marketing & Sales"],
    "Engineering & Industry": ["Civil Engineering", "Electrical Engineering", "Mechanical Engineering", "Architecture", "Chemical Engineering", "Auto Mechanic", "Industrial Management", "Garment & Textile", "Surveying"],
    "Healthcare & Medical": ["General Medicine", "Nursing", "Pharmacy", "Public Health", "Medical Laboratory", "Dentistry", "Radiology", "Midwifery"],
    "General & Soft Skills": ["Team Leadership", "Communication", "Time Management", "Critical Thinking", "Conflict Resolution", "Office Administration"],
    "Leadership": ["Team Building", "Strategic Planning", "Coaching", "Mentoring", "Delegation", "Crisis Management"],
    "Interpersonal Skills": ["Networking", "Interpersonal Relationships", "Conflict Resolution", "Personal Branding", "Empathy"],
  };

  final List<String> languageLevels = ["Native / Bilingual", "Fluent", "Professional", "Intermediate", "Beginner"];
  List<String> selectedSkills = [];
  List<Map<String, dynamic>> selectedLanguages = []; 
  
  final TextEditingController _customSkillController = TextEditingController();
  final TextEditingController _otherLanguageController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = true;
  int? _profileId;
  CvModel? _currentCv; // Added to pass to CustomBottomMenu

  @override
  void initState() {
    super.initState();
    _loadData();
  }

// ... (ሌላው ክፍል እንደነበረ ይቆያል)

Future<void> _loadData() async {
  final rawData = await DatabaseHelper.instance.getFullProfile();
  if (rawData != null) {
    _profileId = rawData['id'];
    
    _currentCv = CvModel();
    _currentCv!.fromMap(rawData);

    final savedSkills = rawData['skills'] as List? ?? [];
    final savedLangs = rawData['languages'] as List? ?? [];
    
    setState(() {
      // እዚህም 'name' የሚለውን ቁልፍ ተጠቀም
      selectedSkills = savedSkills.map((s) => (s['name'] ?? s['skillName'] ?? '').toString()).toList();
      selectedLanguages = savedLangs.map((l) => {
        'name': l['name'] ?? l['languageName'] ?? '',
        'level': l['level'] ?? ''
      }).toList();
      _isLoading = false;
    });
  } else {
    setState(() => _isLoading = false);
  }
}

void _onChanged() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  // ወደ 2 ሰከንድ ማሳደግ ተጠቃሚው መርጦ እንዲጨርስ ዕድል ይሰጣል
  _debounce = Timer(const Duration(seconds: 2), () => _saveData());
}

Future<void> _saveData() async {
  if (_profileId == null) return;
  
  // ኮፒ መያዝ (Concurrent Modification ለመከላከል)
  final skillsToSave = List<String>.from(selectedSkills);
  final languagesToSave = List<Map<String, dynamic>>.from(selectedLanguages);

  try {
    // 1. መጀመሪያ የድሮዎቹን እናጠፋለን
    await DatabaseHelper.instance.clearSkills(_profileId!);
    
    // 2. አዲሶቹን እናስገባለን
    for (var skillName in skillsToSave) {
      if (skillName.isNotEmpty) {
        await DatabaseHelper.instance.addSkill({
          'profileId': _profileId, 
          'name': skillName
        });
      }
    }

    // ለቋንቋዎችም ተመሳሳይ...
    await DatabaseHelper.instance.clearLanguages(_profileId!);
    for (var lang in languagesToSave) {
      await DatabaseHelper.instance.addLanguage({
        'profileId': _profileId,
        'name': lang['name'],
        'level': lang['level']
      });
    }
    
    debugPrint("Local Save Success! ✅");
  } catch (e) {
    debugPrint("Error during save: $e");
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Skills & Languages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader("Select your top skills", "Choose from categories or add your own."),
            ...categorizedSkills.entries.map((entry) => _buildCategorySection(entry.key, entry.value)),
            const SizedBox(height: 15),
            _buildCustomSkillInput(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Divider(thickness: 1, color: Color(0xFFEEEEEE))),
            _buildLanguageSection(),
            const SizedBox(height: 20), // ListView መጨረሻ ላይ ትንሽ ክፍተት
          ],
        ),
      
      // ቁልፎቹን እና ሜኑውን በአንድ ላይ ከታች ለማሳየት
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // ይዘቱ የያዘውን ያህል ቦታ ብቻ እንዲይዝ
        children: [
          // 1. የ BACK እና NEXT ቁልፎች ክፍል
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Back Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BACK", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                // Next Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await _saveData();
                      if (mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferenceScreen()));
                      }
                    },
                    child: const Text("NEXT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. ዋናው የዳሰሳ ሜኑ (Navigation Menu)
          CustomBottomMenu(
            userCv: _currentCv,
            primaryColor: Colors.teal,
            contentColor: Colors.white,
            onRefresh: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subTitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
      const SizedBox(height: 8),
      Text(subTitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildCategorySection(String title, List<String> skills) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800])),
      children: [
        Wrap(spacing: 8, runSpacing: 4, children: skills.map((skill) {
            bool isSelected = selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              onSelected: (bool value) {
                setState(() => isSelected ? selectedSkills.remove(skill) : selectedSkills.add(skill));
                _onChanged();
              },
              selectedColor: Colors.teal,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomSkillInput() {
    return TextField(
      controller: _customSkillController,
      decoration: InputDecoration(
        hintText: "Add custom skill...",
        suffixIcon: IconButton(icon: const Icon(Icons.add_circle, color: Colors.teal), onPressed: () {
          if (_customSkillController.text.isNotEmpty) {
            setState(() => selectedSkills.add(_customSkillController.text.trim()));
            _customSkillController.clear(); _onChanged();
          }
        }),
        filled: true, fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Languages", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        TextButton.icon(onPressed: _showLanguageDialog, icon: const Icon(Icons.add, size: 18), label: const Text("Add Language"), style: TextButton.styleFrom(foregroundColor: Colors.teal))
      ]),
      ...selectedLanguages.asMap().entries.map((entry) {
        int index = entry.key;
        var lang = entry.value;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language, color: Colors.teal),
          title: Text(lang['name']),
          subtitle: Text(lang['level']),
          trailing: IconButton(icon: const Icon(Icons.close, color: Colors.redAccent), onPressed: () {
            setState(() => selectedLanguages.removeAt(index)); _onChanged();
          }),
        );
      }),
    ]);
  }

  void _showLanguageDialog() {
    String? selectedLang;
    String selectedLevel = languageLevels[1];
    bool isOtherSelected = false;
    final List<String> popularLanguages = ["Amharic", "English", "Afaan Oromoo", "Tigrinya", "Somali", "Arabic", "French", "German", "Other (Type your own)"];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              hint: const Text("Choose Language"),
              items: popularLanguages.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setDialogState(() {
                  selectedLang = v;
                  isOtherSelected = (v == "Other (Type your own)");
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            if (isOtherSelected) ...[
              const SizedBox(height: 15),
              TextField(
                controller: _otherLanguageController,
                decoration: const InputDecoration(hintText: "Enter language name", border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: selectedLevel,
              items: languageLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => selectedLevel = v!),
              decoration: const InputDecoration(labelText: "Level", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                String? finalLang = isOtherSelected ? _otherLanguageController.text.trim() : selectedLang;
                if (finalLang != null && finalLang.isNotEmpty && finalLang != "Other (Type your own)") {
                  setState(() => selectedLanguages.add({'name': finalLang, 'level': selectedLevel}));
                  _otherLanguageController.clear();
                  _onChanged(); 
                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }
}