import 'package:flutter/material.dart';
import 'package:color_splice/game/components/character.dart'; // Import CharacterType
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback

class GameGridScreen extends StatefulWidget {
  const GameGridScreen({super.key});

  @override
  State<GameGridScreen> createState() => _GameGridScreenState();
}

class _GameGridScreenState extends State<GameGridScreen> {
  static const int rows = 6;
  static const int columns = 4;

  late List<List<CharacterType?>> board;
  final math.Random _random = math.Random();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer for success sound
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // Initialize AudioPlayer for background music
  final GlobalKey _gridKey = GlobalKey(); // Key for accessing GridView RenderBox
  final GlobalKey _expandedKey = GlobalKey(); // Key for accessing Expanded RenderBox

  // Define character type and their corresponding asset paths and colors
  final Map<CharacterType, String> characterAssetPaths = {
    CharacterType.bear: 'assets/images/bear.png',
    CharacterType.capico: 'assets/images/capico.png',
    CharacterType.frog: 'assets/images/frog.png',
    CharacterType.snake: 'assets/images/snake.png',
  };

  final Map<CharacterType, Color> characterColors = {
    CharacterType.bear: Colors.white,
    CharacterType.capico: Colors.yellow,
    CharacterType.frog: Colors.green,
    CharacterType.snake: Colors.green,
  };

  List<List<int>> _swipePath = [];
  CharacterType? _currentConnectType;

  int _score = 0;
  int _highestCombo = 0; // Assuming combo logic will be added later
  bool _isMuted = false; // State to track mute status

  @override
  void initState() {
    super.initState();
    initializeBoard();
    _loadSound(); // Load the success sound
    _startBackgroundMusic(); // Start background music
  }

  // Start background music
  Future<void> _startBackgroundMusic() async {
    await _backgroundPlayer.setSource(AssetSource('audio/ss1.mp3')); // Assuming background_music.mp3
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music
    _backgroundPlayer.resume(); // Start playing
  }

  // Load the sound file
  Future<void> _loadSound() async {
    await _audioPlayer.setSource(AssetSource('audio/success.mp3')); // Assuming success.mp3 in assets/audio
    _audioPlayer.setReleaseMode(ReleaseMode.release); // Release resources after playback
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the success audio player
    _backgroundPlayer.dispose(); // Dispose the background audio player
    super.dispose();
  }

  void initializeBoard() {
    board = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (j) => null,
      ),
    );
    // Keep generating until there are no matches
    do {
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
          board[i][j] = getRandomCharacter(i, j);
        }
      }
    } while (hasInitialMatches());
  }

  CharacterType getRandomCharacter(int row, int col) {
    final types = CharacterType.values;
    CharacterType type;
    do {
      type = types[_random.nextInt(types.length)];
    } while (wouldCreateMatch(row, col, type));
    return type;
  }

  bool wouldCreateMatch(int row, int col, CharacterType type) {
    // Check horizontal matches
    if (col >= 2) {
      if (board[row][col - 1] == type && board[row][col - 2] == type) {
        return true;
      }
    }
    if (col <= columns - 3) {
      if (board[row][col + 1] == type && board[row][col + 2] == type) {
        return true;
      }
    }
    if (col > 0 && col < columns - 1) {
      if (board[row][col - 1] == type && board[row][col + 1] == type) {
        return true;
      }
    }

    // Check vertical matches
    if (row >= 2) {
      if (board[row - 1][col] == type && board[row - 2][col] == type) {
        return true;
      }
    }
    if (row <= rows - 3) {
      if (board[row + 1][col] == type && board[row + 2][col] == type) {
        return true;
      }
    }
    if (row > 0 && row < rows - 1) {
      if (board[row - 1][col] == type && board[row + 1][col] == type) {
        return true;
      }
    }

    return false;
  }

  bool hasInitialMatches() {
    // Check horizontal matches
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns - 2; col++) {
        if (board[row][col] != null &&
            board[row][col] == board[row][col + 1] &&
            board[row][col] == board[row][col + 2]) {
          return true;
        }
      }
    }

    // Check vertical matches
    for (int row = 0; row < rows - 2; row++) {
      for (int col = 0; col < columns; col++) {
        if (board[row][col] != null &&
            board[row][col] == board[row + 1][col] &&
            board[row][col] == board[row + 2][col]) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Add some space at the top
            const SizedBox(height: 20.0),

            // Header with back button and scores
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Highest Combo: $_highestCombo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Daydream',
                          ),
                        ),
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Daydream',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              key: _expandedKey, // Assign the key to the Expanded widget
              child: SafeArea(
                child: Center(
                  child: GestureDetector(
                    onPanDown: _onPanDown,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: GridView.builder(
                      key: _gridKey, // Assign the key to the GridView
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                      ),
                      itemCount: rows * columns,
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding to the bottom
                      itemBuilder: (context, index) {
                        final row = index ~/ columns;
                        final col = index % columns;

                        final isSelected = _swipePath.any((pos) => pos[0] == row && pos[1] == col);

                        // Basic square representation
                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.5) // Highlight selected cells
                                : characterColors[board[row][col]] ?? Colors.transparent, // Set cell background based on character type
                            border: Border.all(color: Colors.black.withOpacity(isSelected ? 0.8 : 0.3)), // Add a subtle border
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: board[row][col] != null
                                ? Image.asset(
                                    characterAssetPaths[board[row][col]]!,
                                    fit: BoxFit.contain,
                                  )
                                : null, // Display character image or nothing if null
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Optional: Add a flexible space below the grid if needed
            // Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void _onPanDown(DragDownDetails details) {
    debugPrint('_onPanDown called');
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    debugPrint('Pan Down Local Position: $localPosition');
    final index = _getIndexFromPosition(localPosition);

    if (index != null) {
      debugPrint('Pan Down Index: $index');
    }

    if (index != null) {
      final row = index ~/ columns;
      final col = index % columns;
      final characterType = board[row][col];

      if (characterType != null) {
        setState(() {
          _swipePath = [[row, col]];
          _currentConnectType = characterType;
        });
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    debugPrint('_onPanUpdate called');
    if (_currentConnectType == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    debugPrint('Pan Update Local Position: $localPosition');
    final index = _getIndexFromPosition(localPosition);

    if (index != null) {
      debugPrint('Pan Update Index: $index');
    }

    if (index != null) {
      final row = index ~/ columns;
      final col = index % columns;
      final characterType = board[row][col];

      if (characterType == _currentConnectType) {
        // Check if adjacent to the last cell in the path and not already in the path
        if (_swipePath.isNotEmpty) {
          final lastPos = _swipePath.last;
          if (isAdjacent(lastPos[0], lastPos[1], row, col) &&
              !_swipePath.any((pos) => pos[0] == row && pos[1] == col)) {
            setState(() {
              _swipePath.add([row, col]);
            });
          }
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    debugPrint('_onPanEnd called');
    if (_swipePath.length >= 3) { // Process swipe only if at least three cells are selected
      processSwipe(); // Process the swipe (remove, fall, fill)
    }

    // Reset swipe path and current connect type
    setState(() {
      _swipePath = [];
      _currentConnectType = null;
    });
  }

  void processSwipe() {
    // Remove matched characters
    int removedCount = 0;
    for (final pos in _swipePath) {
      board[pos[0]][pos[1]] = null;
      removedCount++;
    }

    // Update score based on the number of characters removed
    if (removedCount >= 3) { // Check if at least 3 characters were removed
      setState(() {
        _score += removedCount * 10; // Example scoring: 10 points per character
        // Combo logic would be added here
      });
    }

    // Make characters fall and fill empty spaces
    makeCharactersFall();
    fillEmptySpaces();

    // Process any new matches created by falling and new characters
    processMatches();
  }

  void makeCharactersFall() {
    for (int col = 0; col < columns; col++) {
      for (int row = rows - 1; row >= 0; row--) {
        if (board[row][col] == null) {
          // Find the first non-null character above
          for (int aboveRow = row - 1; aboveRow >= 0; aboveRow--) {
            if (board[aboveRow][col] != null) {
              board[row][col] = board[aboveRow][col];
              board[aboveRow][col] = null;
              break;
            }
          }
        }
      }
    }
  }

  void fillEmptySpaces() {
    for (int col = 0; col < columns; col++) {
      for (int row = 0; row < rows; row++) {
        if (board[row][col] == null) {
          board[row][col] = getRandomCharacter(row, col);
        }
      }
    }
  }

  void processMatches() {
    bool hasNewMatches = true;
    while (hasNewMatches) {
      hasNewMatches = false;

      // Mark matches for removal
      List<List<bool>> toRemove = List.generate(
        rows,
        (i) => List.generate(columns, (j) => false),
      );

      // Check horizontal matches
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns - 2; col++) {
          if (board[row][col] != null &&
              board[row][col] == board[row][col + 1] &&
              board[row][col] == board[row][col + 2]) {
            toRemove[row][col] = true;
            toRemove[row][col + 1] = true;
            toRemove[row][col + 2] = true;
            hasNewMatches = true;
          }
        }
      }

      // Check vertical matches
      for (int row = 0; row < rows - 2; row++) {
        for (int col = 0; col < columns; col++) {
          if (board[row][col] != null &&
              board[row][col] == board[row + 1][col] &&
              board[row][col] == board[row + 2][col]) {
            toRemove[row][col] = true;
            toRemove[row + 1][col] = true;
            toRemove[row + 2][col] = true;
            hasNewMatches = true;
          }
        }
      }

      if (hasNewMatches) {
        // Collect matched characters for removal
        Set<List<int>> currentMatches = {};
        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < columns; col++) {
            if (toRemove[row][col]) {
              currentMatches.add([row, col]);
            }
          }
        }

        HapticFeedback.vibrate(); // Vibrate on match

        // Remove matched characters
        for (final pos in currentMatches) {
          board[pos[0]][pos[1]] = null;
        }

        // Process subsequent cascades
        makeCharactersFall();
        fillEmptySpaces();
      }
    }
    // After all cascades, check for possible connections
    _checkForPossibleConnections();
  }

  void _checkForPossibleConnections() {
    bool possibleConnectionsExist = false;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (board[row][col] != null) {
          // Check for possible connections starting from this cell
          if (_findConnectionsFromCell(row, col, board[row][col]!, [])) {
            possibleConnectionsExist = true;
            break; // Found at least one connection, no need to check further
          }
        }
      }
      if (possibleConnectionsExist) break;
    }

    if (!possibleConnectionsExist) {
      _showNoPossibleConnectionsDialog();
    }
  }

  // Recursive helper function to find connections from a cell
  bool _findConnectionsFromCell(int row, int col, CharacterType type, List<List<int>> currentPath) {
    // Add current cell to the path
    final newPath = List<List<int>>.from(currentPath)..
        add([row, col]);

    // If the path has at least 3 cells, a connection is possible
    if (newPath.length >= 3) {
      return true;
    }

    // Check adjacent cells
    final possibleMoves = [
      [row - 1, col], // Up
      [row + 1, col], // Down
      [row, col - 1], // Left
      [row, col + 1], // Right
    ];

    for (final move in possibleMoves) {
      final nextRow = move[0];
      final nextCol = move[1];

      // Check if the adjacent cell is within bounds and has the same character type
      if (nextRow >= 0 && nextRow < rows && nextCol >= 0 && nextCol < columns &&
          board[nextRow][nextCol] == type) {
        // Check if the adjacent cell is not already in the current path
        if (!newPath.any((pos) => pos[0] == nextRow && pos[1] == nextCol)) {
          // Recursively check for connections from the adjacent cell
          if (_findConnectionsFromCell(nextRow, nextCol, type, newPath)) {
            return true;
          }
        }
      }
    }

    return false; // No valid connection found from this cell
  }

  void _showNoPossibleConnectionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87, // Dark background for the dialog
          title: const Text(
            'No Possible Slices!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Daydream', // Apply Daydream font
              fontSize: 24,
            ),
          ),
          content: const Text(
            'Shuffling board...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Daydream', // Apply Daydream font
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: 'Daydream', // Apply Daydream font
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Shuffle the board
                initializeBoard();
              },
            ),
          ],
        );
      },
    );
  }

  int? _getIndexFromPosition(Offset position) {
    debugPrint('_getIndexFromPosition called with position: $position');
    final RenderBox? gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?; // Get RenderBox using the key

    if (gridRenderBox == null) {
      debugPrint('Position outside grid bounds or RenderBox not found.');
      return null; // Position is outside the grid or RenderBox not available
    }

    final RenderBox? expandedRenderBox = _expandedKey.currentContext?.findRenderObject() as RenderBox?;
    if (expandedRenderBox == null) {
      debugPrint('Expanded RenderBox not found.');
      return null; // Expanded RenderBox not available
    }

    // Get the offset of the grid from the top of the screen
    final gridOffset = expandedRenderBox.localToGlobal(Offset.zero);
    debugPrint('Grid Offset: $gridOffset');

    // Adjust the touch position relative to the grid's top-left corner
    final adjustedPosition = position - gridOffset;
    debugPrint('Adjusted Position: $adjustedPosition');

    if (!expandedRenderBox.paintBounds.contains(adjustedPosition)) {
      debugPrint('Adjusted Position outside Expanded paint bounds.');
      return null;
    }

    final double gridWidth = expandedRenderBox.size.width;
    final double gridHeight = expandedRenderBox.size.height;

    debugPrint('Grid Size: $gridWidth x $gridHeight');

    // Calculate cell dimensions without accounting for margins here
    final double cellWidth = gridWidth / columns;
    final double cellHeight = gridHeight / rows;

    debugPrint('Cell Dimensions: $cellWidth x $cellHeight');

    // Calculate row and column based on adjusted touch position
    final col = (adjustedPosition.dx / cellWidth).floor();
    final row = (adjustedPosition.dy / cellHeight).floor();

    debugPrint('Calculated Row: $row, Calculated Column: $col');

    // Check if the calculated row and column are within the grid bounds
    if (row >= 0 && row < rows && col >= 0 && col < columns) {
      return row * columns + col;
    }

    return null;
  }

  bool isAdjacent(int row1, int col1, int row2, int col2) {
    return (row1 == row2 && (col1 == col2 + 1 || col1 == col2 - 1)) ||
           (col1 == col2 && (row1 == row2 + 1 || row1 == row2 - 1));
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _backgroundPlayer.pause();
      } else {
        _backgroundPlayer.resume();
      }
    });
  }
} 