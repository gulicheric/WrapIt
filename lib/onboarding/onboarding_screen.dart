// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/onboarding/set_username.dart';
import 'package:tefillin/widgets/submit_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: size.height * .3),
                Center(
                  child: Text(
                    "Lets get set up!",
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Takes less than 1 minute",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .1),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SetProfileScreen(),
                          ),
                        );
                      },
                      child: SubmitButton(text: "Start"),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                GestureDetector(
                    onTap: () async =>
                        await FirebaseAuth.instance.signOut().then(
                              (value) => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => TestRoute()),
                              ),
                            ),
                    child: Text("Already have an account? Sign in")),
                SizedBox(height: 20)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
