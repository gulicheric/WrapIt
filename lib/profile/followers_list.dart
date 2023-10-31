// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';

class FollowersList extends StatefulWidget {
  final String uid;
  final bool isFromYourProfile;

  const FollowersList(
      {super.key, required this.uid, required this.isFromYourProfile});

  @override
  State<FollowersList> createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late Future<List<dynamic>> _FollowersList;
  Map<String, bool> isFollowers = {};
  late Future<List<BoardPreviewModel>> board_members;

  Future<List<BoardPreviewModel>> getAllBoardMembers(String uid) async {
    List<BoardPreviewModel> result = [];
    var userIdSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    for (var id in userIdSnapshot.data()!['followers']) {
      var idInfo =
          await FirebaseFirestore.instance.collection('Users').doc(id).get();

      isFollowers[id] = true;

      result.add(BoardPreviewModel(
          id: id,
          profilePicture: idInfo.data()!['photoUrl'],
          username: idInfo.data()!['username']));
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    board_members = getAllBoardMembers(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<BoardPreviewModel>>(
          future: board_members,
          builder: (BuildContext context,
              AsyncSnapshot<List<BoardPreviewModel>> snapshot) {
            var size = MediaQuery.of(context).size;
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var followersUser = snapshot.data!.elementAt(index).id;
                    var username = snapshot.data!.elementAt(index).username;
                    var photoUrl =
                        snapshot.data!.elementAt(index).profilePicture;
                    return Container(
                      padding: EdgeInsets.only(left: 15.0, top: 15, right: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (FirebaseAuth.instance.currentUser!.uid !=
                                    followersUser) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileOthers(
                                        uid: followersUser,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()),
                                  );
                                }
                              },
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(photoUrl),
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
                              )),
                          if (FirebaseAuth.instance.currentUser!.uid !=
                                  followersUser &&
                              widget.isFromYourProfile)
                            ElevatedButton(
                              onPressed: () async {
                                bool currentlyFollowers =
                                    isFollowers[followersUser] ?? false;

                                if (currentlyFollowers) {
                                  // Unfollow the user
                                  await _firestore
                                      .collection('Users')
                                      .doc(_auth.currentUser?.uid)
                                      .update({
                                    'followers':
                                        FieldValue.arrayRemove([followersUser])
                                  });

                                  isFollowers[followersUser] = false;
                                } else {
                                  // Follow the user
                                  await _firestore
                                      .collection('Users')
                                      .doc(_auth.currentUser?.uid)
                                      .update({
                                    'followers':
                                        FieldValue.arrayUnion([followersUser])
                                  });
                                  isFollowers[followersUser] = true;
                                }

                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red, // Set the button color to red
                              ),
                              child: Text(isFollowers[followersUser] ?? false
                                  ? "Remove"
                                  : "Removed"),
                            )
                        ],
                      ),
                    );
                  });
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class BoardPreviewModel {
  final String id;
  final String profilePicture;
  final String username;

  BoardPreviewModel(
      {required this.id, required this.username, required this.profilePicture});
}
