// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, equal_keys_in_map

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart'; // I

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/posting/add_caption.dart';
import 'package:tefillin/widgets/homepage.dart';

class CheckIfUsersAreReadyToPost extends StatefulWidget {
  const CheckIfUsersAreReadyToPost({super.key, required this.image});

  final File image;

  @override
  State<CheckIfUsersAreReadyToPost> createState() =>
      _CheckIfUsersAreReadyToPostState();
}

class _CheckIfUsersAreReadyToPostState
    extends State<CheckIfUsersAreReadyToPost> {
  bool isLoading = false;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Looks good?"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 500,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10),
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await _uploadImageToFirebase(widget.image);

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                      (Route<dynamic> route) =>
                          false, // This predicate returns false for all routes, so all previous routes are removed.
                    );
                  },
                  child: !isLoading
                      ? const Text(
                          "Post",
                          style: TextStyle(color: Colors.white),
                        )
                      : const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                      width: size.width - 114,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddCaption(image: widget.image),
                              ),
                            );
                          },
                          child: const Text(
                            "Add a caption (optional)",
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> _uploadImageToFirebase(File image) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the identifier from the authentication
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Get the user's latest post
  QuerySnapshot querySnapshot = await firestore
      .collection('Posts')
      .where('postedBy', isEqualTo: currentUser?.uid)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();

  if (!querySnapshot.docs.isEmpty) {
    // Compare the date of the latest post with today's date
    DateTime latestPostDate =
        DateTime.parse(querySnapshot.docs.first.get('createdAt')).toLocal();

    DateTime now = DateTime.now();

    if (latestPostDate.year == now.year &&
        latestPostDate.month == now.month &&
        latestPostDate.day == now.day) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 0,
          duration: const Duration(seconds: 10),
          content: const Padding(
            padding: EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Sorry 😢 - You can only post once a day",
              style: TextStyle(color: Colors.black, fontFamily: 'Circular'),
            ),
          ),
        ),
      );
      return;
    }
  }

  // Read the image from the file
  img.Image imageFile = img.decodeImage(await image.readAsBytes())!;

// Get the dimensions of the image
  int width = imageFile.width;
  int height = imageFile.height;

  int resizedWidth = (width * 0.7).round();
  int resizedHeight = (height * 0.7).round();

  List<int> compressedImage = (await FlutterImageCompress.compressWithFile(
    image.path,
    minWidth: resizedWidth,
    minHeight: resizedHeight,
    quality: 10,
  )) as List<int>;

// Compress and resize the image to 60% of its original size

  // Generate a unique file name for the image
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a reference to the Firebase Storage location
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('images/$fileName');

  // Upload the image to Firebase Storage
  UploadTask uploadTask = ref.putData(compressedImage as Uint8List);

  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

  // Get the download URL for the uploaded image
  String downloadURL = await taskSnapshot.ref.getDownloadURL();

  CollectionReference imagesCollection = firestore.collection('Posts');

  DateTime now = DateTime.now();
  String createdAt = now.toUtc().toIso8601String();
  String dateManipulated = DateFormat('EEEE, MMMM d').format(now);

  var user = await firestore.collection('Users').doc(currentUser?.uid).get();

  // Add the new fields to the document
  DocumentReference postRef = await imagesCollection.add({
    'url': downloadURL,
    'createdAt': createdAt,
    'dateManipulated': dateManipulated,
    'likes': [],
    'likeCount': 0,
    'postedBy': currentUser?.uid,
    'caption': "",
    'reports': 0,
    'numberOfComments': 0,
    'username': user.data()!['username'],
    'photoUrl': user.data()!['photoUrl'],
  });

  incrementStreak(currentUser!.uid);

  // Fetch user document from the 'Users' collection
  DocumentReference userRef =
      firestore.collection('Users').doc(currentUser?.uid);

  // Add the post document ID to the user's document
  await userRef.update({
    'posts': FieldValue.arrayUnion([postRef.id])
  });
}
