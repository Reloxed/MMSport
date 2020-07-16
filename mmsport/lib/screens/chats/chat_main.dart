import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMain extends StatefulWidget {
  State<ChatMain> createState() {
    return _ChatMain();
  }
}

class _ChatMain extends State<ChatMain> {
  SocialProfile chosenSocialProfile;

  Future<Null> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    setState(() {
      chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
      chosenSocialProfile.id = aux['id'];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: Text("Chats"),
                bottom: TabBar(tabs: <Widget>[
                  Container(
                      child: Tab(
                    text: "Chats",
                  )),
                  Container(
                      child: Tab(
                    text: "Usuarios",
                  ))
                ])),
            body: TabBarView(children: <Widget>[
              Text("Chats abiertos"),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection("socialProfiles")
                      .where("sportSchoolId", isEqualTo: chosenSocialProfile.sportSchoolId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        // ignore: missing_return
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = snapshot.data.documents[index];
                          if (document.documentID != chosenSocialProfile.id) {
                            if (index + 1 < snapshot.data.documents.length) {
                              return Column(
                                children: <Widget>[_listItem(document.data), Divider(color: Colors.black38)],
                              );
                            } else {
                              return _listItem(document.data);
                            }
                          } else {
                            return Container();
                          }
                        });
                  }),
            ])));
  }

  Widget _listItem(Map<String, dynamic> socialProfile) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(socialProfile["urlImage"]),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              socialProfile["name"] +
                                  " " +
                                  socialProfile["firstSurname"] +
                                  " " +
                                  socialProfile["secondSurname"],
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(fontSize: 21)),
                          Text("El ultimo mensaje jej",
                              overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 13))
                        ]))),
          ])
        ]));
  }
}
