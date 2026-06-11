import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_controller.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_screen.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_state.dart';

void main() {
  testWidgets(
      'GIVEN perfil cliente WHEN renderizar THEN deve exibir dados e historico minimo',
      (widgetTester) async {
    // GIVEN
    await pumpCustomerProfileScreen(widgetTester);

    // WHEN / THEN
    expect(find.text('Meu perfil'), findsOneWidget);
    expect(find.text('Cliente Exemplo'), findsOneWidget);
    expect(find.text('(51) 9 9999-1234'), findsOneWidget);
    expect(find.text('Conta verificada'), findsOneWidget);
    expect(find.text('Canoas - RS'), findsWidgets);
    expect(find.text('Gerenciar'), findsOneWidget);
    expect(find.text('Profissionais salvos'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsWidgets);
    expect(find.text('Avaliações enviadas'), findsOneWidget);
    expect(find.text('5 de 5 - Anonima publicamente'), findsOneWidget);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets(
      'GIVEN perfil cliente WHEN alterar preferencias THEN deve atualizar controles',
      (widgetTester) async {
    // GIVEN
    final customerProfileController = CustomerProfileController(
      initialState: customerProfileStateFixture(),
    );
    await pumpCustomerProfileScreen(
      widgetTester,
      customerProfileController: customerProfileController,
    );

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('customer-profile-whatsapp-notifications')),
    );
    await widgetTester.pump();
    await widgetTester.tap(
      find.byKey(const ValueKey('customer-profile-personalization')),
    );
    await widgetTester.pump();

    // THEN
    expect(
      customerProfileController.state.whatsappNotificationsEnabled,
      isFalse,
    );
    expect(
      customerProfileController.state.profilePersonalizationEnabled,
      isFalse,
    );
  });

  testWidgets('GIVEN perfil cliente WHEN sair THEN deve executar logout',
      (widgetTester) async {
    // GIVEN
    var logoutCalled = false;
    await pumpCustomerProfileScreen(
      widgetTester,
      onLogout: () {
        logoutCalled = true;
      },
    );

    // WHEN
    await widgetTester
        .tap(find.byKey(const ValueKey('customer-profile-logout')));
    await widgetTester.pump();

    // THEN
    expect(logoutCalled, isTrue);
  });
}

Future<void> pumpCustomerProfileScreen(
  WidgetTester widgetTester, {
  CustomerProfileController? customerProfileController,
  VoidCallback? onLogout,
}) {
  widgetTester.view.physicalSize = const Size(800, 1400);
  widgetTester.view.devicePixelRatio = 1;
  addTearDown(widgetTester.view.resetPhysicalSize);
  addTearDown(widgetTester.view.resetDevicePixelRatio);
  return widgetTester.pumpWidget(
    MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: CustomerProfileScreen(
        customerProfileController: customerProfileController ??
            CustomerProfileController(
              initialState: customerProfileStateFixture(),
            ),
        onLogout: onLogout,
      ),
    ),
  );
}

CustomerProfileState customerProfileStateFixture() {
  return const CustomerProfileState(
    customerName: 'Cliente Exemplo',
    phoneNumber: '(51) 9 9999-1234',
    mainCity: CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
    selectedCities: [
      CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
      CustomerProfileCity(cityName: 'Porto Alegre', stateCode: 'RS'),
    ],
    savedProfessionals: [
      CustomerSavedProfessional(
        professionalIdentifier: 'maria-eletricista',
        professionalName: 'Maria Eletricista',
        categoryName: 'Eletricista',
        cityDisplayName: 'Canoas - RS',
      ),
    ],
    submittedReviews: [
      CustomerSubmittedReview(
        professionalName: 'Maria Eletricista',
        starRating: 5,
        publiclyAnonymous: true,
      ),
    ],
  );
}
