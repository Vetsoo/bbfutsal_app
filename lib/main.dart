import 'dart:convert';
import 'package:bbfutsal_app/model/gameresult.dart';
import 'package:bbfutsal_app/model/ranking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'util/secret.dart';
import 'util/secret_loader.dart';

void main() => runApp(new MyApp());

Future<Secret> secretFuture = SecretLoader(secretPath: "secrets.json").load();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'KZVB App',
        theme: new ThemeData(primaryColor: Colors.deepOrange),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: <Widget>[Tab(text: "Results"), Tab(text: "Ranking")],
              ),
              title: Text("KZVB App"),
            ),
            body: TabBarView(
              children: <Widget>[
                new ResultsList(title: 'Results'),
                new RankingsList(title: 'Ranking'),
              ],
            ),
          ),
        ));
  }
}

class ResultsList extends StatefulWidget {
  ResultsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  var defaultDivision = '2B';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchGameResults(defaultDivision),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(child: Text("Loading..."));
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(width: 1.0))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        new DateFormat('dd').format(snapshot
                                            .data[index]
                                            .date), //splittedDate[0],
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        new DateFormat('MM').format(snapshot
                                            .data[index]
                                            .date), //splittedDate[1],
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      width: 100,
                                      child: Text(
                                        snapshot.data[index].home,
                                        textAlign: TextAlign.left,
                                        textWidthBasis: TextWidthBasis.parent,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      )),
                                  Container(
                                      width: 55,
                                      child: Text(
                                        snapshot.data[index].score,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                      width: 100,
                                      child: Text(
                                        snapshot.data[index].visitors,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ))
                                ],
                              ))));
                });
          }
        });
  }

  Future<List<GameResult>> fetchGameResults(String division) async {
    var secret = await secretFuture;
    final response = await http.get(
        'https://kzvb-datascraper.azurewebsites.net/api/results?code=' +
            secret.resultsEndpointKey +
            '&division=' +
            division);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      List responseJson = json.decode(response.body);
      var gameResults =
          responseJson.map((r) => GameResult.fromJson(r)).toList();
      gameResults.sort((a, b) {
        var adate = a.date;
        var bdate = b.date;
        return bdate.compareTo(
            adate); //to get the order other way just switch `adate & bdate`
      });

      return gameResults;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load game results.');
    }
  }
}

class RankingsList extends StatefulWidget {
  RankingsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RankingsListState createState() => _RankingsListState();
}

class _RankingsListState extends State<RankingsList> {
  var defaultDivision = '2B';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchRanking(defaultDivision),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(child: Text("Loading..."));
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(width: 1.0))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data[index].rank,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ],
                                  )),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                      width: 100,
                                      child: Text(
                                        snapshot.data[index].name,
                                        textAlign: TextAlign.left,
                                        textWidthBasis: TextWidthBasis.parent,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      )),
                                  Container(
                                      width: 55,
                                      child: Text(
                                        snapshot.data[index].points,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ))));
                });
          }
        });
  }
}

Future<List<Ranking>> fetchRanking(String division) async {
  var secret = await secretFuture;
  final response = await http.get(
      'https://kzvb-datascraper.azurewebsites.net/api/ranking?code=' +
          secret.rankingEndpointKey +
          '&division=' +
          division);
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    List responseJson = json.decode(response.body);
    var gameResults = responseJson.map((r) => Ranking.fromJson(r)).toList();
    gameResults.sort((a, b) {
      var aRank = a.rank;
      var bRank = b.rank;
      return aRank.compareTo(bRank);
    });

    return gameResults;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load game rankings.');
  }
}
