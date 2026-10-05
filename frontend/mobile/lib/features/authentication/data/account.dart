class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
  });

  final String id;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;

  String get contact => email ?? phone ?? '';

  factory Account.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final fullName = json['fullName'];
    final role = json['role'];
    if (id is! String || fullName is! String || role is! String) {
      throw const FormatException('Account response was incomplete.');
    }
    return Account(
      id: id,
      fullName: fullName,
      role: role,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
