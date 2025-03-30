import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_flutter/services/vehicle_service.dart';
import 'package:project_flutter/services/log_service.dart';

class EditVehiclePage extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final VehicleService? vehicleService;

  const EditVehiclePage({
    Key? key,
    required this.vehicle,
    this.vehicleService,
  }) : super(key: key);

  @override
  _EditVehiclePageState createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  late final VehicleService _vehicleService;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController safetyCheckController;
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    _vehicleService = widget.vehicleService ?? VehicleService();
    safetyCheckController = TextEditingController(
      text: widget.vehicle['no_of_safety_check'].toString(),
    );
    isCompleted = widget.vehicle['isCompleted'] == 1;
    LogService.i('EditVehiclePage initialized for ${widget.vehicle['vehicle_no']}');
  }

  String? validateSafetyChecks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Safety check count is required';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  Future<void> updateVehicleDetails() async {
    if (!_formKey.currentState!.validate()) {
      LogService.w('Form validation failed');
      return;
    }

    final Map<String, dynamic> data = {
      'vehicle_no': widget.vehicle['vehicle_no'],
      'no_of_safety_check': int.parse(safetyCheckController.text.trim()),
      'isCompleted': isCompleted ? 1 : 0,
    };

    LogService.i('Updating vehicle with data: $data');

    try {
      final response = await _vehicleService
          .updateVehicle(data)
          .timeout(const Duration(seconds: 10));

      LogService.i('Update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully')),
        );
        LogService.i('Vehicle ${data['vehicle_no']} updated successfully');
        Navigator.pop(context, true);
      } else {
        LogService.e('Failed to update vehicle: ${response.statusCode}');
        throw Exception('Failed to update vehicle: ${response.statusCode}');
      }
    } on SocketException {
      LogService.e('SocketException: Network error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Check your connection.')),
      );
    } on TimeoutException {
      LogService.e('TimeoutException: Request timed out');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } catch (e) {
      LogService.e('Unexpected error: $e');
      print("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vehicle Number: ${widget.vehicle['vehicle_no']}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: safetyCheckController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'No. of Safety Checks',
                  border: OutlineInputBorder(),
                ),
                validator: validateSafetyChecks,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Is Completed?"),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                      LogService.i('Checkbox changed: isCompleted = $isCompleted');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: updateVehicleDetails,
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
