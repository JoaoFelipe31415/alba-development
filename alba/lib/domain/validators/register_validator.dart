import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:lucid_validation/lucid_validation.dart';

class RegisterValidator extends LucidValidator<CredentialsRegisterDto> {
  RegisterValidator() {
    ruleFor((dto) => dto.email, key: 'email').notEmpty().validEmail();
    ruleFor((dto) => dto.password, key: 'password', label: 'senha')
        .notEmpty()
        .myPasswordValidator()
        .minLength(6, message: "A senha deve ter pelo menos 6 caracteres")
        .maxLength(20, message: "A senha deve ter no máximo 20 caracteres")
        .mustHaveSpecialCharacter(
          message: "A senha deve ter pelo menos um caractere especial",
        )
        .mustHaveLowercase(
          message: "A senha deve ter pelo menos uma letra minúscula",
        )
        .mustHaveUppercase(
          message: "A senha deve ter pelo menos uma letra maiúscula",
        )
        .mustHaveNumber(message: "A senha deve ter pelo menos um número")
        .cascade(CascadeMode.stopOnFirstFailure);

    ruleFor(
      (dto) => dto.confirmPassword,
      key: 'confirmPassword',
      label: 'confirmar senha',
    ).equalTo((dto) => dto.password, message: 'As senhas não coincidem');

    ruleFor((dto) => dto.phone, key: 'phone').notEmpty().minLength(13);
  }
}

extension MyPasswordValidator on SimpleValidationBuilder<String> {
  SimpleValidationBuilder<String> myPasswordValidator({
    String message = 'A senha não pode conter espaços',
  }) {
    return use((value, entity) {
      if (value.contains(" ")) {
        return ValidationException(
          message: message,
          code: 'password_contains_space',
          key: 'password',
          entity: extractClassName(entity.toString()),
        );
      }

      return null;
    });
  }
}
