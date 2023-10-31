import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/settings_model.dart';
import 'package:tefillin/widgets/submit_button.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    TestRoute()), // Navigate to the login page
            (Route<dynamic> route) => false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: SubmitButton(
            text: 'Log out',
            color: Colors.red,
          ),
        ));
  }
}

Future<String> uploadImageToFirebase(File imageFile) async {
  String fileName = FirebaseAuth
      .instance.currentUser!.uid; // User the user's id as the file name

  FirebaseStorage storage = FirebaseStorage.instance;

  Reference ref = storage.ref().child('userProfilePics/$fileName');
  UploadTask uploadTask = ref.putData(await imageFile.readAsBytes());

  // Get the download URL
  String downloadUrl =
      await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

  return downloadUrl;
}

class SettingsSwitch extends StatefulWidget {
  final SettingsScreenModel setting;
  final void Function(bool) onChanged;

  SettingsSwitch({required this.setting, required this.onChanged});

  @override
  _SettingsSwitchState createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Text(widget.setting.title),
        ),
        Transform.scale(
          scale: 0.8, // Adjust the scale value as needed
          child: CupertinoSwitch(
            value: widget.setting.value,
            onChanged: (bool newValue) {
              HapticFeedback.heavyImpact();
              setState(() {
                widget.setting.value = newValue;
              });
              widget.onChanged(newValue); // Call the specific callback
            },
          ),
        )
      ],
    );
  }
}
