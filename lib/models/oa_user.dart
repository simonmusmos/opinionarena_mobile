class OAUser {
  const OAUser({
    required this.firstName,
    required this.lastName,
    required this.points,
  });

  factory OAUser.fromApiJson(Map<String, dynamic> json) {
    return OAUser(
      firstName: (json['firstName'] as String? ?? '').trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      points: int.tryParse(json['points'] as String? ?? '0') ?? 0,
    );
  }

  final String firstName;
  final String lastName;
  final int points;

  String get initials {
    final String f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final String l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
