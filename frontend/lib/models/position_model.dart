class Position {
  final String id;
  final String name;

  Position({required this.id, required this.name});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['position_id'],
      name: json['position_name'],
    );
  }
}
