import 'package:flutter/material.dart';
import 'package:capico_slice/screens/game_grid_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _startGame() async {
    // Always navigate to GameScreen regardless of audio initialization
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameGridScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/poster.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes based on screen dimensions
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            
            // Calculate font sizes (adjust these multipliers as needed)
            final titleFontSize = screenWidth * 0.15; // 15% of screen width
            final buttonFontSize = screenWidth * 0.06; // 6% of screen width
            
            // Calculate button padding
            final buttonHorizontalPadding = screenWidth * 0.1; // 10% of screen width
            final buttonVerticalPadding = screenHeight * 0.02; // 2% of screen height
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with two different fonts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Capico',
                        style: TextStyle(
                          fontFamily: 'Starbim',
                          fontSize: titleFontSize,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Slice',
                        style: TextStyle(
                          fontFamily: 'Aesthetic',
                          fontSize: titleFontSize,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05), // 5% of screen height
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonHorizontalPadding,
                        vertical: buttonVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05), // 5% of screen width
                      ),
                    ),
                    child: Text(
                      'Start Game',
                      style: TextStyle(
                        fontFamily: 'Daydream',
                        fontSize: buttonFontSize,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 