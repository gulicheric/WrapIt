class PrivacySettingModel {
  final String id;
  final String title;
  bool value;
  final Function(bool) onChanged;

  PrivacySettingModel(
      {required this.id,
      required this.title,
      required this.value,
      required this.onChanged});

  // create toMap function
  Map<String, dynamic> toMap() {
    return {
      'id': id, // 'id' is the document id in firestore
      'title': title,
      'value': value,
    };
  }
}
