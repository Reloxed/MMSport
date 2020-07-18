class ChatRoomModel{
  String id;
  List<String> users;


  ChatRoomModel(String id, List<String> users){
    this.id = id;
    this.users = users;
  }

  static ChatRoomModel chatRoomModelFromMap(Map<String, dynamic> map){
    List<String> users = [];
    users.add(map['users'][0]);
    users.add(map['users'][1]);
    return new ChatRoomModel(map['id'], users);
  }

  Map<String, dynamic> chatRoomModelToJson() => {
    "id": id,
    "users": users
  };
}
