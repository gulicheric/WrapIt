// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:tefillin/widgets/custom_table.dart';
import 'package:tefillin/widgets/share.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key, required this.groupId});

  final String groupId;

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  get currentUser => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, groupSnapshot) {
          if (!groupSnapshot.hasData) {
            return Container();
          }

          final groupDoc = groupSnapshot.data!;
          final List<String> userDocIds =
              (groupDoc.data() as Map<String, dynamic>)['users']
                  .map<String>((item) => item as String)
                  .toList();

          Future<List<Map<String, Object>>> fetchUsersWithStreaks(
              List<String> userDocIds) async {
            // Fetch all user documents at once

            List<DocumentSnapshot> userDocs = await Future.wait(userDocIds.map(
                (userId) => FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .get()));

            // print("We need to see the infromation here");
            // for (DocumentSnapshot userDoc in userDocs) {
            //   print(userDoc.data()!['username']);
            // }

            // Process the fetched documents
            List<Map<String, Object>> usersWithStreaks = [
              for (DocumentSnapshot userDoc in userDocs)
                if ((userDoc.data() as Map<String, dynamic>)['username'] !=
                    'guest')
                  {
                    'userId': userDoc.id,
                    'username':
                        (userDoc.data() as Map<String, dynamic>)['username'],
                    'streak':
                        (userDoc.data() as Map<String, dynamic>)['streak'],
                    'profilePicture':
                        (userDoc.data() as Map<String, dynamic>)['photoUrl'],
                  }
            ];

            // Sort the list based on streaks
            usersWithStreaks.sort(
                (a, b) => (b['streak'] as int).compareTo(a['streak'] as int));

            print("Streaks bb");
            print(usersWithStreaks);
            // return usersWithStreaks;
            return usersWithStreaks;
          }

          // Fetch and sort the users based on their streaks
          return FutureBuilder<List<Map<String, Object>>>(
            future: fetchUsersWithStreaks(userDocIds),
            builder: (context, usersSnapshot) {
              if (!usersSnapshot.hasData) {
                return Container();
              }

              final sortedUserIds = usersSnapshot.data!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    CustomTable(
                      rows: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Text(
                                'Username',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            TableCell(
                              child: Text(
                                'Days',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const TableRow(children: [
                          SizedBox(height: 15),
                          SizedBox(height: 15)
                        ]),
                        ...List.generate(sortedUserIds.length, (index) {
                          final user = sortedUserIds[index];
                          var username = user['username'] as String;
                          var userPhotoUrl = user['profilePicture'] as String;
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      if (currentUser == user['userId']) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfilePage(),
                                          ),
                                        );
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProfileOthers(
                                                uid: user['userId'] as String),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(userPhotoUrl),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(" $username"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(user['streak'].toString()),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ShareWidget(size: size),
                    const SizedBox(height: 55),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
