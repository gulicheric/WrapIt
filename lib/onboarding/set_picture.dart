// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tefillin/firebase/firebase_uploads.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/settings_model.dart';
import 'package:tefillin/onboarding/choose_groups.dart';
import 'package:tefillin/roadmap/roadmap_screen.dart';
import 'package:tefillin/settings/privacy/privary_settings.dart';
import 'package:tefillin/settings/settings_screen.dart';
import 'package:tefillin/settings/settings_util.dart';
import 'package:tefillin/settings/settings_widgets.dart';
import 'package:tefillin/widgets/edit_username.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tefillin/widgets/submit_button.dart';

class SetPictureScreen extends StatefulWidget {
  const SetPictureScreen(
      {super.key, required this.username, required this.age});

  final String username;
  final int age;

  @override
  State<SetPictureScreen> createState() => _SetPictureScreenState();
}

class _SetPictureScreenState extends State<SetPictureScreen> {
  final ImagePicker _picker = ImagePicker();
  bool isSettingUpAccount = false;

  String? currentUserPhoto = "";
  bool isUploading = false; // Step 1: Add this variable

  void _changeProfilePicture() async {
    print("is upload 1: " + isUploading.toString());

    setState(() {
      isUploading = true; // Step 3: Set to true before starting the upload
    });

    print("is upload 2: " + isUploading.toString());

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload the image to Firebase Storage and get the download URL
        String imageUrl = await uploadImageToFirebase(imageFile);

        // Update the UI
        setState(() {
          currentUserPhoto = imageUrl;
          isUploading = false; // Set to false after the upload completes
        });
      } else {
        setState(() {
          isUploading = false; // Set to false if no image was selected
        });
      }
    } catch (e) {
      setState(() {
        isUploading = false; // Set to false if an error occurs
      });

      // Display error message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("This is the age");
    print(widget.age);
    print(widget.username);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 18),
              child: Text("Step 3/4", style: TextStyle(fontSize: 20)),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Ensure the main column is centered
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left aligns its children
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10),
                    child: Text(
                      "Set a profile picture",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    // This will center the CircleAvatar
                    child: Container(
                      margin: EdgeInsets.only(top: 25),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            (currentUserPhoto != "" && currentUserPhoto != null)
                                ? NetworkImage(currentUserPhoto!)
                                : AssetImage("assets/images/unkown_person.jpeg")
                                    as ImageProvider<Object>,
                      ),
                    ),
                  ),
                  Center(
                    // This will center the Text below the CircleAvatar
                    child: Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: Text(
                            "Choose picture",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                fontWeight: FontWeight.w700),
                          )),
                    ),
                  ),
                ],
              ),
              if (isUploading) // Step 2: Add this condition
                Center(child: CircularProgressIndicator()),
              Column(
                children: [
                  SizedBox(height: 30),
                  Text("Skip for now",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 20),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ChooseGroups(
                                    age: widget.age,
                                    username: widget.username,
                                    picture: currentUserPhoto!,
                                  )),
                        );
                      },
                      child: SubmitButton(text: "Next")),
                  SizedBox(height: 30),
                ],
              )
            ],
          ),
        ));
  }
}

// class SubmitButtons extends StatelessWidget {
//   final String text;
//   final bool isLoading;

//   SubmitButtons({required this.text, this.isLoading = false});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: !isLoading ? () => /* your function here */ : null,
//       child: isLoading 
//              ? CircularProgressIndicator()
//              : Text(text),
//       // Add other properties and styles as necessary
//     );
//   }
// }


/**
 
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

                              final UserCredential authResult =
                                  await FirebaseAuth.instance
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

                          await FirebaseFirestore.instance
                              .collection("Groups")
                              .doc('N9wOQ9tRUHGLunAuWUah')
                              .get()
                              .then((value) {
                            List<dynamic> members = value.get('users');
                            members.add(FirebaseAuth.instance.currentUser!.uid);
                            FirebaseFirestore.instance
                                .collection("Groups")
                                .doc('N9wOQ9tRUHGLunAuWUah')
                                .update({'users': members});
                          });

                          setState(() {
                            isSettingUpAccount =
                                false; // Step 3: Set to true before starting the upload
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
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


 */