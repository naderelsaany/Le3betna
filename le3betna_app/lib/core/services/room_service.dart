import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class RoomService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateRoomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit code
  }

  Future<String?> createRoom(String gameName) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final roomCode = _generateRoomCode();
    final roomRef = _db.child('rooms').child(roomCode);

    await roomRef.set({
      'hostUid': user.uid,
      'status': 'waiting',
      'gameName': gameName,
      'maxPlayers': 2,
      'players': {
        user.uid: {
          'name': user.displayName ?? 'Player 1',
          'photo': user.photoURL ?? '',
        }
      },
      'createdAt': ServerValue.timestamp,
    });

    return roomCode;
  }

  Future<bool> joinRoom(String roomCode) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final roomRef = _db.child('rooms').child(roomCode);
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final status = data['status'];
      final players = data['players'] as Map<dynamic, dynamic>?;

      if (status == 'waiting' && players != null && players.length < 2) {
        // Not full yet, join
        await roomRef.child('players').child(user.uid).set({
          'name': user.displayName ?? 'Player 2',
          'photo': user.photoURL ?? '',
        });
        
        // If it was the second player, maybe update status to 'playing'
        if (players.length == 1) {
          await roomRef.update({'status': 'playing'});
        }
        
        return true;
      }
    }
    return false;
  }

  Stream<DatabaseEvent> getRoomStream(String roomCode) {
    return _db.child('rooms').child(roomCode).onValue;
  }
}
