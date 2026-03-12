class OAUser {
  const OAUser({
    required this.id,
    required this.email,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.points,
    this.accessToken,
    this.phone,
    this.phonePrefix,
    this.genderCode,
    this.dob,
    this.shippingAddress,
    this.language,
  });

  factory OAUser.fromApiJson(
    Map<String, dynamic> json, {
    String? accessToken,
  }) {
    // id may come as int or string
    final String id = json['id']?.toString() ?? '';
    // points may come as int or string
    final dynamic rawPoints = json['points'];
    final int points = rawPoints is int
        ? rawPoints
        : int.tryParse(rawPoints?.toString() ?? '0') ?? 0;
    print(json);
    return OAUser(
      id: id,
      email: json['email']?.toString() ?? '',
      firstName: (json['firstName']?.toString() ?? '').trim(),
      middleName: json['middleName']?.toString().trim(),
      lastName: (json['lastName']?.toString() ?? '').trim(),
      points: points,
      accessToken: accessToken,
      phone: json['phone']?.toString().trim(),
      phonePrefix: json['phonePrefix']?.toString().trim(),
      genderCode: json['gender'] is int
          ? json['gender'] as int
          : int.tryParse(json['gender']?.toString() ?? ''),
      dob: json['dob']?.toString().trim(),
      shippingAddress: json['shippingAddress']?.toString().trim(),
      language: json['userLanguage']?.toString().trim(),
    );
  }

  final String id;
  final String email;
  final String firstName;
  final String? middleName;
  final String lastName;
  final int points;
  final String? accessToken;
  final String? phone;
  final String? phonePrefix;
  final int? genderCode;
  final String? dob;
  final String? shippingAddress;
  final String? language;

  String get initials {
    final String f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final String l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  /// e.g. "+63 09171234567"
  String get displayPhone {
    final String prefix = phonePrefix ?? '';
    final String number = phone ?? '';
    if (prefix.isEmpty && number.isEmpty) return '—';
    return '${prefix.isNotEmpty ? "$prefix " : ""}$number'.trim();
  }

  /// 1 → Male, 2 → Female, else —
  String get displayGender {
    switch (genderCode) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return genderCode != null ? genderCode.toString() : '—';
    }
  }

  /// "1999-01-01" → "January 1, 1999"
  String get displayDob {
    if (dob == null || dob!.isEmpty) return '—';
    final List<String> parts = dob!.split('-');
    if (parts.length != 3) return dob!;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return dob!;
    const List<String> months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    if (month < 1 || month > 12) return dob!;
    return '${months[month - 1]} $day, $year';
  }
}
