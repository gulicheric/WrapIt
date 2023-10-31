import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> getRoadmapVotes() async {
  var roadmapVotes = await FirebaseFirestore.instance
      .collection('Roadmap')
      .orderBy("progress", descending: true)
      .get();

  // loop through roadmapVotes and count the number of votes for each type
  int roadmapVotesFeatureRequestCount = 0;
  int roadmapVotesBugCount = 0;

  for (var roadmapVote in roadmapVotes.docs) {
    print(roadmapVote.data()['roadmapType']);
    if (roadmapVote.data()['roadmapType'] == 'fetureRequest') {
      roadmapVotesFeatureRequestCount++;
    } else if (roadmapVote.data()['roadmapType'] == 'bugReport') {
      roadmapVotesBugCount++;
    }
  }

  return {
    'featureRequest': roadmapVotesFeatureRequestCount,
    'bug': roadmapVotesBugCount
  };
}
