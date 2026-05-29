class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (token != null) 'token': token,
      };

  UserModel copyWith({String? name, String? email, String? token}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
}
