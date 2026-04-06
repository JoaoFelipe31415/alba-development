import 'package:flutter_test/flutter_test.dart';
import 'package:alba/domain/validators/tarefa_validator.dart';

void main() {
  group('TarefaValidator - Título', () {
    test('deve retornar erro se vazio', () {
      final result = TarefaValidator.validateTitulo('');
      expect(result, 'Preencha todos os campos obrigatórios.');
    });

    test('deve retornar erro se só espaços', () {
      final result = TarefaValidator.validateTitulo('   ');
      expect(result, 'Preencha todos os campos obrigatórios.');
    });

    test('deve retornar erro se menor que 3 caracteres', () {
      final result = TarefaValidator.validateTitulo('ab');
      expect(result, 'Deve conter pelo menos 3 caracteres');
    });

    test('deve aceitar título válido', () {
      final result = TarefaValidator.validateTitulo('Estudar Flutter');
      expect(result, null);
    });
  });

  group('TarefaValidator - Dias', () {
    test('deve retornar erro se lista vazia', () {
      final result = TarefaValidator.validateDias([]);
      expect(result, 'Selecione pelo menos um dia da semana.');
    });

    test('deve retornar erro se dia inválido', () {
      final result = TarefaValidator.validateDias(['segunda', 'feriado']);
      expect(result, 'Selecione apenas dias válidos da semana.');
    });

    test('deve aceitar dias válidos', () {
      final result = TarefaValidator.validateDias(['segunda', 'quarta']);
      expect(result, null);
    });
  });

  group('TarefaValidator - Horário', () {
    test('deve aceitar vazio (opcional)', () {
      final result = TarefaValidator.validateHorario('');
      expect(result, null);
    });

    test('deve retornar erro se formato inválido', () {
      final result = TarefaValidator.validateHorario('25:00');
      expect(result, 'Informe um horário válido no formato HH:MM.');
    });

    test('deve aceitar horário válido', () {
      final result = TarefaValidator.validateHorario('19:30');
      expect(result, null);
    });
  });
}
