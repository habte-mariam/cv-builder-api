import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ያንተ ፋይሎች
import 'database_helper.dart';
import 'cv_model.dart';
import 'cv_preview_screen.dart';
import 'settings_screen.dart';
import 'saved_cvs_screen.dart';
import 'template_picker_screen.dart';
import 'personal_details_screen.dart';
import 'about_screen.dart';
import 'admin_stats_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CvModel? userCv;
  int _primaryColorValue = 0xFF1E293B;
  bool _isLoading = true;
  int _adminTapCount = 0;

  // Python API Base URL
  final String pythonBaseUrl = "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await _refreshData();
    await _syncFromPython();
    _updateUserStatsOnPython();
  }

  // 1. ከ Python/Supabase ዳታን ማምጣት (Sync)
  Future<void> _syncFromPython() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response =
          await http.get(Uri.parse('$pythonBaseUrl/get-cv/${user.uid}'));

      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> cloudData = jsonDecode(response.body);
        CvModel tempCv = CvModel();
        tempCv.fromMap(cloudData);

        // የ Key ስሞች ሳይቀየሩ ወደ SQLite ማስገባት
        await DatabaseHelper.instance.saveProfile(tempCv.toMap());

        if (mounted) _refreshData();
      }
    } catch (e) {
      debugPrint("Python Sync Error: $e");
    }
  }

  // 2. የተጠቃሚውን ስታቲስቲክስ ወደ Python መላክ
  Future<void> _updateUserStatsOnPython() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String systemLocation = "Unknown Location";

      try {
        final locRes = await http
            .get(Uri.parse('http://ip-api.com/json'))
            .timeout(const Duration(seconds: 5));
        if (locRes.statusCode == 200) {
          final locData = jsonDecode(locRes.body);
          systemLocation = "${locData['city']}, ${locData['country']}";
        }
      } catch (e) {
        debugPrint("IP Location Error: $e");
      }

      final deviceInfo = DeviceInfoPlugin();
      final battery = Battery();
      final connectivityResult = await Connectivity().checkConnectivity();

      String model = "Unknown";
      if (Platform.isAndroid) {
        model = (await deviceInfo.androidInfo).model;
      } else if (Platform.isIOS) {
        model = (await deviceInfo.iosInfo).utsname.machine;
      }

      final statsData = {
        "uid": user.uid,
        "name": user.displayName ?? "Guest User",
        "location": systemLocation,
        "cv_profile_address": userCv?.address ?? "Not Filled",
        "phone": userCv?.phone ?? "Not Provided",
        "model": model,
        "battery": "${await battery.batteryLevel}%",
        "internet": connectivityResult.contains(ConnectivityResult.wifi)
            ? "WiFi"
            : "Mobile/Other",
        "os_version": Platform.operatingSystem,
        "app_version": "1.0.1+Python",
        "last_seen": DateTime.now().toIso8601String()
      };

      // ሎጂኩ በሙሉ ወደ Python ተቀይሯል (Firebase ተወግዷል)
      await http.post(
        Uri.parse('$pythonBaseUrl/user-stats'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(statsData),
      );
    } catch (e) {
      debugPrint("Python Stats Error: $e");
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getFullProfile();
      final settings = await DatabaseHelper.instance.getSettings();
      if (data != null) {
        setState(() {
          userCv = CvModel();
          userCv!.fromMap(data);
          _primaryColorValue = settings['themeColor'] ?? 0xFF1E293B;
        });
      }
    } catch (e) {
      debugPrint("Refresh Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateTo(Widget screen) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => screen));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(_primaryColorValue);
    final Color contentColor =
        _primaryColorValue == 0xFFB9F2FF ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("CV Builder Pro",
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: primaryColor,
        foregroundColor: contentColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateTo(const SettingsScreen()),
          )
        ],
      ),
      drawer: _buildDrawer(primaryColor, contentColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _syncFromPython();
                await _refreshData();
              },
              child: ListView(
                children: [
                  _buildHeader(primaryColor, contentColor),
                  const SizedBox(height: 100),
                  const Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Text("Welcome! Use the menu below to start."),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar:
          _buildPersistentBottomNav(primaryColor, contentColor),
    );
  }

  Widget _buildPersistentBottomNav(Color primaryColor, Color contentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, "Home", () => _refreshData()),
            _navItem(Icons.palette_outlined, "Design",
                () => _navigateTo(const TemplatePickerScreen())),
            _actionButton(primaryColor, contentColor),
            _navItem(Icons.folder_open_rounded, "Saved",
                () => _navigateTo(const SavedCvsScreen())),
            _navItem(Icons.remove_red_eye_outlined, "Preview",
                () => _handlePreview()),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(Color primaryColor, Color contentColor) {
    return GestureDetector(
      onTap: () => _navigateTo(const PersonalDetailsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(userCv == null ? Icons.add : Icons.edit,
                color: contentColor, size: 20),
            const SizedBox(width: 8),
            Text(userCv == null ? "START" : "EDIT",
                style: TextStyle(
                    color: contentColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.blueGrey),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.blueGrey))
      ]),
    );
  }

  void _handlePreview() async {
    if (userCv != null) {
      final settings = await DatabaseHelper.instance.getSettings();
      _navigateTo(CvPreviewScreen(
        cvModel: userCv!,
        templateIndex: settings['templateIndex'] ?? 0,
        primaryColor: Color(settings['themeColor'] ?? 0xFF1E293B),
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill details!")));
    }
  }

  Widget _buildHeader(Color color, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40))),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _adminTapCount++;
              if (_adminTapCount >= 7) {
                _adminTapCount = 0;
                _navigateTo(const AdminStatsPage());
              }
            },
            child: CircleAvatar(
                radius: 45,
                backgroundColor: textColor.withOpacity(0.2),
                child: Icon(Icons.person_outline, size: 50, color: textColor)),
          ),
          const SizedBox(height: 15),
          Text(userCv != null ? "Hello, ${userCv!.firstName}!" : "Welcome!",
              style: TextStyle(
                  color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDrawer(Color primaryColor, Color textColor) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text("${userCv?.firstName ?? 'User'}",
                style: TextStyle(color: textColor)),
            accountEmail: Text(userCv?.email ?? "CV Builder Pro",
                style: TextStyle(color: textColor.withOpacity(0.8))),
            currentAccountPicture: CircleAvatar(
                backgroundColor: textColor.withOpacity(0.2),
                child: Icon(Icons.person, color: textColor)),
          ),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => _navigateTo(const SettingsScreen())),
          ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () => _navigateTo(const AboutScreen())),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Exit", style: TextStyle(color: Colors.red)),
            onTap: () => SystemNavigator.pop(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
