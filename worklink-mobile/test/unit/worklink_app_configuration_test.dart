import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_app_configuration.dart';

void main() {
  test('GIVEN configuracao padrao WHEN ler nome THEN deve retornar WorkLink',
      () {
    // GIVEN
    const applicationConfiguration = WorkLinkAppConfiguration();

    // WHEN
    final applicationName = applicationConfiguration.applicationName;

    // THEN
    expect(applicationName, 'WorkLink');
  });

  test(
      'GIVEN nome customizado WHEN ler nome THEN deve retornar nome customizado',
      () {
    // GIVEN
    const applicationConfiguration =
        WorkLinkAppConfiguration(applicationName: 'WorkLink Local');

    // WHEN
    final applicationName = applicationConfiguration.applicationName;

    // THEN
    expect(applicationName, 'WorkLink Local');
  });
}
