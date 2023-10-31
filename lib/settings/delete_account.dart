// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/widgets/custom_cupertino_dialog.dart';
import 'package:tefillin/widgets/submit_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final reminderText1 = "Are you sure you want to delete your account?";
  final reminderText2 =
      "You will lose all your progress and will not be able to recover your account.";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Delete Account"),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: size.height * .25),
                Text(
                  reminderText1,
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  reminderText2,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CustomCupertinoDialog(
                        titleText:
                            'Are you sure you want to delete your account?',
                        contentText: 'This cannot be undone.',
                        removeButtonText: 'Delete Account',
                        onRemovePressed: () async {
                          final String uid =
                              FirebaseAuth.instance.currentUser!.uid;
                          await deleteUserAccount(uid, context);
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TestRoute()),
                          );
                        },
                      ),
                    );
                  },
                  child: const SubmitButton(
                    text: "Delete Account Forever",
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Future<void> deleteUserAccount(String uid, BuildContext context) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get reference to the Firestore collections
  final CollectionReference groupsCollection = firestore.collection('Groups');
  final CollectionReference usersCollection = firestore.collection('Users');

  // Go through all Groups documents and remove the user from the users array if he is in it
  QuerySnapshot groupSnapshot = await groupsCollection.get();
  for (QueryDocumentSnapshot groupDocument in groupSnapshot.docs) {
    List users = groupDocument['users'];
    if (users.contains(uid)) {
      users.remove(uid);
      await groupsCollection.doc(groupDocument.id).update({'users': users});
    }
  }

  print("Removed from all groups");

  // In the Users collection, check arrays and remove the uid if present
  DocumentSnapshot userDocument = await usersCollection.doc(uid).get();
  Map<String, List<String>> arraysToUpdate = {
    'following_requested': [],
    'following': [],
    'followers': [],
    'followers_requested': [],
  };
  arraysToUpdate.forEach((key, value) {
    if (userDocument[key].contains(uid)) {
      value = List.from(userDocument[key])..remove(uid);
      arraysToUpdate[key] = value;
    }
  });
  await usersCollection.doc(uid).update(arraysToUpdate);

  print("Removed from all arrays in Users collection");
  // Delete the Firestore document in the Users collection
  // await usersCollection.doc(uid).delete();
  // print("Removed from Users collection");

  // Delete the user from Firebase Authentication
  usersCollection.doc(uid).update({"deleted": true});

  await FirebaseAuth.instance.signOut();
}
