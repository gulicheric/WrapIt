import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/settings/privacy/privary_settings_util.dart';

import '../../models/privacy_setting_model.dart';

class PrivarySettingsScreen extends StatefulWidget {
  const PrivarySettingsScreen({super.key});

  @override
  State<PrivarySettingsScreen> createState() => _PrivarySettingsScreenState();
}

class _PrivarySettingsScreenState extends State<PrivarySettingsScreen> {
  List<PrivacySettingModel> settings = [
    PrivacySettingModel(
      id: 'isCalendarPublicToAll',
      title: "Allow anyone to see your calendar",
      value: false,
      onChanged: (value) async {
        final usersCollection = FirebaseFirestore.instance.collection('Users');
        final uid = FirebaseAuth.instance.currentUser!.uid;
        if (value) {
          await usersCollection
              .doc(uid)
              .update({'settings.isCalendarPublicToAll': true});
        } else {
          await usersCollection
              .doc(uid)
              .update({'settings.isCalendarPublicToAll': false});
        }
      },
    ),
    PrivacySettingModel(
      id: 'isCalendarPublicToFriends',
      title: "Allow your friends to see your calendar",
      value: true,
      onChanged: (value) async {
        final usersCollection = FirebaseFirestore.instance.collection('Users');
        final uid = FirebaseAuth.instance.currentUser!.uid;
        if (value) {
          await usersCollection
              .doc(uid)
              .update({'settings.isCalendarPublicToFriends': true});
        } else {
          await usersCollection
              .doc(uid)
              .update({'settings.isCalendarPublicToFriends': false});
        }
      },
    ),
  ];
  late List<PrivacySettingModel> privacySettings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      privacySettings = await getPrivacySettings(
          FirebaseAuth.instance.currentUser!.uid, settings);
      setState(() {}); // notify the framework that widget state has changed
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: settings.map((setting) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: size.width * 0.7,
                      child: Text(setting.title,
                          style: const TextStyle(fontSize: 16))),
                  Transform.scale(
                      scale: 0.8, // Adjust the scale value as needed
                      child: CupertinoSwitch(
                        value: setting.value,
                        onChanged: (bool newValue) {
                          setState(() {
                            setting.value = newValue;
                          });
                          setting.onChanged(
                              newValue); // Call the specific callback
                        },
                      ))
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


/**
 * 
 * 
 
 * FutureBuilder<Map<String, bool>>(
            future: getPrivacySettings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingWidget(); // Show loading spinner while waiting
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Map<String, bool> settings = snapshot.data!;



 * 
 * 
 */