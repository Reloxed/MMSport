class Group{
  String name;
  String schedule;
  String sportSchoolId;
  String trainerId;
  List<String> studentsList;

  Group(String name, String schedule, String sportSchoolId, String trainerId, List<String> studentsList){
    this.name = name;
    this.schedule = schedule;
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
    this.studentsList = studentsList;
  }
}