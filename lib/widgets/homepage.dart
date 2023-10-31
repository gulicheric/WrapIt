// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use

import 'dart:io';
import 'package:intl/intl.dart'; // Import this package to format the date

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import '../profile/profile_page.dart';
import 'camera.dart';
import '../feed/feed_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImageToFirebase(_image!);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 0, right: 0),
        child: FloatingActionButton(
          elevation: 0,
          onPressed: _openCamera,
          child: Icon(Icons.camera_alt),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        title: Text("Feed",
            style: GoogleFonts.sigmarOne(
                textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).shadowColor))),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              FirebaseAuth.instance.signOut();

              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _getFollowingIds(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          print("hyeifjlasdfjalsjdf");
          print("Following ids: ${snapshot.data}");

          return FeedScreen(
            followingIds: snapshot.data!,
            controller: _scrollController,
          );
        },
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('First Page'),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Second Page'),
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Third Page'),
    );
  }
}

Future<void> _uploadImageToFirebase(File image) async {
  // Generate a unique file name for the image
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a reference to the Firebase Storage location
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('images/$fileName');

  // Upload the image to Firebase Storage
  UploadTask uploadTask = ref.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

  // Get the download URL for the uploaded image
  String downloadURL = await taskSnapshot.ref.getDownloadURL();

  // Add the download URL to a Firestore collection
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference imagesCollection = firestore.collection('Posts');

  DateTime now = DateTime.now();
  String createdAt = now.toUtc().toIso8601String();
  String dateManipulated = DateFormat('EEEE, MMMM d').format(now);

  // Get the identifier from the authentication
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Add the new fields to the document
  await imagesCollection.add({
    'url': downloadURL,
    'createdAt': createdAt,
    'dateManipulated': dateManipulated,
    'likes': [],
    'likeCount': 0,
    'postedBy': currentUser?.uid,
    'caption': "",
    'reports': 0
  });

  incrementStreak(currentUser!.uid);
}

Future<List<String>> _getFollowingIds(BuildContext context) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return [];
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef =
      firestore.collection('Users').doc(currentUser.uid);
  DocumentSnapshot userDoc = await userDocRef.get();

  List<String> followingIds =
      List<String>.from(userDoc.get('following') as List<dynamic>);
  followingIds.add(currentUser.uid);
  return followingIds;
}

void incrementStreak(String userId) {
  FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .update({'streak': FieldValue.increment(1)})
      .then((value) => print("Streak incremented"))
      .catchError((error) => print("Failed to increment streak: $error"));

  // if streak is now higher than largest_streak, update largest_streak
  FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      int streak = documentSnapshot.get('streak');
      int largestStreak = documentSnapshot.get('largest_streak');

      if (streak > largestStreak) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .update({'largest_streak': streak})
            .then((value) => print("Largest streak updated"))
            .catchError(
                (error) => print("Failed to update largest streak: $error"));
      }
    }
  });
}
