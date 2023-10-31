// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/widgets/submit_button.dart';

import '../widgets/alert.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  int _selectedImageIndex = -1;
  String _selectedImageUrl = '';
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final List<String> imageUrlList = [
    'https://images.unsplash.com/photo-1680695920053-cb155ad082e8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1680441774216-8a86795a687f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80',
    'https://plus.unsplash.com/premium_photo-1680035238547-bfe1c1fe81a4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
    'https://images.unsplash.com/photo-1681101378971-5f5dc4e5000e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2714&q=80',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/Untitled%202.jpg?alt=media&token=b39b7120-a77f-4630-bafa-fdf910630ec3&_gl=1*7rs8pf*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0MTguMC4wLjA.',
    'https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/midj1.jpg?alt=media&token=b1bfbd1c-49a7-4c28-b07d-8d76f969a956&_gl=1*y28k1i*_ga*NzM3Mjg2NTg0LjE2NzU2MTkyODA.*_ga_CW55HF8NVT*MTY4NTkyMzM5NS42My4xLjE2ODU5MjM0NDMuMC4wLjA.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close), // This is the 'X' icon
          onPressed: () {
            Navigator.of(context)
                .pop(); // This will close the current screen/page
          },
        ),
        automaticallyImplyLeading: false,
        title: Text("Create Group"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Please enter a name for the group and choose an icon. In the future update, you will be able to upload your own images for the icon.',
              //   style: TextStyle(
              //     color: Color.fromARGB(135, 255, 255, 255),
              //     fontSize: 13,
              //     // fontWeight: FontWeight.bold,
              //   ),
              // ),

              Text(
                'Group Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10), // Spacer
              SizedBox(
                height: 80,
                child: TextField(
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
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
              SizedBox(height: 5), //
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
              SizedBox(height: 10),
              Text(
                'Please choose one of these pictures. You can upload your own pictures in setings',
                style: TextStyle(
                  color: Color.fromARGB(135, 255, 255, 255),
                  fontSize: 13,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Reason for creating this group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),

              // New TextField for entering the reason
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  // Adjust the height to fit 5 lines of text
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      // Dismiss the keyboard when the user taps the "Done" button
                      FocusScope.of(context).unfocus();
                    },
                    controller: reasonController, // <-- Use the new controller
                    maxLines: 7, // <-- Allow up to 5 lines
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        // <-- This changes the border when in focus
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 3,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  'We will review the submission within 24 hours',
                  style: TextStyle(
                    color: Color.fromARGB(135, 255, 255, 255),
                    fontSize: 13,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () async {
                  if (nameController.text.isNotEmpty) {
                    final QuerySnapshot result = await FirebaseFirestore
                        .instance
                        .collection('Groups')
                        .where('name', isEqualTo: nameController.text)
                        .limit(1)
                        .get();

                    final List<DocumentSnapshot> documents = result.docs;

                    // if the group name already exists, display a message telling them
                    // to make a new name
                    if (documents.length == 1) {
                      // Group with the same name already exists
                      showCustomDialog(context,
                          'Group name already exists. Please choose a different name.');
                      return;
                    }

                    // if the reason is empty, add alert
                    if (reasonController.text.isEmpty) {
                      // Group with the same name already exists
                      showCustomDialog(
                          context, 'Please make sure to add a reason');
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
                          content: Text(
                              'Are you sure you want to create this group?'),
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
                                if (_selectedImageUrl == "") {
                                  _selectedImageUrl =
                                      "https://firebasestorage.googleapis.com/v0/b/tefillin-7f1b5.appspot.com/o/unkown_person.jpeg?alt=media&token=5543db98-b1e0-4b7e-89d8-c4c6d8afdc8d&_gl=1*1btaye*_ga*MTMxOTQ5MzE2OC4xNjgyNTE4NDcx*_ga_CW55HF8NVT*MTY5NjM4OTUxNC43Ni4xLjE2OTYzOTAwMDguNDIuMC4w";
                                }

                                String uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                // Create Group
                                final groupId = await FirebaseFirestore.instance
                                    .collection('Groups')
                                    .add({
                                  'admin': [uid],
                                  'createdOn': Timestamp.now(),
                                  'name': nameController.text,
                                  'requests': [],
                                  'users': [uid],
                                  'groupPictureUrl': _selectedImageUrl,
                                  'reason': reasonController.text,
                                  'approved': false
                                });

                                // add the group to the user's groups
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(uid)
                                    .update({
                                  'groups': FieldValue.arrayUnion([groupId.id])
                                });

                                // Now pop the context
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
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
                child: SubmitButton(text: "Request Group"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
