class LudoToken {
  final int id; // 0, 1, 2, 3
  final String color; // 'red', 'green', 'yellow', 'blue'
  final int localPosition; // -1 = home, 0-51 = track, 52-56 = safe stretch, 57 = finished

  LudoToken({
    required this.id,
    required this.color,
    this.localPosition = -1,
  });

  factory LudoToken.fromJson(Map<dynamic, dynamic> json) {
    return LudoToken(
      id: json['id'] as int,
      color: json['color'] as String,
      localPosition: json['localPosition'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'localPosition': localPosition,
    };
  }
}
