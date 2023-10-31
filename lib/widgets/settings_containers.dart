import 'package:flutter/material.dart';

class SettingsContainer extends StatelessWidget {
  final String text;

  const SettingsContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.1),
        border: Border.all(),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.arrow_forward_ios, size: 20),
          ),
        ],
      ),
    );
  }
}
