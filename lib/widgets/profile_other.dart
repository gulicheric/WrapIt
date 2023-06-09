// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_page.dart';
import 'followers_list.dart';
import 'following_list.dart';

class ProfileOthers extends StatefulWidget {
  final String uid;
  const ProfileOthers({required this.uid, super.key});

  @override
  State<ProfileOthers> createState() => _ProfileOthersState();
}

class _ProfileOthersState extends State<ProfileOthers> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                // Functionality to navigate back to the previous page
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ),

            FutureBuilder<Map<String, dynamic>?>(
              future: getUserData(widget.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == null) {
                  return const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://storage.googleapis.com/nhbt-2022.appspot.com/Unknown_person-modified.png?Expires=1683568988&GoogleAccessId=firebase-adminsdk-nmu32%40nhbt-2022.iam.gserviceaccount.com&Signature=15LTLDV51%2F2c8sEOpTrt0CuX4er0Ul%2BwEz%2FKFKYgW%2Fp1ASRv%2B4tNqrFVeBsX1RhQjdrNBMt4rkcHNv20XrKw%2Fcq1LAcnGl76zLkyvEHIDlpBuVT4W99h7JcHEi8uEBup8ystClxfnaEfwhb2BfWFLdWISsdCnJFGWpxE5bD1i7ukcAsIJHjBCUZXsASXLNgaAteZdpY%2BIQ9jefYwFp%2FJjC91rUCNCtodRveYn0vsn4%2Bm6PEaIX8jWw5oVDzmkk9pDQAZpGPxTIj4oOPNyo1F9oyCFLczyUt4pe2KQ3kUWimNg7mANwLv2aYcgcjD0%2BPcoEBOGf1461tOUtBnvlgTmA%3D%3D'), // Provide a default image
                  );
                } else {
                  List<String> following =
                      List<String>.from(snapshot.data!['following'] ?? []);
                  List<String> followers =
                      List<String>.from(snapshot.data!['followers'] ?? []);
                  var size = MediaQuery.of(context).size;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(snapshot.data!['photoUrl']),
                      ),
                      SizedBox(height: 20),
                      Text("@${snapshot.data!['username'].toString()}",
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 64, 64, 65),
                        ),
                        width: size.width * .92,
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            TopStreakText(
                                text: "You are " + "7" + " days strong!"),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                }
              },
            ),
            // Add other widgets
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> getUserData(String uid) async {
  try {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return userData;
  } catch (e) {
    print('Error getting user data: $e');
    return null;
  }
}
