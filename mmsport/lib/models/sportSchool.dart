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

  SportSchool.sportSchoolWithId(String name, String address, String town, String province, String status, String urlLogo, String id) {
    this.name = name;
    this.address = address;
    this.town = town;
    this.province = province;
    this.status = status;
    this.urlLogo = urlLogo;
    this.id = id;
  }

  static SportSchool sportSchoolFromMap(Map<String, dynamic> map){

    return new SportSchool.sportSchoolWithId(map['name'], map['address'], map['town'], map['province'], map['status'], map['urlLogo'], map['id']);
  }

  Map<String, dynamic> sportSchoolToJson() => {
    "id": id,
    "name": name,
    "address": address,
    "town": town,
    "province": province,
    "status": status,
    "urlLogo": urlLogo
  };

}