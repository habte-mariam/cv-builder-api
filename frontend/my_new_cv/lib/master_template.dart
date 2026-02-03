import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'cv_model.dart'; 
import 'app_fonts.dart';

class MasterTemplate {
  static void addPage(pw.Document pdf, CvModel model, CvDesign design, PdfColor primaryColor, pw.MemoryImage? img, double bodySize, String fontFamily) {
    
    bool hasSidebar = [CvDesign.creative, CvDesign.modern, CvDesign.minimal, CvDesign.professional].contains(design);
    bool sidebarOnLeft = design != CvDesign.modern; 
    
    PdfColor sidebarBg = (design == CvDesign.minimal) ? PdfColors.white : 
                         (design == CvDesign.modern) ? const PdfColor.fromInt(0xFFEEEEEE) : primaryColor;
    
    PdfColor sidebarTextColor = (sidebarBg == PdfColors.white || design == CvDesign.modern) ? PdfColors.black : PdfColors.white;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      // ይሄ ገጽ ሲሞላ በራሱ አዲስ ገጽ እንዲከፍት ይረዳል
      build: (context) {
        
        // --- Sidebar ---
        // MultiPage ውስጥ Sidebar እንዲቀጥል Containerን በየገጹ build እናደርጋለን
        final sidebarWidget = pw.Container(
          width: 180,
          color: sidebarBg,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (img != null) 
                pw.Center(child: pw.ClipOval(child: pw.Image(img, width: 85, height: 85, fit: pw.BoxFit.cover))),
              pw.SizedBox(height: 20),
              
              _sideHeader("CONTACT", sidebarTextColor, fontFamily),
              _sideItem(model.phone, sidebarTextColor, bodySize, fontFamily, label: "Tel: "),
              _sideItem(model.phone2, sidebarTextColor, bodySize, fontFamily, label: "Tel 2: "),
              _sideItem(model.email, sidebarTextColor, bodySize, fontFamily, label: "Email: "),
              _sideItem(model.address, sidebarTextColor, bodySize, fontFamily, label: "Add: "),
              _sideItem(model.linkedin, sidebarTextColor, bodySize, fontFamily, label: "LinkedIn: "),
              _sideItem(model.portfolio, sidebarTextColor, bodySize, fontFamily, label: "Web: "),
              
              if (model.nationality.isNotEmpty || model.gender.isNotEmpty || model.age.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _sideHeader("PERSONAL INFO", sidebarTextColor, fontFamily),
                _sideItem(model.nationality, sidebarTextColor, bodySize, fontFamily, label: "Nation: "),
                _sideItem(model.gender, sidebarTextColor, bodySize, fontFamily, label: "Gender: "),
                _sideItem(model.age, sidebarTextColor, bodySize, fontFamily, label: "Age: "),
              ],
              
// master_template.dart ውስጥ ያለውን የክህሎት ክፍል በዚህ ይተኩ
if (model.skills.isNotEmpty) ...[
  pw.SizedBox(height: 20),
  _sideHeader("SKILLS", sidebarTextColor, fontFamily),
  pw.Wrap(
    spacing: 6,
    runSpacing: 6,
    children: model.skills.map<pw.Widget>((s) {
      // ሎጂኩን እዚህ ጋር እናስተካክላለን - የተለያዩ ቁልፎችን በመፈተሽ
      final String name = (s['skillName'] ?? s['name'] ?? s['skill'] ?? '').toString();
      
      if (name.trim().isEmpty) return pw.SizedBox(); 

      return _buildSkillChip(
        name, 
        sidebarTextColor, 
        fontFamily, 
        isDark: sidebarBg != PdfColors.white,
        borderColor: sidebarTextColor, 
      );
    }).toList(),
  ),
],
              
              if (model.languages.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _sideHeader("LANGUAGES", sidebarTextColor, fontFamily),
                ...model.languages.map((l) => _sideItem("${l['name'] ?? l['languageName'] ?? ''} (${l['level'] ?? ''})", sidebarTextColor, bodySize - 1, fontFamily)),
              ],

              if (model.references.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _sideHeader("REFERENCES", sidebarTextColor, fontFamily),
                ...model.references.map((ref) => _buildReferenceItem(ref, bodySize, sidebarTextColor, fontFamily)),
              ],
            ],
          ),
        );

        // Sidebar ለሌላቸው Header 
        final noSidebarHeader = pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _topContactItem(model.phone, bodySize, fontFamily),
                if (model.email.isNotEmpty) _topContactItem(" | ${model.email}", bodySize, fontFamily),
                if (model.address.isNotEmpty) _topContactItem(" | ${model.address}", bodySize, fontFamily),
              ],
            ),
            if (model.linkedin.isNotEmpty || model.portfolio.isNotEmpty)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (model.linkedin.isNotEmpty) _topContactItem("LinkedIn: ${model.linkedin}", bodySize, fontFamily),
                  if (model.portfolio.isNotEmpty) _topContactItem(" | Web: ${model.portfolio}", bodySize, fontFamily),
                ],
              ),
            pw.SizedBox(height: 5),
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          ]
        );

        // --- Main Body (ይህ ክፍል ነው ገጽ በሚሞላ ጊዜ የሚቆረጠው) ---
return [
  pw.Partitions(
    children: [
      // ሳይድባሩ በግራ በኩል መሆን ካለበት (sidebarOnLeft == true)
      if (hasSidebar && sidebarOnLeft)
        pw.Partition(
          width: 180,
          child: sidebarWidget,
        ),
              
              // ዋናው ይዘት ክፍል
              pw.Partition(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(child: pw.Column(children: [
                        pw.Text(
                          "${model.firstName} ${model.lastName}".toUpperCase(), 
                          style: AppFonts.getStyle(text: "${model.firstName} ${model.lastName}", size: 26, isBold: true, preferredFamily: fontFamily)
                        ),
                        pw.Text(
                          model.jobTitle.toUpperCase(), 
                          style: AppFonts.getStyle(text: model.jobTitle, size: 14, color: primaryColor, isBold: true, preferredFamily: fontFamily)
                        ),
                      ])),
                      
                      pw.SizedBox(height: 10),
                      if (!hasSidebar) noSidebarHeader,

                      if (model.summary.isNotEmpty) ...[
                        _sectionTitle("PROFILE SUMMARY", primaryColor, fontFamily),
                        pw.Text(
                          model.summary, 
                          style: AppFonts.getStyle(text: model.summary, size: bodySize, preferredFamily: fontFamily), 
                          textAlign: pw.TextAlign.justify
                        ),
                      ],

                      if (model.experience.isNotEmpty) ...[
                        _sectionTitle("PROFESSIONAL EXPERIENCE", primaryColor, fontFamily),
                        ...model.experience.map((exp) => _buildExperience(exp, bodySize, primaryColor, fontFamily)),
                      ],

                      if (model.education.isNotEmpty) ...[
                        _sectionTitle("EDUCATION", primaryColor, fontFamily),
                        ...model.education.map((edu) => _buildEducation(edu, bodySize, fontFamily)),
                      ],

                      if (model.certificates.isNotEmpty) ...[
                        _sectionTitle("CERTIFICATIONS", primaryColor, fontFamily),
                        ...model.certificates.map((cert) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Bullet(
                            text: "${cert['certName']} - ${cert['organization']} (${cert['year']})", 
                            style: AppFonts.getStyle(text: "${cert['certName']}", size: bodySize, preferredFamily: fontFamily)
                          ),
                        )),
                      ],
if (!hasSidebar) ...[
  if (model.skills.isNotEmpty) ...[
    _sectionTitle("SKILLS", primaryColor, fontFamily),
    pw.Wrap(
      spacing: 8, 
      runSpacing: 8,
      // እዚህ ጋር .map<pw.Widget> መጠቀማችንን እናረጋግጥ
      children: model.skills.map<pw.Widget>((s) {
        final String name = (s['skillName'] ?? s['name'] ?? '').toString();
        if (name.trim().isEmpty) return pw.SizedBox();
        
        return _buildSkillChip(
          name, 
          PdfColors.black, // ሳይድባር ለሌለው ጥቁር ቦርደር ይሻላል
          fontFamily, 
          isDark: false // ዳራው ነጭ ስለሆነ isDark false መሆን አለበት
        );
      }).toList(),
    ),],


                        if (model.languages.isNotEmpty) ...[
                          _sectionTitle("LANGUAGES", primaryColor, fontFamily),
                          ...model.languages.map((l) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Text(
                              "${l['name'] ?? l['languageName'] ?? ''} (${l['level'] ?? ''})",
                              style: AppFonts.getStyle(text: "Lang", size: bodySize - 1, preferredFamily: fontFamily)
                            ),
                          )),
                        ],

                        if (model.references.isNotEmpty) ...[
                          _sectionTitle("REFERENCES", primaryColor, fontFamily),
                          // MultiPage ውስጥ GridView ችግር ስለሚፈጥር በWrap ወይም Column እንተካዋለን
                          pw.Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: model.references.map((ref) => pw.SizedBox(
                              width: 200,
                              child: _buildReferenceItem(ref, bodySize, PdfColors.black, fontFamily),
                            )).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

      // ሳይድባሩ በቀኝ በኩል መሆን ካለበት (sidebarOnLeft == false)
      if (hasSidebar && !sidebarOnLeft)
        pw.Partition(
          width: 180,
          child: sidebarWidget,
          ),  

            ],
          ),
        ];
      },
    ));
  }

  // --- Helper Widgets (እንዳሉ የቀጠሉ) ---

  static pw.Widget _buildReferenceItem(Map ref, double bodySize, PdfColor color, String fontFamily) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, right: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            ref['name'] ?? '', 
            style: AppFonts.getStyle(text: ref['name'] ?? '', size: bodySize - 1, isBold: true, color: color, preferredFamily: fontFamily)
          ),
          if ((ref['job'] ?? '').isNotEmpty || (ref['organization'] ?? '').isNotEmpty)
            pw.Text(
              "${ref['job'] ?? ''}${(ref['job'] ?? '').isNotEmpty && (ref['organization'] ?? '').isNotEmpty ? ' at ' : ''}${ref['organization'] ?? ''}",
              style: AppFonts.getStyle(text: "Job", size: bodySize - 3, color: color, preferredFamily: fontFamily)
            ),
          pw.Text(
            ref['phone'] ?? '', 
            style: AppFonts.getStyle(text: ref['phone'] ?? '', size: bodySize - 2, color: color, preferredFamily: fontFamily)
          ),
          if ((ref['email'] ?? '').isNotEmpty)
             pw.Text(
              ref['email'] ?? '', 
              style: AppFonts.getStyle(text: "Email", size: bodySize - 3, color: color, preferredFamily: fontFamily)
            ),
        ]
      ),
    );
  }

  static pw.Widget _topContactItem(String text, double size, String fontFamily) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Text(text, style: AppFonts.getStyle(text: text, size: size - 2, preferredFamily: fontFamily));
  }

  static pw.Widget _sideItem(String text, PdfColor color, double size, String fontFamily, {String label = ""}) {
    if (text.isEmpty || text == "null") return pw.SizedBox();
    String fullText = "$label$text";
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(fullText, style: AppFonts.getStyle(text: fullText, color: color, size: size - 2, preferredFamily: fontFamily)),
    );
  }

  static pw.Widget _sideHeader(String title, PdfColor color, String fontFamily) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: AppFonts.getStyle(text: title, color: color, isBold: true, size: 10, preferredFamily: fontFamily)),
      pw.Divider(color: color, thickness: 0.5),
      pw.SizedBox(height: 5),
    ]
  );

  static pw.Widget _sectionTitle(String title, PdfColor color, String fontFamily) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 15, bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: AppFonts.getStyle(text: title, size: 13, isBold: true, color: color, preferredFamily: fontFamily)),
        pw.Container(height: 1, width: 30, color: color),
      ]
    ),
  );

  static pw.Widget _buildExperience(Map exp, double size, PdfColor primary, String fontFamily) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(child: pw.Text(exp['jobTitle'] ?? '', style: AppFonts.getStyle(text: exp['jobTitle'] ?? '', size: size, isBold: true, preferredFamily: fontFamily))),
        pw.Text(exp['duration'] ?? '', style: AppFonts.getStyle(text: exp['duration'] ?? '', size: size - 2, color: PdfColors.black, preferredFamily: fontFamily)),
      ]),
      pw.Text(exp['companyName'] ?? '', style: AppFonts.getStyle(text: exp['companyName'] ?? '', size: size - 1, color: primary, isBold: true, preferredFamily: fontFamily)),
      if (exp['jobDescription']?.isNotEmpty == true)
        pw.Text(exp['jobDescription'], style: AppFonts.getStyle(text: exp['jobDescription'], size: size - 1, preferredFamily: fontFamily)),
      if (exp['achievements']?.isNotEmpty == true)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text("Achievements: ${exp['achievements']}", style: AppFonts.getStyle(text: "Achievements", size: size - 2, isItalic: true, preferredFamily: fontFamily)),
        ),
    ]),
  );

  static pw.Widget _buildEducation(Map edu, double size, String fontFamily) {
    String school = edu['school'] ?? '';
    String degree = edu['degree'] ?? '';
    String field = edu['field'] ?? '';
    String cgpa = edu['cgpa'] ?? '';
    String gradYear = edu['gradYear']?.toString() ?? '';
    bool isSchool = school.toLowerCase().contains('school') || degree.toLowerCase().contains('grade') || degree.toLowerCase().contains('preparatory');

    if (isSchool) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Bullet(text: "$degree: $school", style: AppFonts.getStyle(text: school, size: size - 1, preferredFamily: fontFamily))),
          pw.Text(gradYear, style: AppFonts.getStyle(text: gradYear, size: size - 2, color: PdfColors.black, preferredFamily: fontFamily)),
        ]
      );
    }
    String degreeFull = field.isNotEmpty ? "$degree in $field" : degree;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(child: pw.Text(degreeFull, style: AppFonts.getStyle(text: degreeFull, size: size, isBold: true, preferredFamily: fontFamily))),
            pw.Text("Class of $gradYear", style: AppFonts.getStyle(text: gradYear, size: size - 2, color: PdfColors.black, preferredFamily: fontFamily)),
          ]
        ),
        pw.Text(school, style: AppFonts.getStyle(text: school, size: size - 1, preferredFamily: fontFamily)),
        if (cgpa.isNotEmpty) 
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text("CGPA: $cgpa", style: AppFonts.getStyle(text: cgpa, size: size - 2, isBold: true, preferredFamily: fontFamily)),
          ),
      ]),
    );
  }

static pw.Widget _buildSkillChip(String skill, PdfColor color, String fontFamily, {bool isDark = true, PdfColor? borderColor}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: pw.BoxDecoration(
      // ሳይድባሩ ጨለማ ከሆነ ሳጥኑ ትንሽ ቀለል ይላል፡ ነጭ ከሆነ ደግሞ ግራጫ ይሆናል
      color: isDark ? PdfColors.grey900 : PdfColors.grey200, 
      borderRadius: pw.BorderRadius.circular(3),
      border: pw.Border.all(
        color: borderColor?.flatten() ?? color.flatten(), 
        width: 0.5
      ),
    ),
    child: pw.Text(
      skill, 
      style: AppFonts.getStyle(
        text: skill, 
        size: 8, 
        isBold: true, 
        color: isDark ? PdfColors.white : PdfColors.black,
        preferredFamily: fontFamily
      )
    ),
  );
}
}