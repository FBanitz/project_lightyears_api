import 'package:uuid/uuid.dart';

class User {
  late final DateTime createdAt;
  late final DateTime updatedAt;
  late final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String tocken;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  }) : 
    id = Uuid().v4(), 
    createdAt = DateTime.now(),
    updatedAt = DateTime.now(),
    tocken = Uuid().v4();
  
  User.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    createdAt = DateTime.parse(json['created_at']),
    updatedAt = DateTime.parse(json['updated_at']),
    firstName = json['first_name'],
    lastName = json['last_name'],
    email = json['email'],
    password = json['password'],
    tocken = json['tocken'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt.toIso8601String();
    data['updated_at'] = updatedAt.toIso8601String();
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['password'] = password;
    data['tocken'] = tocken;
    return data;
  }

  Map<String, dynamic> toSafeJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt.toIso8601String();
    data['updated_at'] = updatedAt.toIso8601String();
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }
}