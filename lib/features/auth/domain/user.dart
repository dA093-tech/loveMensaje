class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? partnerId;
  final String? pairingCode;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.partnerId,
    this.pairingCode,
    required this.createdAt,
  });

  bool get hasPartner => partnerId != null;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? partnerId,
    String? pairingCode,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerId: partnerId ?? this.partnerId,
      pairingCode: pairingCode ?? this.pairingCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'partnerId': partnerId,
        'pairingCode': pairingCode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String? ?? '',
        photoUrl: map['photoUrl'] as String?,
        partnerId: map['partnerId'] as String?,
        pairingCode: map['pairingCode'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );
}
