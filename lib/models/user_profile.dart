class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.grade,
    required this.createdAt,
    this.email,
    this.avatarPath,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      grade: json['grade'] as int? ?? 4,
      createdAt: DateTime.parse(json['createdAt'] as String),
      email: json['email'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }

  final String id;
  final String name;

  /// Elementary school grade, 1 to 6.
  final int grade;
  final DateTime createdAt;

  /// Null for guest explorers.
  final String? email;
  final String? avatarPath;

  bool get isGuest => email == null;

  UserProfile copyWith({String? name, int? grade, String? avatarPath}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      createdAt: createdAt,
      email: email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'createdAt': createdAt.toIso8601String(),
    'email': email,
    'avatarPath': avatarPath,
  };
}
