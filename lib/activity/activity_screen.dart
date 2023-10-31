// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tefillin/activity/follower_requests/accept_follower_requests.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';

import '../firebase/firebase_helper.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int selectedTab = 0;
  late Stream<QuerySnapshot<Map<String, dynamic>>> userActvities;
  final currentUserAuth = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    userActvities = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserAuth)
        .collection("Activity")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          backgroundColor: Colors.transparent,
        ),
        body: Column(children: [
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
                      selectedTab = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10, right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: selectedTab == index
                          ? Theme.of(context).colorScheme.secondary
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
                          (index == 0) ? "Notifications" : "Follower Requests",
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
          if (selectedTab == 1) AccessFollowerRequestScreen(),
          if (selectedTab == 0)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: userActvities,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.only(top: size.height * 0.3),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                int length = snapshot.data!.docs.length;

                return Expanded(
                  child: ListView.builder(
                    itemCount: length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileOthers(
                                    uid: snapshot.data!.docs[index]['userId'],
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  snapshot.data!.docs[index]['userPhotoUrl']),
                            ),
                          ),
                          title:
                              (snapshot.data!.docs[index]['type'] == 'comment')
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: snapshot.data!.docs[index]
                                                ['username'],
                                            style: TextStyle(
                                                fontFamily: 'Circular',
                                                fontSize:
                                                    16.0), // adjust fontSize as needed
                                          ),
                                          TextSpan(
                                            text:
                                                ' commented: ${snapshot.data!.docs[index]['comment']}',
                                            style: TextStyle(
                                                fontFamily: 'CircularRegular',
                                                fontSize:
                                                    16.0), // adjust fontSize as needed
                                          ),
                                        ],
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: snapshot.data!.docs[index]
                                                ['username'],
                                            style: TextStyle(
                                                fontFamily: 'Circular',
                                                fontSize:
                                                    16.0), // adjust fontSize as needed
                                          ),
                                          TextSpan(
                                            text: ' liked your picture',
                                            style: TextStyle(
                                                fontFamily: 'CircularRegular',
                                                fontSize:
                                                    16.0), // adjust fontSize as needed
                                          ),
                                        ],
                                      ),
                                    ),
                          trailing: Container(
                            height: 50,
                            width: 40,
                            child: InstaImageViewer(
                              child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        5), // Adjust the value as per your needs
                                    child: Image(
                                      image: NetworkImage(
                                        snapshot.data!.docs[index]
                                            ['postPhotoUrl'],
                                        scale: 2.5,
                                      ),
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child; // Return the image if it's loaded
                                        }

                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            height: 100,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
        ]));
  }
}
