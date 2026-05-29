enum Tool { pen, eraser }

class Stroke {
  final String id;
  final String userId;
  final Tool tool;
  final int color;
  final double width;
  final List<Map<String, double>> points;
  final DateTime timestamp;
  final bool deleted;

  const Stroke({
    required this.id,
    required this.userId,
    required this.tool,
    required this.color,
    required this.width,
    required this.points,
    required this.timestamp,
    this.deleted = false,
  });

  Stroke copyWith({
    String? id,
    String? userId,
    Tool? tool,
    int? color,
    double? width,
    List<Map<String, double>>? points,
    DateTime? timestamp,
    bool? deleted,
  }) {
    return Stroke(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      width: width ?? this.width,
      points: points ?? this.points,
      timestamp: timestamp ?? this.timestamp,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'tool': tool.name,
        'color': color,
        'width': width,
        'points': points,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'deleted': deleted,
      };

  factory Stroke.fromMap(String id, Map<String, dynamic> map) => Stroke(
        id: id,
        userId: map['userId'] as String? ?? '',
        tool: map['tool'] == 'eraser' ? Tool.eraser : Tool.pen,
        color: map['color'] as int? ?? 0xFFFFFFFF,
        width: (map['width'] as num?)?.toDouble() ?? 3.0,
        points: (map['points'] as List<dynamic>?)
                ?.map((p) => Map<String, double>.from(p as Map))
                .toList() ??
            [],
        timestamp: map['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
            : DateTime.now(),
        deleted: map['deleted'] as bool? ?? false,
      );
}
