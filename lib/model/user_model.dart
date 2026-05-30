class UserModel {
  final String id;
  final String name;
  final String email;
  final String? token;
  final String role; // 'admin' atau 'operator'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.role = 'operator', // default operator
  });

  // Helper methods untuk cek role
  bool get isAdmin => role == 'admin';
  bool get isOperator => role == 'operator';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      role: json['role'] ?? 'operator',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (token != null) 'token': token,
      };

  UserModel copyWith({String? name, String? email, String? token, String? role}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}
