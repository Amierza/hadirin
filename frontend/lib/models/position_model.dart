class Position {
  final String positionId;
  final String positionName;

  Position({required this.positionId, required this.positionName});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      positionId: json['position_id'],
      positionName: json['position_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'position_id': positionId, 'position_name': positionName};
  }
}
