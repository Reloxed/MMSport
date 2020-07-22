import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/chat_room.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  State<ChatRoom> createState() {
    return _ChatRoom();
  }
}

class _ChatRoom extends State<ChatRoom> {
  ChatRoomModel chosenChatRoom;
  SocialProfile socialProfileToChat;
  SocialProfile loggedSocialProfile;

  Future<ChatRoomModel> _loadDataChatRoom() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenChatRoom"));
    chosenChatRoom = ChatRoomModel.chatRoomModelFromMap(aux);
    return chosenChatRoom;
  }

  Future<SocialProfile> _loadDataSocialProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map loggedSocialProfileMap = jsonDecode(preferences.get("chosenSocialProfile"));
    loggedSocialProfile = SocialProfile.socialProfileFromMap(loggedSocialProfileMap);
    if (loggedSocialProfile.id == chosenChatRoom.users[0]) {
      DocumentSnapshot aux =
          await Firestore.instance.collection("socialProfiles").document(chosenChatRoom.users[1]).get();
      socialProfileToChat = SocialProfile.socialProfileFromMap(aux.data);
      socialProfileToChat.id = aux.data['id'];
    } else {
      DocumentSnapshot aux =
          await Firestore.instance.collection("socialProfiles").document(chosenChatRoom.users[0]).get();
      socialProfileToChat = SocialProfile.socialProfileFromMap(aux.data);
      socialProfileToChat.id = aux.data['id'];
    }
    return socialProfileToChat;
  }

  @override
  void initState() {
    _loadDataChatRoom();
    _loadDataSocialProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait([_loadDataChatRoom(), _loadDataSocialProfile()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Material(
                child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
                      child: AppBar(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () async {
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            preferences.remove("chosenChatRoom");
                            Navigator.pop(context);
                          },
                        ),
                        title: FlexibleSpaceBar(
                          centerTitle: false,
                          titlePadding: EdgeInsets.all(5),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot.data[1].urlImage),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.55,
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        snapshot.data[1].name + " " + snapshot.data[1].firstSurname,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true
                                      )))
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Text(snapshot.data[0].id)));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
