// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/widgets/edit_username.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tefillin/widgets/submit_button.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  String? currentUserPhoto = FirebaseAuth.instance.currentUser!.photoURL;
  final currentUserName = FirebaseAuth.instance.currentUser!.displayName;

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

  String username = 'John Doe';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(top: 50),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(currentUserPhoto!),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Text(
                        "Edit picture",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w700),
                      )),
                ),
                SizedBox(height: 30),
                Container(
                  height: 50,
                  padding: EdgeInsets.only(
                    left: size.width * .03,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditUsername(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: size.width * .25,
                            child: Text(
                              "Username",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            )),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: size.width * .68,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color.fromARGB(74, 255, 255, 255),
                                width: 1.2,
                              ),
                              bottom: BorderSide(
                                color: Color.fromARGB(74, 255, 255, 255),
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: Text(
                            currentUserName!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            TestRoute()), // Navigate to the login page
                    (Route<dynamic> route) => false,
                  );
                },
                child: SubmitButton(
                  text: 'Log out',
                ))
          ],
        ),
      ),
    );
  }
}

Future<String> uploadImageToFirebase(File imageFile) async {
  String fileName = FirebaseAuth
      .instance.currentUser!.uid; // User the user's id as the file name

  FirebaseStorage storage = FirebaseStorage.instance;

  Reference ref = storage.ref().child('userProfilePics/$fileName');
  UploadTask uploadTask = ref.putData(await imageFile.readAsBytes());

  // Get the download URL
  String downloadUrl =
      await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

  return downloadUrl;
}
