import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_app_flutter/models/parking.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class ParkingsScreen extends StatefulWidget {
  const ParkingsScreen({super.key});

  @override
  _ParkingsScreenState createState() => _ParkingsScreenState();
}

class _ParkingsScreenState extends State<ParkingsScreen>
    with SingleTickerProviderStateMixin {
  final _apiService = ApiService(baseUrl: 'http://192.168.88.39:8080');
  bool _isLoading = true;
  String _errorMessage = '';

  List<ParkingSpace> _parkingSpaces = [];
  List<Vehicle> _userVehicles = [];
  List<Parking> _parkingHistory = [];
  List<Parking> _activeParkings = [];

  late TabController _tabController;

@override
void initState() {
  super.initState();
  
  // Initialize the tab controller with 2 tabs
  _tabController = TabController(length: 2, vsync: this);
  
  // Check if user is logged in
  final currentUser = UserService().currentUser;
  if (currentUser == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingen användare inloggad. Logga in igen.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Redirect to login
      Navigator.pushReplacementNamed(context, '/');
    });
    return;
  }
  
  // Continue with normal initialization
  _loadData();
}

  // Load all necessary data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load parking spaces, user vehicles, active parkings and parking history
      await Future.wait([
        _loadParkingSpaces(),
        _loadUserVehicles(),
        _loadParkingHistory(),
        _loadActiveParkings(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ett fel uppstod: $e';
        _isLoading = false;
      });
    }
  }

  // Load available parking spaces
  Future<void> _loadParkingSpaces() async {
    try {
      final spacesData = await _apiService.getList('/api/parkingSpaces');
      setState(() {
        _parkingSpaces =
            spacesData
                .map<ParkingSpace>((data) => ParkingSpace.fromJson(data))
                .toList();
      });
    } catch (e) {
      throw Exception('Kunde inte ladda parkeringsplatser: $e');
    }
  }

  // Load user's vehicles
 Future<void> _loadUserVehicles() async {
  try {
    // Get current user
    final currentUser = UserService().currentUser;
    if (currentUser == null) {
      throw Exception('Ingen användare inloggad');
    }
    
    final vehiclesData = await _apiService.getList('/api/vehicles/owner/${currentUser.id}');
    setState(() {
      _userVehicles = vehiclesData.map<Vehicle>((data) => Vehicle.fromJson(data)).toList();
    });
  } catch (e) {
    throw Exception('Kunde inte ladda fordon: $e');
  }
}

  // Load parking history
 Future<void> _loadParkingHistory() async {
  try {
    final parkingsData = await _apiService.getList('/api/parkings');
    final currentUser = UserService().currentUser;
    
    // Get the user's vehicle IDs as strings
    final userVehicleIds = _userVehicles.map((v) => v.id.toString()).toSet();
    
    setState(() {
      // Only include parkings for the user's vehicles and with an end time
      _parkingHistory = parkingsData
          .map<Parking>((data) => Parking.fromJson(data))
          .where((parking) => 
              parking.endTime != null && 
              userVehicleIds.contains(parking.fordon))
          .toList();
    });
  } catch (e) {
    throw Exception('Kunde inte ladda parkeringshistorik: $e');
  }
}

  // Load active parkings
  Future<void> _loadActiveParkings() async {
    try {
      final activeParkingsData = await _apiService.getList(
        '/api/parkings/active',
      );
      setState(() {
        _activeParkings =
            activeParkingsData
                .map<Parking>((data) => Parking.fromJson(data))
                .toList();
      });
    } catch (e) {
      throw Exception('Kunde inte ladda aktiva parkeringar: $e');
    }
  }


Future<void> _endParking(Parking parking) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Avsluta parkering'),
      content: const Text('Är du säker på att du vill avsluta denna parkering?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Avbryt'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Avsluta', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  
  if (confirm != true) return;
  
  setState(() => _isLoading = true);
  
  try {
    // Format current time as HH:MM
    final now = DateTime.now();
    final endTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Use the correct endpoint URL for ending a parking
    final response = await http.put(
      Uri.parse('${_apiService.baseUrl}/api/parkings/${parking.id}/end'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"endTime": endTime}),
    );
    
    if (response.statusCode == 200) {
      // Remove this parking from active parkings
      setState(() {
        _activeParkings.removeWhere((p) => p.id == parking.id);
      });
      
      // Reload data to update the history
      await _loadParkingHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkering avslutad')),
      );
    } else {
      throw Exception('Failed to end parking: ${response.body}');
    }
    
    setState(() => _isLoading = false);
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Kunde inte avsluta parkering: $e';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kunde inte avsluta parkering: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
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
              onPressed: _loadData,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0078D7),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0078D7),
          tabs: const [Tab(text: 'Aktiva parkeringar'), Tab(text: 'Historik')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildActiveParkingsTab(), _buildParkingHistoryTab()],
          ),
        ),
      ],
    );
  }

  // Tab for displaying active parkings
  Widget _buildActiveParkingsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadActiveParkings();
      },
      child:
          _activeParkings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Du har inga aktiva parkeringar',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0078D7),
    foregroundColor: Colors.white,
  ),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hitta parkeringsplats'),
        content: const Text('Gå till fliken "Parkeringsplatser" för att hitta och välja en tillgänglig parkeringsplats.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  },
  child: const Text('Hitta parkeringsplats'),
),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _activeParkings.length,
                itemBuilder: (context, index) {
                  final parking = _activeParkings[index];

                  // Find vehicle and parking space details
                  final vehicle = _userVehicles.firstWhere(
                    (v) => v.id.toString() == parking.fordon,
                    orElse:
                        () => Vehicle(
                          id: -1,
                          type: 'Okänt fordon',
                          registrationNumber: 0,
                          owner: _userVehicles.first.owner,
                        ),
                  );

                  final parkingSpace = _parkingSpaces.firstWhere(
                    (s) => s.id.toString() == parking.parkingPlace,
                    orElse:
                        () => ParkingSpace(
                          id: -1,
                          adress: 'Okänd plats',
                          pricePerHour: 0,
                        ),
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${vehicle.type} (${vehicle.registrationNumber})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Plats: ${parkingSpace.adress}'),
                                    Text(
                                      'Pris: ${parkingSpace.pricePerHour} kr/timme',
                                    ),
                                    Text('Starttid: ${parking.startTime}'),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _endParking(parking),
                                child: const Text('Avsluta'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Tab for displaying parking history
  Widget _buildParkingHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadParkingHistory();
      },
      child:
          _parkingHistory.isEmpty
              ? const Center(child: Text('Ingen parkeringshistorik'))
              : ListView.builder(
                itemCount: _parkingHistory.length,
                itemBuilder: (context, index) {
                  final parking = _parkingHistory[index];

                  // Find vehicle and parking space details
                  final vehicle = _userVehicles.firstWhere(
                    (v) => v.id.toString() == parking.fordon,
                    orElse:
                        () => Vehicle(
                          id: -1,
                          type: 'Okänt fordon',
                          registrationNumber: 0,
                          owner:
                              _userVehicles.isNotEmpty
                                  ? _userVehicles.first.owner
                                  : null!,
                        ),
                  );

                  final parkingSpace = _parkingSpaces.firstWhere(
                    (s) => s.id.toString() == parking.parkingPlace,
                    orElse:
                        () => ParkingSpace(
                          id: -1,
                          adress: 'Okänd plats',
                          pricePerHour: 0,
                        ),
                  );

                  // Calculate duration if available
                  String duration = 'N/A';
                  double cost = 0;

                  if (parking.startTime != null && parking.endTime != null) {
                    // Parse times (assuming format like "HH:MM")
                    final startParts = parking.startTime!.split(':');
                    final endParts = parking.endTime!.split(':');

                    if (startParts.length == 2 && endParts.length == 2) {
                      try {
                        final startHour = int.parse(startParts[0]);
                        final startMinute = int.parse(startParts[1]);
                        final endHour = int.parse(endParts[0]);
                        final endMinute = int.parse(endParts[1]);

                        // Create DateTime objects for today with these times
                        final now = DateTime.now();
                        final start = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          startHour,
                          startMinute,
                        );
                        var end = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          endHour,
                          endMinute,
                        );

                        // If end time is before start time, assume it's the next day
                        if (end.isBefore(start)) {
                          end = end.add(const Duration(days: 1));
                        }

                        final difference = end.difference(start);
                        final hours = difference.inHours;
                        final minutes = difference.inMinutes % 60;

                        duration = '$hours tim $minutes min';

                        // Calculate cost (hours + partial hour if minutes > 0)
                        final hoursFraction = hours + (minutes > 0 ? 1 : 0);
                       cost = parkingSpace.pricePerHour.toDouble() * hoursFraction;
                      } catch (e) {
                        // Fallback if parsing fails
                        duration = 'N/A';
                      }
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.type} (${vehicle.registrationNumber})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Plats: ${parkingSpace.adress}'),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Från: ${parking.startTime}'),
                              ),
                              Expanded(child: Text('Till: ${parking.endTime}')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Varaktighet: $duration'),
                          Text('Kostnad: ${cost.toStringAsFixed(0)} kr'),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
