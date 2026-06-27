import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';

class DashboardService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 1. Get or Initialize User Profile
  Stream<UserProfile> getUserProfile(String uid) {
    return _db.child('users/$uid/stats').onValue.map((event) {
      if (event.snapshot.value != null) {
        return UserProfile.fromJson(event.snapshot.value as Map<dynamic, dynamic>, uid);
      } else {
        // Return a default profile if it doesn't exist yet
        return UserProfile(
          uid: uid,
          name: 'Player',
          avatarUrl: '',
          coins: 1000, // starting coins
          xp: 0,
          gamesPlayed: 0,
          wins: 0,
          currentRank: 'Bronze',
        );
      }
    });
  }

  Future<void> initializeUserIfNeeded(String uid, String displayName, String? photoUrl) async {
    final snapshot = await _db.child('users/$uid/stats').get();
    if (!snapshot.exists) {
      final initialProfile = UserProfile(
        uid: uid,
        name: displayName.isNotEmpty ? displayName : 'Player',
        avatarUrl: photoUrl ?? '',
        coins: 1000,
        xp: 0,
        gamesPlayed: 0,
        wins: 0,
        currentRank: 'Bronze',
      );
      await _db.child('users/$uid/stats').set(initialProfile.toJson());
    }
  }

  // 2. Active Rooms Stream
  Stream<List<Map<String, dynamic>>> getActiveRooms() {
    return _db.child('rooms').orderByChild('status').equalTo('waiting').onValue.map((event) {
      List<Map<String, dynamic>> rooms = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> roomsMap = event.snapshot.value as Map<dynamic, dynamic>;
        roomsMap.forEach((key, value) {
          final roomData = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
          roomData['id'] = key;
          rooms.add(roomData);
        });
      }
      return rooms;
    });
  }

  // 3. Online Friends (Mock integration for now, reading all users as friends)
  Stream<List<UserProfile>> getOnlineFriends(String currentUid) {
    // In a real app, you would have a 'friends' node. We will just return top 5 users.
    return _db.child('users').limitToFirst(5).onValue.map((event) {
      List<UserProfile> friends = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> usersMap = event.snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, value) {
          if (key != currentUid && value['stats'] != null) {
             friends.add(UserProfile.fromJson(value['stats'] as Map<dynamic, dynamic>, key));
          }
        });
      }
      return friends;
    });
  }
}
