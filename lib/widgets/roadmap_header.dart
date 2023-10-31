// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class RoadmapHeader extends StatelessWidget {
  const RoadmapHeader({
    super.key,
    required this.size,
    required this.text,
    required this.count,
    required this.isSelected,
  });

  final Size size;
  final String text;
  final String count;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, top: 15, right: 15),
      padding: const EdgeInsets.only(left: 8.0, top: 7),
      width: size.width,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).accentColor : Colors.white,
          width: isSelected ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.0, top: 10),
            child: Text(
              text,
              style: TextStyle(fontSize: 17),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 30, top: 7),
            color: Theme.of(context).accentColor,
            width: 60,
            height: 30,
            child: Center(child: Text(count)),
          ),
        ],
      ),
    );
  }
}
