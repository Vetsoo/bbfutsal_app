import 'package:intl/intl.dart';

class GameResult {
  DateTime date;
  String home;
  String visitors;
  String score;

  GameResult({this.date, this.home, this.visitors, this.score});

  List<String> get splittedDate {
    //return date.split("/");
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      date: new DateFormat('dd/MM/yyyy').parse(json['date']),
      home: json['home'],
      visitors: json['visitors'],
      score: json['score'],
    );
  }
}
