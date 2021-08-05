import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}

var searchUser = '';
var isEmpty = true;

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  api(String name) async {
    var dataList = [];
    var response =
        await http.get(Uri.https('api.github.com', 'users/$name/repos'));
    var jsonresponse = jsonDecode(response.body);
    for (var i in jsonresponse) {
      var userModel = ListClass(
          email: '${i['full_name']}',
          imageUrl: '${i['owner']['avatar_url']}',
          repoUrl: '${i['html_url']}',
          name: '${i['name']}');

      dataList.add(userModel);
    }
    return dataList;
  }

  getData(String e) {
    api(e);
  }

  var searchVal = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 30),
            child: Text(
              'Enter username to fetch the repo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                children: <Widget>[
                  new Flexible(
                    child: new TextField(
                        onChanged: (e) {
                          searchVal = e;
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Username")),
                  ),
                  IconButton(
                      onPressed: () {
                        getData(searchVal);
                        setState(() {});
                      },
                      icon: Icon(Icons.search))
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          searchVal == ''
              ? Center(child: Text('Seach user'))
              : Expanded(
                  child: FutureBuilder(
                    future: api(searchVal),
                    builder: (context, snapshot) {
                      if (snapshot.data == null || snapshot.data.length == 0) {
                        return Center(
                            child: SingleChildScrollView(
                                child: Column(
                          children: [Image.asset('assets/images/error.jpg')],
                        )));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: SingleChildScrollView(
                                child: Column(
                          children: [Image.asset('assets/images/error.jpg')],
                        )));
                      } else
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data[i].imageUrl),
                              ),
                              title: Text('${snapshot.data[i].name}'),
                              subtitle: Text('${snapshot.data[i].email}'),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () {
                                launch('${snapshot.data[i].repoUrl}');
                              },
                            );
                          },
                        );
                    },
                  ),
                ),
        ],
      ),
    ));
  }
}

class ListClass {
  String name;
  String email;
  String imageUrl;
  String repoUrl;
  ListClass({this.email, this.name, this.imageUrl, this.repoUrl});
}
