enum CvDesign {
  creative,
  modern,
  minimal,
  executive,
  classic,
  corporate,
  bold,
  elegant,
  professional,
  compact
}

class CvModel {
  String firstName = '';
  String lastName = '';
  String jobTitle = '';
  String portfolio = '';
  String email = '';
  String phone = '';
  String phone2 = '';
  String address = '';
  String age = '';
  String gender = '';
  String nationality = '';
  String linkedin = '';
  String profileImagePathPath = '';
  String summary = '';

  List<Map<String, dynamic>> education = [];
  List<Map<String, dynamic>> experience = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> languages = [];
  List<Map<String, dynamic>> certificates = [];
  List<Map<String, dynamic>> references = [];

  CvModel();

  void fromMap(Map<String, dynamic> map) {
    firstName = map['firstName'] ?? '';
    lastName = map['lastName'] ?? '';
    jobTitle = map['jobTitle'] ?? '';
    portfolio = map['portfolio'] ?? '';
    email = map['email'] ?? '';
    phone = map['phone'] ?? '';
    phone2 = map['phone2'] ?? '';
    address = map['address'] ?? '';
    age = map['age'] ?? '';
    gender = map['gender'] ?? '';
    nationality = map['nationality'] ?? '';
    linkedin = map['linkedin'] ?? '';
    profileImagePathPath = map['profileImagePath'] ?? '';
    summary = map['summary'] ?? '';

    // ትምህርትን (Education) መጫን - CGPA እና Project ተካተዋል
    if (map['education'] != null) {
      education = (map['education'] as List)
          .map((e) => {
                'school': e['school'] ?? '',
                'degree': e['degree'] ?? '',
                'field': e['field'] ?? '',
                'gradYear': e['gradYear']?.toString() ?? '',
                'cgpa': e['cgpa'] ?? '',
                'project': e['project'] ?? '',
              })
          .toList()
          .cast<Map<String, dynamic>>();
    }

    // የሥራ ልምድን (Experience) መጫን - isCurrentlyWorking እና achievements ተካተዋል
    if (map['experience'] != null) {
      experience = (map['experience'] as List)
          .map((e) => {
                'companyName': e['companyName'] ?? '',
                'jobTitle': e['jobTitle'] ?? '',
                'duration': e['duration'] ?? '',
                'jobDescription': e['jobDescription'] ?? '',
                'achievements': e['achievements'] ?? '',
                'isCurrentlyWorking': e['isCurrentlyWorking'] ?? 0,
              })
          .toList()
          .cast<Map<String, dynamic>>();
    }

    // ሰርተፊኬቶችን (Certificates) መጫን - በ QualificationsScreen ላይ ባለው ስም መሠረት
    if (map['certificates'] != null) {
      certificates = (map['certificates'] as List)
          .map((e) => {
                'certName': e['certName'] ?? '',
                'organization': e['organization'] ?? '',
                'year': e['year']?.toString() ?? '',
              })
          .toList()
          .cast<Map<String, dynamic>>();
    }

    // ሌሎች ዝርዝሮችን መጫን
    skills = _parseList(map['skills']);
    languages = _parseList(map['languages']);

    if (map['user_references'] != null) {
      references = (map['user_references'] as List)
          .map((e) => {
                'name': e['name']?.toString() ?? '',
                'job': e['job']?.toString() ?? '',
                'organization': e['organization']?.toString() ?? '',
                'phone': e['phone']?.toString() ?? '',
                'email': e['email']?.toString() ?? '',
              })
          .toList()
          .cast<Map<String, dynamic>>();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'jobTitle': jobTitle,
      'portfolio': portfolio,
      'email': email,
      'phone': phone,
      'phone2': phone2,
      'address': address,
      'age': age,
      'gender': gender,
      'nationality': nationality,
      'linkedin': linkedin,
      'profileImagePath': profileImagePathPath,
      'summary': summary,
      'education': education,
      'experience': experience,
      'skills': skills,
      'languages': languages,
      'certificates': certificates,
      'user_references': references,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .map((item) {
          if (item is Map) {
            return {
              // 'name' ወይም 'skillName' ቢመጣ 'name' በሚል አንድ አድርጎ ይይዛል
              'name': (item['name'] ??
                      item['skillName'] ??
                      item['languageName'] ??
                      '')
                  .toString(),
              'level': (item['level'] ?? '').toString(),
            };
          }
          return <String, dynamic>{};
        })
        .where((element) => element['name']!.isNotEmpty)
        .toList();
  }
}
