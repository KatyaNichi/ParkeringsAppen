import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _apiService = ApiService(baseUrl: 'http://192.168.88.39:8080');
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';

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

    // Continue with normal initialization
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current user info
      final currentUser = UserService().currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Ingen användare inloggad';
          _isLoading = false;
        });
        return;
      }

      final vehiclesData = await _apiService.getList(
        '/api/vehicles/owner/${currentUser.id}',
      );
      setState(() {
        _vehicles =
            vehiclesData
                .map<Vehicle>((data) => Vehicle.fromJson(data))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda fordon: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addVehicle() async {
    // Show add vehicle dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

                  // Show loading indicator
                  setState(() => _isLoading = true);

                  // Inside the onPressed callback of the dialog's "Lägg till" button:
                  try {
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

                    // Send request to server with current user's ID
                    await _apiService.createItem('/api/vehicles', {
                      'type': _typeController.text,
                      'registrationNumber': regNum,
                      'ownerId': currentUser.id,
                    });

                    // Clear form fields
                    _typeController.clear();
                    _regNumberController.clear();

                    // Reload vehicles to refresh the list
                    await _loadVehicles(); // This will update the state and clear the loading spinner

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fordon har lagts till')),
                    );
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = 'Kunde inte lägga till fordon: $e';
                    });
                  }
                },
                child: const Text('Lägg till'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteVehicle(int id) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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

    setState(() => _isLoading = true);

    try {
      await _apiService.deleteItem('/api/vehicles', id);
      await _loadVehicles();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fordon har tagits bort')));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kunde inte ta bort fordon: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
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
                      onPressed: _loadVehicles,
                      child: const Text('Försök igen'),
                    ),
                  ],
                ),
              )
              : _vehicles.isEmpty
              ? Center(
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
              )
              : RefreshIndicator(
                onRefresh: _loadVehicles,
                child: ListView.builder(
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVehicle(vehicle.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton:
          !_isLoading && _errorMessage.isEmpty
              ? FloatingActionButton(
                onPressed: _addVehicle,
                backgroundColor: const Color(0xFF0078D7),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }
}
