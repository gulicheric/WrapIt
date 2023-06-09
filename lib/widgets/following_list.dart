// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tefillin/widgets/profile_other.dart';

class FollowingList extends StatefulWidget {
  const FollowingList({super.key});

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> _getFollowing() async {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('Users').doc(user.uid).get();
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getFollowing(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final followingList = snapshot.data!['following'];
            return ListView.builder(
              itemCount: followingList.length,
              itemBuilder: (BuildContext context, int index) {
                final followingUser = followingList[index];
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      _firestore.collection('Users').doc(followingUser).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text('No data found'));
                    } else {
                      final username = snapshot.data!['username'];
                      // final url = snapshot.data!['url'];
                      print("hey");
                      print(followingUser);
                      print(followingList);
                      var size = MediaQuery.of(context).size;
                      return Container(
                        padding:
                            EdgeInsets.only(left: 15.0, top: 15, right: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfileOthers(
                                      uid: followingUser,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: size.width * .8,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(
                                          snapshot.data!.get("photoUrl")),
                                    ),
                                    SizedBox(width: 12.0),
                                    Text(
                                      username,
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context)
                                                .disabledColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //     if (followingList.contains(followingUser))
                            //       GestureDetector(
                            //         onTap: () async {
                            //           final currentUser =
                            //               FirebaseAuth.instance.currentUser;
                            //           if (currentUser != null) {
                            //             await _firestore
                            //                 .collection('Users')
                            //                 .doc(currentUser.uid)
                            //                 .update({
                            //               'following': FieldValue.arrayRemove(
                            //                   [followingUser]),
                            //             });
                            //             setState(
                            //                 () {}); // Refresh the widget state to update the UI
                            //           }
                            //         },
                            //         child: Container(
                            //           padding: EdgeInsets.symmetric(
                            //               horizontal: 20, vertical: 10),
                            //           decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(10),
                            //             color: Color.fromARGB(255, 64, 64, 65),
                            //           ),
                            //           child: Text("Following"),
                            //         ),
                            //       ),
                            //     if (!followingList.contains(followingUser))
                            //       Container(
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 20, vertical: 10),
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(10),
                            //           color: Color.fromARGB(255, 64, 64, 65),
                            //         ),
                            //         child: Text("Following"),
                            //       )
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
