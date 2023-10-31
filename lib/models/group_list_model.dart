import 'enums.dart';

class GroupListModel {
  final String id;
  final String profilePicture;
  final String username;
  final GroupRelationship groupRelationship;
  final int priority;
  final bool isAdmin;

  GroupListModel({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.groupRelationship,
    required this.priority,
    required this.isAdmin,
  });

  factory GroupListModel.fromMap(Map<String, dynamic> data) {
    return GroupListModel(
      id: data['id'],
      username: data['username'],
      profilePicture: data['profilePicture'],
      groupRelationship: data['groupRelationship'],
      priority: data['priority'],
      isAdmin: data['isAdmin'],
    );
  }
}
