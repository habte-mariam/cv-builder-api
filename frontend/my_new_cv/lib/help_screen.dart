import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Filtered list focusing only on Technical/App-specific questions
  final List<Map<String, dynamic>> _technicalFaqs = [
    // --- Getting Started & Offline ---
    {"q": "Can I use the app offline?", "a": "Most features work offline. However, you need an internet connection for the AI Assistant and to sync with Firebase.", "icon": Icons.wifi_off_outlined},
    {"q": "Who developed this app?", "a": "This app is developed by HabTech to help professionals create high-quality CVs easily and quickly.", "icon": Icons.code_outlined},
    
    // --- PDF & Storage ---
    {"q": "Where can I find my saved CV files?", "a": "You can find them in the 'Saved CVs' screen within the app, or in the 'Download' folder of your device's file manager.", "icon": Icons.folder_open_outlined},
    {"q": "What format is the CV saved in?", "a": "All CVs are generated and saved as high-quality PDF files, which are compatible with all job application portals.", "icon": Icons.picture_as_pdf_outlined},
    {"q": "Can I print my CV directly from the app?", "a": "Yes, in the 'Preview' screen, use the print icon to connect to any wireless printer or save it as a print-ready file.", "icon": Icons.print_outlined},

    // --- AI Assistant ---
    {"q": "How does the AI Assistant help me?", "a": "The AI analyzes your rough drafts and rewrites them using professional industry keywords to improve your chances of getting hired.", "icon": Icons.auto_awesome_outlined},
    {"q": "Can the AI write my entire CV?", "a": "The AI is designed to assist with 'Professional Summaries' and 'Job Descriptions' rather than generating the entire document from scratch.", "icon": Icons.edit_note_outlined},

    // --- Settings & Customization ---
    {"q": "How do I change the theme color of my CV?", "a": "Go to 'App Settings' and choose a 'Theme Color'. This color will be applied to headings and icons in your generated CV.", "icon": Icons.color_lens_outlined},
    {"q": "How do I adjust the font size?", "a": "In 'App Settings', you can toggle between Small, Medium, and Large font sizes to control how much content fits on a page.", "icon": Icons.format_size_rounded},
    {"q": "Can I use different fonts?", "a": "Yes, go to 'Settings' and select your preferred 'Font Family' (e.g., Poppins, Roboto) to customize the typography of your CV.", "icon": Icons.font_download_outlined},

    // --- Privacy & Security ---
    {"q": "Is my personal data safe?", "a": "Your data is stored locally on your device. We use industry-standard encryption for any data synced with our secure database.", "icon": Icons.security_outlined},
    {"q": "Will my data be lost if I uninstall the app?", "a": "Yes, since the database is local, uninstalling the app will remove your data. We recommend keeping a copy of your exported PDFs.", "icon": Icons.warning_amber_outlined},
    {"q": "How do I delete all my data?", "a": "You can clear all information by going to 'Settings' and selecting 'Reset App Data' or by deleting individual records in the 'Saved CVs' screen.", "icon": Icons.delete_forever_outlined},

    // --- Troubleshooting ---
    {"q": "What should I do if the app crashes?", "a": "Ensure you are using the latest version. Try clearing the app cache or restart your device. If it persists, contact support.", "icon": Icons.bug_report_outlined},
    {"q": "Can I export my data to another device?", "a": "Currently, data is device-specific. We are working on a cloud sync feature for future updates.", "icon": Icons.sync_problem_outlined},
    {"q": "How can I report a bug?", "a": "Use the Telegram or Email buttons below to send us a screenshot and description of the issue.", "icon": Icons.report_problem_outlined},
  ];

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Technical Help & FAQ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text("Technical Support",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 15),
          
          // Displaying the technical list
          ..._technicalFaqs.map((faq) =>
              _buildHelpTile(faq["q"], faq["a"], faq["icon"])),

          const SizedBox(height: 30),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.headset_mic, color: Colors.white, size: 40),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Need Technical Support?",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text("Our developers are here to help",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL("https://t.me/hab7tech"),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Telegram"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[900],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL("mailto:habtiet96@gmail.com"),
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text("Email"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHelpTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.05),
          child: Icon(icon, color: Colors.indigo, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 0, 20, 15),
            child: Text(subtitle,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}