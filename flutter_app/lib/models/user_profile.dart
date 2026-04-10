class UserProfile {
  final String uid;
  final String name;
  final String language;
  final String state;
  final String emergencyContact;
  final String fontSize;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.language,
    required this.state,
    required this.emergencyContact,
    required this.fontSize,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'language': language,
      'state': state,
      'emergency_contact': emergencyContact,
      'font_size': fontSize,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      language: map['language'] ?? 'hindi',
      state: map['state'] ?? 'UP',
      emergencyContact: map['emergency_contact'] ?? '',
      fontSize: map['font_size'] ?? 'medium',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
