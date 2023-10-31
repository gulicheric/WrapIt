import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final Timestamp createdAt;
  final List<String> likes;
  final String username;
  final String photoUrl;

  // contrstuctor requried fields
  CommentModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.likes,
    required this.username,
    required this.photoUrl,
  });

  // factory constructor
  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      text: data['text'],
      createdAt: data['createdAt'],
      likes: data['likes'].cast<String>(),
      username: data['username'],
      photoUrl: data['photoUrl'],
    );
  }

  // create a dictionary from the model
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt,
      'likes': likes,
      'username': username,
      'photoUrl': photoUrl,
    };
  }
}
