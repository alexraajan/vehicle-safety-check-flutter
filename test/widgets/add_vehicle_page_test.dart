import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:project_flutter/add_vehicle_page.dart';
import 'package:project_flutter/services/vehicle_service.dart';
import 'package:mockito/annotations.dart';

import 'add_vehicle_page_test.mocks.dart';

@GenerateMocks([VehicleService])
void main() {
  group('AddVehiclePage Widget Test', () {
    late MockVehicleService mockService;

    setUp(() {
      mockService = MockVehicleService();
    });

    testWidgets('Submit form calls addVehicle on VehicleService', (WidgetTester tester) async {
      when(mockService.addVehicle(any)).thenAnswer(
        (_) async => http.Response(jsonEncode({"message": "Success"}), 201),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddVehiclePage(vehicleService: mockService),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'TR123');
      await tester.enterText(find.byType(TextField).at(1), '3');
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.text('Submit'));

      await tester.pumpAndSettle();

      verify(mockService.addVehicle(argThat(predicate<Map<String, dynamic>>(
        (data) => data['vehicle_no'] == 'TR123' && data['no_of_safety_check'] == 3 && data['isCompleted'] == 1,
      )))).called(1);
    });
  });
}
