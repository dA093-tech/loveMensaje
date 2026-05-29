enum PairStatus { pending, active, disconnected }

class Pair {
  final String pairId;
  final String user1Id;
  final String user2Id;
  final PairStatus status;
  final DateTime createdAt;
  final DateTime? activatedAt;

  const Pair({
    required this.pairId,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.createdAt,
    this.activatedAt,
  });

  bool get isActive => status == PairStatus.active;

  Map<String, dynamic> toMap() => {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'activatedAt': activatedAt?.toIso8601String(),
      };

  factory Pair.fromMap(String pairId, Map<String, dynamic> map) => Pair(
        pairId: pairId,
        user1Id: map['user1Id'] as String? ?? '',
        user2Id: map['user2Id'] as String? ?? '',
        status: PairStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => PairStatus.pending,
        ),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        activatedAt: map['activatedAt'] != null
            ? DateTime.parse(map['activatedAt'] as String)
            : null,
      );
}
