import 'package:flutter/material.dart';
import 'cv_model.dart';
import 'database_helper.dart';
import 'custom_bottom_menu.dart';

class TemplatePickerScreen extends StatefulWidget {
  const TemplatePickerScreen({super.key});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  int _selectedTemplate = 0;
  bool _isLoading = true;
  final CvModel _cvModel = CvModel();

  final List<Map<String, dynamic>> _templates = [
    {"name": "Creative Modern", "desc": "Best for creative roles", "color": const Color(0xFF6366F1), "icon": Icons.palette_outlined},
    {"name": "Modern Professional", "desc": "Clean and modern layout", "color": const Color(0xFF0F172A), "icon": Icons.trending_up},
    {"name": "Minimalist Clean", "desc": "Simple and elegant", "color": const Color(0xFF475569), "icon": Icons.article_outlined}, // እዚህ ጋር ተስተካክሏል
    {"name": "Executive Royal", "desc": "Premium look for leadership", "color": const Color(0xFF1E1B4B), "icon": Icons.stars},
    {"name": "Classic Traditional", "desc": "Standard formal resume", "color": const Color(0xFF111827), "icon": Icons.history_edu},
    {"name": "Corporate Pro", "desc": "Optimized for corporate jobs", "color": const Color(0xFF1E3A8A), "icon": Icons.business},
    {"name": "Bold Statement", "desc": "Makes a strong impression", "color": const Color(0xFF7F1D1D), "icon": Icons.format_bold},
    {"name": "Elegant Style", "desc": "Refined and sophisticated", "color": const Color(0xFF581C87), "icon": Icons.auto_awesome},
    {"name": "Professional Grid", "desc": "Detailed and organized", "color": const Color(0xFF14532D), "icon": Icons.grid_view_rounded},
    {"name": "Compact Fit", "desc": "Concise and content-rich", "color": const Color(0xFF064E3B), "icon": Icons.compress},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final settings = await DatabaseHelper.instance.getSettings();
      final profileData = await DatabaseHelper.instance.getFullProfile();

      if (mounted) {
        setState(() {
          int savedIndex = settings['templateIndex'] ?? 0;
          _selectedTemplate = savedIndex < _templates.length ? savedIndex : 0;
          
          if (profileData != null) {
            _cvModel.fromMap(profileData);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTemplate(int index) async {
    setState(() => _selectedTemplate = index);
    await DatabaseHelper.instance.saveSettings({
      'templateIndex': index,
      'themeColor': _templates[index]['color'].value,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_templates[index]['name']} Selected"),
        duration: const Duration(seconds: 1),
        backgroundColor: _templates[index]['color'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color currentThemeColor = _templates[_selectedTemplate]['color'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Select Design",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blueGrey.withOpacity(0.05),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "The selected design and color will be applied to your PDF.",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) =>
                        _buildTemplateListItem(_templates[index], index),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isLoading 
          ? null 
          : CustomBottomMenu(
              userCv: _cvModel,
              primaryColor: currentThemeColor,
              contentColor: Colors.white,
              onRefresh: _loadAllData,
            ),
    );
  }

  Widget _buildTemplateListItem(Map<String, dynamic> t, int index) {
    bool isSelected = _selectedTemplate == index;
    Color color = t['color'];

    return GestureDetector(
      onTap: () => _updateTemplate(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade200, 
              width: isSelected ? 2.5 : 1),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(isSelected ? 1 : 0.1),
              radius: 25,
              child: Icon(t['icon'], color: isSelected ? Colors.white : color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['name'],
                      style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, 
                          fontSize: 15,
                          color: isSelected ? color : Colors.black87)),
                  Text(t['desc'],
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}