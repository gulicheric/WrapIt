// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tefillin/firebase/firebase_uploads.dart';
import 'package:tefillin/models/comment_model.dart';
import 'package:tefillin/models/post_model.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  final PostModel post;
  final String username;
  final String photoUrl;
  final bool isAskingForComment;

  const CommentPage(
      {super.key,
      required this.postId,
      required this.post,
      required this.username,
      required this.photoUrl,
      required this.isAskingForComment});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  FocusNode _commentFocusNode = FocusNode();

  Stream<QuerySnapshot> _getCommentStream() {
    // Assuming you have a 'comments' subcollection inside a post document
    return FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .collection('Comments')
        .orderBy("createdAt")
        .snapshots();
  }

  void toggleLike(CommentModel comment) async {
    // Check if the user has already liked the comment
    bool isLiked =
        comment.likes.contains(FirebaseAuth.instance.currentUser!.uid);

    // Update Firestore
    CollectionReference commentsCollection = FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .collection('Comments');

    if (isLiked) {
      // If user has liked the comment, then unlike it
      await commentsCollection.doc(comment.id).update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      // If user has not liked the comment, then like it
      await commentsCollection.doc(comment.id).update({
        'likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay focus request until after the widget is built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCommentStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Container());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No comments yet."));
                  }

                  List<DocumentSnapshot> comments = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        CommentModel comment =
                            CommentModel.fromDoc(comments[index]);

                        if (kDebugMode) {
                          print("postedby: ${comment.likes}");
                        }

                        return Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundImage: NetworkImage(
                                  comment.photoUrl,
                                )),
                                const SizedBox(width: 15),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(comment.username,
                                            style: const TextStyle(
                                                fontFamily: 'CircularRegular')),
                                        const SizedBox(width: 10),
                                        const Text("•"),
                                        const SizedBox(width: 10),
                                        Text(
                                            timeago.format(
                                                comment.createdAt.toDate()),
                                            style: const TextStyle(
                                                fontFamily: 'CircularRegular')),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                        width: size.width - 100,
                                        child: Text(comment.text)),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => toggleLike(comment),
                                          child: Icon(
                                            comment.likes.contains(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            size: 15,
                                            color: comment.likes.contains(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                ? Colors.red
                                                : null, // or any default color
                                          ),
                                        ),
                                        comment.likes.isNotEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  _showLikersModal(
                                                      context, comment.likes);
                                                },
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    const Text("•"),
                                                    const SizedBox(width: 10),
                                                    // if like is exactly 1 write like
                                                    comment.likes.length == 1
                                                        ? Text(
                                                            "${comment.likes.length} like",
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'CircularRegular',
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        : Text(
                                                            "${comment.likes.length} likes",
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'CircularRegular',
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ));
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode:
                          widget.isAskingForComment ? _commentFocusNode : null,
                      controller: _commentController,
                      decoration:
                          const InputDecoration(hintText: 'Add a comment...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      Timestamp currentTimestamp =
                          Timestamp.fromMillisecondsSinceEpoch(
                              now.millisecondsSinceEpoch);

                      var docRef = await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();

                      await FirebaseUploads.uploadComment(
                          CommentModel(
                            text: _commentController.text,
                            createdAt:
                                currentTimestamp, // Use server's timestamp
                            likes: [],
                            username: docRef.data()!['username'],
                            photoUrl: docRef.data()!['photoUrl'],
                            id: 'fdedfasfdaf',
                          ),
                          widget.post.id,
                          widget.post.url,
                          widget.post.postedBy);

                      _commentController.text = "";
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  void _showLikersModal(BuildContext context, List<String> likers) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: ListView.builder(
            itemCount: likers.length,
            itemBuilder: (BuildContext context, int index) {
              String uid = likers[index];

              // Use FutureBuilder to fetch and display user details
              return FutureBuilder<Map<String, dynamic>>(
                future: getUserDetails(uid),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 15, top: 20),
                      child: ListTile(
                        leading: CircleAvatar(), // Placeholder while loading
                        title: Text("Loading..."),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const ListTile(
                      leading: CircleAvatar(),
                      title: Text("Error loading user details"),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15, top: 15),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileOthers(uid: uid)),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!['photoUrl']),
                        ),
                        title: Text(snapshot.data!['username']),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
