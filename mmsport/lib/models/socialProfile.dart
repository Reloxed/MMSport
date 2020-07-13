class SocialProfile{

  String id;
  String userAccountId;
  String name;
  String firstSurname;
  String secondSurname;
  String role; // DIRECTOR, TRAINER, STUDENT
  String status; // ACCEPTED, REJECTED, PENDING
  String urlImage;
  String sportSchoolId;
  String groupId;

  SocialProfile(String userAccountId, String name, String firstSurname, String secondSurname, String role,
      String status, String urlImage, String sportSchoolId, String groupId){
    this.userAccountId = userAccountId;
    this.name = name;
    this.firstSurname = firstSurname;
    this.secondSurname = secondSurname;
    this.role = role;
    this.status = status;
    this.urlImage = urlImage;
    this.sportSchoolId = sportSchoolId;
    this.groupId = groupId;
  }

  static SocialProfile socialProfileFromMap(Map<String, dynamic> map){

    return new SocialProfile(map['userAccountId'], map['name'], map['firstSurname'], map['secondSurname'], map['role'], map['status'], map['urlImage'], map['sportSchoolId'], map['groupId']);
  }

  Map<String, dynamic> socialProfileToJson() => {
    "id": id,
    "userAccountId": userAccountId,
    "name": name,
    "firstSurname": firstSurname,
    "secondSurname": secondSurname,
    "role": role,
    "status": status,
    "urlImage": urlImage,
    "sportSchoolId": sportSchoolId,
    "groupId": groupId
  };

}