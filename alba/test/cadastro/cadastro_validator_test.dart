import 'package:flutter_test/flutter_test.dart';
import 'package:alba/domain/validators/register_validator.dart';
import 'package:alba/domain/dto/credentials_register_dto.dart';

void main() {
  group('RegisterValidator - Email', () {
    late RegisterValidator validator;
    late CredentialsRegisterDto dto;

    setUp(() {
      validator = RegisterValidator();
      dto = CredentialsRegisterDto(
        email: '',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        phone: '1234567890123',
      );
    });

    test('deve retornar erro se vazio', () {
      dto.email = '';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final emailErrors = result.exceptions.where((e) => e.key == 'email');
      expect(emailErrors, isNotEmpty);
      expect(emailErrors.any((e) => e.message == "'email' must not be empty."), isTrue);
    });

    test('deve retornar erro se formato inválido', () {
      dto.email = 'invalido';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final emailErrors = result.exceptions.where((e) => e.key == 'email');
      expect(emailErrors.first.message, "'email' is not a valid email address.");
    });

    test('deve aceitar email válido', () {
      dto.email = 'usuario@dominio.com';
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar erro correspondente para email vazio', () {
      dto.email = '';
      final validateEmail = validator.byField(dto, 'email');
      expect(validateEmail(''), "'email' must not be empty.");
    });

    test('byField deve retornar erro correspondente para email inválido', () {
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

  group('RegisterValidator - Senha', () {
    late RegisterValidator validator;
    late CredentialsRegisterDto dto;

    setUp(() {
      validator = RegisterValidator();
      dto = CredentialsRegisterDto(
        email: 'usuario@dominio.com',
        password: '',
        confirmPassword: '',
        phone: '1234567890123',
      );
    });

    test('deve retornar erro se vazia', () {
      dto.password = '';
      dto.confirmPassword = '';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "'senha' must not be empty.");
    });

    test('deve retornar erro se contiver espaços', () {
      dto.password = 'Pass word123!';
      dto.confirmPassword = 'Pass word123!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha não pode conter espaços");
    });

    test('deve retornar erro se menor que 6 caracteres', () {
      dto.password = 'P1!';
      dto.confirmPassword = 'P1!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter pelo menos 6 caracteres");
    });

    test('deve retornar erro se maior que 20 caracteres', () {
      dto.password = 'Password123Password123Password123';
      dto.confirmPassword = 'Password123Password123Password123';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter no máximo 20 caracteres");
    });

    test('deve retornar erro se não contiver caractere especial', () {
      dto.password = 'Password123';
      dto.confirmPassword = 'Password123';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter pelo menos um caractere especial");
    });

    test('deve retornar erro se não contiver letra minúscula', () {
      dto.password = 'PASSWORD123!';
      dto.confirmPassword = 'PASSWORD123!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter pelo menos uma letra minúscula");
    });

    test('deve retornar erro se não contiver letra maiúscula', () {
      dto.password = 'password123!';
      dto.confirmPassword = 'password123!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter pelo menos uma letra maiúscula");
    });

    test('deve retornar erro se não contiver número', () {
      dto.password = 'Password!';
      dto.confirmPassword = 'Password!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final passwordErrors = result.exceptions.where((e) => e.key == 'password');
      expect(passwordErrors.first.message, "A senha deve ter pelo menos um número");
    });

    test('deve aceitar senha válida', () {
      dto.password = 'Password123!';
      dto.confirmPassword = 'Password123!';
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar erro correspondente para senha inválida', () {
      dto.password = 'P1!';
      final validatePassword = validator.byField(dto, 'password');
      expect(validatePassword('P1!'), "A senha deve ter pelo menos 6 caracteres");
    });

    test('byField deve retornar null para senha válida', () {
      dto.password = 'Password123!';
      final validatePassword = validator.byField(dto, 'password');
      expect(validatePassword('Password123!'), isNull);
    });
  });

  group('RegisterValidator - Confirmar Senha', () {
    late RegisterValidator validator;
    late CredentialsRegisterDto dto;

    setUp(() {
      validator = RegisterValidator();
      dto = CredentialsRegisterDto(
        email: 'usuario@dominio.com',
        password: 'Password123!',
        confirmPassword: '',
        phone: '1234567890123',
      );
    });

    test('deve retornar erro se for diferente da senha', () {
      dto.confirmPassword = 'Different123!';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final confirmErrors = result.exceptions.where((e) => e.key == 'confirmPassword');
      expect(confirmErrors.first.message, "As senhas não coincidem");
    });

    test('deve aceitar se for idêntica à senha', () {
      dto.confirmPassword = 'Password123!';
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar erro se for diferente', () {
      dto.confirmPassword = 'Different123!';
      final validateConfirm = validator.byField(dto, 'confirmPassword');
      expect(validateConfirm('Different123!'), "As senhas não coincidem");
    });

    test('byField deve retornar null se for idêntica', () {
      dto.confirmPassword = 'Password123!';
      final validateConfirm = validator.byField(dto, 'confirmPassword');
      expect(validateConfirm('Password123!'), isNull);
    });
  });

  group('RegisterValidator - Telefone', () {
    late RegisterValidator validator;
    late CredentialsRegisterDto dto;

    setUp(() {
      validator = RegisterValidator();
      dto = CredentialsRegisterDto(
        email: 'usuario@dominio.com',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        phone: '',
      );
    });

    test('deve retornar erro se vazio', () {
      dto.phone = '';
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final phoneErrors = result.exceptions.where((e) => e.key == 'phone');
      expect(phoneErrors.any((e) => e.message == "'phone' must not be empty."), isTrue);
    });

    test('deve retornar erro se menor que 13 caracteres', () {
      dto.phone = '123456789012'; // 12 caracteres
      final result = validator.validate(dto);
      expect(result.isValid, isFalse);
      final phoneErrors = result.exceptions.where((e) => e.key == 'phone');
      expect(phoneErrors.first.message, contains("must be at least 13 characters"));
    });

    test('deve aceitar telefone válido', () {
      dto.phone = '1234567890123'; // 13 caracteres
      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
    });

    test('byField deve retornar erro se vazio', () {
      dto.phone = '';
      final validatePhone = validator.byField(dto, 'phone');
      expect(validatePhone(''), "'phone' must not be empty.");
    });

    test('byField deve retornar erro se menor que 13 caracteres', () {
      dto.phone = '123456789012';
      final validatePhone = validator.byField(dto, 'phone');
      expect(validatePhone('123456789012'), contains("must be at least 13 characters"));
    });

    test('byField deve retornar null se válido', () {
      dto.phone = '1234567890123';
      final validatePhone = validator.byField(dto, 'phone');
      expect(validatePhone('1234567890123'), isNull);
    });
  });
}
