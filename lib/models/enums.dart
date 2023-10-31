import 'dart:ui';

import 'package:flutter/material.dart';

enum Progress {
  notStarted,
  inProgress,
  completed,
}

enum RoadMapType {
  fetureRequest,
  bugReport,
}

enum GroupRelationship {
  member,
  requested,
  notMember,
}

enum ActivityType {
  comment,
  like,
}

// make toString for ActivityType
extension ActivityTypeExtension on ActivityType {
  String get displayValue {
    switch (this) {
      case ActivityType.comment:
        return "comment";
      case ActivityType.like:
        return "like";
      default:
        return "";
    }
  }
}

// extensions

extension ProgressExtension on Progress {
  String get displayValue {
    switch (this) {
      case Progress.notStarted:
        return "Not Started";
      case Progress.inProgress:
        return "In Progress";
      case Progress.completed:
        return "Completed";
      default:
        return "";
    }
  }
}

Color getColorFromProgress(Progress progress) {
  switch (progress) {
    case Progress.notStarted:
      return const Color.fromARGB(255, 185, 102, 0); // Example color
    case Progress.inProgress:
      return Color.fromARGB(255, 22, 131, 194); // Example color
    case Progress.completed:
      return const Color.fromARGB(255, 0, 128, 0); // Example color
    default:
      return Colors.grey; // Default color
  }
}
