// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tefillin/firebase/firebase_uploads.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/onboarding/onboarding_screen.dart';

import '../widgets/sign_in_with_email.dart';

class TeffilinPictureAndBigText extends StatelessWidget {
  const TeffilinPictureAndBigText({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        const SizedBox(height: 200),
        SizedBox(
            width: size.width * .8,
            child: Image.asset('assets/images/tefillin.png')),
        Text(
          "One day at a time",
          style: GoogleFonts.sigmarOne(
            textStyle: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}

class EmailAndAppleSignInOptions extends StatelessWidget {
  const EmailAndAppleSignInOptions({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 60),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width: 3, color: Theme.of(context).colorScheme.secondary),
                borderRadius: const BorderRadius.all(Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/apple.png", height: 30, width: 30),
                const SizedBox(width: 10),
                Text(
                  "Continue with Apple",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary),
                )
              ],
            ),
          ),
          onTap: () async {
            try {
              final appleCredential =
                  await SignInWithApple.getAppleIDCredential(
                scopes: [
                  AppleIDAuthorizationScopes.email,
                  AppleIDAuthorizationScopes.fullName,
                ],
              );

              final oAuthProvider = OAuthProvider('apple.com');
              final credential = oAuthProvider.credential(
                idToken: appleCredential.identityToken,
                accessToken: appleCredential.authorizationCode,
              );
              final UserCredential authResult =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              final User? firebaseUser = authResult.user;

              if (firebaseUser != null) {
                DocumentReference userDocRef = FirebaseFirestore.instance
                    .collection('Users')
                    .doc(firebaseUser.uid);
                DocumentSnapshot userDoc = await userDocRef.get();

                if (!userDoc.exists) {
                  // New User, navigate to OnboardingScreen
                  navigatorKey.currentState!.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                } else {
                  var userDoc = await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();

                  if (userDoc.data()!['deleted']) {
                    scaffoldMessengerKey.currentState!.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0,
                        duration: const Duration(seconds: 10),
                        content: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            "You have deleted your account, please allow up to 7 days before you can create an account again",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'CircularRegular'),
                          ),
                        ),
                      ),
                    );
                    await FirebaseAuth.instance.signOut();
                  } else {
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  }
                }
              }
            } catch (e) {
              scaffoldMessengerKey.currentState!.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  elevation: 0,
                  duration: const Duration(seconds: 10),
                  content: const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      "Please sign into your Apple ID in Settings > Apple ID",
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'Circular'),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class GoogleSignOption extends StatelessWidget {
  const GoogleSignOption({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          try {
            final GoogleSignIn googleSignIn = GoogleSignIn();
            final googleUser = await googleSignIn.signIn();

            if (googleUser != null) {
              final GoogleSignInAuthentication googleAuth =
                  await googleUser.authentication;
              final AuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );

              final UserCredential authResult =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              final User? firebaseUser = authResult.user;

              if (firebaseUser != null) {
                DocumentReference userDocRef = FirebaseFirestore.instance
                    .collection('Users')
                    .doc(firebaseUser.uid);
                DocumentSnapshot userDoc = await userDocRef.get();

                if (!userDoc.exists) {
                  // New User, navigate to OnboardingScreen
                  navigatorKey.currentState!.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                } else {
                  // Existing User, navigate to MainScreen
                  var userDoc = await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();
                  if (userDoc.data()!['deleted'] == true) {
                    scaffoldMessengerKey.currentState!.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0,
                        duration: const Duration(seconds: 10),
                        content: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            "You have deleted your account, please allow up to 7 days before you can create an account again",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'CircularRegular'),
                          ),
                        ),
                      ),
                    );
                    await FirebaseAuth.instance.signOut();
                  } else {
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  }
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error during sign-in: $e");
            }
          }
        },
        child: const ContinueWithGoogleWidget());
  }
}

class AutomaticSignout extends StatelessWidget {
  const AutomaticSignout({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hello $text'),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // await FirebaseAuth.instance.currentUser!.delete();
          },
          child: const Text("Sign Out"),
        )
      ],
    );
  }
}

class ContinueWithGoogleWidget extends StatelessWidget {
  const ContinueWithGoogleWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: 3, color: Theme.of(context).colorScheme.secondary),
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/google_logo.png", height: 30, width: 30),
          const SizedBox(width: 10),
          Text(
            "Continue with Google",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary),
          )
        ],
      ),
    );
  }
}

class GuestSignIn extends StatelessWidget {
  const GuestSignIn({
    super.key,
    required this.onFlagChanged,
  });

  final ValueChanged<bool> onFlagChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          bool flag = true;
          UserCredential userCredential =
              await FirebaseAuth.instance.signInAnonymously();
          User? user = userCredential.user;

          DateTime now = DateTime.now();
          String createdAt = now.toUtc().toIso8601String();

          await FirebaseUploads.createUser(
              user!.uid, "guest", createdAt, "guest", 0);

          await FirebaseFirestore.instance
              .collection("Groups")
              .doc('N9wOQ9tRUHGLunAuWUah')
              .get()
              .then((value) {
            List<dynamic> members = value.get('users');
            members.add(FirebaseAuth.instance.currentUser!.uid);
            FirebaseFirestore.instance
                .collection("Groups")
                .doc('N9wOQ9tRUHGLunAuWUah')
                .update({'guests': members});
          });
          onFlagChanged(flag);
        } catch (error) {
          if (kDebugMode) {
            print("Error signing in anonymously: $error");
          }
        }
      },
      child: Container(
        decoration: const BoxDecoration(),
        child: Text("Continue as guest",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary)),
      ),
    );
  }
}

MyGlobals myGlobals = MyGlobals();

class MyGlobals {
  late GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}
