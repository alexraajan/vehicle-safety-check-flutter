import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  final String baseUrl = 'http://10.0.2.2:5000/api';
  final http.Client client;
  VehicleService({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/vehicle-details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicleData),
      );
      return response;
    } catch (e) {
      print("Add vehicle error: $e");
      rethrow;
    }
  }

  Future<http.Response> updateVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/vehicle-details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicleData),
      );
      return response;
    } catch (e) {
      print("Update vehicle error: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> searchVehicle(String vehicleNo) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/vehicle-details?vehicle_no=$vehicleNo'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is List ? decoded : [decoded];
      } else if (response.statusCode == 404) {
        return []; // Not found — return empty list to UI
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Search vehicle error: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> fetchAllVehicles() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/vehicle-details'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Fetch all vehicles error: $e");
      rethrow;
    }
  }

  Future<bool> deleteVehicle(String vehicleNo) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/vehicle-details?vehicle_no=$vehicleNo'));
      return response.statusCode == 200;
    } catch (e) {
      print("Delete vehicle error: $e");
      return false; // You could also rethrow and handle it higher up
    }
  }
}
