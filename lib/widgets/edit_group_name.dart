import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/feed/feed_screen.dart';

class EditGroupSettings extends StatefulWidget {
  final String groupId;
  final String groupName;

  const EditGroupSettings(
      {Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  State<EditGroupSettings> createState() => _EditGroupSettingsState();
}

class _EditGroupSettingsState extends State<EditGroupSettings> {
  late TextEditingController _textEditingController;
  String? currentUsername;
  bool isUsernameChanged = false;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController(text: widget.groupName);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> updateGroupName() async {
    final String newUsername = _textEditingController.text;
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9 ]+$');

    if (isUsernameChanged) {
      if (usernameRegex.hasMatch(newUsername)) {
        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupId)
            .update({'name': newUsername});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group name updated')),
        );
        setState(() {
          currentUsername = newUsername;
          isUsernameChanged = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) =>
              false, // never return true, all routes are removed
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Group name must only contain letters and numbers')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made to group name')),
      );
    }
  }

  void handleUsernameChange(String value) {
    setState(() {
      if (value != currentUsername) {
        isUsernameChanged = true;
      } else {
        isUsernameChanged = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color doneIconColor =
        isUsernameChanged ? Colors.white : Colors.white.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Edit Group Name"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5),
            child: IconButton(
              icon: Icon(Icons.done),
              color: doneIconColor,
              onPressed: updateGroupName,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name"),
              TextField(
                maxLength: 20,
                controller: _textEditingController,
                onChanged: handleUsernameChange,
              ),
              SizedBox(height: 20),
              Text(
                "You can only use letters and numbers, without any spaces",
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
