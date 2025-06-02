// lib/screens/parkings_screen.dart (Enhanced with notifications)
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
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/models/vehicle.dart';

// Import services
import 'package:parking_app_flutter/services/user_service.dart';
import 'package:parking_app_flutter/services/notification_service.dart';

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

  final NotificationService _notificationService = NotificationService();

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
  
  // Start real-time data streams instead of one-time loads
  _loadDataWithStreams();
}

// Replace the old _loadData method with this new one:
Future<void> _loadDataWithStreams() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    // Get the current user
    final currentUser = UserService().currentUser;
    if (currentUser != null) {
      // Load user vehicles (one-time load for now, can be converted to stream later)
      context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
    }

    // Load parking spaces (one-time load for now)
    context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());

    // 🔥 REAL-TIME: Start listening to active parkings stream
    context.read<ParkingBloc>().add(LoadActiveParkingsStream());

    // Load all parkings for history (one-time load)
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

    // 🔥 NEW: Use stream for real-time active parkings
    context.read<ParkingBloc>().add(LoadActiveParkingsStream());

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

  // End a parking and cancel its notification
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
  
  // 🔍 DEBUG: Check what we're trying to cancel
  print('🔍 DEBUG: Trying to cancel notification...');
  print('  - parking.id: ${parking.id}');
  print('  - parking.notificationId: ${parking.notificationId}');
  
  // 🔔 NOTIFICATION: Cancel notification if it exists
  if (parking.notificationId != null) {
    try {
      await _notificationService.cancelParkingReminder(parking.notificationId!);
      print('✅ Successfully cancelled notification: ${parking.notificationId}');
    } catch (e) {
      print('❌ Failed to cancel notification: $e');
    }
  } else {
    print('⚠️ No notificationId found in parking record');
  }
    
    // 🔔 NOTIFICATION: Cancel notification if it exists
    if (parking.notificationId != null) {
      try {
        await _notificationService.cancelParkingReminder(parking.notificationId!);
        print('📱 Cancelled notification for parking ${parking.id}');
      } catch (e) {
        print('⚠️ Failed to cancel notification: $e');
      }
    }
    
    // Format current time as HH:MM
    final now = DateTime.now();
    final endTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Dispatch the event to end the parking
    context.read<ParkingBloc>().add(EndParking(
      parkingId: parking.id,
      endTime: endTime,
    ));
  }

  // 🔔 NOTIFICATION: Extend parking time (VG feature)
  Future<void> _extendParking(Parking parking) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Förläng parkering'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Välj antal timmar att förlänga:'),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final hours = index + 1;
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('$hours ${hours == 1 ? 'timme' : 'timmar'}'),
                onTap: () => Navigator.of(context).pop(hours),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
        ],
      ),
    );
    
    if (result == null) return;
    
    try {
      // Cancel existing notification
      if (parking.notificationId != null) {
        await _notificationService.cancelParkingReminder(parking.notificationId!);
      }
      
      // Find vehicle and parking space
      final vehicle = _userVehicles.firstWhere(
        (v) => v.id.toString() == parking.fordon,
        orElse: () => throw Exception('Vehicle not found'),
      );
      
      final parkingSpace = _parkingSpaces.firstWhere(
        (s) => s.id.toString() == parking.parkingPlace,
        orElse: () => throw Exception('Parking space not found'),
      );
      
      // Schedule new notification with extended time
      final currentDuration = parking.estimatedDurationHours ?? 2;
      final newDuration = currentDuration + result;
      
      final newNotificationId = await _notificationService.scheduleReminderForExistingParking(
        vehicle: vehicle,
        parkingSpace: parkingSpace,
        startTimeString: parking.startTime!,
        estimatedDurationHours: newDuration,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📱 Parkering förlängd med $result ${result == 1 ? 'timme' : 'timmar'}. Ny påminnelse schemalagd.')),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Kunde inte förlänga parkering: $e')),
      );
    }
  }

  // 🔔 NOTIFICATION: Show notification debug info
  Future<void> _showNotificationDebug() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📱 Aktiva påminnelser'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final notification = pending[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notification.title ?? 'Ingen titel'),
                  subtitle: Text(notification.body ?? 'Ingen beskrivning'),
                  trailing: Text('ID: ${notification.id}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _notificationService.cancelAllParkingReminders();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🗑️ Alla påminnelser avbrutna')),
                );
              },
              child: const Text('Avbryt alla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stäng'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Kunde inte ladda notifikationer: $e')),
      );
    }
  }

 Widget _buildActiveParkingsTab() {
  return RefreshIndicator(
    onRefresh: () async {
      // OLD WAY: context.read<ParkingBloc>().add(LoadActiveParkings());
      
      // NEW WAY: Restart the real-time stream
      context.read<ParkingBloc>().add(LoadActiveParkingsStream());
    },
    child: _activeParkings.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_parking,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
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
                  // Navigate to parking spaces to start a new parking
                  _tabController.animateTo(0);
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
                orElse: () => Vehicle(
                  id: '-1',
                  type: 'Okänt fordon',
                  registrationNumber: 0,
                  owner: _userVehicles.isNotEmpty 
                      ? _userVehicles.first.owner 
                      : Person(
                          id: '-1',
                          name: 'Okänd ägare',
                          personnummer: 0,
                        ),
                ),
              );

              final parkingSpace = _parkingSpaces.firstWhere(
                (s) => s.id.toString() == parking.parkingPlace,
                orElse: () => ParkingSpace(
                  id: '-1',
                  adress: 'Okänd plats',
                  pricePerHour: 0,
                ),
              );

              // Calculate time information
              String timeInfo = 'Starttid: ${parking.startTime}';
              String statusInfo = '';
              
              if (parking.estimatedDurationHours != null && parking.startTime != null) {
                try {
                  final startTime = _notificationService.parseStartTime(parking.startTime!);
                  final endTime = startTime.add(Duration(hours: parking.estimatedDurationHours!));
                  final now = DateTime.now();
                  
                  if (endTime.isAfter(now)) {
                    final timeLeft = endTime.difference(now);
                    if (timeLeft.inHours > 0) {
                      statusInfo = '⏰ ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}min kvar';
                    } else {
                      statusInfo = '⏰ ${timeLeft.inMinutes}min kvar';
                    }
                  } else {
                    statusInfo = '⚠️ Parkeringstid har gått ut';
                  }
                } catch (e) {
                  statusInfo = '';
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
                      Row(
                        children: [
                          Icon(
                            vehicle.type.toLowerCase() == 'bil' ? Icons.directions_car :
                            vehicle.type.toLowerCase() == 'buss' ? Icons.directions_bus :
                            vehicle.type.toLowerCase() == 'lastbil' ? Icons.local_shipping :
                            Icons.directions_car,
                            color: const Color(0xFF0078D7),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
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
                                const SizedBox(height: 4),
                                Text(
                                  parkingSpace.adress,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (statusInfo.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    statusInfo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: statusInfo.contains('⚠️') ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // 🔔 NOTIFICATION: Notification indicator
                          if (parking.notificationId != null)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pris: ${parkingSpace.pricePerHour} kr/timme'),
                                Text(timeInfo),
                                if (parking.estimatedDurationHours != null)
                                  Text('Planerad tid: ${parking.estimatedDurationHours} timmar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 🔔 NOTIFICATION: Extend parking button (VG feature)
                          TextButton.icon(
                            onPressed: () => _extendParking(parking),
                            icon: const Icon(Icons.add_alarm, size: 20),
                            label: const Text('Förläng'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0078D7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _endParking(parking),
                            icon: const Icon(Icons.stop, size: 20),
                            label: const Text('Avsluta'),
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

  Widget _buildParkingHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ParkingBloc>().add(LoadParkings());
      },
      child: _parkingHistory.isEmpty
          ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Ingen parkeringshistorik',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
          : ListView.builder(
            itemCount: _parkingHistory.length,
            itemBuilder: (context, index) {
              final parking = _parkingHistory[index];
              // Implementation for history items...
              return ListTile(
                title: Text('Historik ${index + 1}'),
                subtitle: Text('${parking.startTime} - ${parking.endTime}'),
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
    return MultiBlocListener(
      listeners: [
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parkeringar'),
          backgroundColor: const Color(0xFF0078D7),
          foregroundColor: Colors.white,
          actions: [
            // 🔔 NOTIFICATION: Debug notifications button
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: _showNotificationDebug,
              tooltip: 'Visa påminnelser',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Uppdatera',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Aktiva parkeringar'),
              Tab(text: 'Historik'),
            ],
          ),
        ),
        body: BlocBuilder<ParkingBloc, ParkingState>(
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

            return TabBarView(
              controller: _tabController,
              children: [
                _buildActiveParkingsTab(),
                _buildParkingHistoryTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}