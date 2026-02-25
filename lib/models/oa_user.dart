class OAUser {
  const OAUser({
    required this.id,
    required this.email,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.points,
    this.accessToken,
  });

  factory OAUser.fromApiJson(
    Map<String, dynamic> json, {
    String? accessToken,
  }) {
    return OAUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: (json['firstName'] as String? ?? '').trim(),
      middleName: (json['middleName'] as String?)?.trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      points: int.tryParse(json['points'] as String? ?? '0') ?? 0,
      accessToken: accessToken,
    );
  }

  final String id;
  final String email;
  final String firstName;
  final String? middleName;
  final String lastName;
  final int points;
  final String? accessToken;

  String get initials {
    final String f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final String l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
