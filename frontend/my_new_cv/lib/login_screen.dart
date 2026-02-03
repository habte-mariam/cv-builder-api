/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoggingIn = true);

    try {
      final authService = AuthService();
      User? user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        // ሎጊን ከተሳካ ወደ HomeScreen ይወስደዋል
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // የጀርባ ዲዛይን (ጌጥ)
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.1,
                child: CircleAvatar(
                  radius: size.width * 0.4,
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.05),
                ),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_rounded, 
                          size: 80, 
                          color: Color(0xFF1E293B)
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      const Text(
                        "CV Pro Generator",
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF1E293B),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Professional resumes made simple.\nSign in to start building.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey, height: 1.5),
                      ),
                      
                      const SizedBox(height: 60),

                      _isLoggingIn 
                        ? const CircularProgressIndicator(color: Color(0xFF1E293B))
                        : SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: Image.network(
                                'https://authjs.dev/img/providers/google.svg', 
                                height: 24,
                                // ኢንተርኔት ከሌለ ወይም ምስሉ ካልመጣ Icon ያሳያል
                                errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.account_circle, color: Colors.blue),
                              ),
                              label: const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontSize: 17, 
                                  fontWeight: FontWeight.w600, 
                                  color: Colors.black87
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 1,
                                shadowColor: Colors.black26,
                              ),
                            ),
                          ),

                      const SizedBox(height: 40),
                      
                      const Text(
                        "By continuing, you agree to our Terms of Service\nand Privacy Policy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/