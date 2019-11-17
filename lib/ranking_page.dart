import 'dart:convert';
import 'package:bbfutsal_app/model/ranking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'util/secret.dart';
import 'util/secret_loader.dart';

Future<Secret> secretFuture = SecretLoader(secretPath: "secrets.json").load();

class RankingPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'KZVB App',
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: new ListPage(title: 'Ranking'),
    );
  }
}

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Ranking> rankings;

  @override
  void initState() {
    fetchRanking().then((result) {
      setState(() {
        rankings = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(widget.title)
    );

    final makeDataColumns = [
      DataColumn(
          label: Text('#',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          tooltip: 'Ranking'),
      DataColumn(
          label: Text('Name',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          tooltip: 'Club name'),
      DataColumn(
          label: Text('P',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          tooltip: 'Points'),
      DataColumn(
          label: Text('GP',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          tooltip: 'Games played'),
    ];

    List<DataCell> makeDataCells(
            int rank, String name, String points, String played) =>
        [
          DataCell(Text(rank.toString(),
              style: TextStyle(color: Colors.white, fontSize: 18))),
          DataCell(Text(name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 18))),
          DataCell(Text(points,
              style: TextStyle(color: Colors.white, fontSize: 18))),
          DataCell(Text(played,
              style: TextStyle(color: Colors.white, fontSize: 18))),
        ];

    List<DataRow> makeDataRows() => rankings
        .map((f) =>
            DataRow(cells: makeDataCells(f.rank, f.name, f.points, f.played)))
        .toList();

    final makeBody = DataTable(
      columns: makeDataColumns,
      rows: makeDataRows(),
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: topAppBar,
      body: makeBody,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Results'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
            ListTile(
              title: Text('Ranking'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Ranking>> fetchRanking() async {
  var secret = await secretFuture;
  final response = await http.get(
      'https://kzvb-scraper.azurewebsites.net/api/ranking?code=' + secret.rankingEndpointKey + '&division=2B');
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
