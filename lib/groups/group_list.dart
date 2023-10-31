// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:tefillin/anonymous/sign_up.dart';
import 'package:tefillin/groups/create_group_screen.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/groups/group_page.dart';
import 'package:tefillin/widgets/submit_button.dart';

import '../widgets/alert.dart';

class GroupsMainPage extends StatefulWidget {
  GroupsMainPage({
    Key? key,
    this.selectedTab = 0,
  }) : super(key: key);

  int selectedTab;

  @override
  State<GroupsMainPage> createState() => _GroupsMainPageState();
}

class _GroupsMainPageState extends State<GroupsMainPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<QuerySnapshot> _groupsFuture;
  List<bool> requested = List.filled(100000, false);
  int _selectedImageIndex = -1;
  String _selectedImageUrl = '';

  final List<String> imageUrlList = [
    'https://images.unsplash.com/photo-1680695920053-cb155ad082e8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1680441774216-8a86795a687f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80',
    'https://plus.unsplash.com/premium_photo-1680035238547-bfe1c1fe81a4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1681101378971-5f5dc4e5000e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2714&q=80',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/Untitled%202.jpg?alt=media&token=b39b7120-a77f-4630-bafa-fdf910630ec3&_gl=1*7rs8pf*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0MTguMC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/midj1.jpg?alt=media&token=b1bfbd1c-49a7-4c28-b07d-8d76f969a956&_gl=1*y28k1i*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0NDMuMC4wLjA.',
  ];

  @override
  void initState() {
    super.initState();
    _groupsFuture = fetchData();
  }

  // fetches all the data from Groups
  Future<QuerySnapshot> fetchData() {
    return FirebaseFirestore.instance.collection('Groups').get();
  }

  // Gets groups for the user ONLY for 'Your Pages'
  Future<List<DocumentSnapshot>> getUserGroups() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Groups')
        .where('users', arrayContains: currentUserId)
        .where('approved', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Groups"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!FirebaseAuth.instance.currentUser!.isAnonymous)
            Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 3),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CreateGroupScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                ),
                child: Icon(
                  Icons.group_add,
                  size: 30,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                HapticFeedback.heavyImpact();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.selectedTab = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10, right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: widget.selectedTab == index
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the radius value as needed
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (index == 0) ? Icons.group_sharp : Icons.explore,
                          color: Colors.white,
                          size: 18, // Adjust the size value as needed
                        ),
                        SizedBox(width: 5),
                        Text(
                          (index == 0) ? "Your Pages" : "Explore",
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
          if (widget.selectedTab == 1)
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _groupsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 500.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  // print("Let's see teh groups");
                  // print(snapshot.data!.docs.first.data());

                  // Current user's id
                  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  // Filter out groups where the current user is already a member
                  // Filter out groups where the current user is already a member and 'approved' is true
                  List<DocumentSnapshot> filteredGroups = snapshot.data!.docs
                      .where((group) =>
                              !group['users'].contains(currentUserId) &&
                              group['approved'] ==
                                  true // Check that 'approved' is true
                          )
                      .toList();

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if (FirebaseAuth.instance.currentUser!.isAnonymous)
                          SignUpButton(
                            text: "Sign up to join groups!",
                            size: size,
                            vertical: 20,
                          ),
                        Expanded(
                          child: GridView.builder(
                            itemCount: filteredGroups.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // Specifies the number of columns
                              crossAxisSpacing:
                                  10, // Specifies the spacing along the cross-axis.
                              mainAxisSpacing:
                                  1.0, // Specifies the spacing along the main-axis.
                              childAspectRatio: 3 / 4.8,
                            ),
                            itemBuilder: (context, index) {
                              var groupPicture =
                                  filteredGroups[index]['groupPictureUrl'];

                              DocumentSnapshot group = filteredGroups[index];
                              List<dynamic> users = group['users'];
                              List<dynamic> admin = group['admin'];

                              // print("There are the users");
                              // print(users);

                              // Current user's id
                              String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;

                              // If the current user is in the group, don't render the group.
                              if (users.contains(currentUserId)) {
                                return Container();
                              }

                              if (admin.isEmpty) {
                                return Text('No Admin');
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(admin[0])
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        adminSnapshot) {
                                  if (adminSnapshot.hasError) {
                                    return Text(
                                        "Error: ${adminSnapshot.error}");
                                  }
                                  if (adminSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic>? adminData =
                                        adminSnapshot.data?.data()
                                            as Map<String, dynamic>?;
                                    if (adminData == null) {
                                      return Text('Admin User not found');
                                    }

                                    if (group['requests'].contains(FirebaseAuth
                                        .instance.currentUser!.uid)) {
                                      requested[index] = true;
                                    }

                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter localSetState) {
                                        return Container(
                                            margin: EdgeInsets.only(
                                              top: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  12.0), // Adjust the border radius as needed
                                            ),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  12.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  12.0),
                                                        ),
                                                        child: Image.network(
                                                          groupPicture,
                                                          fit: BoxFit.fitWidth,
                                                          width:
                                                              size.width * .6,
                                                          height: 100,
                                                        ),
                                                      ),
                                                      SizedBox(height: 12),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          group['name'],
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(adminData[
                                                            'username']),
                                                      ),
                                                      SizedBox(height: 4),
                                                      (users.length == 1)
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                  '${users.length} Member'),
                                                            )
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                  '${users.length} Members')),
                                                      SizedBox(height: 15),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      localSetState(() {
                                                        requested[index] =
                                                            !requested[
                                                                index]; // Invert the requested status
                                                      });

                                                      if (requested[index]) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Groups')
                                                            .doc(group.id)
                                                            .update({
                                                          'requests': FieldValue
                                                              .arrayUnion([
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                          ])
                                                        });
                                                      } else {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Groups')
                                                            .doc(group.id)
                                                            .update({
                                                          'requests': FieldValue
                                                              .arrayRemove([
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                          ])
                                                        });
                                                      }
                                                    },
                                                    child: Center(
                                                      child:
                                                          (!FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .isAnonymous)
                                                              ? Container(
                                                                  width:
                                                                      size.width *
                                                                          .35,
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: requested[
                                                                            index]
                                                                        ? Theme.of(context)
                                                                            .accentColor
                                                                        : Colors
                                                                            .white
                                                                            .withOpacity(0.8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child: Text(
                                                                    requested[
                                                                            index]
                                                                        ? "Requested"
                                                                        : "Join",
                                                                    style:
                                                                        TextStyle(
                                                                      color: requested[
                                                                              index]
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                )
                                                              : Container(),
                                                    ),
                                                  )
                                                ]));
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (widget.selectedTab == 0)
            FutureBuilder<List<DocumentSnapshot>>(
              future: getUserGroups(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.only(top: size.height * .3),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: size.height * .3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Join groups to see posts and follow people"),
                        SizedBox(height: 20),
                        GestureDetector(
                            onTap: () => setState(() {
                                  widget.selectedTab = 1;
                                }),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Text("Join groups",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  )),
                            ))
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data![index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      bool isAdmin =
                          (data['admin'] as List).contains(currentUserId);
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupPage(groupId: doc.id),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, right: 15, left: 15),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        data['groupPictureUrl'],
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        (data['users'].length == 1)
                                            ? Text(
                                                '${data['users'].length} Member')
                                            : Text(
                                                '${data['users'].length} Members'),
                                      ],
                                    ),
                                    SizedBox(width: 30),
                                    if (isAdmin)
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Text('Admin')),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
