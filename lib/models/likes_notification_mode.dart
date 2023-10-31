import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tefillin/models/enums.dart';

class LikesNotificationModel {
  final String id;
  final String userId;
  final String userPhotoUrl;
  final String username;
  final String postPhotoUrl;
  final String postId;
  final Timestamp timestamp;
  final seen = false;
  final ActivityType type = ActivityType.like;

  LikesNotificationModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.userPhotoUrl,
    required this.username,
    required this.postPhotoUrl,
    required this.timestamp,
  });

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'userPhotoUrl': userPhotoUrl,
      'username': username,
      'postPhotoUrl': postPhotoUrl,
      'timestamp': timestamp,
      'seen': seen,
      'type': type.displayValue,
    };
  }
}
