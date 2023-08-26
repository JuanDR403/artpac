import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artpac/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('Register and Login Test', (WidgetTester tester) async {
    // Configura la base de datos para las pruebas
    final databasePath = join(await getDatabasesPath(), 'flutter.db');
    final databaseFactory = databaseFactoryFfi;

    final database = await databaseFactory.openDatabase(databasePath);

    // Inicia la aplicación
    await tester.pumpWidget(MyApp());

    // Prueba de registro y navegación a la pantalla de login
    await tester.tap(find.byKey(Key('register_button')));
    await tester.pumpAndSettle(); // Espera a que la navegación termine

    // Ingresa los datos de registro
    await tester.enterText(find.byKey(Key('username_field')), 'testuser');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    // Ingresa otros campos necesarios

    // Toca el botón de registro
    await tester.tap(find.byKey(Key('register_submit_button')));
    await tester.pumpAndSettle(); // Espera a que se complete el registro

    // Verifica que se haya realizado el registro y se haya navegado a la pantalla de inicio de sesión
    expect(find.text('Login'), findsOneWidget);

    // Realiza pruebas de login (puedes implementar esta parte similar al registro)

    await database.close();
    await deleteDatabase(
        databasePath); // Elimina la base de datos después de la prueba
  });
}

void sqfliteFfiInit() {}

mixin databaseFactoryFfi {}
