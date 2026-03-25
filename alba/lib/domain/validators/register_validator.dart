import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:lucid_validation/lucid_validation.dart';

class RegisterValidator extends LucidValidator<CredentialsRegisterDto> {
  RegisterValidator() {
    ruleFor((dto) => dto.email, key: 'email').notEmpty().validEmail();
    ruleFor((dto) => dto.password, key: 'password', label: 'senha')
        .minLength(6)
        .maxLength(20)
        .mustHaveSpecialCharacter()
        .mustHaveLowercase()
        .mustHaveUppercase()
        .mustHaveNumber();

    ruleFor(
      (dto) => dto.confirmPassword,
      key: 'confirmPassword',
      label: 'confirmar senha',
    ).equalTo((dto) => dto.password);
  }
}
