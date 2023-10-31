import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/feed/feed_screen.dart';
import 'package:tefillin/models/post_model.dart';

class PostTab extends StatefulWidget {
  const PostTab({super.key, required this.groupId});

  final String groupId;

  @override
  State<PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  Future<List<DocumentSnapshot>> getGroupPosts(
      List<String> groupUserUids) async {
    List<DocumentSnapshot> groupPosts = [];

    for (String uid in groupUserUids) {
      QuerySnapshot userPosts = await FirebaseFirestore.instance
          .collection('Posts')
          .where('postedBy', isEqualTo: uid)
          .get();
      groupPosts.addAll(userPosts.docs);
    }

    return groupPosts;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!groupSnapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          // get the group data
          Map<String, dynamic> groupData =
              groupSnapshot.data!.data() as Map<String, dynamic>;
          // get the list of user uids in the group
          List<String> groupUserUids = List<String>.from(groupData['users']);

          return FutureBuilder<List<DocumentSnapshot>>(
            future: getGroupPosts(groupUserUids),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(child: Container()),
                );
              }
              if (!postSnapshot.hasData || postSnapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text('No posts')),
                );
              }
              postSnapshot.data!.sort(
                  (a, b) => b.get('createdAt').compareTo(a.get('createdAt')));

              return Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: postSnapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Convert the current document into a PostModel
                    PostModel postModel =
                        PostModel.fromDocument(postSnapshot.data![index]);
                    return PostWidget(post: postModel);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PostsTab extends StatefulWidget {
  const PostsTab({
    super.key,
    required this.groupId,
    required this.users,
  });

  final String groupId;
  final List<String> users;

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final ScrollController _scrollController = ScrollController();
  final postsCollection = FirebaseFirestore.instance.collection('Posts');
  List<DocumentSnapshot> _allDocs = [];

  bool _isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMorePosts();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print("Loading more posts");
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_isLoading && widget.users.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Query query = postsCollection
          .where('postedBy', whereIn: widget.users)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (_allDocs.isNotEmpty) {
        query = query.startAfterDocument(_allDocs.last);
      }

      final querySnapshot = await query.get();
      _allDocs.addAll(querySnapshot.docs);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _allDocs.length + 1, // Add 1 for loading indicator
        itemBuilder: (context, index) {
          if (_allDocs.length % 10 != 0) hasMore = false;

          if (index < _allDocs.length) {
            // Convert the current document into a PostModel
            PostModel postModel = PostModel.fromDocument(_allDocs[index]);
            return PostWidget(post: postModel);
          } else {
            return hasMore
                ? const Center(child: CircularProgressIndicator())
                : const NoMorePostWidget();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
