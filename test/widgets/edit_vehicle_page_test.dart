import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:project_flutter/edit_vehicle_page.dart';
import 'package:project_flutter/services/vehicle_service.dart';

import 'edit_vehicle_page_test.mocks.dart';

@GenerateMocks([VehicleService])
void main() {
  group('EditVehiclePage Widget Test', () {
    late MockVehicleService mockService;

    setUp(() {
      mockService = MockVehicleService();
    });

    final mockVehicle = {
      'vehicle_no': 'TR1234',
      'no_of_safety_check': 3,
      'isCompleted': 1,
    };

    testWidgets('Form validation error when input is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditVehiclePage(vehicle: mockVehicle),
        ),
      );

      // Clear the input
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.textContaining('Safety check count is required'), findsOneWidget);
    });
  });
}
