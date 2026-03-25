class CredentialsRegisterDto {
  String email;
  String password;
  String confirmPassword;

  CredentialsRegisterDto({
    this.email = "",
    this.password = "",
    this.confirmPassword = "",
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
}
