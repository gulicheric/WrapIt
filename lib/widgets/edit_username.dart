import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/feed/feed_page.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/widgets/feed_screen.dart';

class EditUsername extends StatefulWidget {
  final Function? onUsernameUpdated;

  const EditUsername({Key? key, this.onUsernameUpdated}) : super(key: key);

  @override
  State<EditUsername> createState() => _EditUsernameState();
}

class _EditUsernameState extends State<EditUsername> {
  late TextEditingController _textEditingController;
  String? currentUsername;
  bool isUsernameChanged = false;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    currentUsername = FirebaseAuth.instance.currentUser?.displayName;
    _textEditingController = TextEditingController(text: currentUsername);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> updateUserDisplayName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String newUsername = _textEditingController.text;
    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');

    if (user != null && isUsernameChanged) {
      if (usernameRegex.hasMatch(newUsername)) {
        await user.updateDisplayName(newUsername);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({'username': newUsername});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated')),
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
              content: Text('Username must only contain letters and numbers')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made to username')),
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
        title: const Text("Edit Username"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5),
            child: IconButton(
              icon: Icon(Icons.done),
              color: doneIconColor,
              onPressed: updateUserDisplayName,
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
