class User {
  int? id;
  String email;
  String username;
  String? password;
  String? token;
  String? fotoUrl;

  User({
    this.id,
    required this.email,
    required this.username,
    this.password,
    this.token,
    this.fotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['name'],
      email: json['email'],
      password: '',
      token: json['token'],
    );
  }
  User copyWith({
    int? id,
    String? email,
    String? username,
    String? password,
    String? token,
    String? fotoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
