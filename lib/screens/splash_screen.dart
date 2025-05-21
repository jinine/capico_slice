import 'package:flutter/material.dart';
import 'package:capico_slice/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Navigate to home screen after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate logo size based on screen dimensions
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          // Use the smaller dimension to ensure the logo fits both width and height
          final logoSize = screenWidth < screenHeight 
              ? screenWidth * 0.8  // 80% of width if width is smaller
              : screenHeight * 0.8; // 80% of height if height is smaller

          return Center(
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/logo1.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
} 