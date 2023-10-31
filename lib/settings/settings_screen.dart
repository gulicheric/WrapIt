// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/settings_model.dart';
import 'package:tefillin/roadmap/roadmap_screen.dart';
import 'package:tefillin/settings/blocked_accounts.dart';
import 'package:tefillin/settings/delete_account.dart';
import 'package:tefillin/settings/how_it_works.dart';
import 'package:tefillin/settings/privacy/privary_settings.dart';
import 'package:tefillin/settings/settings_util.dart';
import 'package:tefillin/settings/settings_widgets.dart';
import 'package:tefillin/widgets/custom_container.dart';
import 'package:tefillin/widgets/edit_username.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tefillin/widgets/submit_button.dart';

import '../widgets/roadmap_container.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  String? currentUserPhoto = FirebaseAuth.instance.currentUser!.photoURL;
  final currentUserName = FirebaseAuth.instance.currentUser!.displayName;
  late List<SettingsScreenModel> privacySettings;

  Future<void> _changeProfilePicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload the image to Firebase Storage and get the download URL
        String imageUrl = await uploadImageToFirebase(imageFile);

        // Update the photoURL of the Firebase user
        User user = FirebaseAuth.instance.currentUser!;
        await user.updatePhotoURL(imageUrl);

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({'photoUrl': imageUrl});

        // Update the UI
        setState(() {
          currentUserPhoto = imageUrl;
        });

        // Navigate back to MainScreen and show a snackbar
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) =>
              false, // never return true, all routes are removed
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picture updated successfully')),
        );
      } else {
        // handle when no image was selected
      }
    } catch (e) {
      // Display error message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating picture: $e')),
      );
    }
  }

  List<SettingsScreenModel> settings = [
    SettingsScreenModel(
      id: 'isTefillinHelpRequired',
      title: "Do you need the Tefillin Helper feature?",
      value: true,
      onChanged: (value) async {
        final usersCollection = FirebaseFirestore.instance.collection('Users');
        final uid = FirebaseAuth.instance.currentUser!.uid;
        if (value) {
          // go to Settings collection, and go to document isCalendarPublicToAll and set it to true
          await usersCollection
              .doc(uid)
              .update({'settings.isTefillinHelpRequired': true});
        } else {
          // go to Settings collection, and go to document isCalendarPublicToAll and set it to false
          await usersCollection
              .doc(uid)
              .update({'settings.isTefillinHelpRequired': false});
        }
      },
    ),
  ];

  String username = 'John Doe';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      privacySettings =
          await getSettings(FirebaseAuth.instance.currentUser!.uid, settings);
      setState(() {}); // notify the framework that widget state has changed
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }

                          if (!snapshot.hasData) {
                            return Center(child: Text('No data available'));
                          }

                          // check to see if document has the element 'photoUrl' and if not, print an empty list
                          if (!snapshot.data!.exists) {
                            return Center(
                                child: Text('Document does not exist'));
                          }

                          DocumentSnapshot? document = snapshot.data!;
                          final photoUrl = document['photoUrl'];

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            NetworkImage(photoUrl!),
                                      )),
                                  SizedBox(width: 15),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: GestureDetector(
                                        onTap: _changeProfilePicture,
                                        child: Text(
                                          "Edit picture",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w700),
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              Container(
                                width: size.width * .9,
                                // margin: EdgeInsets.symmetric(horizontal: 15),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.1),
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(
                                        10.0) // This adds a border radius of 10 units
                                    ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditUsername(
                                          username: document['username']),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: size.width * .25,
                                              child: Text(
                                                "Username:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              )),
                                          Text(
                                            document['username'] ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: Icon(Icons.arrow_forward_ios,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
                SizedBox(height: 15),
                HowItWorksWidget(),
                SizedBox(height: 15),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PrivarySettingsScreen(),
                    ),
                  ),
                  child: Container(
                      width: size.width * .9,
                      // margin: EdgeInsets.symmetric(horizontal: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.1),
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(
                              10.0) // This adds a border radius of 10 units
                          ),
                      child: ClickableSettingRow(
                        text: "Privacy Settings",
                      )),
                ),
                SizedBox(height: 15),
                // Tefillin Helper Switch
                // make this a separate widget
                DeleteAccountWidget(),
                SizedBox(height: 15),
                BlockedAccountsWidget(),
                SizedBox(height: 15),
                CustomContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: settings.map((setting) {
                      return SettingsSwitch(
                        setting: setting,
                        onChanged: (bool newValue) {
                          setting.onChanged(
                              newValue); // Call the specific callback
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RoadmapContainer(size: size),
                ),
              ]),
              SizedBox(height: 20),
              LogoutButton()
            ],
          ),
        ),
      ),
    );
  }
}

class BlockedAccountsWidget extends StatelessWidget {
  const BlockedAccountsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlockedAccountsScreen(),
        ),
      ),
      child: CustomContainer(
        child: ClickableSettingRow(
          text: "Blocked Accounts",
        ),
      ),
    );
  }
}

class ClickableSettingRow extends StatelessWidget {
  const ClickableSettingRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Icon(Icons.arrow_forward_ios, size: 20),
        ),
      ],
    );
  }
}

class DeleteAccountWidget extends StatelessWidget {
  const DeleteAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeleteAccountScreen(),
        ),
      ),
      child: CustomContainer(
        child: ClickableSettingRow(
          text: "Delete Account",
        ),
      ),
    );
  }
}

class HowItWorksWidget extends StatelessWidget {
  const HowItWorksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => HowItWorksScreen(),
        ),
      ),
      child: CustomContainer(
        child: ClickableSettingRow(
          text: "How It Works",
        ),
      ),
    );
  }
}
