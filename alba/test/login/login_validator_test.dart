import 'package:flutter_test/flutter_test.dart';
import 'package:alba/domain/validators/login_validator.dart';
import 'package:alba/domain/dto/credentials_login_dto.dart';

void main() {
  group('LoginValidator - Email', () {
    late LoginValidator validator;
    late CredentialsLoginDto dto;

    setUp(() {
      validator = LoginValidator();
      dto = CredentialsLoginDto();
    });

    test('deve retornar erro se o email for vazio', () {
      dto.email = '';
      final result = validator.validate(dto);
      
      expect(result.isValid, isFalse);
      
      final emailErrors = result.exceptions.where((e) => e.key == 'email');
      expect(emailErrors, isNotEmpty);
      expect(emailErrors.first.message, "'email' must not be empty.");
    });

    test('deve retornar erro se o email for inválido', () {
      dto.email = 'email-invalido';
      final result = validator.validate(dto);
      
      expect(result.isValid, isFalse);
      
      final emailErrors = result.exceptions.where((e) => e.key == 'email');
      expect(emailErrors, isNotEmpty);
      expect(emailErrors.first.message, "'email' is not a valid email address.");
    });

    test('deve passar se o email for válido', () {
      dto.email = 'usuario@dominio.com';
      dto.password = 'senha123';
      
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar mensagem correta para email vazio', () {
      dto.email = '';
      final validateEmail = validator.byField(dto, 'email');
      expect(validateEmail(''), "'email' must not be empty.");
    });

    test('byField deve retornar mensagem correta para email inválido', () {
      dto.email = 'invalido';
      final validateEmail = validator.byField(dto, 'email');
      expect(validateEmail('invalido'), "'email' is not a valid email address.");
    });

    test('byField deve retornar null para email válido', () {
      dto.email = 'usuario@dominio.com';
      final validateEmail = validator.byField(dto, 'email');
      expect(validateEmail('usuario@dominio.com'), isNull);
    });
  });

  group('LoginValidator - Senha', () {
    late LoginValidator validator;
    late CredentialsLoginDto dto;

    setUp(() {
      validator = LoginValidator();
      dto = CredentialsLoginDto();
    });

    test('deve retornar erro se a senha for vazia', () {
      dto.password = '';
      final result = validator.validate(dto);
      
      expect(result.isValid, isFalse);
      
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors, isNotEmpty);
      expect(passwordErrors.first.message, "'password' must not be empty.");
    });

    test('deve passar se a senha for preenchida', () {
      dto.email = 'usuario@dominio.com';
      dto.password = 'senha123';
      
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar mensagem correta para senha vazia', () {
      dto.password = '';
      final validatePassword = validator.byField(dto, 'password');
      expect(validatePassword(''), "'password' must not be empty.");
    });

    test('byField deve retornar null para senha preenchida', () {
      dto.password = 'senha123';
      final validatePassword = validator.byField(dto, 'password');
      expect(validatePassword('senha123'), isNull);
    });
  });
}
