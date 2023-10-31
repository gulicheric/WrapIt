// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('How It Works'),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feed Page',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 20),
                Text(
                  "The feed page shows the most recent posts from users you follow and from users in the same group as you.\n\nTo post a picture, just click on the camera button on the bottom left corner. To post a picture of someone else puttin on tefillin, long press on the camera button.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Profile Page',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 20),
                Text(
                  "This is where you can see your followers, following, and groups.\n\nYou can also see your pictures and can edit your profile.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Groups Page',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 20),
                Text(
                  "This is where you can see your groups and join new ones.\n\nYou will automatically join the group called 'Everyone' when you sign up. You can always leave the group.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ));
  }
}
