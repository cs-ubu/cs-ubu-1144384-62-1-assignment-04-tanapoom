import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new CSUBUFlutterApp());
}

class CSUBUFlutterApp extends StatelessWidget {
  final appTitle = 'CSUBU App Page';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        //fontFamily: 'Roboto'
      ),
      home: AppHomePage(title: appTitle),
    );
  }
}

class AppHomePage extends StatefulWidget {
  AppHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _counter = 0;
  var _courses = <dynamic>[];
  // Future<dynamic> _students;
  var _car = [];
  var _loading = true;
  var _page = 0;
  var like = false;
  _getCars() async {
    var url =
        'http://cs.sci.ubu.ac.th:7512/topic-1/5711403250/_search?from=${_page * 10}&size=10';
    const headers = {'Content-Type': 'application/json; charset=utf-8'};
    const query = {
      'query': {'match_all': {}}
    };
    final response =
        await http.post(url, headers: headers, body: json.encode(query));
    _car = [];
    if (response.statusCode == 200) {
      var result =
          jsonDecode(utf8.decode(response.bodyBytes))['result']['hits'];
      result.forEach((item) {
        if (item.containsKey('_source')) {
          var source = item['_source'];
          if (source.containsKey('model') &&
              source.containsKey('brand') &&
              source.containsKey('like')) {
            _car.add(item['_source']);
          }
        }
      });
    }
    setState(() {
      
      _loading = false;
    });
  }

  void _like() {
    setState(() {
       like = !like; 
      });
    print(like);
  }

  void _incrementCounter() {
    setState(() {
      _loading = true;
    });
    _getCars();
    print("complete");
  }

  Widget carWidgets(BuildContext context) {
    return ListView.builder(
        itemCount: _car.length,
        padding: const EdgeInsets.all(8.0),
        //separatorBuilder: (context, i) => const Divider(),
        itemBuilder: (context, i) {
          final c = _car[i];
          var sum = 0;
          return Card(
            child: ListTile(
              title: Column(children: <Widget>[
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    '${c["pic"]}',
                    width: 300,
                    height: 200,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text('${c["model"]}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  'Brand: ${c["brand"]}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '${c["like"]}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                ),
                                IconButton(
                                    icon: Icon(
                                      (like) ? Icons.thumb_up : Icons.thumb_up,
                                      color: (like)
                                          ? Colors.blueAccent
                                          : Colors.black38,
                                      
                                    ),
                                    
                                    onPressed: _like
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          );
        });
  }

  Widget loadingWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('loading....'),
        CircularProgressIndicator(),
        Text('Click the button '),
        Icon(Icons.cloud_download)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: _incrementCounter,
          ),
        ],
      ),
      body: Center(
        child: (_loading) ? loadingWidget(context) : carWidgets(context),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 0,
        ),
      ),
    );
  }
}
