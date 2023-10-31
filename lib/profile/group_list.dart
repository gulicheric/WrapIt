// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tefillin/models/enums.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/groups/group_page.dart';
import 'package:tefillin/profile/profile_widgets.dart';

import '../models/group_list_model.dart';

class GroupList extends StatefulWidget {
  final String uid;

  const GroupList({super.key, required this.uid});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, GroupRelationship> isGroup = {};
  late Future<List<GroupListModel>> groupListInfomartion;
  late GroupRelationship relationshipType;

  Future<void> _toggleGroupMembership(GroupListModel group) async {
    GroupRelationship currentlyGroup = isGroup[group.id]!;

    if (currentlyGroup == GroupRelationship.member) {
      // remove group from groups in Users
      await _firestore.collection('Users').doc(_auth.currentUser?.uid).update({
        'groups': FieldValue.arrayRemove([group.id])
      });

      // remove user from users in Groups
      await _firestore.collection('Groups').doc(group.id).update({
        'users': FieldValue.arrayRemove([_auth.currentUser?.uid])
      });

      isGroup[group.id] = GroupRelationship.notMember;
    } else if (currentlyGroup == GroupRelationship.requested) {
      // remove users from requests in Groups
      await _firestore.collection('Groups').doc(group.id).update({
        'requests': FieldValue.arrayRemove([_auth.currentUser!.uid])
      });

      // remove from groups_requested in Users
      await _firestore.collection('Users').doc(_auth.currentUser?.uid).update({
        'groups_requested': FieldValue.arrayRemove([group.id])
      });

      isGroup[group.id] = GroupRelationship.notMember;
    } else {
      // Join the group
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(group.id)
          .update({
        'requests': FieldValue.arrayUnion([_auth.currentUser!.uid])
      });

      // add to groups_requested in Users
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser?.uid)
          .update({
        'groups_requested': FieldValue.arrayUnion([group.id])
      });

      isGroup[group.id] = GroupRelationship.requested;
    }
  }

  Future<List<GroupListModel>> getGroupListInformation() async {
    List<GroupListModel> result = [];

    var groups = await FirebaseFirestore.instance.collection('Groups').get();

    for (var group in groups.docs) {
      if (group.get("approved")) {
        var groupData = group.data();
        var currentUserUid = _auth.currentUser?.uid;

        bool isAdmin = groupData['admin'].contains(currentUserUid);
        bool isUserMember = groupData['users'].contains(currentUserUid);
        bool hasRequested = groupData['requests'].contains(currentUserUid);

        if (isUserMember || hasRequested) {
          GroupRelationship relationship = isUserMember
              ? GroupRelationship.member
              : GroupRelationship.requested;

          int priority = isUserMember ? 1 : 0;
          isGroup[group.id] = relationship;

          result.add(GroupListModel(
            id: group.id,
            profilePicture: groupData['groupPictureUrl'],
            username: groupData['name'],
            groupRelationship: relationship,
            priority: priority,
            isAdmin: isAdmin,
          ));
        }
      }
    }

    // Sort by priority
    result.sort((a, b) => b.priority.compareTo(a.priority));

    return result;
  }

  @override
  void initState() {
    super.initState();
    groupListInfomartion = getGroupListInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<GroupListModel>>(
          future: groupListInfomartion,
          builder: (BuildContext context,
              AsyncSnapshot<List<GroupListModel>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  var group = snapshot.data![index];
                  if (group.groupRelationship == GroupRelationship.member ||
                      group.groupRelationship == GroupRelationship.requested) {
                    return GroupListItem(
                      group: group,
                      onActionButtonPressed: () async {
                        await _toggleGroupMembership(group);
                        setState(() {});
                      },
                      groupRelationshipType: isGroup[group.id]!,
                    );
                  }

                  return Container();
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class GroupListItem extends StatelessWidget {
  final GroupListModel group;
  // final bool isMember;
  final Function onActionButtonPressed;
  final GroupRelationship groupRelationshipType;

  const GroupListItem({
    super.key,
    required this.group,
    // required this.isMember,
    required this.onActionButtonPressed,
    required this.groupRelationshipType,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(left: 15.0, top: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => GroupPage(groupId: group.id)),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(group.profilePicture),
                ),
                SizedBox(width: 12.0),
                SizedBox(
                  width: size.width * 0.4,
                  child: Text(
                    group.username,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          if (!group.isAdmin)
            ElevatedButton(
              onPressed: () => onActionButtonPressed(),
              style: _getButtonStyle(context, groupRelationshipType),
              child: Text(_getButtonText(groupRelationshipType)),
            ),
        ],
      ),
    );
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

  ButtonStyle _getButtonStyle(
      BuildContext context, GroupRelationship relationship) {
    // Define styles for different group relationships
    switch (relationship) {
      case GroupRelationship.member:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // For example, red for 'Leave' button
        );
      case GroupRelationship.requested:
        return ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(
              255, 93, 18, 54), // Greyed out 'Requested' button, for example
        );
      default: // This will be for the 'Join' button
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).accentColor,
        );
    }
  }
}
