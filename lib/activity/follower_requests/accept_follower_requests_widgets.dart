import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../profile/profile_other.dart/profile_other_screen.dart';

class FollowerRequestProfilePictureAndUsernameWidget extends StatelessWidget {
  const FollowerRequestProfilePictureAndUsernameWidget({
    super.key,
    required this.userData,
    required this.id,
  });

  final Map<String, dynamic> userData;
  final String id;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileOthers(uid: id))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: userData['photoUrl'],
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 25.0,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.grey[300],
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          SizedBox(width: 15),
          Text(
            userData['username'],
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
