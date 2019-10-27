class Ranking {
  int rank;
  String name;
  String points;
  String played;

  Ranking({this.rank, this.name, this.points, this.played});

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      rank: json['ranking'],
      name: json['clubName'],
      points: json['points'],
      played: json['gamesPlayed'],
    );
  }
}
