import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tefillin/profile/profile_other.dart/profile_other_screen.dart';
import 'package:tefillin/profile/profile_page.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key, required this.users});

  final List<String> users;

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  get currentUser => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.only(top: 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2 / 2.5,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return StreamBuilder<DocumentSnapshot>(
                stream: getUserDataStream(widget.users[index]),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  if (userData['username'] == 'guest') {
                    return Container(); // Return an empty container for users with username "guest"
                  }

                  return GestureDetector(
                      onTap: () {
                        if (currentUser == widget.users[index]) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileOthers(uid: widget.users[index]),
                            ),
                          );
                        }
                      },
                      child: Container(
                        // color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            CachedNetworkImage(
                              imageUrl: userData['photoUrl'],
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 40.0,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${userData['username']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
            childCount: widget.users.length,
          ),
        ));
  }
}
