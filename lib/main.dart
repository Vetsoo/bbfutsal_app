import 'dart:convert';
import 'package:bbfutsal_app/model/gameresult.dart';
import 'package:bbfutsal_app/ranking_page.dart';
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
      title: 'KZVB App  ',
      theme: new ThemeData(
          primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
          canvasColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: new ListPage(title: 'Results'),
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
  var dropdownValue = '2B';

  @override
  void initState() {
    fetchGameResults(dropdownValue).then((result) {
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
        title: Text(widget.title));

    ListTile makeListTile(GameResult gameResult) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 1.0, color: Colors.white24))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  new DateFormat('dd')
                      .format(gameResult.date), //splittedDate[0],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.normal),
                ),
                Text(
                  new DateFormat('MM')
                      .format(gameResult.date), //splittedDate[1],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.normal),
                ),
              ],
            )),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                width: 100,
                child: Text(
                  gameResult.home,
                  textAlign: TextAlign.left,
                  textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal),
                )),
            Container(
                width: 55,
                child: Text(
                  gameResult.score,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                )),
            Container(
                width: 100,
                child: Text(
                  gameResult.visitors,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal),
                ))
          ],
        ));

    Card makeCard(GameResult gameResult) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: makeListTile(gameResult),
          ),
        );

    final makeBody = Container(
        child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
            width: 100,
            child: Text(
              "Division:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.normal),
            )),
        DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          onChanged: (String newValue) {
            fetchGameResults(newValue).then((result) {
              setState(() {
                gameResults = result;
                dropdownValue = newValue;
              });
            });           
          },
          items: <String>['01', '2A', '2B', '3A', '3B', '3C']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.normal),
                ));
          }).toList(),
        )
      ]),
      Expanded(
          child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: gameResults.length,
        itemBuilder: (BuildContext context, int index) {
          return makeCard(gameResults[index]);
        },
      ))
    ]));

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
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Ranking'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RankingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<GameResult>> fetchGameResults(String division) async {
  var secret = await secretFuture;
  final response = await http.get(
      'https://kzvb-datascraper.azurewebsites.net/api/results?code=' + secret.resultsEndpointKey + '&division=' +
          division);
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
