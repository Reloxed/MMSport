import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/chat_room.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMain extends StatefulWidget {
  State<ChatMain> createState() {
    return _ChatMain();
  }
}

class _ChatMain extends State<ChatMain> {
  SocialProfile chosenSocialProfile;
  Map<SocialProfile, String> openChats = new Map();

  Future<SocialProfile> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
    chosenSocialProfile.id = aux['id'];
    return chosenSocialProfile;
  }

  Future<Map<SocialProfile, String>> _loadOpenChats() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
    chosenSocialProfile.id = aux['id'];
    Set<String> ids = new Set();
    await Firestore.instance
        .collection("chatRooms")
        .where("users", arrayContains: chosenSocialProfile.id)
        .getDocuments()
        .then((value) => value.documents.forEach((document) {
              if (document.data['users'][0] == chosenSocialProfile.id) {
                ids.add(document.data['users'][1]);
              } else {
                ids.add(document.data['users'][0]);
              }
            }));
    openChats.clear();
    for (String id in ids) {
      SocialProfile auxProfile;
      await Firestore.instance.collection("socialProfiles").document(id).get().then((value) {
        auxProfile = SocialProfile.socialProfileFromMap(value.data);
        auxProfile.id = id;
      });
      String lastMessage;
      var existsDoc =
          await Firestore.instance.collection("chatRooms").document(chosenSocialProfile.id + "_" + id).get();
      if (existsDoc.exists) {
        await Firestore.instance
            .collection("chatRooms")
            .document(chosenSocialProfile.id + "_" + id)
            .collection("messages")
            .orderBy("sentDate", descending: true)
            .snapshots()
            .first
            .then((value) => lastMessage = value.documents[0].data['message']);
      } else {
        await Firestore.instance
            .collection("chatRooms")
            .document(id + "_" + chosenSocialProfile.id)
            .collection("messages")
            .orderBy("sentData", descending: true)
            .snapshots()
            .first
            .then((value) => lastMessage = value.documents[0].data['message']);
      }
      bool contains = false;
      for(SocialProfile p in openChats.keys){
        if(auxProfile.id == p.id){
          contains = true;
          break;
        }
      }
      if(contains == false){
        openChats.putIfAbsent(auxProfile, () => lastMessage);
      }
    }
    return openChats;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialProfile>(
        future: _loadData(),
        builder: (context, snapshotSocialProfile) {
          if (snapshotSocialProfile.hasData) {
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
                      FutureBuilder(
                        future: _loadOpenChats(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                if (index + 1 < snapshot.data.length) {
                                  return Column(
                                    children: <Widget>[
                                      _listItemOpenChat(
                                          snapshot.data.keys.elementAt(index), snapshot.data.values.elementAt(index)),
                                      Divider(
                                        color: Colors.black38,
                                      )
                                    ],
                                  );
                                } else {
                                  return _listItemOpenChat(
                                      snapshot.data.keys.elementAt(index), snapshot.data.values.elementAt(index));
                                }
                              },
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("socialProfiles")
                              .where("sportSchoolId", isEqualTo: snapshotSocialProfile.data.sportSchoolId)
                              .snapshots(),
                          builder: (context, listSnapshot) {
                            if (listSnapshot.hasData) {
                              return ListView.builder(
                                  itemCount: listSnapshot.data.documents.length,
                                  // ignore: missing_return
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document = listSnapshot.data.documents[index];
                                    if (document.documentID != snapshotSocialProfile.data.id) {
                                      if (index + 1 < listSnapshot.data.documents.length) {
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
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                    ])));
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _listItemOpenChat(SocialProfile socialProfile, String lastMessage) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(socialProfile.urlImage),
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
                                socialProfile.name +
                                    " " +
                                    socialProfile.firstSurname +
                                    " " +
                                    socialProfile.secondSurname,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(fontSize: 21)),
                            Text(lastMessage,
                                overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 13))
                          ]))),
              Container(child: Icon(Icons.chevron_right))
            ]),
          ])),
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
        var existsDoc = await Firestore.instance
            .collection("chatRooms")
            .document(chosenSocialProfile.id + "_" + socialProfile.id)
            .get();
        if (existsDoc.exists) {
          // Check if document exists one way
          List<String> users = [];
          users.add(existsDoc.data['users'][0]);
          users.add(existsDoc.data['users'][1]);
          ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.documentID, users);
          preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
        } else {
          // Check if document exists the other way
          var existsDoc2 = await Firestore.instance
              .collection("chatRooms")
              .document(socialProfile.id + "_" + chosenSocialProfile.id)
              .get();
          if (existsDoc2.exists) {
            List<String> users = [];
            users.add(existsDoc2.data['users'][0]);
            users.add(existsDoc2.data['users'][1]);
            ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.documentID, users);
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          } else {
            // None of previous exists, create a new chat room
            ChatRoomModel chatRoomModel = new ChatRoomModel(
                chosenSocialProfile.id + "_" + socialProfile.id, [chosenSocialProfile.id, socialProfile.id]);
            await Firestore.instance
                .collection("chatRooms")
                .document(chatRoomModel.id)
                .setData(chatRoomModel.chatRoomModelToJson());
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          }
        }
        navigateToChatRoom(context);
      },
    );
  }

  Widget _listItem(Map<String, dynamic> socialProfile) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              CircleAvatar(
                radius: 30,
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
                          ]))),
              Container(child: Icon(Icons.chevron_right))
            ]),
          ])),
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
        var existsDoc = await Firestore.instance
            .collection("chatRooms")
            .document(chosenSocialProfile.id + "_" + socialProfile['id'])
            .get();
        if (existsDoc.exists) {
          // Check if document exists one way
          List<String> users = [];
          users.add(existsDoc.data['users'][0]);
          users.add(existsDoc.data['users'][1]);
          ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.documentID, users);
          preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
        } else {
          // Check if document exists the other way
          var existsDoc2 = await Firestore.instance
              .collection("chatRooms")
              .document(socialProfile['id'] + "_" + chosenSocialProfile.id)
              .get();
          if (existsDoc2.exists) {
            List<String> users = [];
            users.add(existsDoc2.data['users'][0]);
            users.add(existsDoc2.data['users'][1]);
            ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.documentID, users);
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          } else {
            // None of previous exists, create a new chat room
            ChatRoomModel chatRoomModel = new ChatRoomModel(
                chosenSocialProfile.id + "_" + socialProfile['id'], [chosenSocialProfile.id, socialProfile['id']]);
            await Firestore.instance
                .collection("chatRooms")
                .document(chatRoomModel.id)
                .setData(chatRoomModel.chatRoomModelToJson());
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          }
        }
        navigateToChatRoom(context);
      },
    );
  }
}
