import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_flutter/services/vehicle_service.dart';
import 'add_vehicle_page.dart';
import 'edit_vehicle_page.dart';
import 'package:project_flutter/services/log_service.dart';

class Home extends StatefulWidget {
  final VehicleService? vehicleService;
  const Home({Key? key, this.vehicleService}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final VehicleService _vehicleService;
  final _searchFormKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();

  List<dynamic> vehicleData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _vehicleService = widget.vehicleService ?? VehicleService();
    LogService.i('Initializing Home screen');
    fetchAllVehicles();
  }

  String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }    
    return null;
  }

  void showError(String message) {
    LogService.e(message);
    setState(() {
      vehicleData = [];
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchAllVehicles() async {
    LogService.i('Fetching all vehicles');
    setState(() => isLoading = true);
    try {
      final data = await _vehicleService.fetchAllVehicles()
          .timeout(const Duration(seconds: 10));
      LogService.d('Fetched ${data.length} vehicles');
      setState(() {
        vehicleData = data;
        isLoading = false;
      });
    } on SocketException {
      showError('Network error. Please check your internet connection.');
    } on TimeoutException {
      showError('Request timed out. Try again later.');
    } catch (e) {
      LogService.e('Error fetching vehicles: $e');
      showError('Failed to fetch vehicles.');
    }
  }

  Future<void> searchVehicle(String vehicleNo) async {
    LogService.i('Searching for vehicle: $vehicleNo');
    setState(() => isLoading = true);
    try {
      final data = await _vehicleService.searchVehicle(vehicleNo)
          .timeout(const Duration(seconds: 10));
      LogService.d('Search returned ${data.length} record(s)');
      setState(() {
        vehicleData = data;
        isLoading = false;
      });
    } on SocketException {
      showError('Network error. Please check your connection.');
    } on TimeoutException {
      showError('Search request timed out.');
    } catch (e) {
      LogService.e('Search error: $e');
      showError('Error searching for the vehicle.');
    }
  }

  Future<void> confirmAndDelete(String vehicleNo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$vehicleNo"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      LogService.w('Attempting to delete vehicle: $vehicleNo');
      final deleted = await _vehicleService.deleteVehicle(vehicleNo)
          .timeout(const Duration(seconds: 10));

      if (deleted) {
        LogService.i('Deleted vehicle: $vehicleNo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle $vehicleNo deleted successfully')),
        );
        fetchAllVehicles();
      } else {
        showError('Failed to delete vehicle.');
      }
    } on SocketException {
      showError('Network error. Unable to delete.');
    } on TimeoutException {
      showError('Delete request timed out.');
    } catch (e) {
      LogService.e('Error deleting vehicle: $e');
      showError('An error occurred while deleting.');
    }
  }

  void navigateToAddVehiclePage() async {
    LogService.i('Navigating to AddVehiclePage');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVehiclePage()),
    );
    if (result == true) {
      fetchAllVehicles();
    }
  }

  void navigateToEditVehiclePage(Map<String, dynamic> vehicle) async {
    LogService.i('Navigating to EditVehiclePage for ${vehicle['vehicle_no']}');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditVehiclePage(vehicle: vehicle)),
    );
    if (result == true) {
      fetchAllVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Safety Check')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Form(
                  key: _searchFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: searchController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Enter Vehicle Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateVehicleNumber,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final query = searchController.text.trim();
                          if (query.isEmpty) {
                            fetchAllVehicles();
                          } else if (_searchFormKey.currentState!.validate()) {
                            searchVehicle(query.toUpperCase());
                          }
                        },
                        child: const Text('Search Vehicle'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vehicleData.isEmpty
                          ? const Center(child: Text('No vehicle data found.'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                columns: const [
                                  DataColumn(label: Text('Vehicle No')),
                                  DataColumn(label: Text('Safety Checks')),
                                  DataColumn(label: Text('Completed')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: vehicleData.map((vehicle) {
                                  return DataRow(cells: [
                                    DataCell(Text(vehicle['vehicle_no'].toString())),
                                    DataCell(Text(vehicle['no_of_safety_check'].toString())),
                                    DataCell(Text(vehicle['isCompleted'] == 1 ? 'Yes' : 'No')),
                                    DataCell(
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            navigateToEditVehiclePage(vehicle);
                                          } else if (value == 'delete') {
                                            confirmAndDelete(vehicle['vehicle_no']);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit, color: Colors.blue),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red),
                                              title: Text('Delete'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: navigateToAddVehiclePage,
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
              tooltip: 'Add Vehicle',
              mini: true,
            ),
          ),
        ],
      ),
    );
  }
}