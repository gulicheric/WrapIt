// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/groups/add_admin_group.dart';
import 'package:tefillin/main.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Accounts"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data == null || !snapshot.hasData) {
              return const Center(child: Text("No Blocked Users"));
            }

            List<String> blocked = List.from(snapshot.data?['blocked'] ?? []);

            return _buildUsernamesList(blocked);
          },
        ),
      ),
    );
  }

  Widget _buildUsernamesList(List<String> users) {
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
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildUserRow(
                snapshot.data![index],
                snapshot.data!.length,
                index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserRow(
      Map<String, String> userData, int totalCount, int currentIndex) {
    // bool isAdmin = admins.contains(userData['userId']);
    bool isCurrentUser = currentUser == userData['userId'];
    bool isFirst = currentIndex == 0;
    bool isLast = currentIndex == totalCount - 1;

    return GestureDetector(
      onTap: () => _handleUserTap(userData),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.25),
          borderRadius: isFirst
              ? const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              : isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))
                  : null,
        ),
        child: AdminsRowWidget(
          url: userData['photoUrl'] ?? '',
          text: userData['username'] ?? '',
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }

  void _handleUserTap(Map<String, String> userData) {
    if (currentUser == userData['userId']) return;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return BlockedCustomModalBottomSheet(
          data: userData,
          groupId: currentUser,
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

class AdminsRowWidget extends StatelessWidget {
  final String text;
  final String url;
  final bool isCurrentUser;

  const AdminsRowWidget(
      {super.key,
      required this.text,
      required this.isCurrentUser,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius:
                  20, // set the radius to half of the image width/height to make it circular
              backgroundImage: url != null ? NetworkImage(url) : null,
            ),
            if (!isCurrentUser) const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
            if (!isCurrentUser) const SizedBox(width: 10),
          ],
        ),
        Row(
          children: [
            // if (isAdmin)
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            //     decoration: BoxDecoration(
            //         color: Colors.white.withOpacity(.3),
            //         // border radius on bottom left and bottom right
            //         borderRadius: BorderRadius.all(Radius.circular(12))),
            //     child: Text("Admin"),
            //   ),

            if (!isCurrentUser)
              const Padding(
                padding: EdgeInsets.only(top: .5, right: 15),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class BlockedCustomModalBottomSheet extends StatelessWidget {
  final Map<String, String> data;
  final String groupId;

  const BlockedCustomModalBottomSheet({
    super.key,
    required this.data,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                    const SizedBox(width: 10),
                    Text(
                      data['username']!,
                      style: const TextStyle(
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
                  child: const Icon(Icons.cancel),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'blocked': FieldValue.arrayRemove([data['userId']])
                });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TestRoute()),
                  (Route<dynamic> route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${data['username'] ?? ''} unblocked')),
                );
              },
              child: Container(
                width: size.width * .9,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.1),
                  // border radius on top left and top right
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text((true) ? "Unblock User" : "Block User"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/**
 
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
                // if (!isAdmin) {
                //   await FirebaseFirestore.instance
                //       .collection("Groups")
                //       .doc(groupId)
                //       .update({
                //     'admin': FieldValue.arrayUnion([data['userId']])
                //   });
                // } else {
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
 */
