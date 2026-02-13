class UserEntity {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });
}
