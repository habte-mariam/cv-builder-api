import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:geocoding/geocoding.dart';   
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'qualifications_screen.dart'; 
import 'custom_bottom_menu.dart'; 

class PersonalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const PersonalDetailsScreen({super.key, this.initialData});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _isLocating = false;
  String _selectedGender = "Male"; 
  String _detectedCountryCode = "ET";

  // Controllers
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController(); // አዲስ
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _detectedCountryCode = prefs.getString('user_country_code') ?? 'ET';
    });

    Map<String, dynamic>? data = widget.initialData ?? await DatabaseHelper.instance.getFullProfile();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      if (data != null && data.isNotEmpty) {
        _fNameController.text = data['firstName'] ?? '';
        _lNameController.text = data['lastName'] ?? '';
        _jobTitleController.text = data['jobTitle'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _phone2Controller.text = data['phone2'] ?? ''; 
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _ageController.text = data['age'] ?? ''; 
        _nationalityController.text = data['nationality'] ?? ''; // አዲስ
        _linkedinController.text = data['linkedin'] ?? '';
        _websiteController.text = data['portfolio'] ?? ''; 
        _selectedGender = data['gender'] ?? 'Male';
        if (data['profileImagePath'] != null && data['profileImagePath'].isNotEmpty) {
          _image = File(data['profileImagePath']);
        }
      } else if (user != null) {
        String fullName = user.displayName ?? "";
        List<String> nameParts = fullName.split(" ");
        _fNameController.text = nameParts.isNotEmpty ? nameParts[0] : "";
        _lNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
        _emailController.text = user.email ?? "";
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { await Geolocator.openLocationSettings(); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Denied';
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() { _addressController.text = "${place.locality}, ${place.administrativeArea}, ${place.country}"; });
      }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"))); }
    finally { setState(() => _isLocating = false); }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime(2000), 
      firstDate: DateTime(1950), 
      lastDate: DateTime.now()
    );
    if (picked != null) {
      int age = DateTime.now().year - picked.year;
      if (DateTime.now().month < picked.month || (DateTime.now().month == picked.month && DateTime.now().day < picked.day)) {
        age--;
      }
      setState(() => _ageController.text = "$age");
    }
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _saveAndNext() async {
    if (_formKey.currentState!.validate()) {
      try {
        await DatabaseHelper.instance.saveProfile({
          'firstName': _fNameController.text.trim(),
          'lastName': _lNameController.text.trim(),
          'jobTitle': _jobTitleController.text.trim(),
          'phone': _phoneController.text.trim(),
          'phone2': _phone2Controller.text.trim(), 
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'age': _ageController.text.trim(),
          'nationality': _nationalityController.text.trim(), // አዲስ
          'gender': _selectedGender,
          'linkedin': _linkedinController.text.trim(),
          'portfolio': _websiteController.text.trim(),
          'profileImagePath': _image?.path ?? '',
        });
        if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const QualificationsScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("DB Error: $e")));
      }
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Personal Details", style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.indigo[900], 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // ቁልፉ ከታች ስለሚሆን padding ቀንሰነዋል
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(),
              _buildSectionTitle("Basic Information"),
              _buildTextField("First Name", _fNameController, isMandatory: true, icon: Icons.person),
              _buildTextField("Last Name", _lNameController, isMandatory: true, icon: Icons.person_outline),
              _buildGenderPicker(),
              const SizedBox(height: 12),
              _buildTextField(
                "Age", 
                _ageController, 
                icon: Icons.cake, 
                readOnly: true, 
                onTap: _pickDate, 
                isMandatory: true
              ),
              _buildTextField("Nationality", _nationalityController, icon: Icons.flag_outlined, hint: "e.g. Ethiopian"),
              _buildTextField("Job Title", _jobTitleController, isMandatory: true, icon: Icons.work_outline),

              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 4),
                child: Text("Primary Phone Number *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              IntlPhoneField(
                key: Key(_detectedCountryCode),
                controller: _phoneController,
                initialCountryCode: _detectedCountryCode,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (phone) {
                  // Option: update controller to store complete number
                },
              ),
              
              _buildTextField("Alternative Phone (Optional)", _phone2Controller, icon: Icons.phone_android, type: TextInputType.phone),
              _buildTextField("Email Address", _emailController, isMandatory: true, icon: Icons.email_outlined, type: TextInputType.emailAddress),
              
              _buildSectionTitle("Online Profiles & Location"),
              _buildTextField("LinkedIn Profile URL", _linkedinController, icon: Icons.link),
              _buildTextField("Portfolio URL", _websiteController, icon: Icons.language),
              
              _buildTextField("City, Country", _addressController, icon: Icons.map, isMandatory: true),
              _buildLocationButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ቁልፉን እና ሜኑውን በአንድ ላይ ከታች ማሳያ ክፍል
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: _saveAndNext, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900], 
                minimumSize: const Size(double.infinity, 55), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ), 
              child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ),
          ),
          CustomBottomMenu(
            userCv: null, 
            primaryColor: Colors.indigo[900]!,
            contentColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildTextField(String label, TextEditingController controller, {bool isMandatory = false, IconData? icon, TextInputType type = TextInputType.text, bool readOnly = false, VoidCallback? onTap, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.indigo[700], size: 20) : null,
          labelText: label,
          hintText: hint,
          suffixIcon: isMandatory ? const Icon(Icons.star, color: Colors.red, size: 8) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => (isMandatory && (value == null || value.trim().isEmpty)) ? "Required" : null,
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Gender", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      Row(children: [
        Radio(value: "Male", groupValue: _selectedGender, activeColor: Colors.indigo, onChanged: (val) => setState(() => _selectedGender = val as String)),
        const Text("Male"),
        Radio(value: "Female", groupValue: _selectedGender, activeColor: Colors.indigo, onChanged: (val) => setState(() => _selectedGender = val as String)),
        const Text("Female"),
      ])
    ]);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(top: 25, bottom: 10), child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[900], fontSize: 16)));
  }

  Widget _buildImageHeader() {
    return Center(
      child: Stack(children: [
        CircleAvatar(radius: 50, backgroundColor: Colors.grey[300], backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null),
        Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.indigo, radius: 18, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16), onPressed: _pickImage)))
      ])
    );
  }

  Widget _buildLocationButton() {
    return Align(
      alignment: Alignment.centerRight, 
      child: TextButton.icon(
        onPressed: _isLocating ? null : _getCurrentLocation, 
        icon: _isLocating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, size: 16), 
        label: Text(_isLocating ? "Locating..." : "Auto-fill Location", style: const TextStyle(fontSize: 12))
      )
    );
  }
}