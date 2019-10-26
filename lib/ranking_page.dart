import 'dart:convert';
import 'package:bbfutsal_app/model/gameresult.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

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
  List<GameResult> gameResults;

  @override
  void initState() {
    fetchGameResults().then((result) {
      setState(() {
        gameResults = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RankingPage()),
            );
          },
        )
      ],
    );

    TableRow _buildTableRow(
            String rank, String name, String points, String played) =>
        TableRow(
          children: [
            Container(
                margin: EdgeInsets.all(2),
                color: Color.fromRGBO(58, 66, 86, 1.0),
                width: 5.0,
                child: Center(
                    child: Text(rank,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18)))),
            Container(
                margin: EdgeInsets.all(2),
                color: Color.fromRGBO(58, 66, 86, 1.0),
                width: 5.0,
                child: Center(
                    child: Text(name,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18)))),
            Container(
                margin: EdgeInsets.all(2),
                color: Color.fromRGBO(58, 66, 86, 1.0),
                width: 5.0,
                child: Center(
                    child: Text(points,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18)))),
            Container(
                margin: EdgeInsets.all(2),
                color: Color.fromRGBO(58, 66, 86, 1.0),
                width: 5.0,
                child: Center(
                    child: Text(played,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18))))
          ],
        );

    final makeDataColumns = [
      DataColumn(label: Text('#'), tooltip: 'Ranking'),
      DataColumn(label: Text('Name'), tooltip: 'Club name'),
      DataColumn(label: Text('P'), tooltip: 'Points'),
      DataColumn(label: Text('GP'), tooltip: 'Games played'),
    ];

    List<DataCell> makeDataCells(String rank,String name,String points,String played) => [
      DataCell(Text(rank)),
      DataCell(Text(name)),
      DataCell(Text(points)),
      DataCell(Text(played)),
    ];

    List<DataRow> makeDataRows(String rank, String name, String points, String played) => [
      DataRow(cells: makeDataCells(rank, name, points, played)),
      DataRow(cells: makeDataCells(rank, name, points, played)),
      DataRow(cells: makeDataCells(rank, name, points, played))
    ];

    final makeBody = DataTable(
      columns: makeDataColumns,
      rows: makeDataRows("#1", "Animo", "24", "3"),
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

Future<List<GameResult>> fetchGameResults() async {
  final response = await http.get(
      'https://kzvb-scraper.azurewebsites.net/api/results?code=V4HVAE88k211oy4rXrVdtaayBXMYGcyIi/6SYduVKY876q43b6Ekeg==&division=2B');
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    List responseJson = json.decode(response.body);
    var gameResults = responseJson.map((r) => GameResult.fromJson(r)).toList();
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
