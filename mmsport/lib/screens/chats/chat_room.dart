import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/chat_message.dart';
import 'package:mmsport/models/chat_room.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmsport/components/dialogs.dart';

class ChatRoom extends StatefulWidget {
  State<ChatRoom> createState() {
    return _ChatRoom();
  }
}

class _ChatRoom extends State<ChatRoom> {
  ChatRoomModel chosenChatRoom;
  SocialProfile socialProfileToChat;
  SocialProfile loggedSocialProfile;
  bool isButtonEnabled = true;
  TextEditingController _textController = TextEditingController();

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
    loggedSocialProfile.id = loggedSocialProfileMap['id'];
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
                              snapshot.data[1].urlImage != null
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(snapshot.data[1].urlImage),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      child: ClipOval(
                                          child: Icon(
                                        Icons.person,
                                        size: 44,
                                      ))),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.55,
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Text(snapshot.data[1].name + " " + snapshot.data[1].firstSurname,
                                          overflow: TextOverflow.ellipsis, softWrap: true)))
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Column(children: <Widget>[
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(color: Colors.black12),
                              child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection("chatRooms")
                                    .document(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
                                    .collection("messages")
                                    .orderBy("sentDate", descending: true)
                                    .snapshots(),
                                builder: (context, listSnapshot) {
                                  if (listSnapshot.hasData && snapshot.hasData) {
                                    return ListView.builder(
                                        itemCount: listSnapshot.data.documents.length,
                                        reverse: true,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot document = listSnapshot.data.documents[index];
                                          ChatMessage chatMessage = ChatMessage.chatMessageFromMap(document.data);
                                          bool isMe = chatMessage.senderId == loggedSocialProfile.id;
                                          return _buildMessage(chatMessage, isMe);
                                        });
                                  } else {
                                    return loading();
                                  }
                                },
                              ))),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        height: MediaQuery.of(context).size.height * 0.08,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration.collapsed(hintText: "Enviar mensaje..."),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              iconSize: 25.0,
                              color: Colors.blueAccent,
                              onPressed: () async {
                                if (_textController.text.isNotEmpty && isButtonEnabled == true) {
                                  isButtonEnabled = false;
                                  ChatMessage chatMessage =
                                      new ChatMessage(_textController.text, loggedSocialProfile.id, Timestamp.now());
                                  await Firestore.instance
                                      .collection("chatRooms")
                                      .document(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
                                      .collection("messages")
                                      .add(chatMessage.chatMessageToJson())
                                      .then((value) => _textController.clear());
                                  isButtonEnabled = true;
                                }
                              },
                            )
                          ],
                        ),
                      )
                    ])));
          } else {
            return loading();
          }
        });
  }

  Widget _buildMessage(ChatMessage message, bool isMe) {
    return Container(
      margin: isMe
          ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: MediaQuery.of(context).size.width * 0.25)
          : EdgeInsets.only(top: 8.0, bottom: 8.0, right: MediaQuery.of(context).size.width * 0.25),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white,
          borderRadius: isMe
              ? BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0))
              : BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0))),
      child: Text(message.message,
          style:
              isMe ? TextStyle(color: Colors.white, fontSize: 16.0) : TextStyle(color: Colors.black, fontSize: 16.0)),
    );
  }
}
