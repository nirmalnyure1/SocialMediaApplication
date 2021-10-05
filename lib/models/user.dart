import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? username;
  final String? bio;
  final String? email;
  final String? displayname;
  final String? photoUrl;

  UserModel({
    this.id,
    this.username,
    this.bio,
    this.email,
    this.displayname,
    this.photoUrl,
  });
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc['id'],
      bio: doc['bio'],
      username: doc['username'],
      email: doc['email'],
      displayname: doc['displayName'],
      photoUrl: doc['photoUrl'],
    );
  }
}
