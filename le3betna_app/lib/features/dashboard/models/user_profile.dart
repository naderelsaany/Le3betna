class UserProfile {
  final String uid;
  final String name;
  final String avatarUrl;
  final int coins;
  final int xp;
  final int gamesPlayed;
  final int wins;
  final String currentRank;

  UserProfile({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.coins,
    required this.xp,
    required this.gamesPlayed,
    required this.wins,
    required this.currentRank,
  });

  double get winRate => gamesPlayed == 0 ? 0.0 : (wins / gamesPlayed) * 100;
  
  double get xpProgress {
    // Assuming each level requires 1000 XP
    int currentLevel = (xp / 1000).floor();
    int currentLevelXp = xp - (currentLevel * 1000);
    return currentLevelXp / 1000.0;
  }

  int get level => (xp / 1000).floor() + 1;

  factory UserProfile.fromJson(Map<dynamic, dynamic> json, String uid) {
    return UserProfile(
      uid: uid,
      name: json['name'] ?? 'Player',
      avatarUrl: json['avatarUrl'] ?? '',
      coins: json['coins'] ?? 0,
      xp: json['xp'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      currentRank: json['currentRank'] ?? 'Bronze',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'xp': xp,
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'currentRank': currentRank,
    };
  }
}
