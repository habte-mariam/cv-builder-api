import 'package:flutter/material.dart';
import 'database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentTheme = 0xFF1E293B;
  String _fontSize = "Medium";
  String _fontFamily = "Times"; // ዲፎልቱን ወደ "Times" ቀይሬዋለሁ
  bool _isLoading = true;

  final List<int> _themeOptions = [
    0xFF15803D, 0xFF0284C7, 0xFFB9F2FF, 0xFFB91C1C, 0xFF7E22CE, 0xFF000000,
    0xFF70D1F4, 0xFFF97316, 0xFF1A237E, 0xFF374151, 0xFF065F46, 0xFF9D174D,
  ];

  // ማሳሰቢያ፡ እነዚህ ስሞች በ AppFonts.availableFamilies ውስጥ ካሉት ጋር አንድ መሆን አለባቸው
  final List<String> _fontOptions = [
    "Times",
    "Poppins",
    "Arimo",
    "NotoSerif"
  ];

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final s = await DatabaseHelper.instance.getSettings();
    setState(() {
      _currentTheme = s['themeColor'] ?? 0xFF1E293B;
      _fontSize = s['fontSize'] ?? "Medium";
      
      // የድሮ ዳታ "Times New Roman" ከሆነ ወደ አዲሱ "Times" እንዲቀየር
      String savedFont = s['fontFamily'] ?? "Times";
      if (savedFont == "Times New Roman") savedFont = "Times";
      
      _fontFamily = savedFont;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings({int? theme, String? fSize, String? fFamily}) async {
    Map<String, dynamic> newSettings = {
      'themeColor': theme ?? _currentTheme,
      'fontSize': fSize ?? _fontSize,
      'fontFamily': fFamily ?? _fontFamily,
    };

    await DatabaseHelper.instance.saveSettings(newSettings);
    await _fetchSettings(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool isLightColor = _currentTheme == 0xFFB9F2FF;
    final Color primaryColor = Color(_currentTheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Customization", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: isLightColor ? Colors.black87 : Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildHeader("DESIGN & THEME PREFERENCES", primaryColor),
          _buildThemeSelector(),
          
          const Divider(),

          // CV Font Size
          ListTile(
            leading: const Icon(Icons.format_size_rounded, color: Colors.blueGrey),
            title: const Text("CV Font Size"),
            subtitle: Text("Current: $_fontSize"),
            trailing: DropdownButton<String>(
              value: _fontSize,
              underline: const SizedBox(),
              onChanged: (v) => _updateSettings(fSize: v),
              items: ["Small", "Medium", "Large"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),

          // CV Font Family
          ListTile(
            leading: const Icon(Icons.font_download_rounded, color: Colors.blueGrey),
            title: const Text("CV Font Family"),
            subtitle: Text("Current: $_fontFamily"),
            trailing: DropdownButton<String>(
              value: _fontOptions.contains(_fontFamily) ? _fontFamily : _fontOptions[0],
              underline: const SizedBox(),
              onChanged: (v) => _updateSettings(fFamily: v),
              items: _fontOptions.map((f) => DropdownMenuItem(
                value: f, 
                child: Text(f, style: TextStyle(fontFamily: f == "Times" ? "TimesNewRoman" : f)),
              )).toList(),
            ),
          ),

          const Divider(),

          _buildHeader("DATA MANAGEMENT", primaryColor),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text("Factory Reset", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text("Delete all CVs and reset settings"),
            onTap: () => _showResetDialog(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
    );
  }

  Widget _buildThemeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: _themeOptions.map((colorValue) => GestureDetector(
          onTap: () => _updateSettings(theme: colorValue),
          child: Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: _currentTheme == colorValue ? Colors.orange : Colors.grey.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: _currentTheme == colorValue ? Icon(Icons.check, color: colorValue == 0xFFB9F2FF ? Colors.black : Colors.white) : null,
          ),
        )).toList(),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Everything?"),
        content: const Text("ይህ እርምጃ ሁሉንም የሲቪ መረጃዎች እና ሴቲንጎች ያጠፋል። እርግጠኛ ኖት?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearAll();
              if (mounted) Navigator.pop(context);
              _fetchSettings();
            }, 
            child: const Text("RESET ALL", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}