import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  Future<PostRequest> _futureRequest;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: (_futureRequest == null)
                  ? Column(
                      children: [
                        Text(
                          'Please Log in',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        TextField(
                          controller: email,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hintText: 'Email',
                            hintStyle: TextStyle(
                                fontSize: 20, color: Colors.grey.shade400),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 0.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent, width: 2.0)),
                          ),
                        ),
                        TextField(
                          controller: password,
                          autocorrect: false,
                          obscureText: true,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hintText: 'Password',
                            hintStyle: TextStyle(
                                fontSize: 20, color: Colors.grey.shade400),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 0.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent, width: 2.0)),
                          ),
                        ),
                        RaisedButton(
                            child: Text('Submit'),
                            onPressed: () {
                              setState(() {
                                _futureRequest = postData(
                                    email: email.text, password: password.text);
                              });
                            })
                      ],
                    )
                  : FutureBuilder(
                      future: _futureRequest,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: <Widget>[
                              Text(snapshot.data.email),
                              Text(snapshot.data.password),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class PostRequest {
  String email;
  String password;

  PostRequest({this.email, this.password});

  factory PostRequest.fromJson(Map<String, dynamic> json) {
    return PostRequest(
      email: json['email'],
      password: json['password'],
    );
  }
}

const apiURL = 'https://us-central1-mubarack-6c72b.cloudfunctions.net/app/login';

Future<PostRequest> postData({String email, String password}) async {
  final http.Response response = await http.post(
    apiURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  if (response.statusCode == 200) {
    //if server returns a 200 response, parse the JSON.
    return PostRequest.fromJson(json.decode(response.body));
  } else if (response.statusCode == 400) {
    //if server returns a 400 response, throw an exception
    throw Exception('Bad request');
  } else if (response.statusCode == 500) {
    //if server returns a 500 response, throw an exception
    throw Exception('Server is down');
  } else {
    print(response.statusCode);
    throw Exception('Failed to load data');
  }
}
