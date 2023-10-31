// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/anonymous/sign_up.dart';
import 'package:tefillin/firebase/firebase_helper.dart';
import 'package:tefillin/profile/group_list.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_widget.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:tefillin/widgets/calendar.dart';
import 'package:tefillin/widgets/calendar_other.dart';
import 'package:tefillin/widgets/profile_following_follower_group_row_info.dart';

import '../followers_list.dart';
import '../following_list.dart';
import 'group_list_from_other_profile_screen.dart';
import 'profile_other_util.dart';

class ProfileOthers extends StatefulWidget {
  final String uid;
  const ProfileOthers({required this.uid, super.key});

  @override
  State<ProfileOthers> createState() => _ProfileOthersState();
}

class _ProfileOthersState extends State<ProfileOthers> {
  final userAuthId = FirebaseAuth.instance.currentUser!.uid;
  Stream<DocumentSnapshot>? streamGroup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('Users').doc(widget.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // streambuilder that gets the streak from the user
              SizedBox(
                height: 220,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text('Something went wrong'));
                    }

                    var blockList = snapshot.data!.get("blocked");
                    var blockedByList = snapshot.data!.get("blockedBy");
                    bool isBlocked = (blockList.contains(widget.uid) ||
                            blockedByList.contains(widget.uid)) &&
                        !FirebaseAuth.instance.currentUser!.isAnonymous;

                    if (isBlocked) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          ProfileOtherProfilePictureAndUsernameWidget(
                              widget: widget, isBlocked: isBlocked),
                          Padding(
                              padding: EdgeInsets.only(top: size.height * .2),
                              child: Text(
                                "You cannot see this user's profile",
                                style: TextStyle(fontSize: 17),
                              )),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        SizedBox(
                          height: 180,
                          child: ProfileOtherProfilePictureAndUsernameWidget(
                              widget: widget, isBlocked: isBlocked),
                        ),
                        SizedBox(
                          height: 20,
                          child: ProfileOtherFollowFollowerGroupSectionWidget(
                              widget: widget),
                        ),
                        // get streak from user streambuilder
                        if (FirebaseAuth.instance.currentUser!.isAnonymous)
                          SignUpButton(
                            size: size,
                            vertical: 15,
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                SizedBox(
                  height: 80,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userAuthId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(child: Text('Something went wrong'));
                      }

                      bool isFollowing =
                          snapshot.data!.get("following").contains(widget.uid);

                      bool isFollowingRequested = snapshot.data!
                          .get("following_requested")
                          .contains(widget.uid);

                      Map<String, bool> followingStatus = {
                        'isFollowing': isFollowing,
                        'isRequested': isFollowingRequested
                      };

                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Follow Buttons
                            SizedBox(height: 20),

                            GestureDetector(
                                onTap: () async {
                                  // if user is following
                                  await dealWithFollowingButton(
                                      followingStatus);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: size.width * .6,
                                      decoration:
                                          _getButtonDecoration(followingStatus),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            _getButtonText(followingStatus),
                                            style: _getButtonTextStyle(
                                                followingStatus, context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(width: size.width * .02),
                                    // Container(
                                    //   width: 40,
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white,

                                    //     border: Border.all(color: Colors.white, width: 2),borderRadius:
                                    //         BorderRadius.circular(6.0),
                                    //   ),
                                    //   child: Align(
                                    //     alignment: Alignment.center,
                                    //     child: Padding(
                                    //         padding: const EdgeInsets
                                    //                 .symmetric(
                                    //             vertical: 6.0),
                                    //         child: Icon(
                                    //           Icons.menu,
                                    //           color: Colors.blue,
                                    //         )),
                                    //   ),
                                    // ),
                                  ],
                                )),
                          ]);
                    },
                  ),
                ),
              SizedBox(height: 20),
              ProfileOtherCurrentStreakWidget(widget: widget),
              ProfileOtherCalendarWidget(widget: widget)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> dealWithFollowingButton(
      Map<String, bool> followingStatus) async {
    if (followingStatus['isFollowing']!) {
      followingStatus['isFollowing'] = false;
      await FirebaseHelper.removeFollowing(userAuthId, widget.uid);
      await FirebaseHelper.removeFollowers(widget.uid, userAuthId);
    } else if (followingStatus['isRequested']!) {
      followingStatus['isRequested'] = false;
      await FirebaseHelper.removeFollowingRequested(userAuthId, widget.uid);
      await FirebaseHelper.removeFollowersRequested(widget.uid, userAuthId);
    } else {
      // if user is not following or requested
      followingStatus['isRequested'] = false;
      // adding the current using to following_requested for a specific userId
      await FirebaseHelper.addFollowingRequested(userAuthId, widget.uid);
      // adding a user to followers_requested for a specific userId
      await FirebaseHelper.addFollowersRequested(widget.uid, userAuthId);
    }
  }
}

BoxDecoration _getButtonDecoration(Map<String, bool?> followingStatus) {
  if (followingStatus['isFollowing']!) {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(6.0),
    );
  } else if (followingStatus['isRequested']!) {
    return BoxDecoration(
      color: Color.fromARGB(255, 96, 10, 57),
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(6.0),
    );
  } else {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(6.0),
    );
  }
}

String _getButtonText(Map<String, bool?> followingStatus) {
  if (followingStatus['isFollowing']!) {
    return "Following";
  } else if (followingStatus['isRequested']!) {
    return "Requested";
  } else {
    return "Follow";
  }
}

TextStyle _getButtonTextStyle(
    Map<String, bool?> followingStatus, BuildContext context) {
  if (followingStatus['isFollowing']! || followingStatus['isRequested']!) {
    return TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  } else {
    return TextStyle(
      color: Theme.of(context).accentColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }
}
