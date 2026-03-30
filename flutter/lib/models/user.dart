import 'package:flutter_app/extensions/map.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profilePhotoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json.get('id'),
      name: json.get('name'),
      email: json.get('email'),
      profilePhotoUrl: json.get('profilePhotoUrl'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
