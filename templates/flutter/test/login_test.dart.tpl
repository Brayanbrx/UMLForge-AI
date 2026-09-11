import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/schema.dart';
import '../lib/data/api.dart';
import '../lib/ui/app_model.dart';
import '../lib/main.dart';

void main() {
  testWidgets(
    'login accesible a 360px, sin desbordamiento y sin credenciales incrustadas',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final schema = AppSchema({
        'resources': [
          {
            'className': 'Cliente',
            'path': '/api/clientes',
            'primaryKey': 'id',
            'fields': [
              {
                'name': 'id',
                'javaType': 'String',
                'nullable': false,
                'primaryKey': true,
              },
            ],
          },
        ],
      });
      final model = AppModel(schema, ApiClient(), SessionStore());
      await tester.pumpWidget(ManagementApp(model));
      expect(find.text('Iniciar sesion'), findsOneWidget);
      final password = tester
          .widgetList<TextField>(find.byType(TextField))
          .firstWhere((f) => f.obscureText);
      expect(password.controller!.text, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
}
