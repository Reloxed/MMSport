import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage{
  String message;
  String senderId;
  String receiverId;
  Timestamp sentDate;

  ChatMessage(String message, String senderId, String receiverId, Timestamp sentDate){
    this.message = message;
    this.senderId = senderId;
    this.receiverId = receiverId;
    this.sentDate = sentDate;
  }

  static ChatMessage chatMessageFromMap(Map<String, dynamic> map){
    return new ChatMessage(map['message'], map['senderId'], map['receiverId'], map['sentDate']);
  }

  Map<String, dynamic> chatMessageToJson() => {
    "message": message,
    "senderId": senderId,
    "receiverId": receiverId,
    "sentDate": sentDate
  };
}