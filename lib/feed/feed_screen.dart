// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tefillin/feed/comments.dart';
import 'package:tefillin/feed/feed_utils.dart';
import 'package:tefillin/feed/post_likes.dart';
import 'package:tefillin/models/comment_model.dart';
import 'package:tefillin/models/likes_notification_mode.dart';
import 'package:tefillin/models/post_model.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class FeedScreenss extends StatefulWidget {
  const FeedScreenss(
      {super.key, required this.followingIds, required this.controller});

  final ScrollController controller;
  final List<String> followingIds;

  @override
  State<FeedScreenss> createState() => _FeedScreenssState();
}

class _FeedScreenssState extends State<FeedScreenss>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;

  late Future<List> _postsList;
  var _postIndex = 0;
  List _data = [];
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _postsList = getFeedPosts(widget.followingIds);
    _fetchPosts();
    widget.controller.addListener(_scrollListener);
  }

  _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    // Wait for the _postsList future to complete if it hasn't already
    List allPosts = await _postsList;

    // Get the next chunk of posts
    int end = (_postIndex + 10 <= allPosts.length)
        ? _postIndex + 10
        : allPosts.length;
    List nextPosts = allPosts.sublist(_postIndex, end);
    _postIndex = end;

    if (_postIndex >= allPosts.length) {
      _hasMorePosts = false;
    }

    if (mounted) {
      setState(() {
        _data.addAll(nextPosts);
        _isLoading = false;
      });
    }
  }

  _scrollListener() {
    if (widget.controller.offset >=
            widget.controller.position.maxScrollExtent &&
        !_isLoading &&
        _hasMorePosts) {
      // Check _isLoading to prevent multiple fetches

      _fetchPosts();

      // Adjust the scroll offset to ensure loading indicator is visible
      widget.controller.animateTo(
        widget.controller.offset +
            50, // This 50 can be the height of your CircularProgressIndicator or any other value you prefer
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List>(
        future: _postsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('An error occurred!'));
          } else {
            List<Widget> postWidgets = _data.map<Widget>((postSnapshot) {
              return PostWidgets(post: PostModel.fromDocument(postSnapshot));
            }).toList();

            if (_postIndex >= snapshot.data!.length) {
              postWidgets.add(
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 60),
                  child: Text("No more posts to show"),
                ),
              );
            } else if (_isLoading) {
              postWidgets.add(Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(),
              ));
            }

            var size = MediaQuery.of(context).size;
            return SingleChildScrollView(
              controller: widget.controller,
              child: SizedBox(
                width: size.width,
                child: Column(children: postWidgets),
              ),
            );
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class FeedScreens extends StatefulWidget {
  const FeedScreens(
      {super.key, required this.followingIds, required this.controller});

  final ScrollController controller;
  final List<String> followingIds;

  @override
  State<FeedScreens> createState() => _FeedScreensState();
}

class _FeedScreensState extends State<FeedScreens>
    with AutomaticKeepAliveClientMixin {
  final postsCollection = FirebaseFirestore.instance.collection('Posts');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  late List<String> followingIds;
  bool hasMore = true;
  List<DocumentSnapshot> postsList = [];
  DocumentSnapshot? lastDocument;
  final int postsLimit = 10; // Number of posts to fetch at a time
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    followingIds = widget.followingIds;
    _fetchFeedPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        _fetchFeedPosts();
      }
    });
  }

  _fetchFeedPosts() async {
    List<DocumentSnapshot> fetchedPosts = [];

    for (int i = 0; i < followingIds.length; i += 10) {
      // Take chunks of 10 from followingIds
      var chunk = followingIds.sublist(
          i, i + 10 > followingIds.length ? followingIds.length : i + 10);

      Query query = postsCollection
          .where('postedBy', whereIn: chunk)
          .orderBy('createdAt', descending: true)
          .limit(postsLimit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();
      fetchedPosts.addAll(querySnapshot.docs);
    }

    if (fetchedPosts.length < postsLimit) {
      hasMore = false;
    }

    if (fetchedPosts.isNotEmpty) {
      lastDocument = fetchedPosts.last;
      postsList.addAll(fetchedPosts);
    }

    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      controller: _scrollController,
      itemCount: hasMore ? postsList.length + 1 : postsList.length,
      itemBuilder: (context, index) {
        if (index == postsList.length) {
          // Display a loading indicator at the bottom when fetching more posts
          return Center(child: CircularProgressIndicator());
        }

        PostModel currentPost = PostModel.fromDocument(postsList[index]);

        // Prefetching the next images
        for (int i = 1; i <= 10; i++) {
          if (index + i < postsList.length) {
            PostModel nextPost = PostModel.fromDocument(postsList[index + i]);
            precacheImage(NetworkImage(nextPost.url), context);
          }
        }

        return PostWidgets(
          post: currentPost,
        );
      },
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen(
      {super.key, required this.followingIds, required this.controller});

  final ScrollController controller;
  final List<String> followingIds;

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  final postsCollection = FirebaseFirestore.instance.collection('Posts');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  late List<String> followingIds;
  bool hasMore = true;
  late Future<List> postsList;
  int totalPosts = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    followingIds = widget.followingIds;
    postsList = getFeedPosts(followingIds);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: postsList,
      builder: (context, snapshot) {
        // if waiting for the future to complete
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            // Convert the current document into a PostModel
            PostModel currentPost =
                PostModel.fromDocument(snapshot.data![index]);

            // Prefetching the next 3 images
            for (int i = 1; i <= 10; i++) {
              if (index + i < snapshot.data!.length) {
                PostModel nextPost =
                    PostModel.fromDocument(snapshot.data![index + i]);
                precacheImage(NetworkImage(nextPost.url), context);
              }
            }

            return PostWidgets(
              post: currentPost,
              // onScrollToTop: () {
              //   _scrollController.animateTo(
              //     0,
              //     duration: Duration(milliseconds: 100),
              //     curve: Curves.easeInOut,
              //   );
              // },
            );
          },
        );
      },
    );
  }
}

class PostWidgets extends StatefulWidget {
  const PostWidgets({super.key, required this.post});

  final PostModel post;

  @override
  State<PostWidgets> createState() => _PostWidgetsState();
}

class _PostWidgetsState extends State<PostWidgets> {
  bool _isHeartFull = false;
  int _likeCount = 0;
  String? _userPhotoUrl;
  String? _username;
  List<String> _likesList = [];
  final String _authUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _initializePostData();
    _fetchUserData();
  }

  void _initializePostData() {
    _likeCount = widget.post.likes.length;
    _isHeartFull = widget.post.likes.contains(_authUserId);
    _likesList = widget.post.likes;
  }

  Future<void> _fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postedBy)
        .get();

    var userData = userDoc.data();

    if (userData != null) {
      _userPhotoUrl = userData['photoUrl'] ?? '';
      _username = userData['username'] ?? 'Update App';
    } else {
      // Handle the scenario where the document does not exist or has no data
      _userPhotoUrl = '';
      _username = 'Update App';
    }
  }

  Future<void> _toggleHeart() async {
    final updateData =
        _isHeartFull ? _decrementLikeData() : _incrementLikeData();

    if (!_isHeartFull) {
      DocumentReference notificationRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.postedBy)
          .collection("Activity")
          .doc();

      var user = await FirebaseFirestore.instance
          .collection("Users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      DateTime utcTime = DateTime.now().toUtc();

      // 2. Convert UTC time to Eastern Time Zone (ET is UTC-5 but can be UTC-4 due to daylight saving, so you may need to adjust accordingly)
      DateTime easternTime = utcTime.subtract(Duration(hours: 5));

      var notificationLike = LikesNotificationModel(
        id: notificationRef.id,
        userId: FirebaseAuth.instance.currentUser!.uid,
        postId: widget.post.id,
        userPhotoUrl: user.data()!['photoUrl'],
        username: user.data()!['username'],
        postPhotoUrl: widget.post.url,
        timestamp: Timestamp.fromDate(easternTime),
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.post.postedBy)
          .collection("Activity")
          .doc(notificationRef.id)
          .set(notificationLike.toMap());
    }

    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .update(updateData);

    setState(() => _isHeartFull = !_isHeartFull);
  }

  Map<String, dynamic> _incrementLikeData() {
    _likeCount++;

    _likesList.add(_authUserId);

    return {
      'likes': FieldValue.arrayUnion([_authUserId]),
      'likeCount': FieldValue.increment(1)
    };
  }

  Map<String, dynamic> _decrementLikeData() {
    _likeCount--;

    _likesList.remove(_authUserId);

    return {
      'likes': FieldValue.arrayRemove([_authUserId]),
      'likeCount': FieldValue.increment(-1)
    };
  }

  String _timeAgo(String dateStr) {
    DateTime postDate = DateTime.parse(dateStr);
    Duration timePassed = DateTime.now().difference(postDate);
    return timeago.format(DateTime.now().subtract(timePassed));
  }

  @override
  Widget build(BuildContext context) {
    return _buildPostContainer(context);
  }

  Widget _buildPostContainer(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          SizedBox(height: 8),
          _buildPostImage(size),
          SizedBox(height: 0),
          _buildPostCaption(),
          _buildPostFooter(context),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildUserProfileRow(context)],
    );
  }

  Widget _buildUserProfileRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _navigateToProfile(context),
      child: Row(
        children: [
          SizedBox(width: 5),
          _buildUserAvatar(),
          SizedBox(width: 8),
          Text(widget.post.username),
        ],
      ),
    );
  }

  CircleAvatar _buildUserAvatar() {
    return CircleAvatar(
      radius: 15,
      backgroundImage: NetworkImage(widget.post.photoUrl),
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (_username == null) return;

    String? userId = widget.post.postedBy;
    final page = (FirebaseAuth.instance.currentUser!.uid == userId)
        ? ProfilePage()
        : ProfileOthers(uid: userId);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildPostImage(Size size) {
    return GestureDetector(
      onDoubleTap: _toggleHeart,
      child: SizedBox(
        height: 500,
        width: size.width * 10,
        child: CachedNetworkImage(
          fit: BoxFit.fitWidth,
          imageUrl: widget.post.url,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey[300],
              height: 500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCaption() {
    return (widget.post.caption.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(right: 12, left: 12, top: 10),
            child: Text(widget.post.caption,
                style: TextStyle(fontFamily: 'CircularRegular', fontSize: 18)),
          )
        : SizedBox.shrink();
  }

  Widget _buildPostFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLikesAndCommentsInfo(context),
          SizedBox(height: 5),
          _buildActionIcons(context)
        ],
      ),
    );
  }

  Widget _buildLikesAndCommentsInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 10),
      child: Row(
        children: [
          _buildLikesInfo(context),
          SizedBox(width: 8),
          Text("•"),
          _buildTimeInfo(),
          _buildCommentsInfo(context)
        ],
      ),
    );
  }

  Widget _buildLikesInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLikersModal(context, _likesList),
      child: Row(
        children: [
          Text(_likeCount.toString(), style: TextStyle(fontSize: 15)),
          Text(" Tefillins", style: TextStyle(fontFamily: 'CircularRegular')),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(_timeAgo(widget.post.createdAt),
          style: TextStyle(fontFamily: 'CircularRegular')),
    );
  }

  Widget _buildCommentsInfo(BuildContext context) {
    return (widget.post.numOfComments > 0)
        ? GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentPage(
                  postId: widget.post.id,
                  post: widget.post,
                  photoUrl: _userPhotoUrl!,
                  username: _username!,
                  isAskingForComment: false,
                ),
              ),
            ),
            child: Row(
              children: [
                Text("•"),
                SizedBox(width: 10),
                Text(
                  "${widget.post.numOfComments} ${(widget.post.numOfComments == 1) ? 'comment' : 'comments'}",
                  style: TextStyle(fontFamily: 'CircularRegular'),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  void _showLikersModal(BuildContext context, List<String> likers) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 40, 40, 40),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: ListView.builder(
            itemCount: likers.length,
            itemBuilder: (BuildContext context, int index) {
              print("printing likeers: " + likers.toString());
              print(index);

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
                      padding: EdgeInsets.only(right: 15, top: 15),
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
                        trailing: Icon(Icons.chevron_right, color: Colors.grey),
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

  Widget _buildActionIcons(BuildContext context) {
    return (!FirebaseAuth.instance.currentUser!.isAnonymous)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleHeart,
                    child: _isHeartFull
                        ? TeffilinLikePicturePressed(numberOfLikes: _likeCount)
                        : TeffilinLikePictureOutline(numberOfLikes: _likeCount),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(
                            postId: widget.post.id,
                            post: widget.post,
                            photoUrl: _userPhotoUrl!,
                            username: _username!,
                            isAskingForComment: true,
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.chat_bubble_outline_outlined),
                  ),
                ],
              ),
            ],
          )
        : SizedBox.shrink();
  }
}

class PostWidget extends StatefulWidget {
  const PostWidget({Key? key, required this.post}) : super(key: key);

  final PostModel post;

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isHeartFull = false;
  int _likeCount = 0;
  String? _userPhotoUrl;
  String? _username;
  List<String> _likesList = [];
  final String _authUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<CommentModel>> _postComments;

  @override
  void initState() {
    super.initState();
    _initializePostData();
    _fetchUserData();
  }

  void _initializePostData() {
    _likeCount = widget.post.likes.length;
    _isHeartFull = widget.post.likes.contains(_authUserId);
    _likesList = widget.post.likes;
  }

  Future<void> _fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.post.postedBy)
        .get();
    setState(() {
      _userPhotoUrl = userDoc['photoUrl'];
      _username = userDoc['username'];
    });
  }

  Future<void> _toggleHeart() async {
    final updateData =
        _isHeartFull ? _decrementLikeData() : _incrementLikeData();

    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id)
        .update(updateData);

    setState(() => _isHeartFull = !_isHeartFull);
  }

  Map<String, dynamic> _incrementLikeData() {
    _likeCount++;

    _likesList.add(_authUserId);

    return {
      'likes': FieldValue.arrayUnion([_authUserId]),
      'likeCount': FieldValue.increment(1)
    };
  }

  Map<String, dynamic> _decrementLikeData() {
    _likeCount--;

    _likesList.remove(_authUserId);

    return {
      'likes': FieldValue.arrayRemove([_authUserId]),
      'likeCount': FieldValue.increment(-1)
    };
  }

  String _timeAgo(String dateStr) {
    DateTime postDate = DateTime.parse(dateStr);
    Duration timePassed = DateTime.now().difference(postDate);
    return timeago.format(DateTime.now().subtract(timePassed));
  }

  @override
  Widget build(BuildContext context) {
    return _buildPostContainer(context);
  }

  Widget _buildPostContainer(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          SizedBox(height: 5),
          _buildPostImage(size),
          SizedBox(height: 10),
          _buildPostCaption(),
          _buildPostFooter(context),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildUserProfileRow(context), reportDialog(widget: widget)],
    );
  }

  Widget _buildUserProfileRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _navigateToProfile(context),
      child: Row(
        children: [
          SizedBox(width: 5),
          if (_userPhotoUrl != null) _buildUserAvatar(),
          SizedBox(width: 8),
          Text(_username ?? "Error"),
        ],
      ),
    );
  }

  CircleAvatar _buildUserAvatar() {
    return CircleAvatar(
      radius: 15,
      backgroundImage: NetworkImage(_userPhotoUrl!),
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (_username == null) return;

    String? userId = widget.post.postedBy;
    final page = (FirebaseAuth.instance.currentUser!.uid == userId)
        ? ProfilePage()
        : ProfileOthers(uid: userId);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildPostImage(Size size) {
    return GestureDetector(
      onDoubleTap: _toggleHeart,
      child: SizedBox(
        height: 550,
        width: size.width,
        child: CachedNetworkImage(
          imageUrl: widget.post.url,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey[300],
              width: size.width,
              height: 550,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCaption() {
    return (widget.post.caption.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Text(widget.post.caption,
                style: TextStyle(fontFamily: 'CircularRegular', fontSize: 18)),
          )
        : SizedBox.shrink();
  }

  Widget _buildPostFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLikesAndCommentsInfo(context),
          SizedBox(height: 5),
          _buildActionIcons(context)
        ],
      ),
    );
  }

  Widget _buildLikesAndCommentsInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 10),
      child: Row(
        children: [
          _buildLikesInfo(context),
          SizedBox(width: 8),
          Text("•"),
          _buildTimeInfo(),
          _buildCommentsInfo(context)
        ],
      ),
    );
  }

  Widget _buildLikesInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        _showLikersModal(context, _likesList),
      },
      child: Row(
        children: [
          Text(_likeCount.toString(), style: TextStyle(fontSize: 15)),
          Text(" Tefillins", style: TextStyle(fontFamily: 'CircularRegular')),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(_timeAgo(widget.post.createdAt),
          style: TextStyle(fontFamily: 'CircularRegular')),
    );
  }

  Widget _buildCommentsInfo(BuildContext context) {
    return (widget.post.numOfComments > 0)
        ? GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentPage(
                  postId: widget.post.id,
                  post: widget.post,
                  photoUrl: _userPhotoUrl!,
                  username: _username!,
                  isAskingForComment: false,
                ),
              ),
            ),
            child: Row(
              children: [
                Text("•"),
                SizedBox(width: 10),
                Text(
                  "${widget.post.numOfComments} ${(widget.post.numOfComments == 1) ? 'comment' : 'comments'}",
                  style: TextStyle(fontFamily: 'CircularRegular'),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
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
              print("printing likeers: " + likers.toString());
              print(index);

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
                      padding: EdgeInsets.only(right: 15, top: 15),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileOthers(uid: widget.post.postedBy)),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!['photoUrl']),
                        ),
                        title: Text(snapshot.data!['username']),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey),
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

  Widget _buildActionIcons(BuildContext context) {
    return (!FirebaseAuth.instance.currentUser!.isAnonymous)
        ? Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _toggleHeart();
                },
                child: _isHeartFull
                    ? TeffilinLikePicturePressed(numberOfLikes: _likeCount)
                    : TeffilinLikePictureOutline(numberOfLikes: _likeCount),
              ),
              SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentPage(
                        postId: widget.post.id,
                        post: widget.post,
                        photoUrl: _userPhotoUrl!,
                        username: _username!,
                        isAskingForComment: true,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.chat_bubble_outline_outlined),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}

class reportDialog extends StatelessWidget {
  const reportDialog({
    super.key,
    required this.widget,
  });

  final PostWidget widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Would you like to report this picture?'),
            content: const Text(
                'You should report pictures that are not of tefillin or that you think are innapropriate'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text('Report'),
                onPressed: () async {
                  FirebaseFirestore.instance
                      .collection('Posts')
                      .doc(widget.post.id)
                      .update({'reports': FieldValue.increment(1)});

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        child: Icon(Icons.report_outlined),
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
      // decoration: BoxDecoration(
      //   // color: Color.fromARGB(28, 255, 255, 255),
      //   border: Border.all(color: Color.fromARGB(134, 255, 255, 255), width: 2),
      //   borderRadius: BorderRadius.circular(12.0),
      // ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/tefillin_outlined.png',
            width: 30,
            height: 30,
          ),
          // SizedBox(width: 8),
          // Text(numberOfLikes.toString())
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
      child: Row(
        children: [
          Image.asset(
            'assets/images/tefillin_filled.png',
            width: 30,
            height: 30,
          )
        ],
      ),
    );
  }
}

class NoMorePostWidget extends StatelessWidget {
  const NoMorePostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0, top: 20.0),
      child:
          Center(child: const Text("There are no more posts for you to see")),
    );
  }
}
