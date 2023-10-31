import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _usersCollection = _firestore.collection('Users');
  static final _groupsCollection = _firestore.collection('Groups');

  // Add a string to following
  static Future<void> addFollowing(String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'following': FieldValue.arrayUnion([valueToAdd])
    });
  }

  // // Remove a string from following
  static Future<void> removeFollowing(String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'following': FieldValue.arrayRemove([valueToAdd])
    });
  }

  // Add a string to following
  static Future<void> addFollowers(String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'followers': FieldValue.arrayUnion([valueToAdd])
    });
  }

  // // Remove a string from following
  static Future<void> removeFollowers(String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'followers': FieldValue.arrayRemove([valueToAdd])
    });
  }

  // Add a string to following_requested
  static Future<void> addFollowingRequested(
      String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'following_requested': FieldValue.arrayUnion([valueToAdd])
    });
  }

  // Remove a string from following_requested
  static Future<void> removeFollowingRequested(
      String userId, String valueToRemove) async {
    return _usersCollection.doc(userId).update({
      'following_requested': FieldValue.arrayRemove([valueToRemove])
    });
  }

  // Add a string to followers_requested
  static Future<void> addFollowersRequested(
      String userId, String valueToAdd) async {
    return _usersCollection.doc(userId).update({
      'followers_requested': FieldValue.arrayUnion([valueToAdd])
    });
  }

  // Remove a string from followers_requested
  static Future<void> removeFollowersRequested(
      String userId, String valueToRemove) async {
    return _usersCollection.doc(userId).update({
      'followers_requested': FieldValue.arrayRemove([valueToRemove])
    });
  }

  // Blocking a user
  static Future<void> blockUser(String userId, String valueToAdd) async {
    await _usersCollection.doc(userId).update({
      'blocked': FieldValue.arrayUnion([valueToAdd])
    });
    await _usersCollection.doc(valueToAdd).update({
      'blockedBy': FieldValue.arrayUnion([userId])
    });

    await removeFollowers(userId, valueToAdd);
    await removeFollowing(userId, valueToAdd);
    await removeFollowers(valueToAdd, userId);
    await removeFollowing(valueToAdd, userId);
  }
}
