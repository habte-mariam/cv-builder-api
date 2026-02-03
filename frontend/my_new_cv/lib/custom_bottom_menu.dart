import 'package:flutter/material.dart';
import 'cv_model.dart';
import 'database_helper.dart';
import 'cv_preview_screen.dart';
import 'template_picker_screen.dart';
import 'saved_cvs_screen.dart';
import 'personal_details_screen.dart';

class CustomBottomMenu extends StatelessWidget {
  
  final CvModel? userCv;
  final Color primaryColor;
  final Color contentColor;
  final Function? onRefresh; // Home ላይ ከሆንክ ዳታውን ለማደስ

  const CustomBottomMenu({
    super.key,
    required this.userCv,
    required this.primaryColor,
    required this.contentColor,
    this.onRefresh,
  });

  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (onRefresh != null) onRefresh!();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home_filled, "Home", () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
              _navItem(context, Icons.palette_outlined, "Design", () => _navigateTo(context, const TemplatePickerScreen())),
              
              // Center Action Button
              GestureDetector(
                onTap: () => _navigateTo(context, const PersonalDetailsScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Icon(userCv == null ? Icons.add : Icons.edit, color: contentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        userCv == null ? "START" : "EDIT",
                        style: TextStyle(color: contentColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              _navItem(context, Icons.folder_open_rounded, "Saved", () => _navigateTo(context, const SavedCvsScreen())),

              _navItem(context, Icons.remove_red_eye_outlined, "Preview", () async {
                if (userCv != null) {
                  final settings = await DatabaseHelper.instance.getSettings();
                  if (!context.mounted) return;
                  _navigateTo(context, CvPreviewScreen(
                    cvModel: userCv!,
                    templateIndex: settings['templateIndex'] ?? 0,
                    primaryColor: Color(settings['themeColor'] ?? 0xFF1E293B),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill your details first!"))
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 26),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}