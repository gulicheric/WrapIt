// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/models/enums.dart';
import 'package:tefillin/models/roadmap_model.dart';

class RoadmapFeatureListWidget extends StatelessWidget {
  const RoadmapFeatureListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Roadmap')
          .where("roadmapType", isEqualTo: "fetureRequest")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        }

        final roadmapDocs = snapshot.data!.docs;
        return Expanded(
          child: ListView.builder(
            itemCount: roadmapDocs.length,
            itemBuilder: (context, index) {
              final roadmapDoc = roadmapDocs[index];
              final roadmap = RoadMapModel.fromMap(
                  roadmapDoc.data() as Map<String, dynamic>);
              return RoadmapItem(
                roadmap: roadmap,
                roadmapId: roadmapDoc.id,
              );
            },
          ),
        );
      },
    );
  }
}

class RoadmapBugListWidget extends StatelessWidget {
  const RoadmapBugListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Roadmap')
          .where("roadmapType", isEqualTo: "bugReport")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingWidget();
        }

        final roadmapDocs = snapshot.data!.docs;

        return Expanded(
          child: ListView.builder(
            itemCount: roadmapDocs.length,
            itemBuilder: (context, index) {
              final roadmapDoc = roadmapDocs[index];
              final roadmap = RoadMapModel.fromMap(
                  roadmapDoc.data() as Map<String, dynamic>);
              return RoadmapItem(
                roadmap: roadmap,
                roadmapId: roadmapDoc.id,
              );
            },
          ),
        );
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class RoadmapItem extends StatelessWidget {
  final RoadMapModel roadmap;
  final String roadmapId;

  const RoadmapItem(
      {super.key, required this.roadmap, required this.roadmapId});

  @override
  Widget build(BuildContext context) {
    final USERID = FirebaseAuth.instance.currentUser!.uid;
    var size = MediaQuery.of(context).size;
    final title = roadmap.title.length > 50
        ? '${roadmap.title.substring(0, 50)}...'
        : roadmap.title;
    final description = roadmap.description;
    final votes = roadmap.votes.length;
    final progress = roadmap.progress;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.only(left: 15.0, top: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: getColorFromProgress(progress),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(progress.displayValue,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 10),
                    child: Text(title, style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 10, bottom: 10),
                    child:
                        Text(description, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  // if user has not voted, add vote
                  if (!roadmap.votes.contains(USERID)) {
                    await FirebaseFirestore.instance
                        .collection('Roadmap')
                        .doc(roadmapId)
                        .update({
                      'votes': FieldValue.arrayUnion([USERID])
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('Roadmap')
                        .doc(roadmapId)
                        .update({
                      'votes': FieldValue.arrayRemove([USERID])
                    });
                  }
                },

                // if user has voted, make arrow green
                child: roadmap.votes.contains(USERID)
                    ? Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.arrow_upward_outlined,
                            size: 40, color: Theme.of(context).accentColor),
                      )
                    : Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.arrow_upward_outlined, size: 40),
                      ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(votes.toString(),
                    style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
