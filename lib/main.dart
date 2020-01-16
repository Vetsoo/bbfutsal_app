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
      home: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text("KZVB App"),
        ),
        body: Column(children: [
          Container(
              color: Colors.orangeAccent,
              height: 150.0,
              child: Center(child: Text('Something'))),
          DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Expanded(
              child: Column(children: [
                TabBar(
                  tabs: [Tab(text: "Results"), Tab(text: "Ranking")],
                  labelColor: Colors.black,
                ),
                Expanded(
                                  child: TabBarView(
                    children: [
                      new ResultsList(title: 'Results'),
                      new RankingsList(title: 'Ranking'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ]),
      )),
    );
  }
}

class ResultsList extends StatefulWidget {
  ResultsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList>
    with AutomaticKeepAliveClientMixin<ResultsList> {
  var defaultDivision = '2B';
  Future<List<GameResult>> _gameResults;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _gameResults =
        fetchGameResults(defaultDivision); // only create the future once.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // because we use the keep alive mixin.
    return FutureBuilder(
        future: _gameResults,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(child: Text("Loading..."));
          } else {
            return RefreshIndicator(
                onRefresh: refreshGameResults,
                child: ListView.builder(
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
                                              right:
                                                  new BorderSide(width: 1.0))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            textWidthBasis:
                                                TextWidthBasis.parent,
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
                    }));
          }
        });
  }

  Future refreshGameResults() async {
    setState(() {
      _gameResults = fetchGameResults(defaultDivision);
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

class FilterGlance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 5, 0),
          child: Text("FILTER",
              style: TextStyle(
                  color: Colors.white30, fontWeight: FontWeight.bold)),
        ),
        Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            verticalDirection: VerticalDirection.down,
            runSpacing: 3.0,
            spacing: 3.0,
            children: <Widget>[
              ChipDesign("Lifetime"),
              ChipDesign("Student"),
              ChipDesign("Salaried"),
              ChipDesign("Corporate"),
              ChipDesign("Open"),
              ChipDesign("My Referral Code Users"),
              ChipDesign("+10"),
            ],
          ),
        ),
      ],
    );
  }
}

class ChipDesign extends StatelessWidget {
  final String _label;

  ChipDesign(this._label);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Chip(
        label: Text(
          _label,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      ),
      margin: EdgeInsets.only(left: 10, right: 3, top: 0, bottom: 0),
    );
  }
}

class RankingsList extends StatefulWidget {
  RankingsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RankingsListState createState() => _RankingsListState();
}

class _RankingsListState extends State<RankingsList>
    with AutomaticKeepAliveClientMixin<RankingsList> {
  var defaultDivision = '2B';
  Future<List<Ranking>> _rankings;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _rankings = fetchRanking(defaultDivision); // only create the future once.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // because we use the keep alive mixin.
    return FutureBuilder(
        future: _rankings,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(child: Text("Loading..."));
          } else {
            return RefreshIndicator(
                onRefresh: refreshRanking,
                child: ListView.builder(
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
                                              right:
                                                  new BorderSide(width: 1.0))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            textWidthBasis:
                                                TextWidthBasis.parent,
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
                    }));
          }
        });
  }

  Future refreshRanking() async {
    setState(() {
      _rankings = fetchRanking(defaultDivision);
    });
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
      var rankings = responseJson.map((r) => Ranking.fromJson(r)).toList();
      rankings.sort((a, b) {
        var aRank = a.rank;
        var bRank = b.rank;
        return aRank.compareTo(bRank);
      });
      return rankings;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load game rankings.');
    }
  }
}
