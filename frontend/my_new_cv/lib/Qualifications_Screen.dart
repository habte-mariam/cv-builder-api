import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_new_cv/cv_model.dart';
import 'skills_screen.dart';
import 'database_helper.dart';
import 'custom_bottom_menu.dart'; // ሜኑውን እዚህም ለመጠቀም

class QualificationsScreen extends StatefulWidget {
  const QualificationsScreen({super.key});

  @override
  State<QualificationsScreen> createState() => _QualificationsScreenState();
}

class _QualificationsScreenState extends State<QualificationsScreen> {
  List<Map<String, dynamic>> educationList = [];
  List<Map<String, dynamic>> experienceList = [];
  List<Map<String, dynamic>> certificatesList = [];

  bool _isLoading = true;
  int? _profileId;
  Timer? _debounce;

  final List<String> qualifications = [
    "Grade 1-8", "Grade 9-10", "Grade 11-12", 
    "TVET/Level", "Diploma", "Bachelor of Science Degree", 
    "Bachelor of Arts Degree", "Masters", "PhD", "Other"
  ];

  CvModel? get _currentCv => null;
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }
Future<void> _loadAllData() async {
  try {
    final fullProfile = await DatabaseHelper.instance.getFullProfile();
    
    // 1. መጀመሪያ ስክሪኑ ገና መኖሩን (Mounted መሆኑን) እናረጋግጣለን
    if (!mounted) return;

    if (fullProfile != null) {
      _profileId = fullProfile['id'];
      setState(() {
        educationList = List<Map<String, dynamic>>.from(fullProfile['education'] ?? []);
        experienceList = List<Map<String, dynamic>>.from(fullProfile['experience'] ?? []);
        certificatesList = List<Map<String, dynamic>>.from(fullProfile['certificates'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    // 2. እዚህም ጋር setState ከመጥራት በፊት ማረጋገጥ አስፈላጊ ነው
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () => _saveAllToDatabase());
  }

  Future<void> _saveAllToDatabase() async {
    if (_profileId == null) return;

    // 1. ትምህርትን ማስቀመጥ
    await DatabaseHelper.instance.clearEducation(_profileId!);
    for (var edu in educationList) {
      await DatabaseHelper.instance.addEducation({
        'profileId': _profileId,
        'school': edu['school'],
        'degree': edu['degree'],
        'field': edu['field'],
        'gradYear': edu['gradYear'] ?? "",
        'cgpa': edu['cgpa'] ?? "",
        'project': edu['project'] ?? "",
      });
    }

    // 2. የሥራ ልምድን ማስቀመጥ
    await DatabaseHelper.instance.clearExperience(_profileId!);
    for (var exp in experienceList) {
      await DatabaseHelper.instance.addExperience({
        'profileId': _profileId,
        'companyName': exp['companyName'],
        'jobTitle': exp['jobTitle'],
        'duration': exp['duration'],
        'jobDescription': exp['jobDescription'] ?? "",
        'achievements': exp['achievements'] ?? "",
        'isCurrentlyWorking': exp['isCurrentlyWorking'] ?? 0,
      });
    }

    // 3. ሰርተፊኬቶችን ማስቀመጥ
    final db = await DatabaseHelper.instance.database;
    await db.delete('certificates', where: 'profileId = ?', whereArgs: [_profileId]);
    for (var cert in certificatesList) {
      await db.insert('certificates', {
        'profileId': _profileId,
        'certName': cert['certName'],
        'organization': cert['organization'],
        'year': cert['year'],
      });
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Qualifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), // Padding ቀንሰነዋል
              children: [
                _buildVerticalStep(
                  index: "1", title: "Education", color: Colors.indigo,
                  child: _buildEducationList(), onAdd: () => _showEducationDialog(),
                ),
                _buildVerticalStep(
                  index: "2", title: "Work Experience", color: Colors.orange,
                  child: _buildExperienceList(), onAdd: () => _showExperienceDialog(),
                ),
                _buildVerticalStep(
                  index: "3", title: "Certificates", color: Colors.redAccent,
                  child: _buildCertificateList(), onAdd: () => _showCertificateDialog(),
                ),
              ],
            ),
      
      // የ Skills Screen አይነት አቀማመጥ እዚህ ይጀምራል
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // ኮለኑ ይዘቱ የያዘውን ያህል ቦታ ብቻ እንዲይዝ
        children: [
          // 1. የ BACK እና NEXT ቁልፎች
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // BACK Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.indigo[900]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("BACK", style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                // NEXT Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await _saveAllToDatabase();
                      if (mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SkillsScreen()));
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
            userCv: _currentCv, // ከላይ በነገርኩህ መሰረት _currentCv መኖሩን አረጋግጥ
            primaryColor: Colors.indigo[900]!,
            contentColor: Colors.white,
            onRefresh: _loadAllData,
          ),
        ],
      ),
    );
  }

  void _showEducationDialog({int? index}) {
    final schoolCtrl = TextEditingController(text: index != null ? educationList[index]['school'] : '');
    final fieldCtrl = TextEditingController(text: index != null ? educationList[index]['field'] : '');
    final gpaCtrl = TextEditingController(text: index != null ? educationList[index]['cgpa'] : '');
    final projectCtrl = TextEditingController(text: index != null ? educationList[index]['project'] : '');
    final yearCtrl = TextEditingController(text: index != null ? educationList[index]['gradYear'] : '');
    String selectedDegree = index != null ? educationList[index]['degree'] : qualifications[5]; // Default to BSc

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // CGPA የሚታየው ለከፍተኛ ትምህርት ብቻ እንዲሆን (Grades ላይ እንዳይታይ)
          bool showGPA = !["Grade 8", "Grade 10", "Grade 12"].contains(selectedDegree);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Education Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _dialogTextField(schoolCtrl, "School / University", Icons.school),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDegree,
                    decoration: const InputDecoration(labelText: "Qualification Level", border: OutlineInputBorder()),
                    items: qualifications.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedDegree = v!;
                    }),
                  ),
                  const SizedBox(height: 10),
                  if (showGPA) _dialogTextField(fieldCtrl, "Field of Study", Icons.book),
                  Row(
                    children: [
                      if (showGPA)
                        Expanded(child: _dialogTextField(gpaCtrl, "CGPA", Icons.grade, type: TextInputType.number)),
                      if (showGPA) const SizedBox(width: 10),
                      Expanded(child: TextField(
                        controller: yearCtrl, readOnly: true,
                        decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1970), lastDate: DateTime(2030));
                          if (picked != null) setDialogState(() => yearCtrl.text = picked.year.toString());
                        },
                      )),
                    ],
                  ),
                  if (showGPA) _dialogTextField(projectCtrl, "Thesis/Major Project (Optional)", Icons.assignment, maxLines: 2),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 50)),
                    onPressed: () {
                      if (schoolCtrl.text.isNotEmpty) {
                        final data = {
                          'school': schoolCtrl.text, 'degree': selectedDegree, 
                          'field': showGPA ? fieldCtrl.text : "General Education",
                          'gradYear': yearCtrl.text, 'cgpa': showGPA ? gpaCtrl.text : "", 
                          'project': showGPA ? projectCtrl.text : "",
                        };
                        setState(() {
                          if (index == null) {
                            educationList.add(data);
                          } else {
                            educationList[index] = data;
                          }
                        });
                        _onChanged(); Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Education", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildVerticalStep({required String index, required String title, required Color color, required Widget child, required VoidCallback onAdd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18, backgroundColor: color,
              child: Text(index, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const Spacer(),
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle), color: color, iconSize: 28),
          ],
        ),
        Padding(padding: const EdgeInsets.only(left: 35, top: 10, bottom: 20), child: child),
      ],
    );
  }

  Widget _itemCard({required String title, required String subtitle, required String trailing, required VoidCallback onDelete, required VoidCallback onEdit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50], borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: onEdit,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
          ],
        ),
      ),
    );
  }

  // --- Education Logic ---
  Widget _buildEducationList() {
    return Column(
      children: educationList.asMap().entries.map((e) => _itemCard(
        title: "${e.value['degree']} in ${e.value['field']}",
        subtitle: e.value['school'],
        trailing: e.value['gradYear'] ?? "",
        onEdit: () => _showEducationDialog(index: e.key),
        onDelete: () => setState(() { educationList.removeAt(e.key); _onChanged(); }),
      )).toList(),
    );
  }


  // --- Experience Logic ---
  Widget _buildExperienceList() {
    return Column(
      children: experienceList.asMap().entries.map((e) => _itemCard(
        title: e.value['jobTitle'] ?? "",
        subtitle: e.value['companyName'] ?? "",
        trailing: e.value['duration'] ?? "",
        onEdit: () => _showExperienceDialog(index: e.key),
        onDelete: () => setState(() { experienceList.removeAt(e.key); _onChanged(); }),
      )).toList(),
    );
  }

  void _showExperienceDialog({int? index}) {
    final compCtrl = TextEditingController(text: index != null ? experienceList[index]['companyName'] : '');
    final titleCtrl = TextEditingController(text: index != null ? experienceList[index]['jobTitle'] : '');
    final durationCtrl = TextEditingController(text: index != null ? experienceList[index]['duration'] : '');
    final descCtrl = TextEditingController(text: index != null ? experienceList[index]['jobDescription'] : '');
    final achievementCtrl = TextEditingController(text: index != null ? experienceList[index]['achievements'] : '');
    bool isCurrent = index != null ? (experienceList[index]['isCurrentlyWorking'] == 1) : false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Work Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _dialogTextField(compCtrl, "Company Name", Icons.business),
                _dialogTextField(titleCtrl, "Job Title", Icons.work),
                TextField(
                  controller: durationCtrl,
                  decoration: InputDecoration(
                    labelText: "Duration (e.g., Jan 2020 - Present)", border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: () async {
                      if (isCurrent) {
                        DateTime? start = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
                        if (start != null) setDialogState(() => durationCtrl.text = "${DateFormat('MMM yyyy').format(start)} - Present");
                      } else {
                        DateTimeRange? picked = await showDateRangePicker(context: context, firstDate: DateTime(1950), lastDate: DateTime.now());
                        if (picked != null) setDialogState(() => durationCtrl.text = "${DateFormat('MMM yyyy').format(picked.start)} - ${DateFormat('MMM yyyy').format(picked.end)}");
                      }
                    }),
                  ),
                ),
                CheckboxListTile(
                  title: const Text("I currently work here"), value: isCurrent,
                  onChanged: (v) => setDialogState(() => isCurrent = v!),
                ),
                _dialogTextField(descCtrl, "Job Description", Icons.description, maxLines: 3),
                _dialogTextField(achievementCtrl, "Key Achievements", Icons.star, maxLines: 2),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (compCtrl.text.isNotEmpty) {
                      final data = {
                        'companyName': compCtrl.text, 'jobTitle': titleCtrl.text, 'duration': durationCtrl.text,
                        'jobDescription': descCtrl.text, 'achievements': achievementCtrl.text, 'isCurrentlyWorking': isCurrent ? 1 : 0
                      };
                      setState(() {
                        if (index == null) {
                          experienceList.add(data);
                        } else {
                          experienceList[index] = data;
                        }
                      });
                      _onChanged(); Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Experience", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Certificate Logic ---
  Widget _buildCertificateList() {
    return Column(
      children: certificatesList.asMap().entries.map((e) => _itemCard(
        title: e.value['certName'] ?? "",
        subtitle: e.value['organization'] ?? "",
        trailing: e.value['year'] ?? "",
        onEdit: () => _showCertificateDialog(index: e.key),
        onDelete: () => setState(() { certificatesList.removeAt(e.key); _onChanged(); }),
      )).toList(),
    );
  }

  void _showCertificateDialog({int? index}) {
    final nameCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    String certYear = DateFormat('yyyy').format(DateTime.now());

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Certificate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _dialogTextField(nameCtrl, "Certificate Name", Icons.verified),
              _dialogTextField(orgCtrl, "Organization", Icons.account_balance),
              ListTile(
                title: const Text("Year Achieved"),
                trailing: Text(certYear, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1980), lastDate: DateTime.now());
                  if (picked != null) setDialogState(() => certYear = picked.year.toString());
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    setState(() => certificatesList.add({'certName': nameCtrl.text, 'organization': orgCtrl.text, 'year': certYear}));
                    _onChanged(); Navigator.pop(context);
                  }
                },
                child: const Text("Add Certificate", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogTextField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20), border: const OutlineInputBorder()),
      ),
    );
  }
}