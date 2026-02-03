import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ያንተ የገጽ ፋይሎች
import 'splash_screen.dart';
import 'home_screen.dart';
//import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase-ን ማስነሳት
  await Firebase.initializeApp();

  // ማሳሰቢያ፡ Python/Supabase ስለምንጠቀም የ Firebase Database Persistence አያስፈልግህም
  // FirebaseDatabase.instance.setPersistenceEnabled(true); // <--- ካልተጠቀምክበት አጥፋው

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CV Maker Pro',
      // መጀመሪያ Splash Screen እንዲታይ '/' ወደ SplashScreen እንቀይረው
      initialRoute: '/',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'Times New Roman',
      ),
      routes: {
        '/': (context) => const SplashScreen(), // 1. መጀመሪያ ይሄ ይከፈታል
        '/auth': (context) => const AuthWrapper(), // 2. ከ Splash በኋላ እዚህ ይመጣል
        '/home': (context) => const HomeScreen(),
        //  '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // ገጹ እንደተከፈተ አፕዴት መኖሩን ቼክ ያደርጋል
    _checkAppUpdate();
  }

  Future<void> _checkAppUpdate() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: Duration.zero,
      ));

      // ሪሞት ኮንፊግ ዳታውን አምጣና አግብር
      await remoteConfig.fetchAndActivate();

      String configJson = remoteConfig.getString('appConfig');

      if (configJson.isNotEmpty && configJson != "{}") {
        Map<String, dynamic> config = jsonDecode(configJson);
        int newVersion = config['new_version'] ?? 0;
        String updateUrl = config['url'] ?? 'https://google.com';

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        int currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;

        if (newVersion > currentVersion && mounted) {
          _showUpdateDialog(updateUrl);
        }
      }
    } catch (e) {
      debugPrint("Update Check Error: $e");
    }
  }

  void _showUpdateDialog(String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Required! 🚀",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "A new and improved version is available. Please update to continue using the app."),
        actions: [
          TextButton(
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                debugPrint("Could not launch $url");
              }
            },
            child: const Text("UPDATE NOW",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ለጊዜው Login-ን Skip ለማድረግ snapshot.hasData የሚለውን ቼክ አንጠቀምም
        // በቀጥታ HomeScreen-ን ይመልስልሃል
        return const HomeScreen();

        /* // ለወደፊቱ Login ሲስተካክል ይሄን ትመልሰዋለህ፡
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
        */
      },
    );
  }
}
