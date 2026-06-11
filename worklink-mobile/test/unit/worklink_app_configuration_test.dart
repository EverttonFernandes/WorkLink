import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_app_configuration.dart';

void main() {
  test(
      'GIVEN configuracao padrao WHEN ler nome THEN deve retornar Profissional Perto',
      () {
    // GIVEN
    const applicationConfiguration = WorkLinkAppConfiguration();

    // WHEN
    final applicationName = applicationConfiguration.applicationName;

    // THEN
    expect(applicationName, 'Profissional Perto');
  });

  test(
      'GIVEN nome customizado WHEN ler nome THEN deve retornar nome customizado',
      () {
    // GIVEN
    const applicationConfiguration =
        WorkLinkAppConfiguration(applicationName: 'Profissional Perto Local');

    // WHEN
    final applicationName = applicationConfiguration.applicationName;

    // THEN
    expect(applicationName, 'Profissional Perto Local');
  });
}
