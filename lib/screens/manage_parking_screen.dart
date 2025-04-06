import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageParkingScreen extends StatefulWidget {
  final ParkingSpace parkingSpace;
  
  const ManageParkingScreen({super.key, required this.parkingSpace});

  @override
  _ManageParkingScreenState createState() => _ManageParkingScreenState();
}

class _ManageParkingScreenState extends State<ManageParkingScreen> {
  final _apiService = ApiService(baseUrl: 'http://192.168.88.39:8080');
  bool _isLoading = true;
  String _errorMessage = '';
  List<Vehicle> _userVehicles = [];
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
  }
  
  Future<void> _loadUserVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get current user from UserService
      final currentUser = UserService().currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Ingen användare inloggad';
          _isLoading = false;
        });
        return;
      }
      
      // Get vehicles for the current user
      final vehiclesData = await _apiService.getList('/api/vehicles/owner/${currentUser.id}');
      setState(() {
        _userVehicles = vehiclesData.map<Vehicle>((data) => Vehicle.fromJson(data)).toList();
        if (_userVehicles.isNotEmpty) {
          _selectedVehicle = _userVehicles.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda fordon: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _startParking() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Välj ett fordon först')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // First, check if the vehicle is already parked somewhere
      final activeParkings = await _apiService.getList('/api/parkings/active');
      
      // Check if any active parking is using this vehicle
      final isAlreadyParked = activeParkings.any((p) => 
        p['fordon'] == _selectedVehicle!.id.toString()
      );
      
      if (isAlreadyParked) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedVehicle!.type} (${_selectedVehicle!.registrationNumber}) är redan parkerad. Avsluta den parkeringen först.')),
        );
        return;
      }
      
      // Format current time as HH:MM
      final now = DateTime.now();
      final startTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      await _apiService.createItem('/api/parkings', {
        'fordon': _selectedVehicle!.id.toString(),
        'parkingPlace': widget.parkingSpace.id.toString(),
        'startTime': startTime,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parkering startad för ${_selectedVehicle!.type}')),
      );
      
      // Navigate back to main screen and switch to parking tab
      Navigator.pop(context, true); // Return true to indicate a parking was started
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kunde inte starta parkering: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte starta parkering: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starta parkering'),
        backgroundColor: const Color(0xFF0078D7),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserVehicles,
                        child: const Text('Försök igen'),
                      ),
                    ],
                  ),
                )
              : _userVehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Du har inga registrerade fordon',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to vehicles tab
                              Navigator.pop(context);
                              // You might need additional logic to switch to vehicles tab
                            },
                            child: const Text('Lägg till fordon'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parking space info
                          Card(
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Parkeringsplats',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.parkingSpace.adress,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pris: ${widget.parkingSpace.pricePerHour} kr/timme',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Vehicle selection
                          const Text(
                            'Välj fordon',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Vehicle selection cards
                          Expanded(
                            child: ListView.builder(
                              itemCount: _userVehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = _userVehicles[index];
                                final isSelected = vehicle.id == _selectedVehicle?.id;
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? const Color(0xFF0078D7) : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  elevation: isSelected ? 4 : 1,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedVehicle = vehicle;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            vehicle.type.toLowerCase() == 'bil' ? Icons.directions_car :
                                            vehicle.type.toLowerCase() == 'buss' ? Icons.directions_bus :
                                            vehicle.type.toLowerCase() == 'lastbil' ? Icons.local_shipping :
                                            Icons.directions_car,
                                            size: 36,
                                            color: isSelected ? const Color(0xFF0078D7) : Colors.grey,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vehicle.type,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text('Reg nr: ${vehicle.registrationNumber}'),
                                              ],
                                            ),
                                          ),
                                          Radio<Vehicle>(
                                            value: vehicle,
                                            groupValue: _selectedVehicle,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedVehicle = value;
                                              });
                                            },
                                            activeColor: const Color(0xFF0078D7),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: _isLoading || _errorMessage.isNotEmpty || _userVehicles.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _startParking,
                  child: const Text(
                    'Starta parkering',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
    );
  }
}