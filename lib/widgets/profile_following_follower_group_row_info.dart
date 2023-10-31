import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final int followingCount;
  final int followersCount;
  final int groupsCount;
  final Function onTapFollowing;
  final Function onTapFollowers;
  final Function onTapGroups;

  InfoRow({
    required this.followingCount,
    required this.followersCount,
    required this.groupsCount,
    required this.onTapFollowing,
    required this.onTapFollowers,
    required this.onTapGroups,
  });

  Widget buildInfoRow(int count, String label, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 14, fontFamily: 'CircularBlack'),
            ),
          ),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildInfoRow(followingCount, "Following", onTapFollowing),
        SizedBox(width: 10),
        buildInfoRow(followersCount, "Followers", onTapFollowers),
        SizedBox(width: 10),
        buildInfoRow(groupsCount, "Groups", onTapGroups),
      ],
    );
  }
}
