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

  Future<dynamic> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenChatRoom"));
    Map loggedSocialProfileMap = await jsonDecode(preferences.get("chosenSocialProfile"));
    setState(() async {
      chosenChatRoom = ChatRoomModel.chatRoomModelFromMap(aux);
      SocialProfile loggedSocialProfile = SocialProfile.socialProfileFromMap(loggedSocialProfileMap);
      if (loggedSocialProfile.id == chosenChatRoom.users[0]) {
        await Firestore.instance
            .collection("socialProfiles")
            .document(chosenChatRoom.users[1])
            .get()
            .then((value) {
          socialProfileToChat = SocialProfile.socialProfileFromMap(value.data);
          socialProfileToChat.id = value.data['id'];
        });
      } else {
        await Firestore.instance.collection("socialProfiles").document(chosenChatRoom.users[0]).get().then((value) {
          socialProfileToChat = SocialProfile.socialProfileFromMap(value.data);
          socialProfileToChat.id = value.data['id'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            default:
              return Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(MediaQuery
                        .of(context)
                        .size
                        .height * 0.1),
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
                              backgroundImage: NetworkImage(socialProfileToChat.urlImage),
                            ),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Text(socialProfileToChat.name + " " + socialProfileToChat.firstSurname))
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Text(chosenChatRoom.id));
          }
        });
  }
}
