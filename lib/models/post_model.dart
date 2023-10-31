import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tefillin/models/comment_model.dart';

class PostModel {
  final String id;

  final String createdAt;
  final int likeCount;
  final List<String> likes;
  final String postedBy;
  final String url;
  final String caption;
  final int numOfComments;
  final String username;
  final String photoUrl;

  PostModel(
      {required this.caption,
      required this.id,
      required this.createdAt,
      required this.likeCount,
      required this.likes,
      required this.postedBy,
      required this.url,
      required this.numOfComments,
      required this.username,
      required this.photoUrl});

  static PostModel fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      caption: data['caption'] ?? '',
      createdAt: data['createdAt'] ?? '',
      likeCount: data['likeCount'] ?? 0,
      likes: List<String>.from(data['likes'] ?? []),
      postedBy: data['postedBy'] ?? '',
      url: data['url'] ?? '',
      numOfComments: data['numberOfComments'] ?? 0,
      photoUrl: data['photoUrl'] ?? '',
      username: data['username'] ?? 'Please update app',
    );
  }

  static Future<List<CommentModel>> _fetchComments(
      DocumentReference postDocRef) async {
    QuerySnapshot commentSnapshots =
        await postDocRef.collection('Comments').get();
    return commentSnapshots.docs
        .map((doc) => CommentModel.fromDoc(doc))
        .toList();
  }
}
