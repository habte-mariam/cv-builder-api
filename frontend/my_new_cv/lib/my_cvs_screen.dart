import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'database_helper.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  List<Map<String, dynamic>> _savedCvs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCvs();
  }

  // 1. የተቀመጡ ሲቪዎችን ከዳታቤዝ ማምጣት
  Future<void> _fetchCvs() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getSavedCvs();
      setState(() {
        _savedCvs = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching CVs: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. የማረጋገጫ መጠየቂያ ዳያሎግ (Confirm Delete)
  Future<void> _confirmDelete(int id, String filePath, String fileName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("ሲቪ ማጥፊያ", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("'$fileName'ን ከስልኩ ላይ በቋሚነት ማጥፋት እርግጠኛ ነዎት?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("ተመለስ", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCv(id, filePath);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            child: const Text("አጥፋ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. ሲቪውን ከዳታቤዝ እና ከስልክ ማከማቻ ማጥፋት
  Future<void> _deleteCv(int id, String filePath) async {
    try {
      // ከዳታቤዝ አጥፋ
      await DatabaseHelper.instance.deleteCv(id);
      
      // ከፋይል ማከማቻ አጥፋ
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      _fetchCvs(); // ዝርዝሩን አድስ
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ሲቪው በተሳካ ሁኔታ ጠፍቷል"), backgroundColor: Colors.black87)
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // ትንሽ አመድማ ነጭ
      appBar: AppBar(
        title: const Text("የተቀመጡ ሲቪዎች", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _savedCvs.isEmpty
              ? _buildEmptyState()
              : _buildCvList(),
    );
  }

  // 4. የሲቪ ዝርዝር እይታ (ListView)
  Widget _buildCvList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      itemCount: _savedCvs.length,
      itemBuilder: (context, index) {
        final cv = _savedCvs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
            ),
            title: Text(
              cv['fileName'], 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 5),
                  Text(
                    cv['createdDate'].toString().split(' ')[0], 
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              onPressed: () => _confirmDelete(cv['id'], cv['filePath'], cv['fileName']),
            ),
onTap: () async {
  // Verify if the file actually exists
  final file = File(cv['filePath']);
  if (await file.exists()) {
    // Using OpenFilex to avoid the duplicate class error
    final result = await OpenFilex.open(cv['filePath']);
    
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open file: ${result.message}"))
      );
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sorry, the file was not found on your device!"), 
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
},
          ),
        );
      },
    );
  }

  // 5. ሲቪ በማይኖርበት ጊዜ የሚታይ (Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.folder_off_outlined, size: 70, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          const Text("እስካሁን ምንም ሲቪ አልተቀመጠም", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(height: 10),
          Text("ሲቪ ሲሰሩ እዚህ ዝርዝር ውስጥ ያገኙታል", 
            style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}