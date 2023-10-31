// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/widgets/custom_cupertino_dialog.dart';

class AddAdminGroup extends StatefulWidget {
  const AddAdminGroup({super.key, required this.groupId, required this.admins});

  final String groupId;
  final List<String> admins;

  @override
  State<AddAdminGroup> createState() => _AddAdminGroupState();
}

class _AddAdminGroupState extends State<AddAdminGroup> {
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Admin"),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Groups")
              .doc(widget.groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data == null || !snapshot.hasData) {
              return const Center(child: Text("No users in this group"));
            }

            List<String> users = List.from(snapshot.data?['users'] ?? []);
            List<String> admins = List.from(snapshot.data?['admin'] ?? []);

            return _buildUsernamesList(users, admins);
          },
        )));
  }

  Widget _buildUsernamesList(List<String> users, List<String> admins) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _getUsernames(users),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildUserRow(
                snapshot.data![index],
                admins,
                snapshot.data!.length,
                index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserRow(Map<String, String> userData, List<String> admins,
      int totalCount, int currentIndex) {
    bool isAdmin = admins.contains(userData['userId']);
    bool isCurrentUser = currentUser == userData['userId'];
    bool isFirst = currentIndex == 0;
    bool isLast = currentIndex == totalCount - 1;

    return GestureDetector(
      onTap: () => _handleUserTap(userData, isAdmin),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          borderRadius: isFirst
              ? BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              : isLast
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))
                  : null,
        ),
        child: AdminRowWidget(
          text: userData['username'] ?? '',
          isAdmin: isAdmin,
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }

  void _handleUserTap(Map<String, String> userData, bool isAdmin) {
    if (currentUser == userData['userId']) return;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return CustomModalBottomSheet(
          data: userData,
          groupId: widget.groupId,
          isAdmin: isAdmin,
        );
      },
    );
  }
}

Future<List<Map<String, String>>> _getUsernames(List<String> ids) async {
  List<Map<String, String>> userInfos = [];
  for (String id in ids) {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(id).get();

    Map<String, dynamic>? data = userDoc.data();

    if (data != null) {
      String? username = data['username'] as String?;
      if (username != null && username != 'guest') {
        userInfos.add({
          'userId': userDoc.id,
          'username': username,
          'photoUrl': data['photoUrl'] ?? '',
        });
      }
    }
  }
  return userInfos;
}

class AdminRowWidget extends StatelessWidget {
  final String text;
  final bool isAdmin;
  final bool isCurrentUser;

  const AdminRowWidget(
      {super.key,
      required this.text,
      required this.isAdmin,
      required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        Row(
          children: [
            if (isAdmin)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.3),
                    // border radius on bottom left and bottom right
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text("Admin"),
              ),
            if (!isCurrentUser) SizedBox(width: 10),
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(top: .5),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MakeGroupAdminWidget extends StatelessWidget {
  final String text;
  final Color textColor;
  final IconData icon;

  const MakeGroupAdminWidget(
      {super.key,
      required this.text,
      required this.textColor,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
        SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: .5),
          child: Icon(
            icon,
            color: textColor,
            size: 25,
          ),
        ),
      ],
    );
  }
}

class CustomModalBottomSheet extends StatelessWidget {
  final Map<String, String> data;
  final String groupId;
  final bool isAdmin;

  CustomModalBottomSheet({
    required this.data,
    required this.groupId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // add the photoUrl and username
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(data['photoUrl']!),
                    ),
                    SizedBox(width: 10),
                    Text(
                      data['username']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.cancel),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (!isAdmin) {
                  await FirebaseFirestore.instance
                      .collection("Groups")
                      .doc(groupId)
                      .update({
                    'admin': FieldValue.arrayUnion([data['userId']])
                  });
                } else {
                  // if user is an admin, remove them from admin list
                  List<String> admins = List<String>.from(
                      await FirebaseFirestore.instance
                          .collection("Groups")
                          .doc(groupId)
                          .get()
                          .then((value) => value.data()?['admin']!));
                  if (admins.length > 1) {
                    await FirebaseFirestore.instance
                        .collection("Groups")
                        .doc(groupId)
                        .update({
                      'admin': FieldValue.arrayRemove([data['userId']])
                    });
                  }
                }
                Navigator.pop(context);
              },
              child: (isAdmin)
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        // border radius on top left and top right
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: MakeGroupAdminWidget(
                        text: "Dismiss as admin",
                        textColor: Colors.red,
                        icon: Icons.person_remove,
                      ),
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        // border radius on top left and top right
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: MakeGroupAdminWidget(
                        text: "Make Group Admin",
                        textColor: Colors.white,
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                    ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Are you sure you want to remove this user?'),
                    content: Text('This cannot be undone.'),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('Remove'),
                        onPressed: () async {
                          // remove from users array
                          await FirebaseFirestore.instance
                              .collection("Groups")
                              .doc(groupId)
                              .update({
                            'users': FieldValue.arrayRemove([data['userId']])
                          });

                          // remove from user's groups
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(data['userId'])
                              .update({
                            'groups': FieldValue.arrayRemove([groupId])
                          });

                          if (isAdmin) {
                            // remove from admin array
                            await FirebaseFirestore.instance
                                .collection("Groups")
                                .doc(groupId)
                                .update({
                              'admin': FieldValue.arrayRemove([data['userId']])
                            });
                          }

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.1),
                  // border radius on top left and top right
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: MakeGroupAdminWidget(
                  text: "Remove From Group",
                  textColor: Colors.red,
                  icon: Icons.do_not_disturb_on,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
