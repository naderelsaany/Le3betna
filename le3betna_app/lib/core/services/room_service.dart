import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class RoomService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateRoomCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // 4-digit code
  }

  Future<String?> createRoom(String gameName) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Fetch up-to-date photo from database since Auth might fail with large base64
    String photoUrl = '';
    String name = user.displayName ?? 'اللاعب 1';
    if (name.isEmpty) name = 'اللاعب 1';
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

    // Cleanup: If the host disconnects or leaves, remove the entire room
    roomRef.onDisconnect().remove();

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
        String name = user.displayName ?? 'اللاعب 2';
        if (name.isEmpty) name = 'اللاعب 2';
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
        
        // Cleanup: If the guest disconnects, remove them from the room
        roomRef.child('players').child(user.uid).onDisconnect().remove();
        
        return true;
      }
    }
    return false;
  }

  Future<void> leaveRoom(String roomCode) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final roomRef = _db.child('rooms').child(roomCode);
    final snapshot = await roomRef.get();
    
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final hostUid = data['hostUid'];
      
      if (hostUid == user.uid) {
        // Host left -> destroy the room completely
        await roomRef.remove();
      } else {
        // Guest left -> remove them from players list
        await roomRef.child('players').child(user.uid).remove();
      }
    }
  }

  Stream<DatabaseEvent> getRoomStream(String roomCode) {
    return _db.child('rooms').child(roomCode).onValue;
  }
}
