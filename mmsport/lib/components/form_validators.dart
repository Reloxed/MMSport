class FormValidators {
  static bool validateEmptyEmail(String email) {

    return email == null || email.trim().isEmpty ? false : true;
  }

  static bool validateValidEmail(String email){
    final RegExp emailRegex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");
    return !emailRegex.hasMatch(email) ? false : true;
  }

  static bool validateEmptyPassword(String password){
    return password == null || password.trim().isEmpty ? false : true;
  }

  static bool validateShortPassword(String password){
    return password.length <= 5 ? false : true;
  }

  static bool validateNotEmpty(String field){
    return field == null || field.trim().isEmpty ? false : true;
  }
}
