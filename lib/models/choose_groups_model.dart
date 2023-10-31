class ChooseGroupsModel {
  final String groupName;
  final String id;
  bool value;
  final String photoUrl;
  final Function(bool) onChanged;

  ChooseGroupsModel(
      {required this.id,
      required this.photoUrl,
      required this.groupName,
      required this.value,
      required this.onChanged});

  // create toMap function
  Map<String, dynamic> toMap() {
    return {
      'id': id, // 'id' is the document id in firestore
      'groupName': groupName,
      'value': value,
      'photoUrl': photoUrl,
    };
  }
}
