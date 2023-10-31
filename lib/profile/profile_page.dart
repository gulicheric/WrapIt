// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/profile/following_list.dart';
import 'package:tefillin/profile/group_list.dart';
import 'package:tefillin/roadmap/roadmap_screen.dart';
import 'package:tefillin/settings/settings_screen.dart';
import 'package:tefillin/widgets/custom_container.dart';

import '../widgets/calendar.dart';
import 'followers_list.dart';
import '../widgets/profile_following_follower_group_row_info.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser!;
    var size = MediaQuery.of(context).size;

    return StreamBuilder<DocumentSnapshot>(
      stream: getUserDataStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        DocumentSnapshot? document = snapshot.data;

        // check to see if document has the element 'following' and if not, print an empty list
        if (!document!.exists) {
          return Center(child: Text('Document does not exist'));
        }

        List<String> following = List<String>.from(document['following'] ?? []);
        List<String> followers = List<String>.from(document['followers'] ?? []);
        final currentUserName = document['username'];
        final photoUrl = document['photoUrl'];
        final userStreak = document['streak'].toString();
        List userGroups = document['groups'];
        final totalPosts = document['posts'].length.toString();
        final longestStreak = document['largest_streak'].toString();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(
                                  true); // passing a value back to first page
                            },
                            child: Icon(Icons.arrow_back_ios_new),
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
                                        builder: (context) => SettingsPage(),
                                      ),
                                    ),
                                child: Icon(
                                  Icons.settings,
                                  size: 30,
                                ))),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                  ),
                  SizedBox(height: 15),
                  Text("${currentUserName}",
                      style: TextStyle(
                          fontFamily: 'CircularBlack',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).shadowColor)),
                  SizedBox(height: 10),
                  InfoRow(
                    followingCount: following.length,
                    followersCount: followers.length,
                    groupsCount: userGroups.length,
                    onTapFollowing: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FollowingList(
                            isFromYourProfile: true,
                            uid: user.uid,
                          ),
                        ),
                      );
                    },
                    onTapFollowers: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FollowersList(
                            uid: user.uid,
                            isFromYourProfile: true,
                          ),
                        ),
                      );
                    },
                    onTapGroups: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupList(
                            uid: user.uid,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  CustomContainer(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Streaks",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RoadMapScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Want to see another stat?",
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // total posts
                          SizedBox(
                            width: size.width * .22,
                            child: Column(
                              children: [
                                Text(
                                  totalPosts,
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(height: 10),
                                Text("Total")
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * .25,
                            child: Column(
                              children: [
                                Text(
                                  userStreak,
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(height: 10),
                                Text("Current")
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * .22,
                            child: Column(
                              children: [
                                Text(
                                  longestStreak,
                                  style: TextStyle(fontSize: 25),
                                ),
                                SizedBox(height: 10),
                                Text("Longest")
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                  SizedBox(height: 15),
                  // Text(
                  //   "Current Streak: " + userStreak.toString(),
                  //   style: TextStyle(fontSize: 18),
                  // ),
                  SizedBox(height: 0),
                  Container(
                    padding: EdgeInsets.only(left: 20, bottom: 15, top: 5),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(.1),
                    ),
                    child: TableBasicsExample(),
                  )
                ])),
          ),
        );
      },
    );
  }
}

class FollowersFollowingTab extends StatelessWidget {
  const FollowersFollowingTab({
    super.key,
    required this.bottomText,
    required this.topText,
  });

  final String bottomText;
  final String topText;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 35, 37, 38),
      ),
      width: size.width * .45,
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TopFollowText(text: topText),
          // SizedBox(height: 3),
          BottomFollowText(
            text: bottomText,
          )
        ],
      ),
    );
  }
}

class BottomFollowText extends StatelessWidget {
  const BottomFollowText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.dmSans(
            textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).disabledColor)));
  }
}

class TopFollowText extends StatelessWidget {
  const TopFollowText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.dmSans(
            textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).disabledColor)));
  }
}

class TopStreakText extends StatelessWidget {
  const TopStreakText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.dmSans(
            textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).disabledColor)));
  }
}

class DateProfileList extends StatelessWidget {
  const DateProfileList({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.dmSans(
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).disabledColor)));
  }
}

Stream<DocumentSnapshot> getUserDataStream(String userId) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection('Users').doc(userId);
  return userDocRef.snapshots();
}

Widget buildInfoRow(int count, String label, Function onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 16, fontFamily: 'CircularBlack'),
          ),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    ),
  );
}
