import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart'; // ይህ በጣም አስፈላጊ ነው! AuthWrapper-ን እንዲያውቀው ያደርጋል

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotateController; 
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _displayedText = "";
  final String _fullText = "CV Builder Pro";
  int _charIndex = 0;

  final List<String> _quotes = [
    "Success starts with preparation!",
    "Build a CV that matches your dreams today.",
    "Have confidence in your abilities!",
    "A quality CV opens doors to job opportunities."
  ];
  late String _randomQuote;

  @override
  void initState() {
    super.initState();
    _randomQuote = _quotes[Random().nextInt(_quotes.length)];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // ጽሁፍ የመጻፍ አኒሜሽን
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_charIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _displayedText += _fullText[_charIndex];
            _charIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });

    // በትክክል ከ 4 ሰከንድ በኋላ ወደ AuthWrapper ይሸጋገራል
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[900]!,
              const Color(0xFF1A237E),
              const Color(0xFF0D47A1),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(6, (index) => _buildBubble(index)),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateY(_rotateController.value * 2 * pi),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/app_icon.png',
                          height: 85,
                          errorBuilder: (context, error, stackTrace) => 
                              Icon(Icons.description_rounded, size: 85, color: Colors.indigo[900]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _displayedText,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [Shadow(blurRadius: 15, color: Colors.blueAccent)],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _randomQuote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orangeAccent.withOpacity(0.9),
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(int index) {
    final random = Random();
    return Positioned(
      top: random.nextDouble() * 700,
      left: random.nextDouble() * 350,
      child: Opacity(
        opacity: 0.1,
        child: Container(
          width: (index + 1) * 20.0,
          height: (index + 1) * 20.0,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}