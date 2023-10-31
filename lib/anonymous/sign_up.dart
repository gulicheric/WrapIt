import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/onboarding/onboarding_screen.dart';
import 'package:tefillin/widgets/submit_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SignUpButton(size: size));
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    required this.size,
    this.vertical = 0,
    this.text = "Sign up!",
  });

  final Size size;
  final double vertical;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      margin: EdgeInsets.symmetric(vertical: vertical),
      // padding: EdgeInsets.symmetric(horizontal: size.width * .2),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        ),
        child: SubmitButton(text: text),
      ),
    ));
  }
}
