// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/onboarding/onboarding_screen.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    var userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.data()!['deleted'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You have deleted your account, please allow up to 7 days before you can create an account again",
            style: TextStyle(fontFamily: 'CircularRegular'),
          ),
          showCloseIcon: true,
          duration: Duration(seconds: 10),
        ),
      );
      FirebaseAuth.instance.signOut();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    }

    // try {
    //   final UserCredential authResult =
    //       await _auth.createUserWithEmailAndPassword(
    //     email: _emailController.text,
    //     password: _passwordController.text,
    //   );
    //   final User? firebaseUser = authResult.user;
    //   if (firebaseUser != null) {
    //     DocumentReference userDocRef = FirebaseFirestore.instance
    //         .collection('Users')
    //         .doc(firebaseUser.uid);
    //     DocumentSnapshot userDoc = await userDocRef.get();

    //     if (!userDoc.exists) {
    //       // New User, navigate to OnboardingScreen
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(
    //           builder: (context) => OnboardingScreen(),
    //         ),
    //       );
    //     } else {
    //       // Existing User, navigate to MainScreen
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(
    //           builder: (context) => MainScreen(),
    //         ),
    //       );
    //     }
    //   }
    // } on FirebaseAuthException catch (e) {
    //   print('Failed to create account: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
