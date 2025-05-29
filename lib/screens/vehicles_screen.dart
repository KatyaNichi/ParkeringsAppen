// lib/screens/vehicles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  // Controllers for the add vehicle form
  final _typeController = TextEditingController();
  final _regNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
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
    
    // Load vehicles for the current user
    _loadVehicles(currentUser.id);
  }
  
  void _loadVehicles(String ownerId) { // Changed int to String
  // Dispatch the event to load vehicles by owner
  context.read<VehicleBloc>().add(LoadVehiclesByOwner(ownerId));
}

  Future<void> _addVehicle() async {
    // Show add vehicle dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lägg till fordon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Fordonstyp',
                  hintText: 'T.ex. Bil, Lastbil, Buss',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _regNumberController,
                decoration: const InputDecoration(
                  labelText: 'Registreringsnummer',
                  hintText: 'Numeriskt registreringsnummer',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate input
              if (_typeController.text.isEmpty ||
                  _regNumberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alla fält måste fyllas i')),
                );
                return;
              }

              final regNum = int.tryParse(_regNumberController.text);
              if (regNum == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registreringsnumret måste vara numeriskt',
                    ),
                  ),
                );
                return;
              }

              // Close dialog
              Navigator.of(context).pop();

              // Get current user
              final currentUser = UserService().currentUser;
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingen användare inloggad'),
                  ),
                );
                return;
              }

              // Dispatch the event to add a vehicle
           context.read<VehicleBloc>().add(AddVehicle(
  type: _typeController.text,
  registrationNumber: regNum,
  ownerId: currentUser.id, // This is now String, so it works
));
              
              // Clear form fields
              _typeController.clear();
              _regNumberController.clear();
            },
            child: const Text('Lägg till'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(String id) async { // Changed int to String
  // Show confirmation dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ta bort fordon'),
      content: const Text(
        'Är du säker på att du vill ta bort detta fordon?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Avbryt'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Ta bort',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  // Dispatch the event to delete a vehicle
  context.read<VehicleBloc>().add(DeleteVehicle(id));
}

// Inside the build method of your VehiclesScreen
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        // Show loading indicator when loading
        if (state is VehicleLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Laddar fordon...', style: TextStyle(fontSize: 16))
              ],
            ),
          );
        }
        
        // Show error message when an error occurs
        if (state is VehicleError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final currentUser = UserService().currentUser;
                    if (currentUser != null) {
                      context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
                    }
                  },
                  child: const Text('Försök igen'),
                ),
              ],
            ),
          );
        }
        
        // Show vehicles list when loaded
        if (state is VehicleLoaded) {
          final vehicles = state.vehicles;
          
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Du har inga registrerade fordon',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Lägg till fordon'),
                    onPressed: _addVehicle,
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              final currentUser = UserService().currentUser;
              if (currentUser != null) {
                context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
              }
            },
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                
                // Show pending changes indicator if needed
                final isPending = state.pendingChanges;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Add a color overlay if changes are pending
                  color: isPending ? Colors.amber.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: Icon(
                      vehicle.type.toLowerCase() == 'bil'
                          ? Icons.directions_car
                          : vehicle.type.toLowerCase() == 'buss'
                          ? Icons.directions_bus
                          : vehicle.type.toLowerCase() == 'lastbil'
                          ? Icons.local_shipping
                          : Icons.directions_car,
                      size: 36,
                      color: const Color(0xFF0078D7),
                    ),
                    title: Text(
                      '${vehicle.type} (${vehicle.registrationNumber})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Ägare: ${vehicle.owner.name}'),
                    // Show syncing icon if pending changes
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPending)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.sync, color: Colors.amber),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVehicle(vehicle.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        
        // Default state - should not happen in practice
        return Center(
          child: ElevatedButton(
            onPressed: () {
              final currentUser = UserService().currentUser;
              if (currentUser != null) {
                context.read<VehicleBloc>().add(LoadVehiclesByOwner(currentUser.id));
              }
            },
            child: const Text('Ladda fordon'),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addVehicle,
      backgroundColor: const Color(0xFF0078D7),
      child: const Icon(Icons.add),
    ),
  );

  }

  @override
  void dispose() {
    _typeController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }
}