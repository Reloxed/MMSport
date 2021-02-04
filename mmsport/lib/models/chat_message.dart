import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage{
  String message;
  String senderId;
  String receiverId;
  Timestamp sentDate;
  bool read;

  ChatMessage(String message, String senderId, String receiverId, bool read, Timestamp sentDate){
    this.message = message;
    this.senderId = senderId;
    this.receiverId = receiverId;
    this.sentDate = sentDate;
    this.read = read;
  }

  static ChatMessage chatMessageFromMap(Map<String, dynamic> map){
    return new ChatMessage(map['message'], map['senderId'], map['receiverId'],  map['read'], map['sentDate'],);
  }

  Map<String, dynamic> chatMessageToJson() => {
    "message": message,
    "senderId": senderId,
    "receiverId": receiverId,
    "sentDate": sentDate,
    "read": read
  };
}