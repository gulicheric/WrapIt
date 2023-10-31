// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AcceptGroupRequests extends StatefulWidget {
  const AcceptGroupRequests({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String groupId;

  @override
  _AcceptGroupRequestsState createState() => _AcceptGroupRequestsState();
}

class _AcceptGroupRequestsState extends State<AcceptGroupRequests> {
  late Stream<DocumentSnapshot> streamGroup;

  @override
  void initState() {
    super.initState();
    streamGroup = FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserDataStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Member Requests"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: streamGroup,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List<String> requests = List<String>.from(data['requests'] as List);

          return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: getUserDataStream(requests[index]),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    }

                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius:
                                    25.0, // Adjust the radius as needed to control the size of the circle
                                backgroundImage:
                                    NetworkImage(userData['photoUrl']),
                              ),
                              SizedBox(width: 8),
                              Text(
                                userData['username'],
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Groups')
                                      .doc(widget.groupId)
                                      .update({
                                    'requests': FieldValue.arrayRemove(
                                        [requests[index]]),
                                    'users':
                                        FieldValue.arrayUnion([requests[index]])
                                  });

                                  // remove from user's requests
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(requests[index])
                                      .update({
                                    'groups_requested':
                                        FieldValue.arrayRemove([widget.groupId])
                                  });

                                  // add to user's groups
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(requests[index])
                                      .update({
                                    'groups':
                                        FieldValue.arrayUnion([widget.groupId])
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Groups')
                                      .doc(widget.groupId)
                                      .update({
                                    'requests': FieldValue.arrayRemove(
                                        [requests[index]])
                                  });

                                  // remove from user's requests
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(requests[index])
                                      .update({
                                    'groups_requested':
                                        FieldValue.arrayRemove([widget.groupId])
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
        },
      ),
    );
  }
}
