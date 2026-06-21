import 'package:flutter_test/flutter_test.dart';
import 'package:alba/domain/validators/meta_validator.dart';

void main() {
  group('MetaValidator - validateTitulo', () {
    test('deve retornar erro se o título for vazio', () {
      expect(MetaValidator.validateTitulo(''), 'Título é obrigatório');
      expect(MetaValidator.validateTitulo('   '), 'Título é obrigatório');
    });

    test('deve retornar erro se o título for muito curto (< 3 caracteres)', () {
      expect(MetaValidator.validateTitulo('ab'), 'Deve conter pelo menos 3 caracteres');
    });

    test('deve retornar erro se o título for muito longo (> 100 caracteres)', () {
      final tituloLongo = 'a' * 101;
      expect(MetaValidator.validateTitulo(tituloLongo), 'Deve conter no máximo 100 caracteres');
    });

    test('deve aceitar título válido', () {
      expect(MetaValidator.validateTitulo('Estudar Flutter'), isNull);
    });
  });

  group('MetaValidator - validateDescricao', () {
    test('deve aceitar descrição vazia ou nula', () {
      expect(MetaValidator.validateDescricao(null), isNull);
      expect(MetaValidator.validateDescricao(''), isNull);
      expect(MetaValidator.validateDescricao('   '), isNull);
    });

    test('deve retornar erro se a descrição for muito longa (> 500 caracteres)', () {
      final descricaoLonga = 'a' * 501;
      expect(MetaValidator.validateDescricao(descricaoLonga), 'Deve conter no máximo 500 caracteres');
    });

    test('deve aceitar descrição válida', () {
      expect(MetaValidator.validateDescricao('Esta é uma descrição de teste válida.'), isNull);
    });
  });

  group('MetaValidator - validatePrazo', () {
    test('deve retornar erro se prazo for nulo', () {
      expect(MetaValidator.validatePrazo(null), 'Prazo é obrigatório');
    });

    test('deve retornar erro se data for no passado', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      expect(MetaValidator.validatePrazo(ontem), 'Deve ser uma data futura');
    });

    test('deve retornar erro se data for hoje', () {
      final hoje = DateTime.now();
      expect(MetaValidator.validatePrazo(hoje), 'Deve ser uma data futura');
    });

    test('deve aceitar se data for amanhã ou depois', () {
      final amanha = DateTime.now().add(const Duration(days: 1));
      expect(MetaValidator.validatePrazo(amanha), isNull);
    });
  });

  group('MetaValidator - validatePrazoTexto', () {
    test('deve retornar erro se texto do prazo for nulo ou vazio', () {
      expect(MetaValidator.validatePrazoTexto(null), 'Prazo é obrigatório');
      expect(MetaValidator.validatePrazoTexto(''), 'Prazo é obrigatório');
      expect(MetaValidator.validatePrazoTexto('   '), 'Prazo é obrigatório');
    });

    test('deve retornar erro se formato for inválido', () {
      expect(MetaValidator.validatePrazoTexto('12/03/20'), 'Formato inválido. Use DD/MM/AAAA');
      expect(MetaValidator.validatePrazoTexto('12-03-2026'), 'Formato inválido. Use DD/MM/AAAA');
      expect(MetaValidator.validatePrazoTexto('12/03/20261'), 'Formato inválido. Use DD/MM/AAAA');
    });

    test('deve retornar erro se a data for inválida', () {
      expect(MetaValidator.validatePrazoTexto('31/02/2026'), 'Fevereiro não possui 31 dias');
      expect(MetaValidator.validatePrazoTexto('32/01/2026'), 'Janeiro não possui 32 dias');
      expect(MetaValidator.validatePrazoTexto('00/01/2026'), 'Dia inválido');
      expect(MetaValidator.validatePrazoTexto('15/13/2026'), 'Mês inválido');
      expect(MetaValidator.validatePrazoTexto('aa/bb/cccc'), 'Data inválida');
    });

    test('deve retornar erro se data for no passado ou hoje', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      final ontemTexto = MetaValidator.formatDate(ontem);
      expect(MetaValidator.validatePrazoTexto(ontemTexto), 'Deve ser uma data futura');

      final hoje = DateTime.now();
      final hojeTexto = MetaValidator.formatDate(hoje);
      expect(MetaValidator.validatePrazoTexto(hojeTexto), 'Deve ser uma data futura');
    });

    test('deve aceitar se data for amanhã ou posterior', () {
      final amanha = DateTime.now().add(const Duration(days: 1));
      final amanhaTexto = MetaValidator.formatDate(amanha);
      expect(MetaValidator.validatePrazoTexto(amanhaTexto), isNull);
    });
  });

  group('MetaValidator - validateTag', () {
    test('deve retornar erro se tag for nula ou vazia', () {
      expect(MetaValidator.validateTag(null), 'Tag é obrigatória');
      expect(MetaValidator.validateTag(''), 'Tag é obrigatória');
      expect(MetaValidator.validateTag('   '), 'Tag é obrigatória');
    });

    test('deve retornar erro se tag for inválida', () {
      expect(MetaValidator.validateTag('lazer'), 'Tag inválida');
    });

    test('deve aceitar tags válidas', () {
      expect(MetaValidator.validateTag('negocio'), isNull);
      expect(MetaValidator.validateTag('faculdade'), isNull);
    });
  });

  group('MetaValidator - parseDate & isValidDate & formatDate', () {
    test('parseDate deve analisar datas válidas', () {
      final data = MetaValidator.parseDate('25/12/2026');
      expect(data, isNotNull);
      expect(data!.day, 25);
      expect(data.month, 12);
      expect(data.year, 2026);
    });

    test('parseDate deve lidar corretamente com anos bissextos', () {
      // 2024 é bissexto (29 dias em fevereiro)
      expect(MetaValidator.parseDate('29/02/2024'), isNotNull);
      // 2023 não é bissexto (28 dias em fevereiro)
      expect(MetaValidator.parseDate('29/02/2023'), isNull);
    });

    test('isValidDate deve retornar true apenas para datas válidas', () {
      expect(MetaValidator.isValidDate('10/10/2026'), isTrue);
      expect(MetaValidator.isValidDate('35/10/2026'), isFalse);
      expect(MetaValidator.isValidDate('invalid'), isFalse);
    });

    test('formatDate deve formatar DateTime corretamente no padrão DD/MM/AAAA', () {
      final data = DateTime(2026, 6, 21);
      expect(MetaValidator.formatDate(data), '21/06/2026');
    });
  });
}
