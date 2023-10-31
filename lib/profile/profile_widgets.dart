// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../models/enums.dart';

ButtonStyle _getButtonStyle(
    BuildContext context, GroupRelationship relationship) {
  // Define styles for different group relationships
  switch (relationship) {
    case GroupRelationship.member:
      return ElevatedButton.styleFrom(
        primary: Colors.red, // For example, red for 'Leave' button
      );
    case GroupRelationship.requested:
      return ElevatedButton.styleFrom(
        primary: Colors.grey, // Greyed out 'Requested' button, for example
        onPrimary: Colors.black,
      );
    default: // This will be for the 'Join' button
      return ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
      );
  }
}

String _getButtonText(GroupRelationship relationship) {
  switch (relationship) {
    case GroupRelationship.member:
      return "Leave";
    case GroupRelationship.requested:
      return "Requested";
    case GroupRelationship.notMember:
    default:
      return "Join";
  }
}
