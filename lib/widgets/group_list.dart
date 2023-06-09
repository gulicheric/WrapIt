// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/widgets/group_page.dart';
import 'package:tefillin/widgets/submit_button.dart';

class GroupsMainPage extends StatefulWidget {
  const GroupsMainPage({Key? key}) : super(key: key);

  @override
  State<GroupsMainPage> createState() => _GroupsMainPageState();
}

class _GroupsMainPageState extends State<GroupsMainPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<QuerySnapshot> _groupsFuture;
  List<bool> requested = List.filled(100000, false);
  int _selectedImageIndex = -1;
  String _selectedImageUrl = '';
  int selectedTab = 0;
  final List<String> imageUrlList = [
    'https://images.unsplash.com/photo-1680695920053-cb155ad082e8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1680441774216-8a86795a687f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80',
    'https://plus.unsplash.com/premium_photo-1680035238547-bfe1c1fe81a4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1681101378971-5f5dc4e5000e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2714&q=80',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/Untitled%202.jpg?alt=media&token=b39b7120-a77f-4630-bafa-fdf910630ec3&_gl=1*7rs8pf*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0MTguMC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/midj1.jpg?alt=media&token=b1bfbd1c-49a7-4c28-b07d-8d76f969a956&_gl=1*y28k1i*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0NDMuMC4wLjA.',
  ];

  @override
  void initState() {
    super.initState();
    _groupsFuture = fetchData();
  }

  Future<QuerySnapshot> fetchData() {
    return FirebaseFirestore.instance.collection('Groups').get();
  }

  Future<List<DocumentSnapshot>> getUserGroups() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Groups')
        .where('users', arrayContains: currentUserId)
        .get();

    return snapshot.docs;
  }

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget _buildSubmitButton(
        BuildContext context, TextEditingController nameController) {
      return GestureDetector(
        onTap: () async {
          if (nameController.text.isNotEmpty) {
            final QuerySnapshot result = await FirebaseFirestore.instance
                .collection('Groups')
                .where('name', isEqualTo: nameController.text)
                .limit(1)
                .get();

            final List<DocumentSnapshot> documents = result.docs;
            if (documents.length == 1) {
              // Group with the same name already exists
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      'Group name already exists. Please choose a different name.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    elevation: 0,
                    backgroundColor: Color.fromARGB(255, 141, 140, 140),
                    actions: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue.withOpacity(0.5);
                              } else {
                                return Colors.blue;
                              }
                            },
                          ), foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue.withOpacity(0.5);
                              } else {
                                return Colors.white;
                              }
                            },
                          )),
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  );
                },
              );

              return;
            }

            // Group with the same name does not exist, show dialog for confirmation
            showDialog(
              context: context,
              builder: (BuildContext context) {
                print("hfadsfasdfasii");
                return AlertDialog(
                  elevation: 0,
                  title: Text('Confirmation'),
                  content: Text('Are you sure you want to create this group?'),
                  actions: [
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () async {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        // Create Group
                        await FirebaseFirestore.instance
                            .collection('Groups')
                            .add({
                          'admin': [uid],
                          'createdOn': Timestamp.now(),
                          'name': nameController.text,
                          'requests': [],
                          'users': [uid],
                          'groupPictureUrl': _selectedImageUrl,
                        });

                        // Refetch data from Firebase
                        _groupsFuture = fetchData();

                        // Update state
                        if (mounted) {
                          setState(() {});
                        }

                        // Now pop the context
                        Navigator.of(context).pop();

                        // Close the modal bottom sheet
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter group name')),
            );
          }
        },
        child: SubmitButton(text: 'Create Group'),
      );
    }

    Widget _buildModalDivider(BuildContext context) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .42,
          vertical: 15,
        ),
        child: Container(
          height: 5.0, // the same as the thickness of your previous Divider
          decoration: BoxDecoration(
            color: Color.fromARGB(93, 255, 255, 255),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0)), // adjust the radius as per your needs
          ),
        ),
      );
    }

    Padding _buildGroupNameField(TextEditingController nameController,
        BuildContext context, StateSetter setState) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Group',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please enter a name for the group and choose an icon. In the future update, you will be able to upload your own images for the icon.',
              style: TextStyle(
                color: Color.fromARGB(135, 255, 255, 255),
                fontSize: 13,
                // fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30), //
            Text(
              'Group Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10), // Spacer
            Container(
              height: 40,
              child: TextField(
                controller: nameController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30), //
            Text(
              'Group Icon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 120, // specify the height here
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal, // Makes the ListView horizontal
                itemCount: imageUrlList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                        _selectedImageUrl = imageUrlList[index];
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (_selectedImageIndex == index)
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            imageUrlList[index],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    void _showAddGroupModal(BuildContext context) {
      showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
            // <-- Add this
            builder: (BuildContext context, StateSetter setState) {
              // <-- And modify this
              return Container(
                padding: EdgeInsets.only(bottom: 80),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 36, 36, 36),
                  // Set the background color to black
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30), // Radius for top left
                    topRight: Radius.circular(30), // Radius for top right
                  ),
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  child: Column(
                    children: [
                      _buildModalDivider(context),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildGroupNameField(nameController, context,
                                setState), // <-- And pass setState here
                            _buildSubmitButton(context, nameController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 3),
            child: GestureDetector(
              onTap: () => _showAddGroupModal(context),
              child: Icon(
                Icons.group_add,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: selectedTab == index
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the radius value as needed
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (index == 0) ? Icons.group_sharp : Icons.explore,
                          color: Colors.white,
                          size: 18, // Adjust the size value as needed
                        ),
                        SizedBox(width: 5),
                        Text(
                          (index == 0) ? "Your Pages" : "Explore",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13, // Adjust the fontSize value as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedTab == 1)
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _groupsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  // Current user's id
                  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  // Filter out groups where the current user is already a member
                  List<DocumentSnapshot> filteredGroups = snapshot.data!.docs
                      .where((group) => !group['users'].contains(currentUserId))
                      .toList();

                  List<bool> requested =
                      List.filled(filteredGroups.length, false);

                  return GridView.builder(
                    itemCount: filteredGroups.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Specifies the number of columns
                      crossAxisSpacing:
                          10, // Specifies the spacing along the cross-axis.
                      mainAxisSpacing:
                          1.0, // Specifies the spacing along the main-axis.
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot group = filteredGroups[index];
                      List<dynamic> users = group['users'];
                      List<dynamic> admin = group['admin'];

                      // Current user's id
                      String currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;

                      // If the current user is in the group, don't render the group.
                      if (users.contains(currentUserId)) {
                        return Container();
                      }

                      if (admin.isEmpty) {
                        return Text('No Admin');
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(admin[0])
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> adminSnapshot) {
                          if (adminSnapshot.hasError) {
                            return Text("Error: ${adminSnapshot.error}");
                          }
                          if (adminSnapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic>? adminData = adminSnapshot.data
                                ?.data() as Map<String, dynamic>?;
                            if (adminData == null) {
                              return Text('Admin User not found');
                            }

                            if (group['requests'].contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              requested[index] = true;
                            }

                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  StateSetter localSetState) {
                                return Container(
                                    margin: EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          12.0), // Adjust the border radius as needed
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(12.0),
                                                  topRight:
                                                      Radius.circular(12.0),
                                                ),
                                                child: Image.network(
                                                  imageUrlList[index],
                                                  fit: BoxFit.fitWidth,
                                                  width: size.width * .6,
                                                  height: 100,
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  group['name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child:
                                                    Text(adminData['username']),
                                              ),
                                              SizedBox(height: 4),
                                              (users.length == 1)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          '${users.length} Member'),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          '${users.length} Members')),
                                              SizedBox(height: 15),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              localSetState(() {
                                                requested[index] = !requested[
                                                    index]; // Invert the requested status
                                              });

                                              if (requested[index]) {
                                                await FirebaseFirestore.instance
                                                    .collection('Groups')
                                                    .doc(group.id)
                                                    .update({
                                                  'requests':
                                                      FieldValue.arrayUnion([
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                  ])
                                                });
                                              } else {
                                                await FirebaseFirestore.instance
                                                    .collection('Groups')
                                                    .doc(group.id)
                                                    .update({
                                                  'requests':
                                                      FieldValue.arrayRemove([
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                  ])
                                                });
                                              }
                                            },
                                            child: Center(
                                              child: Container(
                                                width: size.width * .4,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                decoration: BoxDecoration(
                                                  color: requested[index]
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Text(
                                                  requested[index]
                                                      ? "Requested"
                                                      : "Join",
                                                  style: TextStyle(
                                                    color: requested[index]
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          )
                                        ]));
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          if (selectedTab == 0)
            FutureBuilder<List<DocumentSnapshot>>(
              future: getUserGroups(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data![index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      bool isAdmin =
                          (data['admin'] as List).contains(currentUserId);
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupPage(groupId: doc.id),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0, right: 15),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        data['groupPictureUrl'],
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        (data['users'].length == 1)
                                            ? Text(
                                                '${data['users'].length} Member')
                                            : Text(
                                                '${data['users'].length} Members'),
                                      ],
                                    ),
                                    SizedBox(width: 30),
                                    if (isAdmin)
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).accentColor,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Text('Admin')),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
