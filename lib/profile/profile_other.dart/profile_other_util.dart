import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, bool>> isUserFollowing(
    String currentUserUID, String targetUserUID) async {
  Map<String, bool> result = {'isFollowing': false, 'isRequested': false};

  try {
    // Fetch the document for the current user
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserUID)
        .get();

    // Check if the document exists and contains the 'following' field
    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Check if the user is following the target user
      if (data.containsKey('following')) {
        List<dynamic> followingList = data['following'];
        result['isFollowing'] = followingList.contains(targetUserUID);
      }

      if (data.containsKey('following_requested')) {
        List<dynamic> followingRequestedList = data['following_requested'];
        result['isRequested'] = followingRequestedList.contains(targetUserUID);
      }
    }
  } catch (e) {
    print("An error occurred: $e");
  }

  return result;
}
