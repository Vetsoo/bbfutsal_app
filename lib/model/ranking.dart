import 'package:intl/intl.dart';

class Ranking {
  String rank;
  String name;
  String points;
  String played;

  Ranking({this.rank, this.name, this.points, this.played});

  factory Ranking.fromJson(Map<String, dynamic> json) {
    var ranking = Ranking(
      rank: null,
      name: json['clubName'],
      points: json['points'],
      played: json['gamesPlayed'],
    );

    var f = NumberFormat("00");
    ranking.rank = f.format(json['ranking']);
    return ranking;
  }
}
