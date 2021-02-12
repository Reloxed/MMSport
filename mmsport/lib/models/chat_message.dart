import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage{
  String message;
  String senderId;
  String receiverId;
  Timestamp sentDate;
  bool read;
  String url;
  String type;

  ChatMessage(String message, String senderId, String receiverId, bool read, Timestamp sentDate, String url, String type){
    this.message = message;
    this.senderId = senderId;
    this.receiverId = receiverId;
    this.sentDate = sentDate;
    this.read = read;
    this.url = url;
    this.type = type;
  }

  static ChatMessage chatMessageFromMap(Map<String, dynamic> map){
    return new ChatMessage(map['message'], map['senderId'], map['receiverId'],  map['read'], map['sentDate'], map['url'], map['type']);
  }

  Map<String, dynamic> chatMessageToJson() => {
    "message": message,
    "senderId": senderId,
    "receiverId": receiverId,
    "sentDate": sentDate,
    "read": read,
    "url" : url,
    "type" : type
  };
}