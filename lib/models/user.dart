class User {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String role;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['mobile'],
      role: json['role'] ?? '',
    );
  }
}
