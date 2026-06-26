import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransientService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> sendEmoji(String roomCode, String emoji) async {
    if (_uid.isEmpty) return;
    
    await _db.child('rooms').child(roomCode).child('transient').child(_uid).set({
      'emoji': emoji,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> listenToTransients(String roomCode) {
    return _db.child('rooms').child(roomCode).child('transient').onChildChanged;
  }
}
