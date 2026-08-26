class PointsEntry {
  final String id;
  final int delta;
  final String reason;
  final DateTime createdAt;

  PointsEntry({
    required this.id,
    required this.delta,
    required this.reason,
    required this.createdAt,
  });

  factory PointsEntry.fromJson(Map<String, dynamic> json) {
    return PointsEntry(
      id: json['id'] as String,
      delta: json['delta'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
