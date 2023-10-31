// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:share_plus/share_plus.dart';
import 'package:tefillin/firebase/firebase_group_helper.dart';
import 'package:tefillin/groups/group_sections/prizes.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/post_model.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/widgets/accept_requets.dart';
import 'package:tefillin/feed/feed_screen.dart';
import 'package:tefillin/groups/group_setttings.dart';
import 'package:tefillin/widgets/custom_cupertino_dialog.dart';
import 'package:tefillin/widgets/share.dart';

import '../anonymous/sign_up.dart';
import '../profile/profile_page.dart';
import 'add_admin_group.dart';
import 'group_sections/leaderboard.dart';
import 'group_sections/members.dart';
import 'group_sections/posts.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String groupId;

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  Stream<DocumentSnapshot>? streamGroup;
  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  int selectedTab = 0;
  var isRequested = false;
  late Future<List<DocumentSnapshot>> _postsFuture;

  void updateTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  void initState() {
    super.initState();
    streamGroup = FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .snapshots();

    _postsFuture = fetchPostsForGroup(widget.groupId);
    _getPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getPosts();
      }
    });
  }

  _getPosts() async {
    Query query = _firestore.collection('Posts').orderBy('createdAt').limit(10);
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.length < 10) {
      // End of the collection
      _isLoading = false;
    } else {
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      _data.addAll(querySnapshot.docs);
      setState(() {}); // Trigger a rebuild
    }
  }

  Stream<DocumentSnapshot> getUserDataStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _data = [];
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: streamGroup,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.data!.data() == null) {
          return Center(child: Text('No data found'));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isAdmin = (data['admin'] as List)
            .contains(FirebaseAuth.instance.currentUser!.uid);
        int requestCount = (data['requests'] as List).length;
        var size = MediaQuery.of(context).size;

        List<String> users = List<String>.from(data['users'] as List);

        isRequested = (data['requests'] as List).contains(currentUser);

        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(data['name']),
              actions: [
                if (isAdmin && requestCount > 0)
                  Padding(
                    padding: EdgeInsets.only(right: 15.0, top: 12),
                    child: badges.Badge(
                      badgeContent: Text(requestCount.toString()),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AcceptGroupRequests(
                                groupId: widget.groupId,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupSettingsPage(
                                groupId: widget.groupId,
                                isAdmin: isAdmin,
                                groupName: data['name'],
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.settings,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                if (!isAdmin && !FirebaseAuth.instance.currentUser!.isAnonymous)
                  IconButton(
                    icon: Icon(
                        Icons.settings), // You can use a more appropriate icon.
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                  ),
              ],
            ),
            body: CustomScrollView(slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 150,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    data['groupPictureUrl'],
                    fit: BoxFit.fitWidth,
                  ),
                ),
                pinned: false,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          data['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                  // Add more widgets as needed
                ]),
              ),
              if (!users.contains(currentUser))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: Column(
                      children: [
                        Text("You are not a member of this group"),
                        SizedBox(height: 20),
                        // add a button to add user to request list
                        if (FirebaseAuth.instance.currentUser!.isAnonymous)
                          SignUpButton(
                            size: size,
                            vertical: 15,
                          ),
                        if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return isRequested
                                          ? Color.fromARGB(255, 93, 18, 54)
                                          : Colors
                                              .grey; // Change Colors.grey to whatever you want for the default pressed color.
                                    }
                                    return isRequested
                                        ? Color.fromARGB(255, 93, 18, 54)
                                        : Theme.of(context)
                                            .accentColor; // or any other default color
                                  },
                                ),
                              ),
                              onPressed: () async {
                                // see if user is already in request list
                                DocumentSnapshot groupDoc =
                                    await FirebaseFirestore.instance
                                        .collection('Groups')
                                        .doc(widget.groupId)
                                        .get();

                                if (groupDoc.exists) {
                                  List<String> requests = (groupDoc.data()
                                          as Map<String, dynamic>)['requests']
                                      .map<String>((item) => item as String)
                                      .toList();

                                  if (requests.contains(currentUser)) {
                                    // remove user from reqeust list
                                    await FirebaseFirestore.instance
                                        .collection('Groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'requests':
                                          FieldValue.arrayRemove([currentUser])
                                    });

                                    // remove group from user's requested list
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(currentUser)
                                        .update({
                                      'groups_requested':
                                          FieldValue.arrayRemove(
                                              [widget.groupId])
                                    });
                                  } else {
                                    // add user to request list
                                    await FirebaseFirestore.instance
                                        .collection('Groups')
                                        .doc(widget.groupId)
                                        .update({
                                      'requests':
                                          FieldValue.arrayUnion([currentUser])
                                    });

                                    // add group to user's requested list
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(currentUser)
                                        .update({
                                      'groups_requested': FieldValue.arrayUnion(
                                          [widget.groupId])
                                    });
                                  }
                                }
                              },
                              child: isRequested
                                  ? Text("Remove request")
                                  : Text("Join Group")),
                      ],
                    )),
                  ),
                ),
              if (users.contains(currentUser))
                SliverPersistentHeader(
                  pinned: true,
                  delegate:
                      MyHeaderDelegate(selectedTab, updateTab, data['name']),
                ),
              if (users.contains(currentUser))
                if (selectedTab == 0) MembersTab(users: users),
              // if (selectedTab == 1)
              //   PostsTab(groupId: widget.groupId, users: users),
              if (selectedTab == 1)
                SliverToBoxAdapter(
                    child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final posts = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          // Convert the current document into a PostModel
                          PostModel postModel =
                              PostModel.fromDocument(posts[index]);
                          return PostWidget(post: postModel);
                        },
                      );
                    }
                  },
                )),

              if (selectedTab == 2) LeaderboardTab(groupId: widget.groupId),
              if (selectedTab == 3) PrizeTab(),
            ]));
      },
    );
  }

  Future<List<DocumentSnapshot>> fetchPostsForGroup(String groupId) async {
    print("fetching posts for group $groupId");
    DocumentSnapshot groupDoc =
        await _firestore.collection('Groups').doc(groupId).get();

    print("Data: ${groupDoc.data()}");

    List<String> groupMembers = [];
    final data = groupDoc.data() as Map<String, dynamic>;
    if (data.containsKey('users')) {
      groupMembers = List<String>.from(data['users']);
    }

    print("no way");
    print(groupMembers);

    // Fetch posts made by these users
    List<QueryDocumentSnapshot> allPosts = [];
    for (String userId in groupMembers) {
      QuerySnapshot userPosts = await _firestore
          .collection('Posts')
          .where('postedBy', isEqualTo: userId)
          .get();
      allPosts.addAll(userPosts.docs);
    }

    // Sort posts chronologically
    allPosts.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aDate = aData['createdAt'] as String;
      final bDate = bData['createdAt'] as String;

      return bDate.compareTo(aDate);
    });

    return allPosts;
  }

  void _showBottomSheet(BuildContext context) {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return Container(
            height: 180, // Adjust this to your needs
            color: Colors.black, // Could adjust this to your needs
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // SizedBox(height: 20),
                    // SizedBox(height: 20),
                    Container(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomCupertinoDialog(
                              titleText:
                                  'Are you sure you want to leave the group?',
                              contentText: 'This cannot be undone.',
                              removeButtonText: 'Leave Group',
                              onRemovePressed: () async {
                                await FirebaseGroupHelper.removeUserFromGroup(
                                    widget.groupId, currentUser);

                                await FirebaseGroupHelper.removeUserFromGroup(
                                    widget.groupId, currentUser);

                                // Now pop the context
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              height: 5.0,
                              width: size.width * .1,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
                              ),
                            ),
                            SizedBox(height: 25),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.1),
                                // border radius on top left and top right
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: MakeGroupAdminWidget(
                                text: "Leave Group",
                                textColor: Colors.red,
                                icon: Icons.do_not_disturb_on,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class SquareWidget extends StatelessWidget {
  final Color color;

  SquareWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      color: color,
    );
  }
}

class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final String groupName;

  MyHeaderDelegate(this.selectedTab, this.onTabSelected, this.groupName);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.black, // Customize the header background color
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: 3,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTabSelected(index);
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: 10, right: 5, top: 5, left: 5),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: selectedTab == index
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the radius value as needed
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          (index == 0)
                              ? Icons.group_sharp
                              : (index == 1)
                                  ? Icons.image
                                  : (index == 2)
                                      ? Icons.star_rounded
                                      : Icons.star, // Add an icon for Posts
                          color: Colors.white,
                          size: 18, // Adjust the size value as needed
                        ),
                        SizedBox(width: 5),
                        Text(
                          (index == 0)
                              ? "Members"
                              : (index == 1)
                                  ? "Posts"
                                  : (index == 2)
                                      ? "Leaderboard"
                                      : "Prizes", // Add the text for Posts
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13, // Adjust the fontSize value as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50; // Customize the maximum header extent

  @override
  double get minExtent => 50; // Customize the minimum header extent

  @override
  bool shouldRebuild(covariant MyHeaderDelegate oldDelegate) {
    return selectedTab != oldDelegate.selectedTab;
  }
}

// Define an async function to get the user data for a user ID