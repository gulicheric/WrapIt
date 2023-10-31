// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/onboarding/set_age.dart';
import 'package:tefillin/widgets/submit_button.dart';

class SetProfileScreen extends StatefulWidget {
  const SetProfileScreen({Key? key})
      : super(key: key); // Corrected super.key to key

  @override
  State<SetProfileScreen> createState() => _SetProfileScreenState();
}

class _SetProfileScreenState extends State<SetProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool isUsernameValid = false;
  bool isUsernameInUse = false;
  final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');

  void handleUsernameChange(String value) async {
    isUsernameInUse = false;
    // if username is already in use, show error
    await FirebaseFirestore.instance.collection("Users").get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc["username"] == value) {
          isUsernameInUse = true;
        }
      });
    });

    setState(() {
      isUsernameValid = usernameRegex.hasMatch(value) && value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorForValidUsername = isUsernameValid
        ? Theme.of(context).accentColor
        : Colors.white.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 18),
            child: Text("Step 1/4", style: TextStyle(fontSize: 20)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructions(), // Extracted method for instructions
            _buildNextButton(
                colorForValidUsername), // Extracted method for next button
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 10),
          child: Text("Enter a username", style: TextStyle(fontSize: 35)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _usernameController,
            style: TextStyle(fontSize: 20.0),
            maxLines: 1,
            maxLength: 20,
            onChanged: handleUsernameChange,
            decoration: InputDecoration(
              border: InputBorder.none, // No border
              hintText: "Enter username",
            ),
          ),
        ),
        if (isUsernameInUse)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Username already in use",
              style: TextStyle(color: Colors.red),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "You can only use letters and numbers, without any spaces",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(Color colorForValidUsername) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: () {
          if (isUsernameValid && !isUsernameInUse) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SetAgeScreen(username: _usernameController.text),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Please enter a valid username that is not in use')),
            );
          }
        },
        child: SubmitButton(
          text: "Next",
          color: colorForValidUsername,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController
        .dispose(); // Dispose the controller when it's no longer needed.
    super.dispose();
  }
}
