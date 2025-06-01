// lib/screens/manage_parking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_event.dart';
import 'package:parking_app_flutter/blocs/parking/parking_state.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/services/user_service.dart';
import 'package:parking_app_flutter/services/notification_service.dart';

class ManageParkingScreen extends StatefulWidget {
  final ParkingSpace parkingSpace;
  
  const ManageParkingScreen({super.key, required this.parkingSpace});

  @override
  _ManageParkingScreenState createState() => _ManageParkingScreenState();
}

class _ManageParkingScreenState extends State<ManageParkingScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<Vehicle> _userVehicles = [];
  Vehicle? _selectedVehicle;
  int _selectedDurationHours = 2; // Default 2 hours
  bool _enableNotifications = true;
  
  final NotificationService _notificationService = NotificationService();

  // Duration options in hours
  final List<int> _durationOptions = [1, 2, 3, 4, 6, 8, 12, 24];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserVehicles();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      print('⚠️ Failed to initialize notifications: $e');
    }
  }
  
  void _loadUserVehicles() {
    final currentUser = UserService().currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Ingen användare inloggad';
        _isLoading = false;
      });
      return;
    }
    
    context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
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
      // Check if the vehicle is already parked
      context.read<ParkingBloc>().add(LoadActiveParkings());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final parkingState = context.read<ParkingBloc>().state;
      if (parkingState is ActiveParkingsLoaded) {
        final isAlreadyParked = parkingState.activeParkings.any((p) => 
          p.fordon == _selectedVehicle!.id.toString()
        );
        
        if (isAlreadyParked) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_selectedVehicle!.type} (${_selectedVehicle!.registrationNumber}) är redan parkerad. Avsluta den parkeringen först.'
              ),
            ),
          );
          return;
        }
      }
      
      // Format current time as HH:MM
      final now = DateTime.now();
      final startTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      // Schedule notification if enabled
      String? notificationId;
      if (_enableNotifications) {
        try {
          // Request permissions and schedule notification
          final hasPermission = await _notificationService.requestPermissions();
          if (hasPermission) {
            notificationId = await _notificationService.scheduleActiveParkingReminder(
              vehicle: _selectedVehicle!,
              parkingSpace: widget.parkingSpace,
              estimatedDurationHours: _selectedDurationHours,
              reminderMinutesBefore: 15, // Remind 15 minutes before expiry
            );
            
            if (notificationId != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📱 Påminnelse schemalagd 15 minuter före utgång')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⚠️ Notifikationer kräver behörighet för påminnelser')),
            );
          }
        } catch (e) {
          print('❌ Failed to schedule notification: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Kunde inte schemalägga påminnelse: $e')),
          );
        }
      }
      
      // Start parking using ParkingBloc
      context.read<ParkingBloc>().add(StartParking(
        vehicleId: _selectedVehicle!.id.toString(),
        parkingPlaceId: widget.parkingSpace.id.toString(),
        startTime: startTime,
      ));
      
      // Show success message
      final durationText = _selectedDurationHours == 1 ? '1 timme' : '$_selectedDurationHours timmar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parkering startad för ${_selectedVehicle!.type} ($durationText)')),
      );
      
      // Navigate back to main screen
      Navigator.pop(context, true);
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

  void _showNotificationTest() async {
    try {
      await _notificationService.showTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔔 Test-notifikation skickad!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Kunde inte skicka test-notifikation: $e')),
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
        actions: [
          // Debug button for testing notifications
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _showNotificationTest,
            tooltip: 'Testa notifikationer',
          ),
        ],
      ),
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleLoaded) {
            setState(() {
              _userVehicles = state.vehicles;
              if (_userVehicles.isNotEmpty) {
                _selectedVehicle = _userVehicles.first;
              }
              _isLoading = false;
            });
          } else if (state is VehicleLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is VehicleError) {
            setState(() {
              _errorMessage = state.message;
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (state is VehicleLoading || _isLoading) {
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
                    onPressed: _loadUserVehicles,
                    child: const Text('Försök igen'),
                  ),
                ],
              ),
            );
          }
          
          if (_userVehicles.isEmpty) {
            return Center(
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
                      Navigator.pop(context);
                    },
                    child: const Text('Lägg till fordon'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
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
                
                // Duration selection
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parkeringstid',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _durationOptions.map((hours) {
                            final isSelected = hours == _selectedDurationHours;
                            final cost = hours * widget.parkingSpace.pricePerHour;
                            
                            return ChoiceChip(
                              label: Text('$hours h\n$cost kr'),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedDurationHours = hours;
                                  });
                                }
                              },
                              selectedColor: const Color(0xFF0078D7).withOpacity(0.2),
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF0078D7) : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total kostnad: ${_selectedDurationHours * widget.parkingSpace.pricePerHour} kr',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0078D7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notification settings
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Påminnelser',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Aktivera påminnelser'),
                          subtitle: const Text('Få en notifikation 15 minuter före parkeringstiden går ut'),
                          value: _enableNotifications,
                          onChanged: (value) {
                            setState(() {
                              _enableNotifications = value;
                            });
                          },
                          activeColor: const Color(0xFF0078D7),
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
                ...List.generate(_userVehicles.length, (index) {
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
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleLoading || _isLoading || _userVehicles.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return BlocListener<ParkingBloc, ParkingState>(
            listener: (context, state) {
              if (state is ParkingOperationSuccess) {
                Navigator.pop(context, true);
              } else if (state is ParkingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SafeArea(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(
                        'Starta parkering (${_selectedDurationHours}h)',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}