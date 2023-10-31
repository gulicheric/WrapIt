// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/firebase/firebase_helper.dart';
import 'package:tefillin/groups/add_admin_group.dart';
import 'package:tefillin/profile/followers_list.dart';
import 'package:tefillin/profile/following_list.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:tefillin/widgets/calendar_other.dart';
import 'package:tefillin/widgets/custom_cupertino_dialog.dart';

import 'group_list_from_other_profile_screen.dart';

class ProfileOtherProfilePictureAndUsernameWidget extends StatelessWidget {
  const ProfileOtherProfilePictureAndUsernameWidget({
    super.key,
    required this.widget,
    required this.isBlocked,
  });

  final ProfileOthers widget;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Text("No data");
        }

        DocumentSnapshot? document = snapshot.data!;

        String? photoUrl = document['photoUrl'];
        String username = document['username'];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                if (!isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                            onTap: () =>
                                _showBottomSheet(context, isBlocked, username),
                            child: Icon(Icons.menu))),
                  ),
              ],
            ),
            CircleAvatar(
              radius:
                  50, // set the radius to half of the image width/height to make it circular
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            ),
            SizedBox(height: 10),
            Text("${document['username']}",
                style: TextStyle(
                    fontFamily: 'CircularBlack',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).shadowColor)),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, isBlocked, username) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (builder) {
        return Container(
            height: 180, // Adjust this to your needs
            // color: Colors.transparent, // Could adjust this to your needs
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.3),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomCupertinoDialog(
                              titleText:
                                  'Are you sure you want to block this account?',
                              contentText:
                                  'You can unblock this account in settings',
                              removeButtonText: 'Block',
                              onRemovePressed: () async {
                                FirebaseHelper.blockUser(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    widget.uid);
                                // Now pop the context
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '$username blocked. Both of you will not be able to see each other\'s profiles. You can unblock the account in settings')),
                                );
                              },
                            ),
                          );
                        },
                        child: MakeGroupAdminWidget(
                          text: "Block",
                          textColor: Color.fromARGB(255, 254, 148, 141),
                          icon: Icons.do_not_disturb_on,
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

Future<Map<String, dynamic>?> getUserData(String uid) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return userData;
  } catch (e) {
    print('Error getting user data: $e');
    return null;
  }
}

class ProfileOtherCalendarWidget extends StatelessWidget {
  const ProfileOtherCalendarWidget({
    super.key,
    required this.widget,
  });

  final ProfileOthers widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // add future stream that checks in Settings collection whether the document isCalendarPublicToAll has a 'value' of true or false
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          var isCalendarPublicToFriends =
              snapshot.data!['settings.isCalendarPublicToFriends'];

          bool isCurrentUserFollowingThisUser = snapshot.data!['followers']
              .contains(FirebaseAuth.instance.currentUser!.uid);

          var isCalendarPublicToAll =
              snapshot.data!['settings.isCalendarPublicToAll'];

          return isCalendarPublicToAll
              ? TableBasicsExampleOther(
                  uid: widget.uid,
                )
              : isCalendarPublicToFriends
                  ? isCurrentUserFollowingThisUser
                      ? TableBasicsExampleOther(
                          uid: widget.uid,
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text("Only followers can see the calendar"),
                        )
                  : Text("The calendars are set to private");
        });
  }
}

class ProfileOtherCurrentStreakWidget extends StatelessWidget {
  const ProfileOtherCurrentStreakWidget({
    super.key,
    required this.widget,
  });

  final ProfileOthers widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        DocumentSnapshot? document = snapshot.data!;
        int userStreak = document['streak'];

        return Text(
          "Current Streak: " + userStreak.toString(),
          style: TextStyle(fontSize: 18),
        );
      },
    );
  }
}

class ProfileOtherFollowFollowerGroupSectionWidget extends StatelessWidget {
  const ProfileOtherFollowFollowerGroupSectionWidget({
    super.key,
    required this.widget,
  });

  final ProfileOthers widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Text("No data");
              }
              DocumentSnapshot? document = snapshot.data!;

              List<String> following =
                  List<String>.from(document['following'] ?? []);
              List<String> followers =
                  List<String>.from(document['followers'] ?? []);

              return buildInfoRow(following.length, "Following", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FollowingList(
                      uid: widget.uid,
                      isFromYourProfile: false,
                    ),
                  ),
                );
              });
            }),
        SizedBox(width: 10),
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Text("No data");
              }
              DocumentSnapshot? document = snapshot.data!;

              List<String> following =
                  List<String>.from(document['following'] ?? []);
              List<String> followers =
                  List<String>.from(document['followers'] ?? []);

              return buildInfoRow(followers.length, "Followers", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FollowersList(
                      uid: widget.uid,
                      isFromYourProfile: false,
                    ),
                  ),
                );
              });
            }),
        SizedBox(width: 10),
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Text("No data");
              }

              print("This is the user id: " + widget.uid);

              DocumentSnapshot? document = snapshot.data!;

              List userGroups = document['groups'];

              return buildInfoRow(userGroups.length, "Groups", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GroupListFromOtherScreen(
                      uid: widget.uid,
                    ),
                  ),
                );
              });
            }),
      ],
    );
  }
}
