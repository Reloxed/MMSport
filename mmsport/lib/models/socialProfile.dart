class SocialProfile{

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

}