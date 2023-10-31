// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/onboarding/set_picture.dart';
import 'package:tefillin/widgets/submit_button.dart';

class SetAgeScreen extends StatefulWidget {
  const SetAgeScreen({super.key, required this.username});

  final String username;

  @override
  State<SetAgeScreen> createState() => _SetAgeScreenState();
}

class _SetAgeScreenState extends State<SetAgeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String username = "";
  bool isUsernameValid = false;
  final _ageController = TextEditingController();
  int? age;
  final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');

  void handleUsernameChange(String value) {
    setState(() {
      if (int.tryParse(value) != null &&
          int.tryParse(value)! > 0 &&
          int.tryParse(value)! < 120) {
        age = int.tryParse(value);
        isUsernameValid = true;
      } else {
        isUsernameValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color colorForValidUsername = (isUsernameValid)
        ? Theme.of(context).accentColor
        : Colors.white.withOpacity(0.3);
    var size = MediaQuery.of(context).size;
    double height = size.height * .1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 18),
            child: Text("Step 2/4", style: TextStyle(fontSize: 20)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 10),
                  child: Text(
                    "Enter age",
                    style: TextStyle(fontSize: 35),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, top: 10.0),
                  child: TextField(
                    controller: _usernameController,
                    style: TextStyle(fontSize: 20.0),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (value) {
                      handleUsernameChange(value);
                    },
                    decoration: InputDecoration(
                      labelText: null, // No label/hint text
                      border: InputBorder.none, // No border
                      hintText: "Ex: 23", // No hint text
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: () {
                  if (isUsernameValid) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SetPictureScreen(
                            username: widget.username, age: age ?? 0),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid username')),
                    );
                  }
                },
                child: SubmitButton(
                  text: "Next",
                  color: colorForValidUsername,
                ),
              ),
            )
          ],
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
