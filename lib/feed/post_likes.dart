import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';

class PostLikes extends StatefulWidget {
  const PostLikes({super.key, required this.likesList});

  final List<String> likesList;

  @override
  State<PostLikes> createState() => _PostLikesState();
}

class _PostLikesState extends State<PostLikes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Likes"),
          backgroundColor: Colors.transparent,
        ),
        body: FutureBuilder(
          future: Future.wait(
            widget.likesList.map(
              (e) =>
                  FirebaseFirestore.instance.collection('Users').doc(e).get(),
            ),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileOthers(uid: user.id),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.get('photoUrl'),
                      ),
                    ),
                    title: Text(user.get('username')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
