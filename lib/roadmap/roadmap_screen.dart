// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/models/roadmap_model.dart';
import 'package:tefillin/roadmap/create_roadmap.dart';
import 'package:tefillin/roadmap/roadmap_util.dart';
import 'package:tefillin/roadmap/roadmap_widgets.dart';
import 'package:tefillin/widgets/roadmap_header.dart';

class RoadMapScreen extends StatefulWidget {
  const RoadMapScreen({super.key});

  @override
  State<RoadMapScreen> createState() => _RoadMapScreenState();
}

class _RoadMapScreenState extends State<RoadMapScreen> {
  bool isFeatureRequestSelected = true;
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Roadmap'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 33,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRoadMapScreen(),
                  ),
                );
              },
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              FutureBuilder<Map<String, int>>(
                future: getRoadmapVotes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Container(
                    margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10, right: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            decoration: BoxDecoration(
                              color: selectedTab == index
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(
                                  30), // Adjust the radius value as needed
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 5),
                                Text(
                                  (index == 0)
                                      ? "Feature Requests (${snapshot.data!['featureRequest'].toString()})"
                                      : "Bugs (${snapshot.data!['bug'].toString()})",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        13, // Adjust the fontSize value as needed
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              if (selectedTab == 0) RoadmapFeatureListWidget(),
              if (selectedTab == 1) RoadmapBugListWidget()
            ],
          ),
        )

        // body:
        );
  }
}
