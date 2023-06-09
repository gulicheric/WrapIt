// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tefillin/widgets/accept_requets.dart';
import 'package:tefillin/widgets/feed_screen.dart';
import 'package:tefillin/widgets/group_setttings.dart';

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
  int selectedTab = 0;

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
  }

  Stream<DocumentSnapshot> getUserDataStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots();
  }

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

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isAdmin = (data['admin'] as List)
            .contains(FirebaseAuth.instance.currentUser!.uid);
        int requestCount = (data['requests'] as List).length;
        var size = MediaQuery.of(context).size;

        List<String> users = List<String>.from(data['users'] as List);

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
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AcceptGroupRequests(
                              groupId: widget.groupId,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => GroupSettingsPage(
                                        groupId: widget.groupId)),
                              ),
                          child: Icon(
                            Icons.settings,
                            size: 30,
                          ))),
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
                  Container(
                    // third part
                    child: Column(
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
                  ),
                  // Add more widgets as needed
                ]),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate:
                    MyHeaderDelegate(selectedTab, updateTab, data['name']),
              ),

              // SliverList(
              //   delegate: SliverChildListDelegate([
              //     Text("HI"),
              //     const SizedBox(height: 25),
              //   ]),
              // ),
              // SliverAppBar(
              //   titleSpacing: 0,
              //   toolbarHeight: 40,
              //   automaticallyImplyLeading: false,
              //   backgroundColor: Colors.black,
              //   floating: false,
              //   title: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Padding(
              //       padding:
              //           const EdgeInsets.only(top: 15.0, bottom: 10, left: 8),
              //       child: Text(
              //         (selectedTab == 0)
              //             ? "Members"
              //             : (selectedTab == 1)
              //                 ? "Posts"
              //                 : "Leaderboards",
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 17,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ),
              //   ),
              //   // pinned: true,
              // ),
              if (this.selectedTab == 0)
                SliverPadding(
                    padding: EdgeInsets.only(top: 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2 / 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return StreamBuilder<DocumentSnapshot>(
                            stream: getUserDataStream(users[index]),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              }

                              var userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;

                              return Container(
                                // color: Colors.red,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),
                                    CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage:
                                          NetworkImage(userData['photoUrl']),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${userData['username']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        childCount: users.length,
                      ),
                    )),
              if (this.selectedTab == 1)
                SliverToBoxAdapter(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Groups')
                        .doc(widget.groupId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> groupSnapshot) {
                      if (groupSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!groupSnapshot.hasData) {
                        return Center(child: Text('No data found'));
                      }

                      // get the group data
                      Map<String, dynamic> groupData =
                          groupSnapshot.data!.data() as Map<String, dynamic>;
                      // get the list of user uids in the group
                      List<String> groupUserUids =
                          List<String>.from(groupData['users']);

                      print(groupUserUids);

                      return FutureBuilder<List<DocumentSnapshot>>(
                        future: getGroupPosts(groupUserUids),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<DocumentSnapshot>>
                                postSnapshot) {
                          if (postSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!postSnapshot.hasData ||
                              postSnapshot.data!.isEmpty) {
                            return Center(child: Text('No posts found'));
                          }

                          // sort posts by createdAt
                          postSnapshot.data!.sort((a, b) =>
                              b.get('createdAt').compareTo(a.get('createdAt')));

                          // Return your UI here using postSnapshot.data
                          return Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: postSnapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return PostWidget(
                                    post: postSnapshot.data![index]);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ]));
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
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTabSelected(index);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10, right: 10, top: 5),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: selectedTab == index
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the radius value as needed
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (index == 0)
                              ? Icons.group_sharp
                              : (index == 1)
                                  ? Icons.image
                                  : Icons.star_rounded, // Add an icon for Posts
                          color: Colors.white,
                          size: 18, // Adjust the size value as needed
                        ),
                        SizedBox(width: 5),
                        Text(
                          (index == 0)
                              ? "Members"
                              : (index == 1)
                                  ? "Posts"
                                  : "Leaderboardsssssss", // Add the text for Posts
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
