import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tefillin/models/comment_model.dart';
import 'package:tefillin/models/comment_notification_model.dart';

class FirebaseUploads {
  static Future<void> createUser(
    String userDocRef,
    String username,
    String createdAt,
    String currentUserPhoto,
    int age,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userDocRef).set({
        'username': username,
        'createdAt': createdAt,
        'following': [],
        'followers': [],
        'posts': [],
        'photoUrl': currentUserPhoto,
        'streak': 0,
        'groups': [],
        'age': age,
        'blocked': [],
        'blockedBy': [],
        'deleted': false,
        'followers_requested': [],
        'following_requested': [],
        'groups_requested': [],
        'largest_streak': 0,
        'settings': {
          'isCalendarPublicToAll': true,
          'isCalendarPublicToFriends': true,
          'isTefillinHelpRequired': true,
        },
      });
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  static Future<void> uploadComment(CommentModel comment, String postId,
      String postUrl, String personWhoPostedThePicture) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection("Comments")
          .doc(); // This creates a new document reference with a unique ID

      // Step 2: Set the data in the new document, including its ID
      await docRef.set({
        'id': docRef.id, // Set the document's ID
        'text': comment.text,
        'createdAt': comment.createdAt,
        'likes': comment.likes,
        'username': comment.username,
        'photoUrl': comment.photoUrl,
      });

      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .update({'numberOfComments': FieldValue.increment(1)});

      DocumentReference notificationRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(personWhoPostedThePicture)
          .collection("Activity")
          .doc();

      DateTime utcTime = DateTime.now().toUtc();

      // 2. Convert UTC time to Eastern Time Zone (ET is UTC-5 but can be UTC-4 due to daylight saving, so you may need to adjust accordingly)
      DateTime easternTime = utcTime.subtract(Duration(hours: 5));

      var notificationComment = CommentNotificationModel(
        id: notificationRef.id,
        userId: FirebaseAuth.instance.currentUser!.uid,
        postId: postId,
        comment: comment.text,
        userPhotoUrl: comment.photoUrl,
        username: comment.username,
        postPhotoUrl: postUrl,
        timestamp: Timestamp.fromDate(easternTime),
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(personWhoPostedThePicture)
          .collection("Activity")
          .doc(notificationRef.id)
          .set(notificationComment.toMap());
    } catch (e) {
      print('Error uploading comment: $e');
    }
  }
}
