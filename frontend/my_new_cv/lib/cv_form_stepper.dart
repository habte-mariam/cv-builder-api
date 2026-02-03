import 'package:flutter/material.dart';
import 'package:my_new_cv/cv_preview_screen.dart';
import 'database_helper.dart';
import 'cv_model.dart';
import 'ai_service.dart';

class CVFormStepper extends StatefulWidget {
  const CVFormStepper({super.key});

  @override
  State<CVFormStepper> createState() => _CVFormStepperState();
}

class _CVFormStepperState extends State<CVFormStepper> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isAiGenerating = false; // AI ስራ ላይ መሆኑን ለማወቅ

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    // Memory leak ለመከላከል
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    _summaryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final data = await DatabaseHelper.instance.getFullProfile();
    if (data != null) {
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _jobTitleController.text = data['jobTitle'] ?? '';
        _summaryController.text = data['summary'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      });
    }
  }

  // የመረጃ ማረጋገጫ (Validation)
  bool _isStepValid() {
    if (_currentStep == 0) {
      if (_firstNameController.text.trim().isEmpty || 
          _lastNameController.text.trim().isEmpty ||
          _jobTitleController.text.trim().isEmpty) {
        _showSnackBar("Please fill in all required fields (Name & Job Title)");
        return false;
      }
    } else if (_currentStep == 1) {
      if (_summaryController.text.trim().length < 5) {
        _showSnackBar("Please provide a short summary or use AI to generate one.");
        return false;
      }
    }
    return true;
  }

  List<Step> _buildSteps() {
    return [
      Step(
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        title: const Text("Basic Info"),
        content: Column(
          children: [
            _buildTextField("First Name", _firstNameController),
            const SizedBox(height: 12),
            _buildTextField("Last Name", _lastNameController),
            const SizedBox(height: 12),
            _buildTextField("Job Title", _jobTitleController),
            const SizedBox(height: 12),
            _buildTextField("Phone", _phoneController, keyboardType: TextInputType.phone),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        title: const Text("Summary"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Professional Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                _isAiGenerating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton.icon(
                      onPressed: _generateAIContent,
                      icon: const Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
                      label: const Text("AI Generate", style: TextStyle(color: Colors.orange)),
                    ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField("Tell us about your background", _summaryController, maxLines: 5),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: const Text("Finalize"),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.picture_as_pdf, size: 50, color: Colors.indigo),
              SizedBox(height: 16),
              Text(
                "Ready to generate your CV?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "This will save your progress and create a professional PDF document.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _generateAIContent() async {
    if (_jobTitleController.text.trim().isEmpty) {
      _showSnackBar("Please enter your Job Title in Step 1 first!");
      return;
    }
    setState(() => _isAiGenerating = true);
    try {
      // AIው አማርኛ መሆኑን እንዲያውቅ ቼክ እናደርጋለን
      bool isAmharic = RegExp(r'[\u1200-\u137F]').hasMatch(_jobTitleController.text);
      
      String result = await AIService.askAI(_jobTitleController.text, "summary", isAmharic: isAmharic);
      setState(() => _summaryController.text = result);
    } catch (e) {
      _showSnackBar("AI failed to generate content.");
    } finally {
      setState(() => _isAiGenerating = false);
    }
  }

Future<void> _finalizeAndGenerate() async {
    setState(() => _isLoading = true);
    try {
      // 1. መጀመሪያ ዳታውን በዳታቤዝ ውስጥ እናስቀምጣለን
      await DatabaseHelper.instance.saveProfile({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'jobTitle': _jobTitleController.text,
        'phone': _phoneController.text,
        'summary': _summaryController.text,
      });

      // 2. ሙሉውን ዳታ እና ሴቲንግ (ፎንት፣ ከለር) እናነባለን
      final rawData = await DatabaseHelper.instance.getFullProfile();
      final settings = await DatabaseHelper.instance.getSettings();

      if (rawData != null) {
        CvModel model = CvModel();
        model.fromMap(rawData);

        // 3. ከሴቲንግ አስፈላጊ መረጃዎችን እናወጣለን
        int templateIndex = settings['templateIndex'] ?? 0;
        Color primaryColor = Color(settings['themeColor'] ?? Colors.blue.value);
        
        if (!mounted) return;

        // 4. በቀጥታ ወደ Preview Screen እንልካለን (እዚያ ነው ፒዲኤፉ የሚመነጨው)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CvPreviewScreen(
              cvModel: model,
              templateIndex: templateIndex,
              primaryColor: primaryColor,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar("ስህተት ተከስቷል: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your CV"),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            steps: _buildSteps(),
            onStepContinue: () {
              if (_isStepValid()) { // መረጃው ትክክል ከሆነ ብቻ ይቀጥላል
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _finalizeAndGenerate();
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}