import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String uid;
  final String role; // 'parent' or 'child'
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic> quizAnswers;
  final Map<String, dynamic>? parentProfile;
  final bool isSetupCompleted;
  final int currentStreak;
  final int maxStreak;
  final DateTime? lastLoginDate;
  final String streakStatus; // 'active', 'frozen'
  final DateTime? createdAt;

  const UserProfileModel({
    required this.uid,
    required this.role,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    required this.quizAnswers,
    this.parentProfile,
    this.isSetupCompleted = false,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastLoginDate,
    this.streakStatus = 'active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'quizAnswers': quizAnswers,
      'parentProfile': parentProfile,
      'isSetupCompleted': isSetupCompleted,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'streakStatus': streakStatus,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String,
      role: map['role'] as String,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      quizAnswers: Map<String, dynamic>.from(map['quizAnswers'] ?? {}),
      parentProfile: map['parentProfile'] != null
          ? Map<String, dynamic>.from(map['parentProfile'])
          : null,
      isSetupCompleted: map['isSetupCompleted'] ?? false,
      currentStreak: map['currentStreak'] ?? 0,
      maxStreak: map['maxStreak'] ?? 0,
      lastLoginDate: map['lastLoginDate'] != null
          ? DateTime.parse(map['lastLoginDate'])
          : null,
      streakStatus: map['streakStatus'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  UserProfileModel copyWith({
    String? uid,
    String? role,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? quizAnswers,
    Map<String, dynamic>? parentProfile,
    bool? isSetupCompleted,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastLoginDate,
    String? streakStatus,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      parentProfile: parentProfile ?? this.parentProfile,
      isSetupCompleted: isSetupCompleted ?? this.isSetupCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      streakStatus: streakStatus ?? this.streakStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    role,
    email,
    phoneNumber,
    displayName,
    quizAnswers,
    parentProfile,
    isSetupCompleted,
    currentStreak,
    maxStreak,
    lastLoginDate,
    streakStatus,
    createdAt,
  ];
}
