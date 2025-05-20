import 'package:flutter/material.dart';
import 'package:color_splice/game/components/character.dart';
import 'dart:math';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  static const int rows = 11;
  static const int columns = 9;
  late List<List<CharacterType?>> board = List.generate(
    rows,
    (i) => List.generate(columns, (j) => null),
  );
  CharacterType? selectedCharacter;
  int? selectedRow;
  int? selectedColumn;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    setState(() {
      board = List.generate(
        rows,
        (i) => List.generate(
          columns,
          (j) => getRandomCharacter(i, j),
        ),
      );
      // Keep generating until there are no matches
      while (hasInitialMatches()) {
        board = List.generate(
          rows,
          (i) => List.generate(
            columns,
            (j) => getRandomCharacter(i, j),
          ),
        );
      }
    });
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

  void onCharacterTap(int row, int column) {
    if (selectedCharacter == null) {
      // First selection
      setState(() {
        selectedCharacter = board[row][column];
        selectedRow = row;
        selectedColumn = column;
      });
    } else {
      // Second selection - check if adjacent
      if (isAdjacent(selectedRow!, selectedColumn!, row, column)) {
        // Try swap
        final temp = board[row][column];
        board[row][column] = selectedCharacter;
        board[selectedRow!][selectedColumn!] = temp;

        // Check if swap creates a match
        if (hasMatches()) {
          // Valid swap, keep it and process matches
          setState(() {
            processMatches();
          });
        } else {
          // Invalid swap, revert
          board[row][column] = temp;
          board[selectedRow!][selectedColumn!] = selectedCharacter;
        }

        // Reset selection
        selectedCharacter = null;
        selectedRow = null;
        selectedColumn = null;
      } else {
        // Not adjacent, just update selection
        setState(() {
          selectedCharacter = board[row][column];
          selectedRow = row;
          selectedColumn = column;
        });
      }
    }
  }

  bool isAdjacent(int row1, int col1, int row2, int col2) {
    return (row1 == row2 && (col1 == col2 + 1 || col1 == col2 - 1)) ||
           (col1 == col2 && (row1 == row2 + 1 || row1 == row2 - 1));
  }

  bool hasMatches() {
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

  void processMatches() {
    bool hasMatches = true;
    while (hasMatches) {
      hasMatches = false;
      
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
            hasMatches = true;
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
            hasMatches = true;
          }
        }
      }

      if (hasMatches) {
        // Remove matched characters
        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < columns; col++) {
            if (toRemove[row][col]) {
              board[row][col] = null;
            }
          }
        }

        // Make characters fall
        makeCharactersFall();

        // Fill empty spaces with new characters
        fillEmptySpaces();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: columns / rows,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemCount: rows * columns,
        itemBuilder: (context, index) {
          final row = index ~/ columns;
          final col = index % columns;
          final character = board[row][col];
          final isSelected = row == selectedRow && col == selectedColumn;

          return GestureDetector(
            onTap: () => onCharacterTap(row, col),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: character != null
                  ? Image.asset(
                      'assets/${character.name}.png',
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
} 