import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/video_player_widget.dart';
import 'package:mmsport/models/chat_message.dart';
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
  bool isButtonEnabled = true;
  TextEditingController _textController = TextEditingController();

  void showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(leading: Icon(Icons.image), title: Text('Imagen'), onTap: () => showFilePicker(FileType.image)),
                ListTile(
                    leading: Icon(Icons.videocam), title: Text('Vídeo'), onTap: () => showFilePicker(FileType.video)),
                ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text('Archivo'),
                  onTap: () => showFilePicker(FileType.any),
                ),
              ],
            ),
          );
        });
  }

  void showFilePicker(FileType fileType) async {
    File file = await FilePicker.getFile(type: fileType);
    Navigator.pop(context);
    String url = await uploadFile(file, file.path);
    switch (fileType) {
      case FileType.any:
        ChatMessage chatMessage =
            new ChatMessage(null, loggedSocialProfile.id, socialProfileToChat.id, false, Timestamp.now(), url, "file");
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .collection("messages")
            .add(chatMessage.chatMessageToJson())
            .then((value) => _textController.clear());
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .update({'sentDate': chatMessage.sentDate});
        break;
      case FileType.image:
        ChatMessage chatMessage =
            new ChatMessage(null, loggedSocialProfile.id, socialProfileToChat.id, false, Timestamp.now(), url, "image");
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .collection("messages")
            .add(chatMessage.chatMessageToJson())
            .then((value) => _textController.clear());
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .update({'sentDate': chatMessage.sentDate});
        break;
      case FileType.video:
        ChatMessage chatMessage =
            new ChatMessage(null, loggedSocialProfile.id, socialProfileToChat.id, false, Timestamp.now(), url, "video");
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .collection("messages")
            .add(chatMessage.chatMessageToJson())
            .then((value) => _textController.clear());
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
            .update({'sentDate': chatMessage.sentDate});
        break;
      default:
        break;
    }
  }

  Future<String> uploadFile(File file, String path) async {
    final FirebaseStorage firebaseStorage = new FirebaseStorage();
    String fileName = file.path.split('/').last;
    String chatId = chosenChatRoom.id;
    String loggedProfileId = loggedSocialProfile.id;
    StorageReference reference = firebaseStorage.ref().child(
        '$path/$chatId/$loggedProfileId-${DateTime.now().millisecondsSinceEpoch}-$fileName'); // get a reference to the path of the image directory
    String p = await reference.getPath();
    print('Subiendo archivo a $p');
    StorageUploadTask uploadTask = reference.putFile(file); // put the file in the path
    StorageTaskSnapshot result = await uploadTask.onComplete; // wait for the upload to complete
    String url = await result.ref.getDownloadURL(); //retrieve the download link and return it
    return url;
  }

  Future<ChatRoomModel> _loadDataChatRoom() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenChatRoom"));
    chosenChatRoom = ChatRoomModel.chatRoomModelFromMap(aux);
    Map profile = await jsonDecode(preferences.get("chosenSocialProfile"));
    SocialProfile chosenSocialProfile = SocialProfile.socialProfileFromMap(profile);
    List<String> nonReadMessagesId = new List<String>();
    chosenSocialProfile.id = profile['id'];
    List<String> socialIds = chosenChatRoom.id.split("_");
    var existsDoc =
        await FirebaseFirestore.instance.collection("chatRooms").doc(socialIds[0] + "_" + socialIds[1]).get();
    if (existsDoc.exists) {
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(existsDoc.id)
          .collection("messages")
          .where("read", isEqualTo: false)
          .where("receiverId", isEqualTo: chosenSocialProfile.id)
          .get()
          .then((value) => value.docs.forEach((document) {
                nonReadMessagesId.add(document.id);
              }));
      for (String id in nonReadMessagesId) {
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(chosenChatRoom.id)
            .collection("messages")
            .doc(id)
            .set({"read": true}, SetOptions(merge: true));
      }
    } else {
      existsDoc = await FirebaseFirestore.instance.collection("chatRooms").doc(socialIds[1] + "_" + socialIds[0]).get();
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(existsDoc.id)
          .collection("messages")
          .where("read", isEqualTo: false)
          .where("receiverId", isEqualTo: chosenSocialProfile.id)
          .get()
          .then((value) => value.docs.forEach((document) {
                nonReadMessagesId.add(document.id);
              }));
      for (String id in nonReadMessagesId) {
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(existsDoc.id)
            .collection("messages")
            .doc(id)
            .set({"read": true}, SetOptions(merge: true));
      }
    }

    return chosenChatRoom;
  }

  Future<SocialProfile> _loadDataSocialProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map loggedSocialProfileMap = jsonDecode(preferences.get("chosenSocialProfile"));
    loggedSocialProfile = SocialProfile.socialProfileFromMap(loggedSocialProfileMap);
    loggedSocialProfile.id = loggedSocialProfileMap['id'];
    if (loggedSocialProfile.id == chosenChatRoom.users[0]) {
      DocumentSnapshot aux =
          await FirebaseFirestore.instance.collection("socialProfiles").doc(chosenChatRoom.users[1]).get();
      socialProfileToChat = SocialProfile.socialProfileFromMap(aux.data());
      socialProfileToChat.id = aux.data()['id'];
    } else {
      DocumentSnapshot aux =
          await FirebaseFirestore.instance.collection("socialProfiles").doc(chosenChatRoom.users[0]).get();
      socialProfileToChat = SocialProfile.socialProfileFromMap(aux.data());
      socialProfileToChat.id = aux.data()['id'];
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
                                stream: FirebaseFirestore.instance
                                    .collection("chatRooms")
                                    .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
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
                                          ChatMessage chatMessage = ChatMessage.chatMessageFromMap(document.data());
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
                            IconButton(
                                icon: Icon(Icons.attach_file),
                                iconSize: 25.0,
                                color: Colors.blueAccent,
                                onPressed: () => showAttachmentBottomSheet(context)),
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
                                  String text = _textController.text;
                                  _textController.clear();
                                  ChatMessage chatMessage = new ChatMessage(text, loggedSocialProfile.id,
                                      socialProfileToChat.id, false, Timestamp.now(), null, null);
                                  await FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
                                      .collection("messages")
                                      .add(chatMessage.chatMessageToJson())
                                      .then((value) => _textController.clear());
                                  await FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(chosenChatRoom.users[0] + "_" + chosenChatRoom.users[1])
                                      .update({'sentDate': chatMessage.sentDate});
                                  isButtonEnabled = true;
                                }
                              },
                            )
                          ],
                        ),
                      )
                    ])));
          } else {
            return loadingHome();
          }
        });
  }

  Widget _buildMessage(ChatMessage message, bool isMe) {
    return Container(
      margin: isMe
          ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: MediaQuery.of(context).size.width * 0.25)
          : EdgeInsets.only(top: 8.0, bottom: 8.0, right: MediaQuery.of(context).size.width * 0.25),
      padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white,
          borderRadius: isMe
              ? BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0))
              : BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0))),
      child: _buildMessageContent(isMe, message, context),
    );
  }

  Widget _buildMessageContent(bool isSelf, ChatMessage message, BuildContext context) {
    if (message.message != null) {
      return Text(
        message.message,
        style: isSelf ? TextStyle(color: Colors.white, fontSize: 16.0) : TextStyle(color: Colors.black, fontSize: 16.0),
      );
    } else if (message.type == "image") {
      return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage(placeholder: AssetImage("imagen"), image: NetworkImage(message.url)));
    } else if (message.type == "video") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  width: 140,
                  color: isSelf ? Colors.white : Colors.blueAccent,
                  height: 80,
                ),
                Column(
                  children: <Widget>[
                    Icon(
                      Icons.videocam,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Video',
                      style: TextStyle(fontSize: 20, color: isSelf ? Colors.blueAccent : Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
                height: 40,
                child: IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: isSelf ? Colors.white : Colors.blueAccent,
                    ),
                    onPressed: () => showVideoPlayer(context, message.url)))
          ],
        ),
      );
    } else if (message.type == "file") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  width: 140,
                  color: Colors.white,
                  height: 80,
                ),
                Column(
                  children: <Widget>[
                    Icon(
                      Icons.insert_drive_file,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Archivo',
                      style: TextStyle(fontSize: 20, color: isSelf ? Colors.blueAccent : Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
                height: 40,
                child: IconButton(
                    icon: Icon(
                      Icons.file_download,
                      color: isSelf ? Colors.white : Colors.blueAccent,
                    ),
                    onPressed: () => downloadFile(message.url)))
          ],
        ),
      );
    }
    else{
      return Container();
    }
  }

  void showVideoPlayer(parentContext, String videoUrl) async {
    await showModalBottomSheet(
        context: parentContext,
        builder: (BuildContext bc) {
          return VideoPlayerWidget(videoUrl);
        });
  }

  downloadFile(String fileUrl) async {
    final Directory downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    final String downloadsPath = downloadsDirectory.path;
    await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: downloadsPath,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
  }
}
