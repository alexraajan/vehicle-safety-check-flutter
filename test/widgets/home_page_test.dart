// test/home_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:project_flutter/home.dart';
import 'package:project_flutter/services/vehicle_service.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([VehicleService])
void main() {
  group('Home Page Widget Tests', () {
    late MockVehicleService mockService;

    setUp(() {
      mockService = MockVehicleService();
    });

    testWidgets('Search field validation error', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.enterText(find.byType(TextFormField), 'AB');
      await tester.tap(find.text('Search Vehicle'));
      await tester.pump();

      expect(find.textContaining('Invalid vehicle number'), findsOneWidget);
    });

   

    testWidgets('Navigate to Add Vehicle Page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Home()));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add Vehicle'), findsOneWidget);
    });

  });
}