// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/widgets/following_list.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:tefillin/widgets/settings.dart';

import '../widgets/calendar.dart';
import '../widgets/followers_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? photoUrl = user!.photoURL;
    print("Photo url: " + photoUrl!);
    var size = MediaQuery.of(context).size;

    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        List<String> following =
            List<String>.from(snapshot.data!['following'] ?? []);
        List<String> followers =
            List<String>.from(snapshot.data!['followers'] ?? []);
        final currentUserName = FirebaseAuth.instance.currentUser!.displayName;
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
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(Icons.arrow_back_ios_new))),
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
                  CircleAvatar(
                    radius:
                        50, // set the radius to half of the image width/height to make it circular
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                  ),
                  SizedBox(height: 20),
                  Text("@${currentUserName}",
                      style: GoogleFonts.indieFlower(
                          textStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).shadowColor))),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowingList(),
                            ),
                          );
                        },
                        child: FollowersFollowingTab(
                          bottomText: 'Following',
                          topText: following.length.toString(),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowersList(),
                            ),
                          );
                        },
                        child: FollowersFollowingTab(
                          bottomText: 'Followers',
                          topText: followers.length.toString(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TableBasicsExample()
                  // GestureDetector(
                  //   onTap: () => Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (context) => TableBasicsExample(),
                  //     ),
                  //   ),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       color: Color.fromARGB(255, 35, 37, 38),
                  //     ),
                  //     width: size.width * .92,
                  //     height: 60,
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         TopStreakText(
                  //             text: "You are " + "7" + " days strong!"),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  // FutureBuilder<QuerySnapshot>(
                  //   future: FirebaseFirestore.instance
                  //       .collection('Posts')
                  //       .where('postedBy',
                  //           isEqualTo:
                  //               user.uid) // replace <id> with the specific id
                  //       .orderBy('createdAt',
                  //           descending: true) // ordering by createdAt
                  //       .get(),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<QuerySnapshot> snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return CircularProgressIndicator(); // showing loading spinner while waiting for data
                  //     }

                  //     if (!snapshot.hasData) {
                  //       return Text(
                  //           'No posts found.'); // showing message if no posts found
                  //     }

                  //     final List<DocumentSnapshot> documents =
                  //         snapshot.data!.docs;

                  //     return ListView.builder(
                  //       physics: const NeverScrollableScrollPhysics(),
                  //       shrinkWrap: true,
                  //       itemCount: documents.length,
                  //       itemBuilder: (BuildContext context, int index) {
                  //         return ListTile(
                  //           title: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               DateProfileList(
                  //                 text: documents[index].get('dateManipulated'),
                  //               ),
                  //               SizedBox(height: 10),
                  //               InstaImageViewer(
                  //                 child: Container(
                  //                   width: 50,
                  //                   height: 100,
                  //                   decoration: BoxDecoration(
                  //                     image: DecorationImage(
                  //                       image: NetworkImage(
                  //                           documents[index].get('url')),
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                     borderRadius: BorderRadius.circular(10),
                  //                   ),
                  //                 ),
                  //               ),
                  //               SizedBox(height: 15)
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  // )
                ])),
          ),
        );

        // ... (the rest of the ProfilePage layout
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

Future<DocumentSnapshot> getUserData(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection('Users').doc(userId);
  return await userDocRef.get();
}
