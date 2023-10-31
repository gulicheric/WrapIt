import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/models/comment_model.dart';

Future<List> getFeedPosts(List<String> followingIds) async {
  final postsCollection = FirebaseFirestore.instance.collection('Posts');

  List posts = [];
  QuerySnapshot querySnapshot =
      await postsCollection.orderBy('createdAt', descending: true).get();
  //next line is the problem
  for (var post in querySnapshot.docs) {
    Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
    if (followingIds.contains(postData['postedBy'])) {
      posts.add(post);
    }
  }
  return posts;
}

Future<List<CommentModel>> getComments(String postId) async {
  final commentDoc = await FirebaseFirestore.instance
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .get();
  List<CommentModel> comments = [];
  for (var comment in commentDoc.docs) {
    comments.add(CommentModel.fromDoc(comment));
  }
  return comments;
}
