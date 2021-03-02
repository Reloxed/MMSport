import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
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
  Map<SocialProfile, String> openChats = new Map(); // El otro socialProfile, y la ID del chatRoom

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
    Set<String> chatRoomIds = new Set();
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("users", arrayContains: chosenSocialProfile.id)
        .orderBy("sentDate", descending: true)
        .get()
        .then((value) => value.docs.forEach((document) {
              if (document.data()['users'][0] == chosenSocialProfile.id) {
                ids.add(document.data()['users'][1]);
              } else {
                ids.add(document.data()['users'][0]);
              }
              chatRoomIds.add(document.id);
            }));
    openChats.clear();
    for (String id in ids) {
      SocialProfile auxProfile;
      await FirebaseFirestore.instance.collection("socialProfiles").doc(id).get().then((value) {
        auxProfile = SocialProfile.socialProfileFromMap(value.data());
        auxProfile.id = id;
      });
      bool contains = false;
      for (SocialProfile p in openChats.keys) {
        if (auxProfile.id == p.id) {
          contains = true;
          break;
        }
      }
      if (contains == false) {
        String chatRoomId;
        for (String i in chatRoomIds) {
          List<String> aux = i.split("_");
          for (String s in aux) {
            if (s == auxProfile.id) {
              chatRoomId = i;
              break;
            }
          }
        }
        openChats.putIfAbsent(auxProfile, () => chatRoomId);
      }
    }
    return openChats;
  }

  Future<List<SocialProfile>> getTrainers(String sportSchoolId) async {
    List<SocialProfile> trainers = [];
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where("sportSchoolId", isEqualTo: sportSchoolId)
        .where("status", isEqualTo: "ACCEPTED")
        .where("role", isEqualTo: "TRAINER")
        .get()
        .then((value) => value.docs.forEach((element) {
              SocialProfile auxProfile = SocialProfile.socialProfileFromMap(element.data());
              auxProfile.id = element.data()['id'];
              trainers.add(auxProfile);
            }));
    return trainers;
  }

  Future<List<SocialProfile>> getDirector(String sportSchoolId) async {
    List<SocialProfile> director = [];
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where("sportSchoolId", isEqualTo: sportSchoolId)
        .where("status", isEqualTo: "ACCEPTED")
        .where("role", isEqualTo: "DIRECTOR")
        .get()
        .then((value) => value.docs.forEach((element) {
              SocialProfile auxProfile = SocialProfile.socialProfileFromMap(element.data());
              auxProfile.id = element.data()['id'];
              director.add(auxProfile);
            }));
    return director;
  }

  Future<List<SocialProfile>> getStudents(String sportSchoolId) async {
    List<SocialProfile> students = [];
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where("sportSchoolId", isEqualTo: sportSchoolId)
        .where("status", isEqualTo: "ACCEPTED")
        .where("role", isEqualTo: "STUDENT")
        .get()
        .then((value) => value.docs.forEach((element) {
              SocialProfile auxProfile = SocialProfile.socialProfileFromMap(element.data());
              auxProfile.id = element.data()['id'];
              students.add(auxProfile);
            }));
    return students;
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
                            text: "Chats abiertos",
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
                            return loading();
                          }
                        },
                      ),
                      FutureBuilder(
                          future: snapshotSocialProfile.data.role == "DIRECTOR"
                              ? Future.wait([
                                  getTrainers(snapshotSocialProfile.data.sportSchoolId),
                                  getStudents(snapshotSocialProfile.data.sportSchoolId)
                                ])
                              : snapshotSocialProfile.data.role == "TRAINER"
                                  ? Future.wait([
                                      getDirector(snapshotSocialProfile.data.sportSchoolId),
                                      getStudents(snapshotSocialProfile.data.sportSchoolId)
                                    ])
                                  : Future.wait([
                                      getDirector(snapshotSocialProfile.data.sportSchoolId),
                                      getTrainers(snapshotSocialProfile.data.sportSchoolId)
                                    ]),
                          builder: (context, listSnapshot) {
                            if (listSnapshot.hasData) {
                              List<SocialProfile> profilesList = [];
                              profilesList.addAll(listSnapshot.data.elementAt(0));
                              profilesList.addAll(listSnapshot.data.elementAt(1));
                              return ListView.builder(
                                  itemCount: profilesList.length,
                                  // ignore: missing_return
                                  itemBuilder: (context, index) {
                                    SocialProfile profile = profilesList[index];
                                    if (profile.id != snapshotSocialProfile.data.id) {
                                      if (index + 1 < profilesList.length) {
                                        return Column(
                                          children: <Widget>[
                                            _listItem(profile.socialProfileToJson()),
                                            Divider(color: Colors.black38)
                                          ],
                                        );
                                      } else {
                                        return _listItem(profile.socialProfileToJson());
                                      }
                                    } else {
                                      return Container();
                                    }
                                  });
                            } else {
                              return loading();
                            }
                          }),
                    ])));
          } else {
            return loading();
          }
        });
  }

  Widget _listItemOpenChat(SocialProfile socialProfile, String chatRoomId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("sentDate", descending: true)
          .snapshots(),
      builder: (context, listSnapshot) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatRooms")
              .doc(chatRoomId)
              .collection("messages")
              .where("read", isEqualTo: false)
              .where("receiverId", isEqualTo: chosenSocialProfile.id)
              .snapshots(),
          builder: (context, snapshot2) {
            if (listSnapshot.hasData) {
              if (snapshot2.hasData) {
                return ListTile(
                  leading: socialProfile.urlImage != null
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(socialProfile.urlImage),
                        )
                      : CircleAvatar(
                          radius: 24,
                          child: ClipOval(
                              child: Icon(
                            Icons.person,
                            size: 44,
                          ))),
                  title: socialProfile.secondSurname != null
                      ? Text(socialProfile.name + " " + socialProfile.firstSurname + " " + socialProfile.secondSurname,
                          overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16))
                      : Text(socialProfile.name + " " + socialProfile.firstSurname,
                          overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16)),
                  subtitle: listSnapshot.data.documents.length > 0 &&
                          listSnapshot.data.documents.elementAt(0).get("message") != null
                      ? Text(listSnapshot.data.documents.elementAt(0).get("message"),
                          style: TextStyle(color: Colors.black45))
                      : listSnapshot.data.documents.elementAt(0).get("type") == "video"
                          ? RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black45),
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.local_movies, size: 16, color: Colors.black45),
                                  ),
                                  TextSpan(
                                    text: " Vídeo",
                                  ),
                                ],
                              ),
                            )
                          : listSnapshot.data.documents.elementAt(0).get("type") == "image"
                              ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black45),
                                    children: [
                                      WidgetSpan(
                                        child: Icon(Icons.photo, size: 16, color: Colors.black45),
                                      ),
                                      TextSpan(
                                        text: " Imagen",
                                      ),
                                    ],
                                  ),
                                )
                              : listSnapshot.data.documents.elementAt(0).get("type") == "file"
                                  ? RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.black45),
                                        children: [
                                          WidgetSpan(
                                            child:
                                                Icon(Icons.insert_drive_file_rounded, size: 16, color: Colors.black45),
                                          ),
                                          TextSpan(
                                            text: " Archivo",
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                  trailing: snapshot2.data.documents.length > 0
                      ? Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlueAccent),
                          child: Center(
                            child: Text(snapshot2.data.documents.length.toString()),
                          ))
                      : SizedBox.shrink(),
                  onTap: () async {
                    SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
                    var existsDoc = await FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(chosenSocialProfile.id + "_" + socialProfile.id)
                        .get();
                    if (existsDoc.exists) {
                      // Check if document exists one way
                      List<String> users = [];
                      users.add(existsDoc.data()['users'][0]);
                      users.add(existsDoc.data()['users'][1]);
                      ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                      preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                    } else {
                      // Check if document exists the other way
                      var existsDoc2 = await FirebaseFirestore.instance
                          .collection("chatRooms")
                          .doc(socialProfile.id + "_" + chosenSocialProfile.id)
                          .get();
                      if (existsDoc2.exists) {
                        List<String> users = [];
                        users.add(existsDoc2.data()['users'][0]);
                        users.add(existsDoc2.data()['users'][1]);
                        ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                        preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                      } else {
                        // None of previous exists, create a new chat room
                        ChatRoomModel chatRoomModel = new ChatRoomModel(chosenSocialProfile.id + "_" + socialProfile.id,
                            [chosenSocialProfile.id, socialProfile.id]);
                        await FirebaseFirestore.instance
                            .collection("chatRooms")
                            .doc(chatRoomModel.id)
                            .set(chatRoomModel.chatRoomModelToJson());
                        preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                      }
                    }
                    navigateToChatRoom(context);
                  },
                );
              } else {
                return ListTile(
                  leading: socialProfile.urlImage != null
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(socialProfile.urlImage),
                        )
                      : CircleAvatar(
                          radius: 24,
                          child: ClipOval(
                              child: Icon(
                            Icons.person,
                            size: 44,
                          ))),
                  title: socialProfile.secondSurname != null
                      ? Text(socialProfile.name + " " + socialProfile.firstSurname + " " + socialProfile.secondSurname,
                          overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16))
                      : Text(socialProfile.name + " " + socialProfile.firstSurname,
                          overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16)),
                  subtitle: listSnapshot.data.documents.length > 0 &&
                          listSnapshot.data.documents.elementAt(0).get("message") != null
                      ? Text(listSnapshot.data.documents.elementAt(0).get("message"))
                      : SizedBox.shrink(),
                  onTap: () async {
                    SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
                    var existsDoc = await FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(chosenSocialProfile.id + "_" + socialProfile.id)
                        .get();
                    if (existsDoc.exists) {
                      // Check if document exists one way
                      List<String> users = [];
                      users.add(existsDoc.data()['users'][0]);
                      users.add(existsDoc.data()['users'][1]);
                      ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                      preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                    } else {
                      // Check if document exists the other way
                      var existsDoc2 = await FirebaseFirestore.instance
                          .collection("chatRooms")
                          .doc(socialProfile.id + "_" + chosenSocialProfile.id)
                          .get();
                      if (existsDoc2.exists) {
                        List<String> users = [];
                        users.add(existsDoc2.data()['users'][0]);
                        users.add(existsDoc2.data()['users'][1]);
                        ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                        preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                      } else {
                        // None of previous exists, create a new chat room
                        ChatRoomModel chatRoomModel = new ChatRoomModel(chosenSocialProfile.id + "_" + socialProfile.id,
                            [chosenSocialProfile.id, socialProfile.id]);
                        await FirebaseFirestore.instance
                            .collection("chatRooms")
                            .doc(chatRoomModel.id)
                            .set(chatRoomModel.chatRoomModelToJson());
                        preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                      }
                    }
                    navigateToChatRoom(context);
                  },
                );
              }
            } else {
              return ListTile(
                leading: socialProfile.urlImage != null
                    ? CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(socialProfile.urlImage),
                      )
                    : CircleAvatar(
                        radius: 24,
                        child: ClipOval(
                            child: Icon(
                          Icons.person,
                          size: 44,
                        ))),
                title: socialProfile.secondSurname != null
                    ? Text(socialProfile.name + " " + socialProfile.firstSurname + " " + socialProfile.secondSurname,
                        overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16))
                    : Text(socialProfile.name + " " + socialProfile.firstSurname,
                        overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16)),
                subtitle: SizedBox.shrink(),
                onTap: () async {
                  SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
                  var existsDoc = await FirebaseFirestore.instance
                      .collection("chatRooms")
                      .doc(chosenSocialProfile.id + "_" + socialProfile.id)
                      .get();
                  if (existsDoc.exists) {
                    // Check if document exists one way
                    List<String> users = [];
                    users.add(existsDoc.data()['users'][0]);
                    users.add(existsDoc.data()['users'][1]);
                    ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                    preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                  } else {
                    // Check if document exists the other way
                    var existsDoc2 = await FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(socialProfile.id + "_" + chosenSocialProfile.id)
                        .get();
                    if (existsDoc2.exists) {
                      List<String> users = [];
                      users.add(existsDoc2.data()['users'][0]);
                      users.add(existsDoc2.data()['users'][1]);
                      ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
                      preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                    } else {
                      // None of previous exists, create a new chat room
                      ChatRoomModel chatRoomModel = new ChatRoomModel(
                          chosenSocialProfile.id + "_" + socialProfile.id, [chosenSocialProfile.id, socialProfile.id]);
                      await FirebaseFirestore.instance
                          .collection("chatRooms")
                          .doc(chatRoomModel.id)
                          .set(chatRoomModel.chatRoomModelToJson());
                      preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
                    }
                  }
                  navigateToChatRoom(context);
                },
              );
              //return SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _listItem(Map<String, dynamic> socialProfile) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              socialProfile["urlImage"] != null
                  ? CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(socialProfile["urlImage"]),
                    )
                  : CircleAvatar(
                      radius: 24,
                      child: ClipOval(
                          child: Icon(
                        Icons.person,
                        size: 44,
                      ))),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            socialProfile["secondSurname"] != null
                                ? Text(
                                    socialProfile["name"] +
                                        " " +
                                        socialProfile["firstSurname"] +
                                        " " +
                                        socialProfile["secondSurname"],
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(fontSize: 16))
                                : Text(socialProfile["name"] + " " + socialProfile["firstSurname"],
                                    overflow: TextOverflow.ellipsis, softWrap: true, style: TextStyle(fontSize: 16)),
                          ]))),
              Container(child: Icon(Icons.chevron_right))
            ]),
          ])),
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
//          String socialProfileToJson = jsonEncode(socialProfile);
//          preferences.setString("socialProfileToChat", socialProfileToJson);
        var existsDoc = await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenSocialProfile.id + "_" + socialProfile['id'])
            .get();
        if (existsDoc.exists) {
          // Check if document exists one way
          List<String> users = [];
          users.add(existsDoc.data()['users'][0]);
          users.add(existsDoc.data()['users'][1]);
          ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
          preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
        } else {
          // Check if document exists the other way
          var existsDoc2 = await FirebaseFirestore.instance
              .collection("chatRooms")
              .doc(socialProfile['id'] + "_" + chosenSocialProfile.id)
              .get();
          if (existsDoc2.exists) {
            List<String> users = [];
            users.add(existsDoc2.data()['users'][0]);
            users.add(existsDoc2.data()['users'][1]);
            ChatRoomModel chatRoomModel = new ChatRoomModel(existsDoc.id, users);
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          } else {
            // None of previous exists, create a new chat room
            ChatRoomModel chatRoomModel = new ChatRoomModel(
                chosenSocialProfile.id + "_" + socialProfile['id'], [chosenSocialProfile.id, socialProfile['id']]);
            await FirebaseFirestore.instance
                .collection("chatRooms")
                .doc(chatRoomModel.id)
                .set(chatRoomModel.chatRoomModelToJson());
            preferences.setString("chosenChatRoom", jsonEncode(chatRoomModel.chatRoomModelToJson()));
          }
        }
        navigateToChatRoom(context);
      },
    );
  }
}
