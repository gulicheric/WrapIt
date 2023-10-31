class SettingsModel {
  final String title;
  final bool value;

  SettingsModel({required this.title, required this.value});
}

class SettingsScreenModel {
  final String id;
  final String title;
  bool value;

  final Function(bool) onChanged;

  SettingsScreenModel(
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
