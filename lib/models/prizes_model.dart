class PrizesModel {
  final String prize;
  final int days;

  PrizesModel({required this.prize, required this.days});

  factory PrizesModel.fromJson(Map<String, dynamic> json) {
    return PrizesModel(
      prize: json['prize'] as String,
      days: json['days'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'prize': prize,
        'days': days,
      };
}
