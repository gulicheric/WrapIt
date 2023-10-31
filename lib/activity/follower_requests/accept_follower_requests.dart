// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/firebase/firebase_helper.dart';

import 'accept_follower_requests_widgets.dart';

class AccessFollowerRequestScreen extends StatefulWidget {
  const AccessFollowerRequestScreen({super.key});

  @override
  State<AccessFollowerRequestScreen> createState() =>
      _AccessFollowerRequestScreenState();
}

class _AccessFollowerRequestScreenState
    extends State<AccessFollowerRequestScreen> {
  late Stream<DocumentSnapshot> streamGroup;
  final currentUserAuth = FirebaseAuth.instance.currentUser!.uid;

  Stream<DocumentSnapshot> getUserDataStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    streamGroup = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserAuth)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<DocumentSnapshot>(
      stream: streamGroup,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.3),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<String> requests =
            List<String>.from(data['followers_requested'] as List);

        print("request is " + requests.toString());
        if (requests.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.3),
            child: Text("No follower requests"),
          );
        }

        return Expanded(
          child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: getUserDataStream(requests[index]),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Container();
                    }
                    if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    }

                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FollowerRequestProfilePictureAndUsernameWidget(
                            userData: userData,
                            id: userSnapshot.data!.id,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  // add to user's followers
                                  await FirebaseHelper.addFollowers(
                                      currentUserAuth, requests[index]);
                                  // add to request[index] following
                                  await FirebaseHelper.addFollowing(
                                      requests[index], currentUserAuth);

                                  // remove from user's followers_requested
                                  await FirebaseHelper.removeFollowersRequested(
                                      currentUserAuth, requests[index]);
                                  // remove from request[index] following_requested
                                  await FirebaseHelper.removeFollowingRequested(
                                      requests[index], currentUserAuth);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  // remove from user's followers_requested
                                  await FirebaseHelper.removeFollowersRequested(
                                      currentUserAuth, requests[index]);

                                  // remove from request[index] following_requested
                                  await FirebaseHelper.removeFollowingRequested(
                                      requests[index], currentUserAuth);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
        );
      },
    );
  }
}
