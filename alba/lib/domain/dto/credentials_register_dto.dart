class CredentialsRegisterDto {
  String email;
  String password;
  String confirmPassword;
  String phone;

  CredentialsRegisterDto({
    this.email = "",
    this.password = "",
    this.confirmPassword = "",
    this.phone = "",
  });

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  void setConfirmPassword(String confirmPassword) {
    this.confirmPassword = confirmPassword;
  }

  void setPhone(String phone) {
    this.phone = phone;
  }
}
