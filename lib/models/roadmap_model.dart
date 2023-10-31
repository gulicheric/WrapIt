import 'package:flutter/foundation.dart';

import 'enums.dart';

class RoadMapModel {
  final String title;
  final String description;
  final Progress progress;
  final RoadMapType roadmapType;
  final List<String> votes;
  final bool requestApproved = false;

  RoadMapModel({
    required this.title,
    required this.description,
    required this.progress,
    required this.roadmapType,
    required this.votes,
  });

  // add to map function
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'progress': describeEnum(progress), // Convert enum to string
      'roadmapType': describeEnum(roadmapType), // Convert enum to string
      'votes': votes,
      'request_approved': false
    };
  }

  // create fromMap function
  factory RoadMapModel.fromMap(Map<String, dynamic> map) {
    return RoadMapModel(
      title: map['title'],
      description: map['description'],
      progress: Progress.values
          .firstWhere((element) => describeEnum(element) == map['progress']),
      votes: List<String>.from(map['votes']),
      roadmapType: RoadMapType.values
          .firstWhere((element) => describeEnum(element) == map['roadmapType']),
    );
  }
}
