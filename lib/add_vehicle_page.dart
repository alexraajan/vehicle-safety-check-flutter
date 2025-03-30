import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_flutter/services/vehicle_service.dart';
import 'package:project_flutter/services/log_service.dart'; // <-- Add LogService

class AddVehiclePage extends StatefulWidget {
  final VehicleService? vehicleService;
  const AddVehiclePage({Key? key, this.vehicleService}) : super(key: key);

  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  late final VehicleService _vehicleService;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController safetyCheckController = TextEditingController();
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _vehicleService = widget.vehicleService ?? VehicleService();
    LogService.i('AddVehiclePage initialized');
  }

  String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle number is required';
    }

    final cleaned = value.trim().toUpperCase();
    final vehicleNoReg = RegExp(r'^[A-Z0-9\- ]{5,10}$');

    if (!vehicleNoReg.hasMatch(cleaned)) {
      return 'Invalid vehicle number (5–10 chars: A-Z, 0–9, hyphen, space)';
    }

    return null;
  }

  String? validateSafetyChecks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Number of safety checks is required';
    }

    final num = int.tryParse(value.trim());
    if (num == null || num <= 0) {
      return 'Enter a valid positive number';
    }

    return null;
  }

  Future<void> submitVehicleDetails() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      LogService.w('Form validation failed');
      return;
    }

    final Map<String, dynamic> data = {
      'vehicle_no': vehicleNoController.text.trim().toUpperCase(),
      'no_of_safety_check': int.parse(safetyCheckController.text.trim()),
      'isCompleted': isCompleted ? 1 : 0,
    };

    LogService.i('Submitting vehicle: $data');

    try {
      final response = await _vehicleService
          .addVehicle(data)
          .timeout(const Duration(seconds: 10));

      LogService.i('Vehicle add response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
        LogService.i('Vehicle added successfully');
        Navigator.pop(context, true);
      } else if (response.statusCode == 409) {
        try {
          final error = jsonDecode(response.body)['error'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Duplicate entry')),
          );
          LogService.w('Duplicate entry error: ${response.body}');
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Duplicate entry')),
          );
          LogService.w('Duplicate entry caught without body');
        }
      } else {
        LogService.e('Failed to add vehicle: ${response.statusCode}');
        throw Exception('Failed to add vehicle: ${response.statusCode}');
      }
    } on SocketException {
      LogService.e('SocketException: No internet connection');
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
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: vehicleNoController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                validator: validateVehicleNumber,
              ),
              TextFormField(
                controller: safetyCheckController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'No. of Safety Checks'),
                validator: validateSafetyChecks,
              ),
              Row(
                children: [
                  const Text("Is Completed?"),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                      LogService.i('Checkbox changed: $isCompleted');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitVehicleDetails,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
