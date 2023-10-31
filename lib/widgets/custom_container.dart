import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;

  CustomContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
        width: size.width * .9,
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          border: Border.all(),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: child,
        ));
  }
}
