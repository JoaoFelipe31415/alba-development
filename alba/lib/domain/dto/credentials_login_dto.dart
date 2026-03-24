class CredentialsLoginDto {
   String email;
   String password;

  CredentialsLoginDto({ this.email = '',  this.password = ''});

  void setEmail(String value) {
    email = value;
  }
  void setPassword(String value) {
    password = value;
  }
}
