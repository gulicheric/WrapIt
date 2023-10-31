// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tefillin/firebase/firebase_uploads.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/choose_groups_model.dart';
import 'package:tefillin/widgets/submit_button.dart';

class ChooseGroups extends StatefulWidget {
  const ChooseGroups(
      {super.key,
      required this.username,
      required this.picture,
      required this.age});

  final String username;
  final String picture;
  final int age;

  @override
  State<ChooseGroups> createState() => _ChooseGroupsState();
}

class _ChooseGroupsState extends State<ChooseGroups> {
  List<String> _groupList = ['N9wOQ9tRUHGLunAuWUah'];
  late List<ChooseGroupsModel> _groupSelect;
  late List<ChooseGroupsModel> _everyoneSelect;
  bool isSettingUpAccount = false;
  String? currentUserPhoto = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _everyoneSelect = [
      ChooseGroupsModel(
        id: "N9wOQ9tRUHGLunAuWUah",
        groupName: "Everyone",
        value: true,
        photoUrl:
            "https://images.unsplash.com/photo-1680441774216-8a86795a687f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80",
        onChanged: (value) async {
          if (value) {
            _groupList.add("N9wOQ9tRUHGLunAuWUah");
          } else {
            _groupList.remove("N9wOQ9tRUHGLunAuWUah");
          }
        },
      )
    ];
    _groupSelect = [
      ChooseGroupsModel(
        id: "5aGP4yNgt15cmfWE27jz",
        groupName: "Kedma",
        value: false,
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/kedma.jpeg?alt=media&token=9d08ebd6-07a6-4241-880b-2e5697331461&_gl=1*1stvrrr*_ga*MzQwNTU0MTAzLjE2OTA4MzE4Mjc.*_ga_CW55HF8NVT*MTY5Njg2MjM0NC41MC4xLjE2OTY4NjM0ODAuNjAuMC4w",
        onChanged: (value) async {
          if (value) {
            _groupList.add("5aGP4yNgt15cmfWE27jz");
          } else {
            _groupList.remove("5aGP4yNgt15cmfWE27jz");
          }
        },
      ),
      ChooseGroupsModel(
        id: "rojq46dLE5ELKbLumRg2",
        groupName: "NCSY",
        value: false,
        photoUrl:
            "https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/ncsy.png?alt=media&token=4f05a1bf-3886-48b2-91a6-652f40f0274f&_gl=1*3xiwnv*_ga*MzQwNTU0MTAzLjE2OTA4MzE4Mjc.*_ga_CW55HF8NVT*MTY5Njg2MjM0NC41MC4xLjE2OTY4NjM0NzAuMTAuMC4w",
        onChanged: (value) async {
          if (value) {
            _groupList.add("rojq46dLE5ELKbLumRg2");
          } else {
            _groupList.remove("rojq46dLE5ELKbLumRg2");
          }
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 18),
              child: Text("Step 4/4", style: TextStyle(fontSize: 20)),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10, bottom: 20),
                    child:
                        Text("Choose groups", style: TextStyle(fontSize: 35)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _everyoneSelect.map((setting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: size.width * 0.7,
                                child: Row(
                                  children: [
                                    Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(setting.photoUrl),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                    SizedBox(width: 15),
                                    Text(setting.groupName,
                                        style: const TextStyle(fontSize: 20)),
                                  ],
                                )),
                            Transform.scale(
                                scale: 0.8, // Adjust the scale value as needed
                                child: CupertinoSwitch(
                                  value: setting.value,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      setting.value = newValue;
                                    });
                                    setting.onChanged(
                                        newValue); // Call the specific callback
                                  },
                                ))
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "All users of the app are automatically included in this group. If you wish to opt out and view only friends and specific groups, please deselect this option.",
                      style: TextStyle(
                          fontSize: 16, fontFamily: 'CircularRegular'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10, bottom: 10),
                    child: Text("More groups", style: TextStyle(fontSize: 20)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _groupSelect.map((setting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: size.width * 0.7,
                                child: Row(
                                  children: [
                                    Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(setting.photoUrl),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                    SizedBox(width: 15),
                                    Text(setting.groupName,
                                        style: const TextStyle(fontSize: 20)),
                                  ],
                                )),
                            Transform.scale(
                                scale: 0.8, // Adjust the scale value as needed
                                child: CupertinoSwitch(
                                  value: setting.value,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      setting.value = newValue;
                                    });
                                    setting.onChanged(
                                        newValue); // Call the specific callback
                                  },
                                ))
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      setState(() {
                        isSettingUpAccount =
                            true; // Step 3: Set to true before starting the upload
                      });

                      DateTime now = DateTime.now();
                      String createdAt = now.toUtc().toIso8601String();

                      if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                        await FirebaseAuth.instance.currentUser!
                            .delete(); // Delete the anonymous user
                        final googleSignIn = GoogleSignIn();
                        final googleUser = await googleSignIn.signIn();

                        if (googleUser != null) {
                          final GoogleSignInAuthentication googleAuth =
                              await googleUser.authentication;
                          final AuthCredential credential =
                              GoogleAuthProvider.credential(
                            accessToken: googleAuth.accessToken,
                            idToken: googleAuth.idToken,
                          );

                          final UserCredential authResult = await FirebaseAuth
                              .instance
                              .signInWithCredential(credential);
                          final User? firebaseUser = authResult.user;
                        }
                      }

                      if (currentUserPhoto == "") {
                        currentUserPhoto =
                            "https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/unkown_person.jpeg?alt=media&token=5543db98-b1e0-4b7e-89d8-c4c6d8afdc8d&_gl=1*1btaye*_ga*MTMxOTQ5MzE2OC4xNjgyNTE4NDcx*_ga_CW55HF8NVT*MTY5NjM4OTUxNC43Ni4xLjE2OTYzOTAwMDguNDIuMC4w";
                      }

                      await FirebaseAuth.instance.currentUser!
                          .updateProfile(photoURL: currentUserPhoto);

                      await FirebaseAuth.instance.currentUser!
                          .updateDisplayName(widget.username);

                      await FirebaseUploads.createUser(
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.username,
                          createdAt,
                          currentUserPhoto!,
                          widget.age);

                      for (var element in _groupList) {
                        await FirebaseFirestore.instance
                            .collection("Groups")
                            .doc(element)
                            .get()
                            .then((value) {
                          List<dynamic> members = value.get('users');
                          members.add(FirebaseAuth.instance.currentUser!.uid);
                          FirebaseFirestore.instance
                              .collection("Groups")
                              .doc(element)
                              .update({'users': members});
                        });
                      }

                      setState(() {
                        isSettingUpAccount =
                            false; // Step 3: Set to true before starting the upload
                      });

                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: !isSettingUpAccount
                      ? Container(
                          height: 50,
                          width: size.width,
                          padding: EdgeInsets.symmetric(horizontal: 19.0),
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Center(
                            child: Text(
                              "Set up my account",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        )
                      : Container(
                          height: 50,
                          width: size.width,
                          padding: EdgeInsets.symmetric(horizontal: 19.0),
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Center(
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                )),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ));
  }
}
