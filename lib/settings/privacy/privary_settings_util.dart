import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tefillin/models/privacy_setting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tefillin/models/privacy_setting_model.dart';

Future<List<PrivacySettingModel>> getPrivacySettings(
    String userId, List<PrivacySettingModel> privacySettingModelList) async {
  // Get privacy settings from firestore for a specific user
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(userId).get();

  if (!userDoc.exists) {
    // If the user doesn't exist, perhaps throw an error or handle appropriately
    throw Exception('User not found');
  }

  // Access the 'settings' map from the user document
  var data = userDoc.data() as Map<String, dynamic>;
  print(data['settings']);
  Map<String, dynamic> settingsMap = data['settings'] as Map<String, dynamic>;

  // Update privacySettingModelList based on Firestore results
  for (var model in privacySettingModelList) {
    if (settingsMap.containsKey(model.id)) {
      model.value = settingsMap[model.id]!;
    }
  }

  return privacySettingModelList;
}
