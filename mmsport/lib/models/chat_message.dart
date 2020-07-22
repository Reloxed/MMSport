import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage{
  String message;
  String senderId;
  Timestamp sentDate;

  ChatMessage(String message, String senderId, Timestamp sentDate){
    this.message = message;
    this.senderId = senderId;
    this.sentDate = sentDate;
  }

  static ChatMessage chatMessageFromMap(Map<String, dynamic> map){
    return new ChatMessage(map['message'], map['senderId'], map['sentDate']);
  }

  Map<String, dynamic> chatMessageToJson() => {
    "message": message,
    "senderId": senderId,
    "sentDate": sentDate
  };
}