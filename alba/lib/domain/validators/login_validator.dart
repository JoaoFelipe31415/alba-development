import 'package:alba/domain/dto/credentials_login_dto.dart';
import 'package:lucid_validation/lucid_validation.dart';

class LoginValidator extends LucidValidator<CredentialsLoginDto> {
  LoginValidator() {
    ruleFor((dto) => dto.email, key: 'email').notEmpty().validEmail();
    ruleFor((dto) => dto.password, key: 'password').notEmpty();
  }
}
