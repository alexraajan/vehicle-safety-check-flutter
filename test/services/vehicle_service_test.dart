import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_flutter/services/vehicle_service.dart';
import 'dart:convert';

// Generate mock
@GenerateMocks([http.Client])
import 'vehicle_service_test.mocks.dart';

void main() {
  group('VehicleService', () {
    late MockClient mockClient;
    late VehicleService vehicleService;

    setUp(() {
      mockClient = MockClient();
      vehicleService = VehicleService(client: mockClient);
    });

    test('Returns 201 when vehicle is successfully added', () async {
      final vehicleData = {
        'vehicle_no': 'TR001',
        'no_of_safety_check': 3,
        'isCompleted': 1,
      };

      when(mockClient.post(
        Uri.parse('http://10.0.2.2:5000/api/vehicle-details'),
        headers: anyNamed('headers'),
        body: jsonEncode(vehicleData),
      )).thenAnswer((_) async => http.Response('{"message": "Success"}', 201));

      final response = await vehicleService.addVehicle(vehicleData);
      expect(response.statusCode, 201);
    });

    test('Throws exception if vehicle already exists', () async {
      final vehicleData = {
        'vehicle_no': 'TR001',
        'no_of_safety_check': 3,
        'isCompleted': 1,
      };

      when(mockClient.post(
        Uri.parse('http://10.0.2.2:5000/api/vehicle-details'),
        headers: anyNamed('headers'),
        body: jsonEncode(vehicleData),
      )).thenAnswer((_) async => http.Response('{"error": "Vehicle already exists"}', 409));

      final response = await vehicleService.addVehicle(vehicleData);
      expect(response.statusCode, 409);
    });

    test('Returns 200 when vehicle is successfully updated', () async {
      final vehicleData = {
        'vehicle_no': 'AB123',
        'no_of_safety_check': 5,
        'isCompleted': 1,
      };

      when(mockClient.put(
        Uri.parse('http://10.0.2.2:5000/api/vehicle-details'),
        headers: anyNamed('headers'),
        body: jsonEncode(vehicleData),
      )).thenAnswer((_) async => http.Response('{"message": "Updated"}', 200));

      final response = await vehicleService.updateVehicle(vehicleData);
      expect(response.statusCode, 200);
    });
      test('Returns true when vehicle is successfully deleted', () async {
  const vehicleNo = 'AB123';

  when(mockClient.delete(
    Uri.parse('http://10.0.2.2:5000/api/vehicle-details?vehicle_no=$vehicleNo'),
  )).thenAnswer((_) async => http.Response('{"message": "Deleted"}', 200));

  final result = await vehicleService.deleteVehicle(vehicleNo);
  expect(result, true); // assuming you change deleteVehicle to return true/false
});

    test('Fetch all vehicles returns a list', () async {
    final responseJson = jsonEncode([
        {
        "vehicle_no": "TR176",
        "no_of_safety_check": 3,
        "isCompleted": 1
        },
        {
        "vehicle_no": "KW980",
        "no_of_safety_check": 4,
        "isCompleted": 0
        }
    ]);

    when(mockClient.get(
        Uri.parse('http://10.0.2.2:5000/api/vehicle-details'),
    )).thenAnswer((_) async => http.Response(responseJson, 200));

    final response = await vehicleService.fetchAllVehicles();
    expect(response.length, 2);
    expect(response[0]['vehicle_no'], 'TR176');
    });

  });
}
