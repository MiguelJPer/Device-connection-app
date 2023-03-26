import 'dart:async';
import 'dart:convert';

import 'package:device_connection/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/*
API class.
constants:
 - id (Device id, input when creating the marker)
 - IP (IP address of the device wifi)
 */
class DeviceAPI {
  static const id = "123";
  /*
  Function to perform GET request with input String "Order" that changes the
  $command variable depending on the button pressed. Returns an Album with the
  GET response.
   */
  Future<Album> fetchAlbum() async {
    final response = await http
        // URL here would be 'http://$ip/$command/?id=$id'
        .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;
  late String order = "";

  /*
  Creates a new API and updates futureAlbum. Called each time a button is called.
  In the actual code it will have an "Order" input to change the fetchAlbum() order.
  */
  void _getAlbum() {
    var api = DeviceAPI();
    futureAlbum = api.fetchAlbum();
  }

  /*
  Updates the FutureBuilder widget that shows the information by retrieving the
  correct data from the Album according to the input order, else it returns
  an empty string.
  */
  Widget _getProperWidget(String order) {
    if (order != "") {
      return FutureBuilder<Album>(
        future: futureAlbum,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (order == "id") {
              return Text(
                snapshot.data!.id.toString(),
                textAlign: TextAlign.center,
              );
            }
            if (order == "userID") {
              return Text(
                snapshot.data!.userId.toString(),
                textAlign: TextAlign.center,
              );
            } else {
              return Text(
                snapshot.data!.title,
                textAlign: TextAlign.center,
              );
            }
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      );
    } else {
      return const Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      order = "userID";
                    });
                    _getAlbum();
                  },
                  child: const Text("Get userID")),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      order = "id";
                    });
                    _getAlbum();
                  },
                  child: const Text("Get ID")),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      order = "title";
                    });
                    _getAlbum();
                  },
                  child: const Text("Get title")),
              _getProperWidget(order)
            ]),
      ),
    );
  }
}
