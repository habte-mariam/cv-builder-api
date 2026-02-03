import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About CV Maker Pro"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? "1.0.0";
          final buildNumber = snapshot.data?.buildNumber ?? "1";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // የአፑ ሎጎ
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo.shade50,
                  child: const Icon(Icons.description, size: 50, color: Colors.indigo),
                ),
                const SizedBox(height: 15),
                const Text(
                  "CV Maker Pro",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Version $version (Build $buildNumber)",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const Divider(),
                
                // የአፕዴት በተን
                _buildAboutTile(
                  icon: Icons.update,
                  title: "Check for Updates",
                  subtitle: "Ensure you have the latest features",
                  onTap: () {
                     
                    // ይህ ቀደም ሲል የሰራኸውን Update logic ይጠራል
                    // ወይም በቀጥታ ሊንኩን እዚህ መክፈት ትችላለህ
                  },
                ),

                const SizedBox(height: 40),
                const Text(
                  "© 2026 CV Maker Pro Team\nAll Rights Reserved",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}