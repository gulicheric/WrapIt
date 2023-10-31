// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tefillin/firebase/firebase_group_helper.dart';
import 'package:tefillin/groups/delete_group.dart';
import 'package:tefillin/widgets/edit_group_name.dart';
import 'package:tefillin/widgets/edit_username.dart';
import 'package:tefillin/settings/settings_screen.dart';
import 'package:tefillin/widgets/submit_button.dart';

import '../main.dart';
import '../settings/privacy/privary_settings.dart';
import 'add_admin_group.dart';
import '../widgets/settings_containers.dart';

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage(
      {super.key,
      required this.groupId,
      required this.isAdmin,
      required this.groupName});

  final String groupId;
  final bool isAdmin;
  final String groupName;

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
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
        String imageUrl =
            await uploadGroupImageToFirebase(imageFile, widget.groupId);

        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupId)
            .update({'groupPictureUrl': imageUrl});

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
        title: Text('Group Settings'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: (widget.isAdmin)
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: <Widget>[
            Column(children: [
              SizedBox(height: 10),
              if (widget.isAdmin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Groups")
                            .doc(widget.groupId)
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

                          if (!snapshot.data!.exists) {
                            return Center(child: Text('Group does not exist'));
                          }

                          DocumentSnapshot? document = snapshot.data!;
                          final photoUrl = document['groupPictureUrl'];

                          return Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(photoUrl!),
                              ));
                        }),
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
                height: 50,
                padding: EdgeInsets.only(
                  left: size.width * .03,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditGroupSettings(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        SizedBox(
                            width: size.width * .25,
                            child: Text(
                              "Group name",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            )),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: size.width * .60,
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
                            widget.groupName,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _navigateToAddAdmin,
                child: SettingsContainer(text: "Add other users as admins"),
              ),
              SizedBox(height: 20),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _navigateToDeleteGroup,
                child: SettingsContainer(text: "Delete Group"),
              ),
            ]),

            // Leave group
            GestureDetector(
              onTap: () async => await _handleLeaveGroup(),
              child: SubmitButton(
                text: 'Leave Group',
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAddAdmin() async {
    final admins = await _fetchAdminsFromGroup(widget.groupId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAdminGroup(
          groupId: widget.groupId,
          admins: admins,
        ),
      ),
    );
  }

  Future<List<String>> _fetchAdminsFromGroup(String groupId) async {
    var document = await FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupId)
        .get();
    var adminList = document.get("admin");
    return List<String>.from(adminList.map((item) => item as String));
  }

  void _navigateToDeleteGroup() {
    Navigator.of(context).push(_deleteGroupPageRoute());
  }

  MaterialPageRoute _deleteGroupPageRoute() {
    return MaterialPageRoute(
      builder: (context) => DeleteGroup(groupId: widget.groupId),
    );
  }

  Future<void> _handleLeaveGroup() async {
    if (widget.isAdmin) {
      DocumentSnapshot group =
          await FirebaseGroupHelper.getGroup(widget.groupId);

      if (group['admin'].length == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('You must add another admin before leaving the group'),
          ),
        );
        return;
      } else {
        await FirebaseGroupHelper.removeUserFromGroup(widget.groupId, uid);
        await FirebaseGroupHelper.removeAdminFromGroup(widget.groupId, uid);
      }
    } else {
      await FirebaseGroupHelper.removeUserFromGroup(widget.groupId, uid);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TestRoute()),
      (Route<dynamic> route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have left the group')),
    );
  }
}

Future<String> uploadGroupImageToFirebase(File imageFile, group_id) async {
  String fileName = group_id.toString();

  FirebaseStorage storage = FirebaseStorage.instance;

  Reference ref = storage.ref().child('groupProfilePics/$fileName');
  UploadTask uploadTask = ref.putData(await imageFile.readAsBytes());

  // Get the download URL
  String downloadUrl =
      await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

  return downloadUrl;
}
