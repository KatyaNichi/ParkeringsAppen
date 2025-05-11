// lib/screens/parkings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import BLoC classes
import 'package:parking_app_flutter/blocs/parking/parking_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_event.dart';
import 'package:parking_app_flutter/blocs/parking/parking_state.dart';

import 'package:parking_app_flutter/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_state.dart';

import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_state.dart';

// Import models
import 'package:parking_app_flutter/models/parking.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/vehicle.dart';

// Import services
import 'package:parking_app_flutter/services/user_service.dart';

class ParkingsScreen extends StatefulWidget {
  const ParkingsScreen({super.key});

  @override
  _ParkingsScreenState createState() => _ParkingsScreenState();
}


class _ParkingsScreenState extends State<ParkingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ParkingSpace> _parkingSpaces = [];
  List<Vehicle> _userVehicles = [];
  List<Parking> _parkingHistory = [];
  List<Parking> _activeParkings = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
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
    
    // Load data
    _loadData();
  }

  // Load all necessary data using BLoCs
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get the current user
      final currentUser = UserService().currentUser;
      if (currentUser != null) {
        // Load user vehicles
        context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
      }

      // Load parking spaces
      context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());

      // Load active parkings
      context.read<ParkingBloc>().add(LoadActiveParkings());

      // Load all parkings (for history)
      context.read<ParkingBloc>().add(LoadParkings());

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

  // End a parking
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
    
    // Format current time as HH:MM
    final now = DateTime.now();
    final endTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Dispatch the event to end the parking
    context.read<ParkingBloc>().add(EndParking(
      parkingId: parking.id,
      endTime: endTime,
    ));
  }

  @override
  // Tab for displaying active parkings
  Widget _buildActiveParkingsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ParkingBloc>().add(LoadActiveParkings());
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
                        // Navigate to the ParkingSpacesScreen
                        _tabController.animateTo(0); // Switch to first tab in parent screen
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
                          owner: _userVehicles.isNotEmpty ? _userVehicles.first.owner : null!,
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
        context.read<ParkingBloc>().add(LoadParkings());
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
  
  Widget build(BuildContext context) {
    // Listen to BLoC states to update the local data
    return MultiBlocListener(
      listeners: [
        // Listen to VehicleBloc
        BlocListener<VehicleBloc, VehicleState>(
          listener: (context, state) {
            if (state is VehicleLoaded) {
              setState(() {
                _userVehicles = state.vehicles;
              });
            } else if (state is VehicleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
        // Listen to ParkingSpaceBloc
        BlocListener<ParkingSpaceBloc, ParkingSpaceState>(
          listener: (context, state) {
            if (state is ParkingSpaceLoaded) {
              setState(() {
                _parkingSpaces = state.parkingSpaces;
              });
            } else if (state is ParkingSpaceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
        // Listen to ParkingBloc
        BlocListener<ParkingBloc, ParkingState>(
          listener: (context, state) {
            if (state is ParkingLoaded) {
              setState(() {
                _parkingHistory = state.parkings.where((p) => p.endTime != null).toList();
              });
            } else if (state is ActiveParkingsLoaded) {
              setState(() {
                _activeParkings = state.activeParkings;
              });
            } else if (state is ParkingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is ParkingOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ParkingBloc, ParkingState>(
        builder: (context, state) {
          if (_isLoading || state is ParkingLoading) {
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
                tabs: const [
                  Tab(text: 'Aktiva parkeringar'), 
                  Tab(text: 'Historik')
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveParkingsTab(), 
                    _buildParkingHistoryTab()
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );}}