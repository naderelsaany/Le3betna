class DominoTile {
  final int value1;
  final int value2;
  final String id;

  DominoTile({required this.value1, required this.value2, required this.id});

  bool get isDouble => value1 == value2;
  int get sum => value1 + value2;

  factory DominoTile.fromJson(Map<dynamic, dynamic> json) {
    return DominoTile(
      value1: json['value1'],
      value2: json['value2'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value1': value1,
      'value2': value2,
      'id': id,
    };
  }

  // Helper to check if a tile can be played on a specific number
  bool canPlayOn(int number) => value1 == number || value2 == number;

  @override
  String toString() => '[$value1|$value2]';
  
  @override
  bool operator ==(Object other) => identical(this, other) || other is DominoTile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PlayedTile {
  final DominoTile tile;
  final bool reversed; // If true, value2 connects to the previous tile instead of value1

  PlayedTile({required this.tile, this.reversed = false});

  int get leftValue => reversed ? tile.value2 : tile.value1;
  int get rightValue => reversed ? tile.value1 : tile.value2;

  factory PlayedTile.fromJson(Map<dynamic, dynamic> json) {
    return PlayedTile(
      tile: DominoTile.fromJson(json['tile']),
      reversed: json['reversed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tile': tile.toJson(),
      'reversed': reversed,
    };
  }
}
