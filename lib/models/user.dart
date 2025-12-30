class User {
  final String id;
  final String name;
  final String email;
  final String token;

  User({this.id = '', required this.name, required this.email, this.token = ''});

  factory User.fromJson(Map<String, dynamic> json) {
	return User(
	  id: json['id'] ?? '',
	  name: json['name'] ?? '',
	  email: json['email'] ?? '',
	  token: json['token'] ?? '',
	);
  }

  factory User.fromMap(Map<String, dynamic> m) {
	return User(
	  id: m['id'] ?? '',
	  name: m['name'] ?? '',
	  email: m['email'] ?? '',
	  token: m['token'] ?? '',
	);
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email, 'token': token};
}
