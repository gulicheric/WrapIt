import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseGroupHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _groupsCollection = _firestore.collection('Groups');
  static final _usersCollection = _firestore.collection('Users');

  static Future<DocumentSnapshot> getGroup(String groupId) async {
    return _groupsCollection.doc(groupId).get();
  }

  static Future<void> removeUserFromGroup(String groupId, String uid) async {
    return _groupsCollection.doc(groupId).update({
      'users': FieldValue.arrayRemove([uid]),
    });
  }

  static Future<void> removeAdminFromGroup(String groupId, String uid) async {
    return _groupsCollection.doc(groupId).update({
      'admins': FieldValue.arrayRemove([uid]),
    });
  }

  static Future<void> removeGroupFromUser(String groupId, String uid) async {
    return _usersCollection.doc(uid).update({
      'groups': FieldValue.arrayRemove([groupId]),
    });
  }
}
