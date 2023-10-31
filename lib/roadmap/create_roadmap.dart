// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/main.dart';
import 'package:tefillin/models/enums.dart';
import 'package:tefillin/models/roadmap_model.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:tefillin/widgets/submit_button.dart';

class CreateRoadMapScreen extends StatefulWidget {
  const CreateRoadMapScreen({super.key});

  @override
  State<CreateRoadMapScreen> createState() => _CreateRoadMapScreenState();
}

class _CreateRoadMapScreenState extends State<CreateRoadMapScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedValue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create request"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 100,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      textInputAction: TextInputAction.done,
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 10,
                      maxLength: 1000,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Type of request:",
                      style: TextStyle(fontSize: 18),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Feature Request'),
                      leading: Radio<int>(
                        value: 1,
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bug'),
                      leading: Radio<int>(
                        value: 2,
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 40),
                child: GestureDetector(
                    onTap: () async {
                      if (_selectedValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a type of request.'),
                          ),
                        );
                      } else if (_titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please Enter a title and description.'),
                          ),
                        );
                      } else {
                        RoadMapModel roadmapRequest = RoadMapModel(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          progress: Progress.notStarted,
                          votes: [],
                          roadmapType: (_selectedValue == 1)
                              ? RoadMapType.fetureRequest
                              : RoadMapType.bugReport,
                        );
                        await FirebaseFirestore.instance
                            .collection("Roadmap")
                            .add(roadmapRequest.toMap());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request created!'),
                          ),
                        );

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                          (Route<dynamic> route) =>
                              false, // never return true, all routes are removed
                        );
                      }
                    },
                    child: const SubmitButton(
                      text: 'Sumbit',
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
