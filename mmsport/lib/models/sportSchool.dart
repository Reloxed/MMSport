class SportSchool{

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

}