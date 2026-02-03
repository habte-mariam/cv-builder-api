import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; 
import 'database_helper.dart';

class SavedCvsScreen extends StatefulWidget {
  const SavedCvsScreen({super.key});

  @override
  State<SavedCvsScreen> createState() => _SavedCvsScreenState();
}

class _SavedCvsScreenState extends State<SavedCvsScreen> {
  List<Map<String, dynamic>> _savedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // ዳታቤዝ ውስጥ ያሉትን ሲቪዎች መጫን
  Future<void> _loadFiles() async {
    try {
      setState(() => _isLoading = true);
      final files = await DatabaseHelper.instance.getSavedCvs();
      setState(() {
        _savedFiles = files; 
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error loading files: $e");
    }
  }

  // የፋይሉን መጠን (Size) ለማስላት የሚረዳ ተግባር
  Future<String> _getFileSize(String? path) async {
    if (path == null) return "Unknown Size";
    try {
      final file = File(path);
      if (await file.exists()) {
        int bytes = await file.length();
        if (bytes < 1024) return "$bytes B";
        if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
        return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
      }
      return "File Missing";
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    // የአፑ ዋና ቀለም (Indigo)
    final Color primaryColor = Colors.indigo[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Saved CVs", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: "Refresh List",
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedFiles.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: _savedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _savedFiles[index];
                    return _buildFileCard(file);
                  },
                ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
        ),
        title: Text(
          file['fileName'] ?? "Untitled CV",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Created: ${_formatDate(file['createdDate'])}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            // የፋይል መጠን እዚህ ጋር ይታያል
            FutureBuilder<String>(
              future: _getFileSize(file['filePath']),
              builder: (context, snapshot) {
                return Text(
                  "Size: ${snapshot.data ?? '...'}",
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 12),
                );
              },
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_right, color: Colors.grey[400]),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: () => _confirmDelete(file),
            ),
          ],
        ),
        onTap: () => _openPdfFile(file['filePath']),
      ),
    );
  }

  Future<void> _openPdfFile(String? path) async {
    if (path != null) {
      final pdfFile = File(path);
      if (await pdfFile.exists()) {
        await Printing.layoutPdf(
          onLayout: (format) async => await pdfFile.readAsBytes(),
          name: path.split('/').last,
        );
      } else {
        _showSnackBar("ፋይሉ ስልኩ ላይ አልተገኘም ወይም ተሰርዟል!");
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text("No saved CVs yet!", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          const Text("Generate a CV to see it here.", 
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> fileData) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Record?"),
        content: const Text("ይህን የሲቪ ሪከርድ ከዝርዝሩ ማጥፋት ይፈልጋሉ? ፋይሉም ከስልኩ ላይ አብሮ ይጠፋል።"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final int id = fileData['id'];
              final String? filePath = fileData['filePath'];

              // ከዳታቤዝ ማጥፋት
              await DatabaseHelper.instance.deleteCv(id);

              // ከስልኩ ማህደረ ትውስታ (Storage) ማጥፋት
              if (filePath != null) {
                final f = File(filePath);
                if (await f.exists()) await f.delete();
              }

              if (mounted) {
                Navigator.pop(c);
                _loadFiles();
                _showSnackBar("ሪከርዱ ተሰርዟል።");
              }
            },
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "N/A";
    try {
      return dateStr.toString().substring(0, 10);
    } catch (e) {
      return dateStr.toString();
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}