import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cv_pro_final.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path, 
      version: 17, 
      onCreate: _createDB, 
      onUpgrade: _onUpgrade, 
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Profile Table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT, lastName TEXT, jobTitle TEXT,
        gender TEXT, age TEXT, email TEXT, 
        phone TEXT, phone2 TEXT, address TEXT,
        nationality TEXT, summary TEXT, profileImagePath TEXT,
        linkedin TEXT, portfolio TEXT
      )
    ''');

    // 2. Education Table
    await db.execute('''
      CREATE TABLE education (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER, school TEXT, degree TEXT, field TEXT,
        gradYear TEXT, cgpa TEXT, project TEXT,
        FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE
      )
    ''');

    // 3. Experience Table
    await db.execute('''
      CREATE TABLE experience (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profileId INTEGER, companyName TEXT, jobTitle TEXT,
        duration TEXT, jobDescription TEXT, achievements TEXT,
        isCurrentlyWorking INTEGER,
        FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE
      )
    ''');

    // 4. User References Table
    await db.execute('''
      CREATE TABLE user_references (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        profileId INTEGER, 
        name TEXT, 
        job TEXT, 
        organization TEXT, 
        phone TEXT, 
        email TEXT, 
        FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE
      )
    ''');

    // 5. Skills, Languages, Certificates
    await db.execute('CREATE TABLE skills (id INTEGER PRIMARY KEY AUTOINCREMENT, profileId INTEGER, name TEXT, level TEXT, FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE languages (id INTEGER PRIMARY KEY AUTOINCREMENT, profileId INTEGER, name TEXT, level TEXT, FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE certificates (id INTEGER PRIMARY KEY AUTOINCREMENT, profileId INTEGER, certName TEXT, organization TEXT, year TEXT, FOREIGN KEY (profileId) REFERENCES profile (id) ON DELETE CASCADE)');

    // 6. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        themeColor INTEGER,
        language TEXT,
        isLocked INTEGER,
        password TEXT,
        fontSize TEXT,
        fontFamily TEXT,
        templateIndex INTEGER
      )
    ''');

    // 7. Saved CVs Table
    await db.execute('''
      CREATE TABLE saved_cvs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT, filePath TEXT, createdDate TEXT
      )
    ''');

    // የመጀመሪያ ሴቲንግ ዳታ ማስገባት
    await db.insert('settings', {
      'id': 1,
      'themeColor': 0xFF1E293B, 
      'language': 'English', 
      'isLocked': 0, 
      'password': '', 
      'fontSize': 'Medium', 
      'fontFamily': 'Times New Roman',
      'templateIndex': 0
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 17) {
      try {
        await db.execute("ALTER TABLE user_references ADD COLUMN jobTitle TEXT DEFAULT ''");
        await db.execute("ALTER TABLE user_references ADD COLUMN organization TEXT DEFAULT ''");
      } catch (e) { print("v17 upgrade error: $e"); }
    }
  }

  // --- Profile Operations ---
  Future<Map<String, dynamic>?> getFullProfile() async {
    final db = await instance.database;
    final res = await db.query('profile', limit: 1);
    if (res.isEmpty) return null;
    
    Map<String, dynamic> data = Map<String, dynamic>.from(res.first);
    int pId = data['id'];
    
    data['education'] = await db.query('education', where: 'profileId = ?', whereArgs: [pId]);
    data['experience'] = await db.query('experience', where: 'profileId = ?', whereArgs: [pId]);
    data['skills'] = await db.query('skills', where: 'profileId = ?', whereArgs: [pId]);
    data['languages'] = await db.query('languages', where: 'profileId = ?', whereArgs: [pId]);
    data['certificates'] = await db.query('certificates', where: 'profileId = ?', whereArgs: [pId]);
    data['user_references'] = await db.query('user_references', where: 'profileId = ?', whereArgs: [pId]);
    
    return data;
  }

Future<int> saveProfile(Map<String, dynamic> data) async {
  final db = await instance.database;
  
  // የ ዝርዝር መረጃዎች (Lists) ካሉ ዳታቤዙ እንዳይበላሽ አስወግዳቸው
  final cleanData = Map<String, dynamic>.from(data);
  cleanData.remove('education');
  cleanData.remove('experience');
  cleanData.remove('skills');
  cleanData.remove('languages');
  cleanData.remove('certificates');
  cleanData.remove('user_references');

  final existing = await db.query('profile', limit: 1);
  if (existing.isNotEmpty) {
    int id = existing.first['id'] as int;
    await db.update('profile', cleanData, where: 'id = ?', whereArgs: [id]);
    return id;
  } else {
    return await db.insert('profile', cleanData);
  }
}

  Future<int> updateProfileSummary(int profileId, String summaryText) async {
    final db = await instance.database;
    return await db.update('profile', {'summary': summaryText}, where: 'id = ?', whereArgs: [profileId]);
  }

  // --- Settings ---
  Future<Map<String, dynamic>> getSettings() async {
    final db = await instance.database;
    final res = await db.query('settings', where: 'id = 1');
    if (res.isNotEmpty) return res.first;
    
    return {
      'themeColor': 0xFF1E293B, 
      'language': 'English', 
      'isLocked': 0, 
      'fontSize': 'Medium', 
      'fontFamily': 'Times New Roman',
      'password': '',
      'templateIndex': 0
    };
  }

  Future<void> saveSettings(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('settings', {'id': 1, ...data}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- CV History ---
  Future<int> insertSavedCv(String fileName, String filePath) async {
    final db = await instance.database;
    return await db.insert('saved_cvs', {
      'fileName': fileName,
      'filePath': filePath,
      'createdDate': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSavedCvs() async => (await instance.database).query('saved_cvs', orderBy: 'createdDate DESC');

  Future<void> deleteCv(int id) async {
    final db = await instance.database;
    await db.delete('saved_cvs', where: 'id = ?', whereArgs: [id]);
  }

  // --- Add Data Operations ---
  Future<int> addEducation(Map<String, dynamic> data) async => (await instance.database).insert('education', data);
  Future<int> addExperience(Map<String, dynamic> data) async => (await instance.database).insert('experience', data);
  Future<int> addSkill(Map<String, dynamic> data) async => (await instance.database).insert('skills', data);
  Future<int> addLanguage(Map<String, dynamic> data) async => (await instance.database).insert('languages', data);
  Future<int> addCertificate(Map<String, dynamic> data) async => (await instance.database).insert('certificates', data);
  Future<int> addReference(Map<String, dynamic> data) async => (await instance.database).insert('user_references', data);

  // --- Edit/Delete ---
  Future<int> deleteItem(String table, int id) async => (await instance.database).delete(table, where: 'id = ?', whereArgs: [id]);
  Future<int> updateItem(String table, int id, Map<String, dynamic> data) async => (await instance.database).update(table, data, where: 'id = ?', whereArgs: [id]);

  // --- Clear Operations ---
  Future<void> clearEducation(int pId) async => (await instance.database).delete('education', where: 'profileId = ?', whereArgs: [pId]);
  Future<void> clearExperience(int pId) async => (await instance.database).delete('experience', where: 'profileId = ?', whereArgs: [pId]);
  Future<void> clearSkills(int pId) async => (await instance.database).delete('skills', where: 'profileId = ?', whereArgs: [pId]);
  Future<void> clearLanguages(int pId) async => (await instance.database).delete('languages', where: 'profileId = ?', whereArgs: [pId]);
  Future<void> clearCertificates(int pId) async => (await instance.database).delete('certificates', where: 'profileId = ?', whereArgs: [pId]);
  Future<void> clearReferences(int pId) async => (await instance.database).delete('user_references', where: 'profileId = ?', whereArgs: [pId]);

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('profile'); 
    await db.delete('saved_cvs'); 
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final db = await instance.database;
    final res = await db.query('profile', limit: 1);
    if (res.isEmpty) return null;
    
    Map<String, dynamic> data = Map<String, dynamic>.from(res.first);
    int pId = data['id'];
    
    data['education'] = await db.query('education', where: 'profileId = ?', whereArgs: [pId]);
    data['experience'] = await db.query('experience', where: 'profileId = ?', whereArgs: [pId]);
    data['skills'] = await db.query('skills', where: 'profileId = ?', whereArgs: [pId]);
    data['languages'] = await db.query('languages', where: 'profileId = ?', whereArgs: [pId]);
    data['certificates'] = await db.query('certificates', where: 'profileId = ?', whereArgs: [pId]);
    data['user_references'] = await db.query('user_references', where: 'profileId = ?', whereArgs: [pId]);
    
    return data;
  }
}