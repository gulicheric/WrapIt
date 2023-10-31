// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/widgets/submit_button.dart';

class DeleteGroup extends StatefulWidget {
  const DeleteGroup({super.key, required this.groupId});

  final String groupId;

  @override
  State<DeleteGroup> createState() => _DeleteGroupState();
}

class _DeleteGroupState extends State<DeleteGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Group"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          child: GestureDetector(
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                  title:
                      const Text('Are you sure you want to delete this group?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () async {
                        // go through all users in the group and remove the group from their groups list
                        final usersInGroup = await FirebaseFirestore.instance
                            .collection('Groups')
                            .doc(widget.groupId)
                            .get();

                        for (var user in usersInGroup.data()!['users']) {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user)
                              .update({
                            'groups': FieldValue.arrayRemove([widget.groupId])
                          });
                        }

                        await FirebaseFirestore.instance
                            .collection('Groups')
                            .doc(widget.groupId)
                            .delete();

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                          (Route<dynamic> route) =>
                              false, // This condition ensures all routes are removed
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            child: Center(
                child: SubmitButton(text: "Delete Group", color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
