import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String? email;
  final String? name;
  final String? password;

  const UserEntity({this.id, this.email, this.password, this.name});

  toJson() {
    return {
      'Email': email,
      'Password': password,
      'Name': name,
    };
  }


  factory UserEntity.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserEntity(
      id: document.id,
      email: data["Email"],
      password: data["Password"],
      name: data["Name"],
    );
  }

  static var empty = UserEntity(id: "");

  bool get isEmpty => this == UserEntity.empty;

  bool get isnotEmpty => this != UserEntity.empty;

  @override
  List<Object?> get props => [
        id,
        email,
        password,
        name,
      ];
}
