class SportSchool{

  String id;
  String name;
  String address;
  String town;
  String province;
  String status; // ACCEPTED, REJECTED, PENDING
  String urlLogo;

  SportSchool(String name, String address, String town, String province, String status, String urlLogo) {
    this.name = name;
    this.address = address;
    this.town = town;
    this.province = province;
    this.status = status;
    this.urlLogo = urlLogo;
  }

  static SportSchool sportSchoolFromMap(Map<String, dynamic> map){

    return new SportSchool(map['name'], map['address'], map['town'], map['province'], map['status'], map['urlLogo']);
  }

}