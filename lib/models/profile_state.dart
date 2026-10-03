class ProfileState {
  final String name;
  final String email;
  final String? avatarPath;

  const ProfileState({
    required this.name,
    required this.email,
    this.avatarPath,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? avatarPath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
