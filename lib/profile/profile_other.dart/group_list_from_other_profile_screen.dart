import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../models/enums.dart';
import '../../models/group_list_model.dart';
import '../group_list.dart';

class GroupListFromOtherScreen extends StatefulWidget {
  const GroupListFromOtherScreen({super.key, required this.uid});

  final String uid;

  @override
  State<GroupListFromOtherScreen> createState() =>
      _GroupListFromOtherScreenState();
}

class _GroupListFromOtherScreenState extends State<GroupListFromOtherScreen> {
  late Future<List<GroupListModel>> groupListInfomartion;
  Map<String, GroupRelationship> isGroup = {};

  Future<List<GroupListModel>> getGroupListInformation() async {
    List<GroupListModel> result = [];

    var groups = await FirebaseFirestore.instance.collection('Groups').get();
    for (var group in groups.docs) {
      ;
      if (group.get("approved")) {
        var groupData = group.data();
        var currentUserUid = widget.uid;

        // bool isAdmin = groupData['admin'].contains(currentUserUid);
        bool isUserMember = groupData['users'].contains(currentUserUid);
        // bool hasRequested = groupData['requests'].contains(currentUserUid);

        if (isUserMember) {
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
            isAdmin: true,
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
                        // await _toggleGroupMembership(group);
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
