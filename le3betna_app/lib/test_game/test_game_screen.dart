import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'test_game_service.dart';

class TestGameScreen extends StatefulWidget {
  final String roomCode;

  const TestGameScreen({super.key, required this.roomCode});

  @override
  State<TestGameScreen> createState() => _TestGameScreenState();
}

class _TestGameScreenState extends State<TestGameScreen> {
  final TestGameService _testGameService = TestGameService();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<dynamic> _parseFirebaseArray(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return List<dynamic>.from(value.where((e) => e != null));
    }
    if (value is Map) {
      final keys = value.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      return keys.map((k) => value[k]).where((e) => e != null).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Test Game - Room: ${widget.roomCode}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/gameState').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final turn = state['turn'] as String;
          final status = state['status'] as String;
          final testLog = state['testLog'] ?? '';
          final p1 = state['player1'] as String;
          
          final isMyTurn = turn == _myUid;
          final int myPlayerNum = _myUid == p1 ? 1 : 2;

          // Safe Grid Parsing
          final rawGrid = _parseFirebaseArray(state['grid']);
          final grid = rawGrid.map((r) {
            final row = _parseFirebaseArray(r);
            return row.map((e) => (e as num).toInt()).toList();
          }).toList();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Test Log Display
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade800,
                child: Text('LOG: $testLog', style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 20),

              // Turn Indicator
              Text(
                isMyTurn ? 'YOUR TURN (Player $myPlayerNum)' : 'WAITING FOR OPPONENT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isMyTurn ? Colors.yellow : Colors.grey,
                ),
              ),
              if (status == 'finished')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state['winner'] == _myUid ? 'YOU WON!' : 'YOU LOST!',
                    style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 30),

              // Game Board 6x7
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 7 / 6,
                    child: Container(
                      color: Colors.blue.shade900,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: List.generate(6, (r) {
                          return Expanded(
                            child: Row(
                              children: List.generate(7, (c) {
                                int cellValue = grid[r][c];
                                Color cellColor = Colors.black54; // empty
                                if (cellValue == 1) cellColor = Colors.red;
                                if (cellValue == 2) cellColor = Colors.blueAccent;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isMyTurn && status == 'playing') {
                                        print('DEBUG TEST: UI Clicked column $c');
                                        _testGameService.dropToken(widget.roomCode, c);
                                      } else {
                                        print('DEBUG TEST: Click ignored. isMyTurn: $isMyTurn, status: $status');
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
