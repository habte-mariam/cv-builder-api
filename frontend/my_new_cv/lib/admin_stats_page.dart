import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  // የ Python API አድራሻ (በሞባይል Emulator ከሆነ 10.0.2.2 ተጠቀም)
  final String apiUrl = "http://10.0.2.2:8000/admin/user-stats";

  Future<Map<String, dynamic>> fetchStats() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load stats from Python API");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("User Analytics Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
            return const Center(child: Text("No users registered yet."));
          }

          final List items = snapshot.data!['data'];
          final int totalUsers = snapshot.data!['total_active_users'];

          return Column(
            children: [
              _buildSummaryHeader(totalUsers),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    var data = items[index];

                    // Python የላከው ቀን (ISO string) ወደ DateTime መቀየር
                    DateTime date = DateTime.parse(
                        data['last_seen'] ?? DateTime.now().toIso8601String());
                    String formattedDate =
                        DateFormat('MMM d, hh:mm a').format(date);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[50],
                          child: Icon(Icons.person, color: Colors.indigo[900]),
                        ),
                        title: Text(data['name'] ?? "Guest User",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Last Active: $formattedDate",
                            style: const TextStyle(fontSize: 12)),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[50],
                            child: Column(
                              children: [
                                _buildDetailHeader("Location Analytics"),
                                _buildInfoRow(
                                    Icons.gps_fixed,
                                    "GPS Location (Real):",
                                    data['real_gps_location'] ?? "Not Detected",
                                    Colors.green),
                                _buildInfoRow(
                                    Icons.edit_location_alt,
                                    "CV Address (Filled):",
                                    data['cv_profile_address'] ?? "Not Filled",
                                    Colors.orange),
                                _buildInfoRow(
                                    Icons.public,
                                    "System IP Location:",
                                    data['location'] ?? "N/A",
                                    Colors.blue),
                                const Divider(height: 25),
                                _buildDetailHeader("Device Information"),
                                _buildInfoRow(Icons.phone_android, "Model:",
                                    data['model'] ?? "N/A", Colors.black87),
                                _buildInfoRow(Icons.battery_std, "Battery:",
                                    data['battery'] ?? "N/A", Colors.black87),
                                _buildInfoRow(Icons.wifi, "Network:",
                                    data['internet'] ?? "N/A", Colors.black87),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _smallBadge(
                                        "OS: ${data['os_version'] ?? 'N/A'}"),
                                    _smallBadge(
                                        "Ver: ${data['app_version'] ?? '1.0.0'}"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- UI Helper Widgets (ያልተቀየሩ) ---
  Widget _buildSummaryHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 28),
          const SizedBox(width: 15),
          Text("Total Active Users: $count",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900])),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(width: 5),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.indigo[100], borderRadius: BorderRadius.circular(5)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              color: Colors.indigo[900],
              fontWeight: FontWeight.bold)),
    );
  }
}
