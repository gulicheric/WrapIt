// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool success = await signInWithGoogle();
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in canceled. Please try again.')),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png', // Add the Google logo asset to your project
              width: 24.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    print("hey");
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in process
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("no way");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (error) {
      print("Error signing in with Google: $error");
      return false;
    }
  }
}
