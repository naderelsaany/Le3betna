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

    // Fetch up-to-date photo from database since Auth might fail with large base64
    String photoUrl = '';
    String name = user.displayName ?? 'Player 1';
    final userSnap = await _db.child('users/${user.uid}/stats').get();
    if (userSnap.exists) {
      final userData = userSnap.value as Map<dynamic, dynamic>;
      photoUrl = userData['avatarUrl'] ?? '';
      name = userData['name'] ?? name;
    }

    final roomCode = _generateRoomCode();
    final roomRef = _db.child('rooms').child(roomCode);

    await roomRef.set({
      'hostUid': user.uid,
      'status': 'waiting',
      'gameName': gameName,
      'maxPlayers': 2,
      'players': {
        user.uid: {
          'name': name,
          'photo': photoUrl,
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

      if (players != null && players.containsKey(user.uid)) {
        // Player is already in the room, just let them in!
        return true;
      }

      if (status == 'waiting' && (players == null || players.length < 2)) {
        // Fetch up-to-date photo from database
        String photoUrl = '';
        String name = user.displayName ?? 'Player 2';
        final userSnap = await _db.child('users/${user.uid}/stats').get();
        if (userSnap.exists) {
          final userData = userSnap.value as Map<dynamic, dynamic>;
          photoUrl = userData['avatarUrl'] ?? '';
          name = userData['name'] ?? name;
        }

        // Not full yet, join
        await roomRef.child('players').child(user.uid).set({
          'name': name,
          'photo': photoUrl,
        });
        

        
        return true;
      }
    }
    return false;
  }

  Stream<DatabaseEvent> getRoomStream(String roomCode) {
    return _db.child('rooms').child(roomCode).onValue;
  }
}
