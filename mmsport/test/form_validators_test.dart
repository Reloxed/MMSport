import 'package:flutter_test/flutter_test.dart';
import 'package:mmsport/components/form_validators.dart';

void main() {
  // Validando el email
  test('Validación de email - Email vacío', () {
    bool aux = FormValidators.validateEmptyEmail('');
    expect(aux, false);
  });

  test('Validación de email - Email null', () {
    bool aux = FormValidators.validateEmptyEmail(null);
    expect(aux, false);
  });

  test('Validación de email - Email inválido', () {
    bool aux = FormValidators.validateValidEmail("prueba");
    expect(aux, false);
  });

  test('Validación de email - Email correcto', () {
    bool aux = FormValidators.validateValidEmail("prueba@prueba.com");
    expect(aux, true);
  });

  // Validación de contraseña
  test('Validación de contraseña - Contraseña vacía', () {
    bool aux = FormValidators.validateEmptyPassword('');
    expect(aux, false);
  });

  test('Validación de contraseña - Contraseña nula', () {
    bool aux = FormValidators.validateEmptyPassword(null);
    expect(aux, false);
  });

  test('Validación de contraseña - Contraseña menos de 6 carácteres', () {
    bool aux = FormValidators.validateShortPassword("1234");
    expect(aux, false);
  });

  test('Validación de contraseña - Contraseña correcta', () {
    bool aux = FormValidators.validateShortPassword("123456");
    expect(aux, true);
  });

  test('Validación de campo - String vacío', () {
    bool aux = FormValidators.validateNotEmpty('');
    expect(aux, false);
  });

  test('Validación de campo - String correcto', () {
    bool aux = FormValidators.validateNotEmpty("Correcto");
    expect(aux, true);
  });
}
