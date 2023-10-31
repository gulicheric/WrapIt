// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import '../roadmap/roadmap_screen.dart';

class RoadmapContainer extends StatelessWidget {
  final Size size;

  const RoadmapContainer({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoadMapScreen(),
            ),
          );
        },
        child: Container(
            // add rounded borders
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(
                        0.5), // You can adjust the shadow color here
                    spreadRadius: 2, // Spread radius
                    blurRadius: 7, // Blur radius
                    offset: Offset(2, 1), // Offset in the X and Y directions
                  ),
                ],
                color: Theme.of(context).accentColor.withOpacity(.7),
                border: Border.all(),
                borderRadius: BorderRadius.circular(
                    10.0) // This adds a border radius of 10 units
                ),
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 12),
                        child: Text(
                          "Have an idea or problem?",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Let us know & see our roadmap!",
                            style: TextStyle(fontSize: 14)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 12.0),
                        child: Text(
                            "This is a beta version, so it is important for you to provide as much feedback as possible",
                            style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text("→", style: TextStyle(fontSize: 30)),
                ),
              ],
            )),
      ),
    );
  }
}
