// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/widgets/profile_other.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';

import '../profile/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'homepage.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({required this.followingIds});

  final List<String> followingIds;

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getFeedPostsStream(widget.followingIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Hiii"));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No posts available'));
        }

        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = snapshot.data!.docs[index];
              return PostWidget(post: post);
            },
          );
        }

        return Text("Hi");
      },
    );
  }
}

class PostWidget extends StatefulWidget {
  const PostWidget({Key? key, required this.post}) : super(key: key);

  final DocumentSnapshot post;

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  bool isHeartFull = false;
  int likeCount = 0;
  String? userPhotoUrl;
  String? username;

  // Adding Animation controller for heart icon
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    // Fetch and initialize likeCount as before
    likeCount = widget.post['likeCount'] ?? 0;
    fetchUserData();

    // Fetch the array of likes
    List<String> likesArray = List<String>.from(widget.post['likes'] ?? []);

    // Get the current user id
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Check if the current user's ID is in likesArray
    isHeartFull = likesArray.contains(currentUserId);
    likeCount = (widget.post['likes'] as List<dynamic>?)!.length;

    fetchUserData();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Define the animation
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.elasticIn,
    );
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller!.reverse();
      }
    });
  }

  Future<void> fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post['postedBy'])
        .get();
    setState(() {
      userPhotoUrl = userDoc['photoUrl'];
      username = userDoc['username'];
    });
  }

  Future<String?> fetchUserId(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // Return the document ID (user ID)
    } else {
      print('User not found');
      return null;
    }
  }

  Future<void> toggleHeart() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _controller!.forward();
    if (!isHeartFull) {
      // Increment the local like count
      likeCount++;
      // Add the user's ID to the array of likes in Firestore
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });
      // Increment the like count in Firestore
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({'likeCount': FieldValue.increment(1)});
    } else {
      // Decrement the local like count
      likeCount--;
      // Remove the user's ID from the array of likes in Firestore
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({
        'likes': FieldValue.arrayRemove([currentUserId])
      });
      // Decrement the like count in Firestore
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post.id)
          .update({'likeCount': FieldValue.increment(-1)});
    }

    // Update the heart icon state
    setState(() {
      isHeartFull = !isHeartFull;
    });
  }

  String timeAgo(String dateStr) {
    DateTime postDate = DateTime.parse(dateStr);
    DateTime currentDate = DateTime.now();
    Duration timePassed = currentDate.difference(postDate);

    // Format the timePassed Duration to a time ago string
    return timeago.format(currentDate.subtract(timePassed));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 5),
              if (userPhotoUrl != null)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userPhotoUrl!),
                  ),
                ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  if (username != null) {
                    String? userId = await fetchUserId(username!);
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileOthers(uid: userId)),
                      );
                    }
                  }
                },
                child: (username != null) ? Text(username!) : Text("Error"),
              ),
            ],
          ),
          SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              GestureDetector(
                onDoubleTap: () async {
                  await toggleHeart();
                },
                child: Container(
                  height: 470,
                  width: size.width,
                  child: CachedNetworkImage(
                    imageUrl: widget.post['url'],
                    placeholder: (context, url) => Container(
                      color: Color.fromARGB(255, 186, 184, 184),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () async {
                          await toggleHeart();
                        },
                        child: isHeartFull
                            ? TeffilinLikePicturePressed(
                                numberOfLikes: likeCount,
                              )
                            : TeffilinLikePictureOutline(
                                numberOfLikes: likeCount,
                              )),
                    // SizedBox(width: 8),
                    // Text(likeCount.toString())
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(timeAgo(widget.post['createdAt'])),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Divider(thickness: 6),
        ],
      ),
    );
  }
}

class TeffilinLikePictureOutline extends StatelessWidget {
  const TeffilinLikePictureOutline({super.key, required this.numberOfLikes});

  final int numberOfLikes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(28, 255, 255, 255),
        border: Border.all(color: Color.fromARGB(55, 255, 255, 255), width: 2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/tefillin.png',
            width: 30,
            height: 30,
          ),
          SizedBox(width: 8),
          Text(numberOfLikes.toString())
        ],
      ),
    );
  }
}

class TeffilinLikePicturePressed extends StatelessWidget {
  const TeffilinLikePicturePressed({super.key, required this.numberOfLikes});

  final int numberOfLikes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(110, 255, 255, 255),
        border: Border.all(color: Theme.of(context).accentColor, width: 2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/tefillin.png',
            width: 30,
            height: 30,
          ),
          SizedBox(width: 8),
          Text(
            numberOfLikes.toString(),
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}
